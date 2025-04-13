; relative humidity
; pack variable when finished 

begin 

    inpath = "/Users/bartlein/Dropbox/WorkCurrent/ERA5/Data/ERA5-Atm/monthly/"
    outpath = inpath
    print("    inpath: "+inpath)
    print("   outpath: "+outpath)

    ; input files
    dewptfile   = inpath + "ERA5_d2m_monthly_197901-202012.nc"
    tasfile  = inpath + "ERA5_t2m_monthly_197901-202012.nc"
    print(" dewptfile: "+dewptfile)
    print("   tasfile: "+tasfile)

    ; output files
    outfile = inpath + "ERA5_rh_monthly_197901-202012_flt.nc"
    print("   outfile: "+outfile)

    dewpt_in   = addfile(dewptfile, "r" )

    longitude   = dewpt_in->longitude  
    latitude   = dewpt_in->latitude  
    time  = dewpt_in->time 
    printVarSummary(longitude)
    printVarSummary(latitude)
    printVarSummary(time)

    dewpt = short2flt(dewpt_in->d2m)
    printVarSummary(dewpt)
    printMinMax(dewpt, True)

    tas_in  = addfile(tasfile, "r" )

    tas = short2flt(tas_in->t2m)
    printVarSummary(tas)
    printMinMax(tas, True)

    rh = relhum_ttd(tas, dewpt, 0)
   
    rh = rm_single_dims(rh)

    copy_VarAtts(tas, rh)         ; copy attributes
    printVarSummary(rh)
    printMinMax(rh, True)

    ; define output variable
    vout_dimSizes = dimsizes(tas)
    vout_dimNames = getVarDimNames(tas)
    vout = new((vout_dimSizes),typeof(tas),tas@_FillValue)
    vout!0="time"
    vout!1="latitude"
    vout!2="longitude"
    vout_rh=(/rh/)
    vout_rh@comment="calculated using relhum_ttd()"
    vout_rh@units="%"
    vout_rh@long_name="relative humidity (surface)"
    printVarSummary(vout_rh)
    printMinMax(vout_rh, True)

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
    filevardef(fout, "rh", typeof(vout), getvardims(vout))
    setfileoption(fout,"DefineMode",True)

    ; variable attributes
    filevarattdef(fout,"time",time)
    filevarattdef(fout,"latitude",latitude)
    filevarattdef(fout,"longitude",longitude)
    filevarattdef(fout,"rh",vout_rh)

    ; output variables
    fout->longitude = longitude
    fout->latitude = latitude
    fout->time = time
    fout->rh= vout_rh


end

exit()

