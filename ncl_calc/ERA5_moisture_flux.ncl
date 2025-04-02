; moisture flux variables

outpath = "/Volumes/LaCie-12big-T3/Data/ERA5/data/ERA5-Atm/monthly_energy/"
print("    outpath: " + outpath)

begin 

; input files
ufile    = "/Volumes/LaCie-12big-T3/Data/ERA5/data/ERA5-Atm/monthly_4D/ERA5_u_monthly_197901-202012.nc"
vfile    = "/Volumes/LaCie-12big-T3/Data/ERA5/data/ERA5-Atm/monthly_4D/ERA5_v_monthly_197901-202012.nc"
qfile    = "/Volumes/LaCie-12big-T3/Data/ERA5/data/ERA5-Atm/monthly_4D/ERA5_q_monthly_197901-202012.nc"
psfile   = "/Volumes/LaCie-12big-T3/Data/ERA5/data/ERA5-Atm/monthly/ERA5_sp_monthly_197901-202012.nc"

print("     ufile: "+ufile)
print("     vfile: "+vfile)
print("     qfile: "+qfile)
print("    psfile: "+psfile)

; output files
uq_vintfile = "ERA5_uq_monthly_197901-202012.nc"       ; vertically integrated (vint) u-component of moisture flux (uq)
vq_vintfile = "ERA5_vq_monthly_197901-202012.nc"       ; vertically integrated (vint) u-component of moisture flux (uq)
uqvq_vmagfile = "ERA5_uqvq_vmag_monthly_197901-202012.nc"   ; vertically integrated magnitude (vmag) of moisture flux
uqvq_vdivfile = "ERA5_uqvq_divmonthly_197901-202012.nc"   ; vertically integrated moisture flux divergence
q_vintfile   = "ERA5_q_vint_monthly_197901-202012.nc"       ; vertically integrated moisture

print("       uqfile: "+uq_vintfile)
print("       vqfile: "+vq_vintfile)
print("uqvq_vmagfile: "+uqvq_vmagfile)
print("uqvq_vdivfile: "+uqvq_vdivfile)
print("   q_vintfile: "+q_vintfile)

U_in   = addfile(ufile, "r" )    ; [m s-1]
V_in  = addfile(vfile, "r" )     ; [m s-1]
Q_in  = addfile(qfile, "r" )     ; [kg kg-1]      
ps_in  = addfile(psfile, "r" )   ; [Pa]

lon   = U_in->longitude  
lat   = U_in->latitude  
lev   = U_in->level(0:36)
time  = U_in->time 
printVarSummary(lon)
printVarSummary(lat)
printVarSummary(lev)
printVarSummary(time)

U = U_in->u(:,0:36,:,:)
printVarSummary(U)
printMinMax(U, True)

V = V_in->v(:,0:36,:,:)
printVarSummary(V)
printMinMax(V, True)

Q = Q_in->q
printVarSummary(Q)
printMinMax(Q, True)

PS = ps_in->sp
printVarSummary(PS)
printMinMax(PS, True)

; make dummy data sets
vin_dimsizes = dimsizes(U)
three_d = new((/vin_dimsizes(0),vin_dimsizes(2),vin_dimsizes(3)/),float)
three_d!0 = "time"   
three_d!1 = "lat"
three_d!2 = "lon"
three_d&time  = time
three_d&lat  = lat
three_d&lon  = lon
three_d&lat@units="degrees_north"
three_d&lon@units="degrees_east" 
printVarSummary(three_d)

; make dummy data sets
vin_dimsizes = dimsizes(U)
four_d = new((/vin_dimsizes/),float)
four_d!0 = "time"   
four_d!1 = "lev" 
four_d!2 = "lat"
four_d!3 = "lon"
four_d&time  = time
four_d&lev   = lev     
four_d&lat  = lat
four_d&lon  = lon
four_d&lat@units="degrees_north"
four_d&lon@units="degrees_east" 
printVarSummary(four_d)

;---------------------------------------------------------------------------
; moisture flux at each level
uq = four_d
uq = U * Q
vq = four_d
vq = V * Q
printVarSummary(uq)
printVarSummary(vq)

;---------------------------------------------------------------------------
; calculate mass-weighted vertical integral of moisture flux

; get dp (weights = layer thicknesses)

; get layer thicknesses
plev_Pa = lev*100 
plev_Pa@units = "Pa"
plev_Pa!0     = "plev_Pa"
printVarSummary(plev_Pa)
printMinMax(plev_Pa, True)

ptop = 0
dp_Pa = dpres_plevel(plev_Pa, PS, ptop, 0) ; [Pa] => [kg m-1 s-2]
copy_VarCoords(Q, dp_Pa)
printVarSummary(dp_Pa)
printMinMax(dp_Pa, True)

g  = 9.81  ; the gravitational acceleration [m s-2]

