; static energy

outpath = "/mnt/e/Data/ERA5/ERA5-Atm/derived/ltm_monthly/"
print("    outpath: " + outpath)

begin 

; input files 
tfile    = "/mnt/e/Data/ERA5/ERA5-Atm/derived/ltm_monthly_4D/ERA5_t_monthly_199101-202012_ltm.nc"
qfile    = "/mnt/e/Data/ERA5/ERA5-Atm/derived/ltm_monthly_4D/ERA5_q_monthly_199101-202012_ltm.nc"
zfile    = "/mnt/e/Data/ERA5/ERA5-Atm/derived/ltm_monthly_4D/ERA5_z_monthly_199101-202012_ltm.nc"
phisfile   = "/mnt/e/Data/ERA5/ERA5-Atm/source/monthly/ERA5_geopotential.nc"
psfile   = "/mnt/e/Data/ERA5/ERA5-Atm/derived/ltm_monthly/ERA5_sp_monthly_199101-202012_ltm.nc"

print("     tfile: "+tfile)
print("     qfile: "+qfile)
print("     zfile: "+zfile)
print("  phisfile: "+phisfile)
print("    psfile: "+psfile)

; output files
mse_file = "ERA5_vint_mse_monthly_197901-202012_ltm.nc"      
dse_file = "ERA5_vint_dse_monthly_197901-202012_ltm.nc"       
lse_file = "ERA5_vint_lse_monthly_197901-202012_ltm.nc"   

print("       mse_file: "+mse_file)
print("       dse_file: "+dse_file)
print("       lse_file: "+lse_file)

T_in   = addfile(tfile, "r" )    ; [K]
Q_in   = addfile(qfile, "r" )     ; [kg kg-1]
ZG_in  = addfile(zfile, "r" )     ; [m2 s-2]      
phis_in  = addfile(phisfile, "r" )   ; [m2 s-1]
ps_in  = addfile(psfile, "r" )   ; [Pa]

longitude = T_in->longitude  
latitude  = T_in->latitude  
lev   = T_in->level(0:36)
time  = T_in->time 
printVarSummary(longitude)
printVarSummary(latitude)
printVarSummary(lev)
printVarSummary(time)


ZG = short2flt(ZG_in->z)
printVarSummary(ZG)
printMinMax(ZG, True)

PHIS = short2flt(phis_in->z)
printVarSummary(PHIS)
printMinMax(PHIS, True)

phis = conform(ZG, PHIS, (/0,2,3/))
printVarSummary(phis)
phis = phis / 9.8
Z = ZG-phis
copy_VarCoords(ZG,Z)
printVarSummary(Z)
delete(ZG)

T = short2flt(T_in->t)
printVarSummary(T)
printMinMax(T, True)

Q = short2flt(Q_in->q)
printVarSummary(Q)
printMinMax(Q, True)

PS = short2flt(ps_in->sp)
printVarSummary(PS)
printMinMax(PS, True)


SE = static_energy_atm(T, Q, Z, (/1,0/))
printVarSummary(SE)

MSE = SE[0]
printVarSummary(MSE)
printMinMax(MSE, True)

DSE = SE[1]
printVarSummary(DSE)
printMinMax(DSE, True)

LSE = SE[2]
printVarSummary(LSE)
printMinMax(LSE, True)

; make dummy data sets
vin_dimsizes = dimsizes(T)
three_d = new((/vin_dimsizes(0),vin_dimsizes(2),vin_dimsizes(3)/),float)
three_d!0 = "time"   
three_d!1 = "latitude"
three_d!2 = "longitude"
three_d&time  = time
three_d&latitude  = latitude
three_d&longitude  = longitude
three_d&latitude@units="degrees_north"
three_d&longitude@units="degrees_east" 
printVarSummary(three_d)

;---------------------------------------------------------------------------
; calculate mass-weighted vertical integrals

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

; MSE
mse_vint           = three_d
mse_vint           = wgt_vertical_n(MSE,dp_Pa,0,1) ; mse, dp, average, level dimension = 1
; delete(MSE)
mse_vint           = mse_vint/g
mse_vint@long_name = "mass-weighted vertically integrated moist static energy"
mse_vint@units     = "[J kg-1]"
mse_vint@comment   = "calculated using wgt_vertical_n(mse_vint,dp,1,1)"
printVarSummary(mse_vint)
printMinMax(mse_vint, True)

; DSE
dse_vint           = three_d
dse_vint           = wgt_vertical_n(DSE,dp_Pa,0,1) ; dse, dp, sum, level dimension = 1
; delete(DSE)
dse_vint           = dse_vint/g
dse_vint@long_name = "mass-weighted vertically integrated dry static energy"
dse_vint@units     = "[J kg-1]"
dse_vint@comment   = "calculated using wgt_vertical_n(dse_vint,dp,1,1)"
printVarSummary(dse_vint)
printMinMax(dse_vint, True)

