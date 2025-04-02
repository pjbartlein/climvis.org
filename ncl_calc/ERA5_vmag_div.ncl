; moisture flux variables

begin 

var = "_ke"; "_tef" ; "_gpf" ; "lh"; "q"
uvar = "u"+var
vvar = "v"+var
outvar = "uv"+var

u_ncvar = "p67.162" ; "p75.162" ; "p73.162" ; "p69.162" ; "p71.162"
v_ncvar = "p68.162" ; "p76.162" ; "p74.162" ; "p70.162" ; "p72.162"

vint_units = "W m-1" ; "kg m-1 s-1"
div_units =  "W m-2" ; "kg m-2 s-1"

; input files
ufile    = "/mnt/e/Data/ERA5/ERA5-Atm/derived/ltm_monthly/ERA5_" + uvar + "_monthly_199101-202012_ltm.nc"
vfile    = "/mnt/e/Data/ERA5/ERA5-Atm/derived/ltm_monthly/ERA5_" + vvar + "_monthly_199101-202012_ltm.nc"
vintfile = "/mnt/e/Data/ERA5/ERA5-Atm/derived/ltm_monthly/ERA5_" + outvar + "_vint_monthly_199101-202012_ltm.nc"
divfile  = "/mnt/e/Data/ERA5/ERA5-Atm/derived/ltm_monthly/ERA5_" + outvar + "_div_vint_monthly_199101-202012_ltm.nc"

print("        u_file: "+ufile)
print("        v_file: "+vfile)
print("     vint_file: "+vintfile)
print(" vint_div_file: "+divfile)

U_in  = addfile(ufile, "r" )    ; 
V_in  = addfile(vfile, "r" )     ; 

longitude   = U_in->longitude  
latitude    = U_in->latitude  
time        = U_in->time 
printVarSummary(longitude)
printVarSummary(latitude)

u = short2flt(U_in->$u_ncvar$)
printVarSummary(u)
printMinMax(u, True)
varunits = u@units
print(varunits)

v = short2flt(V_in->$v_ncvar$)
printVarSummary(v)
printMinMax(v, True)

; make dummy data sets
vin_dimsizes = dimsizes(v)
three_d = new((/vin_dimsizes(0),vin_dimsizes(1),vin_dimsizes(2)/),float)
three_d!0 = "time"   
three_d!1 = "latitude"
three_d!2 = "longitude"
three_d&time  = time
three_d&latitude  = latitude
three_d&longitude  = longitude
three_d&latitude@units="degrees_north"
three_d&longitude@units="degrees_east" 
printVarSummary(three_d)

; magnitude of u and v
vint = three_d
vint = sqrt(u^2 + v^2)
vint@long_name = "vertically integrated " + outvar
vint@units     = vint_units
vint@comment   = "calculated as sqrt(" + uvar + "^2 * " + vvar + "^2)"
printVarSummary(vint)
printMinMax(vint, True)

; divergence of u and v
div = three_d
; div = uv2dvF(u, v) 
div = uv2dv_cfd(u, v, latitude, longitude, 3) 
div@long_name = "mass-weighted vertically integrated " + outvar
div@units = div_units
; div@comment   = "uv2dvF(" + uvar + ", " + vvar + ")"
div@comment   = "uv2dv_cfd(" + uvar + ", " + vvar + " latitude, longitude, 3 )"
printVarSummary(div) 
printMinMax(div, True)

;---------------------------------------------------------------------------
; output

; global attributes -- all files
fileAtt                 = True
fileAtt@info            = "Calculation with the NCAR Command Language (ver.6.6.2), http://www.ncl.ucar.edu"
fileAtt@history         = "P.J. Bartlein, " + systemfunc("date");
fileAtt@experiment_id   = "ERA5";
fileAtt@model_id        = "NCL 6.2";
fileAtt@project         = "ERA5";
fileAtt@title           = "ERA5"

; names, types, dimensions -- all files
dimUnlim = (/False,False,False/)
print("dimUnlim: "+dimUnlim)

; vint

; create output file
system("/bin/rm -f " + vintfile)    ; remove if exists
fout = addfile(vintfile, "c")
setfileoption(fout, "DefineMode", True)
fileattdef(fout, fileAtt)

; netCDF file definitions
vint_dimSizes = dimsizes(vint)
vint_dimNames = getVarDimNames(vint)
filedimdef(fout, vint_dimNames, vint_dimSizes, dimUnlim) 
filevardef(fout, "time", typeof(time), getvardims(time))
filevardef(fout, "latitude", typeof(latitude), getvardims(latitude))
filevardef(fout, "longitude", typeof(longitude), getvardims(longitude))
filevardef(fout, "vint", typeof(vint), getvardims(vint))

; variable attributes
filevarattdef(fout,"time",time)
filevarattdef(fout,"latitude",latitude)
filevarattdef(fout,"longitude",longitude)
filevarattdef(fout,"vint",vint)

; output variables
fout->longitude = longitude
fout->latitude = latitude
fout->time = time
fout->vint = vint

; div

; create output file
system("/bin/rm -f " + divfile)    ; remove if exists
fout = addfile(divfile, "c")
setfileoption(fout, "DefineMode", True)
fileattdef(fout, fileAtt)

; netCDF file definitions
div_dimSizes = dimsizes(div)
div_dimNames = getVarDimNames(div)
filedimdef(fout, div_dimNames, div_dimSizes, dimUnlim) 
filevardef(fout, "time", typeof(time), getvardims(time))
filevardef(fout, "latitude", typeof(latitude), getvardims(latitude))
filevardef(fout, "longitude", typeof(longitude), getvardims(longitude))
filevardef(fout, "div", typeof(div), getvardims(div))

; variable attributes
filevarattdef(fout,"time",time)
filevarattdef(fout,"latitude",latitude)
filevarattdef(fout,"longitude",longitude)
filevarattdef(fout,"div",div)

; output variables
fout->longitude = longitude
fout->latitude = latitude
fout->time = time
fout->div = div


end

exit()