; mass weighting: (dp//g) => [Pa]/[m s-1] => [Pa][m-1 s2] => [kg m-1 s-2][m-1 s2] => [kg m-2]
; UQ VQ:  [m s-1][kg kg-1][kg m-2] => [kg m-1 s-1]

; vertical integration
uq_vint           = three_d
uq_vint           = wgt_vertical_n(uq,dp_Pa,1,1) ; uq, dp, sum, level dimension = 1
delete(uq)
uq_vint           = uq_vint/g
uq_vint@long_name = "mass-weighted vertically integrated zonal moisture flux"
uq_vint@units     = "[kg m-1 s-1]"
uq_vint@comment   = "calculated using wgt_vertical_n(uq_vint,dp,1,1)"
printVarSummary(uq_vint)
printMinMax(uq_vint, True)

vq_vint = three_d
vq_vint           = wgt_vertical_n(vq,dp_Pa,1,1) ; vq, dp, sum, level dimension = 1
delete(vq)
vq_vint           = vq_vint/g
vq_vint@long_name = "mass-weighted vertically integrated meridional moisture flux"
vq_vint@units     = "[kg m-1 s-1]"
vq_vint@comment   = "calculated using wgt_vertical_n(vq_vint,dp,1,1)"
printVarSummary(vq_vint)
printMinMax(vq_vint, True)

; moisture transport (magnitude of uq_vint and vq_vint)
uqvq_vmag           = three_d  ; moisture transport
uqvq_vmag           = sqrt(uq_vint^2 + vq_vint^2)
uqvq_vmag@long_name = "mass-weighted vertically integrated moisture flux"
uqvq_vmag@units     = "[kg m-1 s-1]"
uqvq_vmag@comment   = "calculated as sqrt(uq_vint^2 + vq_vint^2)"
printVarSummary(uqvq_vmag)
printMinMax(uqvq_vmag, True)

; calculate the divergence with uq_vint and  vq_vint
uqvq_vdiv = three_d  ; divergence
uqvq_vdiv = uv2dvG_Wrap(uq_vint,vq_vint) 
uqvq_vdiv@long_name = "mass-weighted vertically integrated moisture flux divergence"
; uqvq_vdiv = uqvq_vdiv*86400 ; to mm d-1
uqvq_vdiv@units = "[kg m-2 s-1]" ; "[mm d-1]" ;  
uqvq_vdiv@comment   = "uv2dvG_Wrap(uq_vint,vq_vint)"
printVarSummary(uqvq_vdiv) 
printMinMax(uqvq_vdiv, True)

; vertically integrated water vapor (q_vint)
q_vint = three_d  ; vertically integrated water vapor
q_vint = prcwater_dp(Q(time|:,lat|:,lon|:,level|:), dp_Pa(time|:,lat|:,lon|:,level|:))
q_vint@long_name = "vertically integrated moisture"
q_vint@units = "[kg m-2]" ; "[mm]" ;  
q_vint@comment   = "calculated using prcwater_dp(Q, dp_Pa)"
printVarSummary(q_vint) 
printMinMax(q_vint, True)

;---------------------------------------------------------------------------
; output

; global attributes -- all files
fileAtt                 = True
fileAtt@info            = "Calculation with the NCAR Command Language (ver.6.6.2), http://www.ncl.ucar.edu"
fileAtt@history         = "P.J. Bartlein, " + systemfunc("date");
fileAtt@experiment_id   = "ERA5";
fileAtt@model_id        = "ERA5";
fileAtt@project         = "ERA5";
fileAtt@title           = "ERA5"

; names, types, dimensions -- all files
dimUnlim = (/False,False,False/)
print("dimUnlim: "+dimUnlim)

; uqvq_vint_vint

; create output file
system("/bin/rm -f " + outpath+uq_vintfile)    ; remove if exists
fout = addfile(outpath+uq_vintfile, "c")
setfileoption(fout, "DefineMode", True)
fileattdef(fout, fileAtt)

; netCDF file definitions
uq_vint_dimSizes = dimsizes(uq_vint)
uq_vint_dimNames = getVarDimNames(uq_vint)
filedimdef(fout, uq_vint_dimNames, uq_vint_dimSizes, dimUnlim) 
filevardef(fout, "time", typeof(time), getvardims(time))
filevardef(fout, "lat", typeof(lat), getvardims(lat))
filevardef(fout, "lon", typeof(lon), getvardims(lon))
filevardef(fout, "uq_vint", typeof(uq_vint), getvardims(uq_vint))

; variable attributes
filevarattdef(fout,"time",time)
filevarattdef(fout,"lat",lat)
filevarattdef(fout,"lon",lon)
filevarattdef(fout,"uq_vint",uq_vint)

; output variables
fout->lon = lon
fout->lat = lat
fout->time = time
fout->uq_vint = uq_vint

; vq_vint

; create output file
system("/bin/rm -f " + outpath+vq_vintfile)    ; remove if exists
fout = addfile(outpath+vq_vintfile, "c")
setfileoption(fout, "DefineMode", True)
fileattdef(fout, fileAtt)

; netCDF file definitions
vq_vint_dimSizes = dimsizes(vq_vint)
vq_vint_dimNames = getVarDimNames(vq_vint)
filedimdef(fout, vq_vint_dimNames, vq_vint_dimSizes, dimUnlim) 
filevardef(fout, "time", typeof(time), getvardims(time))
filevardef(fout, "lat", typeof(lat), getvardims(lat))
filevardef(fout, "lon", typeof(lon), getvardims(lon))
filevardef(fout, "vq_vint", typeof(vq_vint), getvardims(vq_vint))

; variable attributes
filevarattdef(fout,"time",time)
filevarattdef(fout,"lat",lat)
filevarattdef(fout,"lon",lon)
filevarattdef(fout,"vq_vint",vq_vint)

; output variables
fout->lon = lon
fout->lat = lat
fout->time = time
fout->vq_vint = vq_vint

; uqvq_vmag

; create output file
system("/bin/rm -f " + outpath+uqvq_vmagfile)    ; remove if exists
fout = addfile(outpath+uqvq_vmagfile, "c")
setfileoption(fout, "DefineMode", True)
fileattdef(fout, fileAtt)

; netCDF file definitions
uqvq_vmag_dimSizes = dimsizes(uqvq_vmag)
uqvq_vmag_dimNames = getVarDimNames(uqvq_vmag)
filedimdef(fout, uqvq_vmag_dimNames, uqvq_vmag_dimSizes, dimUnlim) 
filevardef(fout, "time", typeof(time), getvardims(time))
filevardef(fout, "lat", typeof(lat), getvardims(lat))
filevardef(fout, "lon", typeof(lon), getvardims(lon))
filevardef(fout, "uqvq_vmag", typeof(uqvq_vmag), getvardims(uqvq_vmag))

; variable attributes
filevarattdef(fout,"time",time)
filevarattdef(fout,"lat",lat)
filevarattdef(fout,"lon",lon)
filevarattdef(fout,"uqvq_vmag",uqvq_vmag)

; output variables
fout->lon = lon
fout->lat = lat
fout->time = time
fout->uqvq_vmag = uqvq_vmag

; uqvq_vdiv

; create output file
system("/bin/rm -f " + outpath+uqvq_vdivfile)    ; remove if exists
fout = addfile(outpath+uqvq_vdivfile, "c")
setfileoption(fout, "DefineMode", True)
fileattdef(fout, fileAtt)

; netCDF file definitions
uqvq_vdiv_dimSizes = dimsizes(uqvq_vdiv)
uqvq_vdiv_dimNames = getVarDimNames(uqvq_vdiv)
filedimdef(fout, uqvq_vdiv_dimNames, uqvq_vdiv_dimSizes, dimUnlim) 
filevardef(fout, "time", typeof(time), getvardims(time))
filevardef(fout, "lat", typeof(lat), getvardims(lat))
filevardef(fout, "lon", typeof(lon), getvardims(lon))
filevardef(fout, "uqvq_vdiv", typeof(uqvq_vdiv), getvardims(uqvq_vdiv))

; variable attributes
filevarattdef(fout,"time",time)
filevarattdef(fout,"lat",lat)
filevarattdef(fout,"lon",lon)
filevarattdef(fout,"uqvq_vdiv",uqvq_vdiv)

; output variables
fout->lon = lon
fout->lat = lat
fout->time = time
fout->uqvq_vdiv = uqvq_vdiv

; q_vint

; create output file
system("/bin/rm -f " + outpath+q_vintfile)    ; remove if exists
fout = addfile(outpath+q_vintfile, "c")
setfileoption(fout, "DefineMode", True)
fileattdef(fout, fileAtt)

; netCDF file definitions
q_vint_dimSizes = dimsizes(q_vint)
q_vint_dimNames = getVarDimNames(q_vint)
filedimdef(fout, q_vint_dimNames, q_vint_dimSizes, dimUnlim) 
filevardef(fout, "time", typeof(time), getvardims(time))
filevardef(fout, "lat", typeof(lat), getvardims(lat))
filevardef(fout, "lon", typeof(lon), getvardims(lon))
filevardef(fout, "q_vint", typeof(q_vint), getvardims(q_vint))

; variable attributes
filevarattdef(fout,"time",time)
filevarattdef(fout,"lat",lat)
filevarattdef(fout,"lon",lon)
filevarattdef(fout,"q_vint",q_vint)

; output variables
fout->lon = lon
fout->lat = lat
fout->time = time
fout->q_vint = q_vint

end

exit()