; LSE
lse_vint           = three_d
lse_vint           = wgt_vertical_n(LSE,dp_Pa,0,1) ; lse, dp, sum, level dimension = 1
; delete(LSE)
lse_vint           = lse_vint/g
lse_vint@long_name = "mass-weighted vertically integrated latent static energy"
lse_vint@units     = "[J kg-1]"
lse_vint@comment   = "calculated using wgt_vertical_n(lse_vint,dp,1,1)"
printVarSummary(lse_vint)
printMinMax(lse_vint, True)

;---------------------------------------------------------------------------
; output

; global attributes -- all files
fileAtt                 = True
fileAtt@info            = "Calculation with the NCAR Command Language (ver.6.6.2), http://www.ncl.ucar.edu"
fileAtt@history         = "P.J. Bartlein, " + systemfunc("date");
fileAtt@experiment_id   = "ERA5";
fileAtt@model_id        = "static_energy_atm()";
fileAtt@project         = "ERA5";
fileAtt@title           = "ERA5"

; names, types, dimensions -- all files
dimUnlim = (/False,False,False/)
print("dimUnlim: "+dimUnlim)

; mse

; create output file
system("/bin/rm -f " + outpath+mse_file)    ; remove if exists
fout = addfile(outpath+mse_file, "c")
setfileoption(fout, "DefineMode", True)
fileattdef(fout, fileAtt)

; netCDF file definitions
mse_vint_dimSizes = dimsizes(mse_vint)
mse_vint_dimNames = getVarDimNames(mse_vint)
filedimdef(fout, mse_vint_dimNames, mse_vint_dimSizes, dimUnlim) 
filevardef(fout, "time", typeof(time), getvardims(time))
filevardef(fout, "latitude", typeof(latitude), getvardims(latitude))
filevardef(fout, "longitude", typeof(longitude), getvardims(longitude))
filevardef(fout, "mse_vint", typeof(mse_vint), getvardims(mse_vint))

; variable attributes
filevarattdef(fout,"time",time)
filevarattdef(fout,"latitude",latitude)
filevarattdef(fout,"longitude",longitude)
filevarattdef(fout,"mse_vint",mse_vint)

; output variables
fout->longitude = longitude
fout->latitude = latitude
fout->time = time
fout->mse_vint = mse_vint

; dse

; create output file
system("/bin/rm -f " + outpath+dse_file)    ; remove if exists
fout = addfile(outpath+dse_file, "c")
setfileoption(fout, "DefineMode", True)
fileattdef(fout, fileAtt)

; netCDF file definitions
dse_vint_dimSizes = dimsizes(dse_vint)
dse_vint_dimNames = getVarDimNames(dse_vint)
filedimdef(fout, dse_vint_dimNames, dse_vint_dimSizes, dimUnlim) 
filevardef(fout, "time", typeof(time), getvardims(time))
filevardef(fout, "latitude", typeof(latitude), getvardims(latitude))
filevardef(fout, "longitude", typeof(longitude), getvardims(longitude))
filevardef(fout, "dse_vint", typeof(dse_vint), getvardims(dse_vint))

; variable attributes
filevarattdef(fout,"time",time)
filevarattdef(fout,"latitude",latitude)
filevarattdef(fout,"longitude",longitude)
filevarattdef(fout,"dse_vint",dse_vint)

; output variables
fout->longitude = longitude
fout->latitude = latitude
fout->time = time
fout->dse_vint = dse_vint

; lse

; create output file
system("/bin/rm -f " + outpath+lse_file)    ; remove if exists
fout = addfile(outpath+lse_file, "c")
setfileoption(fout, "DefineMode", True)
fileattdef(fout, fileAtt)

; netCDF file definitions
lse_vint_dimSizes = dimsizes(lse_vint)
lse_vint_dimNames = getVarDimNames(lse_vint)
filedimdef(fout, lse_vint_dimNames, lse_vint_dimSizes, dimUnlim) 
filevardef(fout, "time", typeof(time), getvardims(time))
filevardef(fout, "latitude", typeof(latitude), getvardims(latitude))
filevardef(fout, "longitude", typeof(longitude), getvardims(longitude))
filevardef(fout, "lse_vint", typeof(lse_vint), getvardims(lse_vint))

; variable attributes
filevarattdef(fout,"time",time)
filevarattdef(fout,"latitude",latitude)
filevarattdef(fout,"longitude",longitude)
filevarattdef(fout,"lse_vint",lse_vint)

; output variables
fout->longitude = longitude
fout->latitude = latitude
fout->time = time
fout->lse_vint = lse_vint

nt  = 0      
LAT = 0
LON = 300
print(sprintf("%8.1f",lev(:))+"  " \
    +sprintf("%8.1f",  T(nt,:,{LAT},{LON}))+"  " \
    +sprintf("%8.6f",  Q(nt,:,{LAT},{LON}))+"  " \
    +sprintf("%8.1f",  Z(nt,:,{LAT},{LON}))+"  " \
    +sprintf("%8.1f",MSE(nt,:,{LAT},{LON}))+"  " \
    +sprintf("%8.1f",DSE(nt,:,{LAT},{LON}))+"  " \
    +sprintf("%8.1f",LSE(nt,:,{LAT},{LON})) )

end

exit()

