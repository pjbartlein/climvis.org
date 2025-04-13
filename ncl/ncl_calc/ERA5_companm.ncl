; composite anomalies

; create anomalies using CDO and NCO, e.g. for t2m:
; cdo selyear,1991/2020 ERA5_t2m_monthly_197901-202012.nc ERA5_t2m_monthly_199101-202012.nc
; cdo ymonmean ERA5_t2m_monthly_199101-202012.nc ERA5_t2m_monthly_199101-202012_ltm.nc
; cdo -b F64 sub ERA5_t2m_monthly_197901-202012.nc ERA5_t2m_monthly_199101-202012_ltm.nc ERA5_t2m_monthly_197901-202012_anm1991-2020.nc
; ncpdq -O ERA5_t2m_monthly_197901-202012_anm1991-2020.nc ERA5_t2m_monthly_197901-202012_anm1991-2020.nc 

begin 
    
    ; files and paths
    anmpath = "/Users/bartlein/Dropbox/WorkCurrent/ERA5/data/ERA5-Atm/anm_monthly/"
    companmpath = "/Users/bartlein/Dropbox/WorkCurrent/ERA5/climvis-figs/data/test_comp_anm/"
    print("   anmpath: " + anmpath)
    print("   companm: " + companmpath)

    ; input anomaly file
    varname = "t2m"
    baseperiod = "1991-2020"
    begyr = 1979 ; beginning year in anomaly file, not base period
    anmfile   = anmpath + "ERA5_t2m_monthly_197901-202012_anm" + baseperiod + ".nc"
    print("   anmfile: " + anmfile)

    ; composite anomaly month list
    calist = "ca_en_djf" ; ca_ln_djf"
    calistfile = companmpath + calist + ".dat"

    ; no changes below here -----------------------------------------------------------------------

    ; output files
    companmfile = companmpath + "ERA5_" + varname + "_monthly_" + calist + ".nc"
    print("   companmfile: " + companmfile)

    ; read anomaly month list
    title = readAsciiHead(calistfile, 1)
    print(title)

    ; number of anomalies to composite
    ncomp = numAsciiRow(calistfile)
    print(ncomp)

    ; years and months
    ca = readAsciiTable(calistfile, 2, "integer", 1)
    do i = 0, ncomp - 1
        print (sprinti("%0.2i", i) + " " + sprinti("%0.4i", ca(i,0)) + " " + sprinti("%0.2i", ca(i,1)))
    end do

    ; read anomalies
    anm_in   = addfile(anmfile, "r" )

    longitude   = anm_in->longitude  
    latitude   = anm_in->latitude  
    time  = anm_in->time 
    printVarSummary(longitude)
    printVarSummary(latitude)
    printVarSummary(time)

    print(dimsizes(longitude))
    print(dimsizes(latitude))

    anm = short2flt(anm_in->$varname$)
    anm@name = varname
    printVarSummary(anm)
    printMinMax(anm, True)

    ; knock out some values to test handling of missing data
    anm(:, 301:500, 201:400) = anm@_FillValue

    ; make composite anomaly array and dataset
    companm = new((/dimsizes(latitude),dimsizes(longitude)/),float) 
    companm = 0.0

    ; composite anomalies
    do i = 0, ncomp - 1
        n = ((ca(i, 0) - begyr) * 12) + ca(i,1) 
        print (sprinti("%0.2i", i) + " " + sprinti("%0.4i", ca(i,0)) + " " + sprinti("%0.2i", ca(i,1)) + " " + sprinti("%0.4i", n)     )
        companm(:,:) = companm(:,:) + anm(n - 1,:,:)
    end do

    companm = companm / ncomp

    ; create output file
    system("/bin/rm -f " + companmfile)    ; remove if exists
    fout = addfile(companmfile, "c")
    print("companmfile: " + companmfile)

    ; dimension variables and attributes
    companm!0 = "latitude"
    companm!1 = "longitude"
    companm&latitude  = latitude
    companm&longitude  = longitude
    companm&latitude@units="degrees_north"
    companm&longitude@units="degrees_east" 

    ; composite anomaly variable and attributes
    companm@name = anm@name 
    companm@units = anm@units
    companm@long_name = anm@name + " composite anomaly " + title
    companm@_FillValue = 1e+20 
    companm@missing_value = 1e+20 
    companm@comment = "Composite anomalies " + title
    companm@baseperiod = "long-term mean base period: " + baseperiod
    printVarSummary(companm)

    ; global attributes
    fileAtt                 = True
    fileAtt@info            = "Calculation with the NCAR Command Language (ver. 6.6.2), http://www.ncl.ucar.edu"
    fileAtt@history         = "P.J. Bartlein, " + systemfunc("date");
    fileAtt@experiment_id   = "ERA5";
    fileAtt@model_id        = "ERAt-Atm";
    fileAtt@project         = "ERAt-Atm";
    fileAtt@title           = title

    ; enter define mode
    setfileoption(fout, "DefineMode", True)

    ; define diminsions
    dimUnlim = (/False,False/)
    filedimdef(fout, getvardimnames(companm), getvardimsizes(companm), dimUnlim) 

    ; define diminsion and output variables
    filevardef(fout, "latitude", typeof(latitude), getvardims(latitude))
    filevardef(fout, "longitude", typeof(longitude), getvardims(longitude))
    filevardef(fout, varname, typeof(companm), getvardims(companm))

    ; copy variable attributes
    filevarattdef(fout,"latitude",latitude)
    filevarattdef(fout,"longitude",longitude)
    filevarattdef(fout,varname,companm)

    ; copy global attributes
    fileattdef(fout, fileAtt)

    ; exit file definition mode
    setfileoption(fout,"DefineMode",False)

    ; put output variables
    fout->latitude = (/latitude/)
    fout->longitude = (/longitude/)
    fout->$varname$ = (/companm/)

 end

exit()

