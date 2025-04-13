; area averages

; creates an area-weighted average time series for a set of points

; points are specified by sorting and editing ERA5-Atm_pts.csv, which has the format:
;  col,   row,     lon,     lat,    lsm,  grid_area
;    1,     1,    0.00,   90.00,  0.000,      0.421
;    1,     2,    0.00,   89.75,  0.000,      3.372
; ...

; remove the header line ("col,   row, ...") when saving, no blank lines at bottom

begin 
    
    ; files and paths
    inpath = "/Users/bartlein/Dropbox/WorkCurrent/ERA5/data/ERA5-Atm/anm_monthly/"
    areaavepath = "/Users/bartlein/Dropbox/WorkCurrent/ERA5/climvis-figs/data/test_area_ave/"
    print("        inpath: " + inpath)
    print("   areaavepath: " + areaavepath)

    ; input file
    varname = "t2m"
    begyr = 1979 ; beginning year in input file, not base period
    endyr = 2020 ; end year in input file, not base period
    infile   = inpath + "ERA5_t2m_monthly_197901-202012_anm1991-2020.nc"
    print("        infile: " + infile)

    ; area-average points list
    ptslist = "NA_midcont"
    ptslistfile = areaavepath + ptslist + ".csv"

    ; no changes below here -----------------------------------------------------------------------

    ; output files
    areaavefile = areaavepath + "ERA5_" + varname + "_monthly_area_ave_" + ptslist + ".csv"
    print("   areaavefile: " + areaavefile)

    ; number of points
    npts = numAsciiRow(ptslistfile) + 1
    print(npts)

    ; read the points file
    delim = ","
    lines = asciiread(ptslistfile, -1, "string")
    col = stringtoint(str_get_field(lines, 1, delim))
    row = stringtoint(str_get_field(lines, 2, delim))
    grid_area = stringtodouble(str_get_field(lines, 6, delim))
    printVarSummary(col)
    printMinMax(col, True)
    printVarSummary(row)
    printMinMax(row, True)
    printVarSummary(grid_area)

    ; do i = 0, npts - 1
    ;     print (sprinti("%0.3i", col(i)) + " " + sprinti("%0.3i", row(i)) + " " + sprintf("%7.3f", grid_area(i)) )
    ; end do

    ; read data
    data_in   = addfile(infile, "r" )

    longitude   = data_in->longitude  
    latitude   = data_in->latitude  
    time  = data_in->time 
    printVarSummary(longitude)
    printVarSummary(latitude)
    printVarSummary(time)

    print(dimsizes(longitude))
    print(dimsizes(latitude))

    data = short2flt(data_in->$varname$)
    data@name = varname
    printVarSummary(data)
    printMinMax(data, True)

    ; define area-average variables
    nout = (endyr - begyr + 1) * 12
    print(nout)
    year = new((/nout/), integer)
    month = new((/nout/), integer)
    yrmn = new((/nout/), float)
    aave = new((/nout/), double)
    areasum = new((/nout/), double)
    nyr = (endyr - begyr) + 1

    aave = 0.0
    areasum = 0.0

    ; loop over years, months
    i = 0
    do n = begyr, endyr
        do m = 1, 12
            year(i) = n
            month(i) = m
            yrmn(i) = year(i) + ((m - 1) / 12.0)

            ; loop over points
            do p = 0, npts - 1
                aave(i) = aave(i) + data(i, row(p) - 1, col(p) - 1) * grid_area(p)
                areasum(i) = areasum(i) + grid_area(p)
                ; print (sprinti("%0.3i", p) + " " + sprinti("%0.3i", row(p)) + " " + sprinti("%0.3i", col(p)) )
            end do
            aave(i) = aave(i) / areasum(i)
            ; print (sprinti("%0.3i", i) + " " + sprinti("%0.4i", year(i)) + " " + sprinti("%0.2i", month(i))  + " " \
            ;     + sprintf("%9.4f", yrmn(i)) + " " + sprintf("%10.2f", aave(i)) + sprintf("%14.4f", areasum(i)) )
            i = i + 1
        end do 
    end do
        
    ; write out a .csv file for plotting
    system("rm -rf " + areaavefile)
    header = (/"year,  month, yrmn, aave"/)
    hlist = [/header/]
    alist = [/year, month, yrmn, aave/]
    write_table(areaavefile, "w", hlist, "%s ")
    write_table(areaavefile, "a", alist, "%4d, %2d, %10.4f, %6.2f")

 end

exit()

