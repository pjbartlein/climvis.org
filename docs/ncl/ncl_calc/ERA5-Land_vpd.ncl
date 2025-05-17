; vapor-pressure deficit
; pack variable when finished 

begin 

    inpath = "/Users/bartlein/Dropbox/WorkCurrent/ERA5/data/ERA5-Land/monthly/"
    outpath = inpath
    print("    inpath: "+inpath)
    print("   outpath: "+outpath)

    ; input files
    rhfile   = inpath + "ERA5-Land_rh_monthly_195001-202112.nc"
    tasfile  = inpath + "ERA5-Land_t2m_monthly_195001-202112.nc"
    print("    rhfile: "+rhfile)
    print("   tasfile: "+tasfile)

    ; output files
    outfile = inpath + "ERA5-Land_vpd_monthly_195001-202112_flt.nc"
    print("   outfile: "+outfile)

    rh_in   = addfile(rhfile, "r" )

    longitude   = rh_in->longitude  
    latitude   = rh_in->latitude  
    time  = rh_in->time 
    printVarSummary(longitude)
    printVarSummary(latitude)
    printVarSummary(time)

    rh = short2flt(rh_in->rh)
    printVarSummary(rh)
    printMinMax(rh, True)

    tas_in  = addfile(tasfile, "r" )

    tas = short2flt(tas_in->t2m)
    printVarSummary(tas)
    printMinMax(tas, True)

    esat = satvpr_water_bolton(tas, (/1,1/)) ; K 
    ea = vapor_pres_rh(rh / 100., esat) ; %
    vpd = (esat - ea) /100.0 ; hPa

    copy_VarAtts(tas, vpd)         ; copy attributes
    printVarSummary(vpd)
    printMinMax(vpd, True)

    ; define output variable
    vout_dimSizes = dimsizes(tas)
    vout_dimNames = getVarDimNames(tas)
    vout = new((vout_dimSizes),typeof(tas),tas@_FillValue)
    vout!0="time"
    vout!1="latitude"
    vout!2="longitude"
    vout_vpd=(/vpd/)
    vout_vpd@comment="calculated using satvpr_water_bolton() and vapor_pres_rh()"
    vout_vpd@units="hPa"
    vout_vpd@long_name="vapor-pressure deficit"
    printVarSummary(vout_vpd)
    printMinMax(vout_vpd, True)

    ; create output file
    system("/bin/rm -f " + outfile)    ; remove if exists
    fout = addfile(outfile, "c")
    print("outfile: "+outfile)

    ; global attributes
    fileAtt                 = True
    fileAtt@info            = "Calculation with the NCAR Command Language (ver.6.6.2), http://www.ncl.ucar.edu"
    fileAtt@history         = "P.J. Bartlein, " + systemfunc("date");
    fileAtt@experiment_id   = "ERA5";
    fileAtt@model_id        = "ERAt-Atm";
    fileAtt@project         = "ERAt-Atm";
    fileAtt@title           = "ERAt-Atm"
    setfileoption(fout, "DefineMode", True)
    fileattdef(fout, fileAtt)

    ; names, types, dimensions
    dimUnlim = (/False,False,False/)

    print("vout_dimNames: "+vout_dimNames)
    print("vout_dimSizes: "+vout_dimSizes)
    print("dimUnlim: "+dimUnlim)

    filedimdef(fout,vout_dimNames,vout_dimSizes,dimUnlim) 
    filevardef(fout, "time", typeof(time), getvardims(time))
    filevardef(fout, "latitude", typeof(latitude), getvardims(latitude))
    filevardef(fout, "longitude", typeof(longitude), getvardims(longitude))
    filevardef(fout, "vpd", typeof(vout), getvardims(vout))
    setfileoption(fout,"DefineMode",True)

    ; variable attributes
    filevarattdef(fout,"time",time)
    filevarattdef(fout,"latitude",latitude)
    filevarattdef(fout,"longitude",longitude)
    filevarattdef(fout,"vpd",vout_vpd)

    ; output variables
    fout->longitude = longitude
    fout->latitude = latitude
    fout->time = time
    fout->vpd= vout_vpd


end

exit()

