; plot 20CRv3 data

; turn off warnings
err = NhlGetErrorObjectId()
setvalues err
"errLevel" : "Fatal"          ; only report Fatal errors
end setvalues

;  set up times (31 days x 8 (3 hr steps) = 240)

year = 1867
month = 12

nd = 31
nsteps = 8

units = "hours since 1800-1-1 00:00:0.0"
pac_time_offset = 8
plabel = "PST"

; set paths and open files

; data_path = "/Volumes/LaCie-12big-T3/Data/20Cv3/3_hourly/1867/"
data_path = "/mnt/e/Data/20Cv3/3_hourly/1867/"

; 500 hPa heights -- also get lons and lats
f1 = addfile(data_path + "hgt.186712.nc", "r")
lon = f1->lon
lat = f1->lat
; printVarSummary(lon)
; printVarSummary(lat)

nlon = dimsizes(lon)
nlat = dimsizes(lat)


; data ------------------------------------------------------------------------

; 500hPa heights
lvl = 12 
hgt500 = f1->hgt(:, lvl, :, :)

; 500 hPa U and V
lvl = 12 ; 500hPa
f2 = addfile(data_path + "uwnd.186712.nc", "r")
u500 = f2->uwnd(:, lvl, :, :)
f3 = addfile(data_path + "vwnd.186712.nc", "r")
v500 = f3->vwnd(:, lvl, :, :)

; 700 hPa Omega, U, and V
lvl = 8 ; 700hPa
f4 = addfile(data_path + "omega.186712.nc", "r")
omega700 = f4->omega(:, lvl, :, :)
f5 = addfile(data_path + "uwnd.186712.nc", "r")
u700 = f5->uwnd(:, lvl, :, :)
f6 = addfile(data_path + "vwnd.186712.nc", "r")
v700 = f6->vwnd(:, lvl, :, :)

; SLP and 10m U and V
f7 = addfile(data_path + "prmsl.186712.nc", "r")
prmsl = f7->prmsl(:, :, :)
prmsl = prmsl / 100
f8 = addfile(data_path + "uwnd.10m.186712.nc", "r")
u10m = f8->uwnd(:, :, :)
f9 = addfile(data_path + "vwnd.10m.186712.nc", "r")
v10m = f9->vwnd(:, :, :)

; moisture flux, uqvq_vdiv,  and uq_vint and vq_vint
f10 = addfile(data_path + "uqvq_vmag.186712.nc", "r")
uvqmag = f10->uqvq_vmag(:, :, :)
f11 = addfile(data_path + "uq_vint.186712.nc", "r")
uq = f11->uq_vint(:, :, :)
f12 = addfile(data_path + "vq_vint.186712.nc", "r")
vq = f12->vq_vint(:, :, :)
f13 = addfile(data_path + "uqvq_vdiv.186712.nc", "r")
uqvq_vdiv = f13->uqvq_vdiv(:, :, :)
uqvq_vdiv = uqvq_vdiv * 1000

; column-integrated moisture (precipitable water vapor
f14 = addfile(data_path + "pr_wtr.eatm.186712.nc", "r")
pr_wtr = f14->pr_wtr(:, :, :)

; prate
f14 = addfile(data_path + "prate.186712.nc", "r")
prate = f14->prate(:, :, :)
prate = prate * 86400

; 2m air temperature
f15 = addfile(data_path + "air.2m.186712.nc", "r")
tas = f15->air(:, :, :)
tas = tas - 273.15

; 300 hPa U and V
lvl = 16 ; 300hPa
f16 = addfile(data_path + "uwnd.186712.nc", "r")
u300 = f16->uwnd(:, lvl, :, :)
f17 = addfile(data_path + "vwnd.186712.nc", "r")
v300 = f17->vwnd(:, lvl, :, :)
vmag300 = sqrt(u300^2 + v300^2)
copy_VarCoords(u300, vmag300)

; cutpoints and colors --------------------------------------------------------

; hgt500
level_hgt500 = new((/09/),float)
level_hgt500= (/5200, 5300, 5400, 5500, 5600, 5700, 5800, 5900, 6000 /)
level_hgt500_begclr = 74
level_hgt500_endclr = 85

;  omega
level_omega = new((/11/),float)
; level_omega = (/-2.0,-1.0,-.5,-.2,-.1,0,.1,.2,.5,1.0,2.0/) 
level_omega = (/-1.0,-.5,-.2,-.1,-.05,0,.05,.1,.2,.5,1.0/) 
level_omega_begclr = 74
level_omega_endclr = 85

; MSLP 
level_prmsl = new((/ 11 /),float)
; level_prmsl = (/ 960., 970., 980., 990., 1000., 1010., 1020., 1030., 1040./)
level_prmsl = (/ 985., 990., 995., 1000., 1005., 1010., 1015., 1020., 1025., 1030., 1035./)
level_prmsl_begclr = 74
level_prmsl_endclr = 85

; UVQMag
; level_uvqmag = new((/ 6 /), float)
; level_uvqmag = (/ 20, 50, 100, 200, 500, 1000 /)
level_uvqmag = new((/ 5 /), float)
level_uvqmag = (/ 20, 50, 100, 200, 500 /)
level_uvqmag_begclr = 22 ; 91 ; 52
level_uvqmag_endclr = 27 ; 86 ; 46

; uqvq_vdiv
level_uqvq_vdiv = new((/ 11 /), float)
level_uqvq_vdiv = (/ -0.5, -0.2, -0.1, -0.05, -0.02, 0.0, 0.02, 0.05, 0.1, 0.2, 0.5 /)
level_uqvq_vdiv_begclr = 27
level_uqvq_vdiv_endclr = 16

; pr_wtr
; 
; level_pr_wtr = new((/ 7 /), float)
; level_pr_wtr = (/ 2, 5, 10, 20, 50, 100, 200 /)
; level_pr_wtr = new((/ 17 /), float)
; level_pr_wtr = (/ 1, 1.5, 2., 3.5, 5., 7.5, 10., 15., 20., 35., 50., 75., 100., 150., 200., 350., 500. /)
level_pr_wtr = new((/ 7 /), float)
level_pr_wtr = (/ 5, 10, 15, 20, 30, 40, 50 /)
level_pr_wtr_begclr = 37 ; 22 ; 91 ; 52
level_pr_wtr_endclr = 30 ; 27 ; 86 ; 46

; prate
level_prate = new((/ 7 /), float)
level_prate = (/ 1, 2, 5, 10, 20, 50, 100. /)
level_prate_begclr = 37 ; 22 ; 91 ; 52
level_prate_endclr = 30 ; 27 ; 86 ; 46

; 2 m air temperature
level_tas = new((/ 15 /), float)
level_tas = (/-35, -30, -25, -20, -15, -10, -5, 0, 5, 10, 15, 20, 25, 30, 35 /)
level_tas_begclr = 178
level_tas_endclr = 195

; vmag
level_vmag300 = new((/ 5 /), float)
; level_vmag300 = (/ 5, 10, 20, 50, 100/)
level_vmag300 = (/ 10, 20, 30, 40, 50/)
level_vmag300_begclr = 79 ; 91
level_vmag300_endclr = 74 ; 87 


; shapefiles-------------------------------------------------------------------
; land_dir = "/Users/bartlein/Dropbox/WorkCurrent/20CRv3/shp_files/20CRv3_land/" 
land_dir = "/mnt/e/Projects/20CRv3/shp_files/20CRv3_land/"
land_file = "20CRv3_land.shp" 
land_shp = land_dir + land_file
; print(land_shp)
; ice_dir = "/Users/bartlein/Dropbox/WorkCurrent/20CRv3/shp_files/20CRv3_ice/" 
ice_dir = "/mnt/e/Projects/20CRv3/shp_files/20CRv3_ice/"
ice_file = "20CRv3_ice.shp"
ice_shp = ice_dir + ice_file
; print(ice_shp)
; admin_dir = "/Users/bartlein/Dropbox/WorkCurrent/20CRv3/shp_files/NE/" 
; admin_file = "ne_50m_admin_1_states_provinces.shp"
; admin_shp = admin_dir + admin_file
; print(admin_shp)

; loop over individual time intervals

begin

; loop over days and hours
i = -1
do day = 0, (nd - 1)
    hrs = 0

    do h = 0, (nsteps - 1)
        i = i + 1
        hours = h * 3

        time = cd_inv_calendar(stringtoint(year),stringtoint(month),toint(day + 1), \
        toint(hours),0,0,units, 0)
        time@units = units
        time = time - pac_time_offset
        ; print(time)

        utc_date = cd_calendar(time, 0)
        ; print("utc_date: " +utc_date)

        cindex  = sprinti("%0.2i", floattoint(i))
        cyear   = sprinti("%0.4i", floattoint(utc_date(:,0)))
        cmonth  = sprinti("%0.2i", floattoint(utc_date(:,1)))
        cday    = sprinti("%0.2i", floattoint(utc_date(:,2)))
        chour   = sprinti("%0.2i", floattoint(utc_date(:,3)))
        cminute = sprinti("%0.2i", floattoint(utc_date(:,4)))

        output_time = cyear + "-" + cmonth + "-" + cday + " " + chour + ":" + cminute + " " + plabel 
        ; print(output_time)

        map_file = "20CRv3_" + cyear + "_" + cmonth + cday + "_" + chour + cminute
        ; print(map_file)

        ; titles 
        title_l = "NOAA-CIRES-DOE 20th Century Reanalysis (V3)"
        title_r = output_time
        label1a = ""
        label1b = ""


        ; ; output format ----------------------------------------------------------------
        ; wks_type = "pdf"
        ; wks_type@wkOrientation = "portrait"
        wks_type = "png"
        wks_type@wkWidth = 1200 ; 2048
        wks_type@wkHeight = 1200 ; 2048

        wks  = gsn_open_wks (wks_type, map_file)             ; send graphics to PNG file  

        res                        = True               ; plot mods desired
        ; drawNDCGrid(wks)               ; Draw an NDC grid for reference.

        ; set colormap
        clr_map = "ClimA6"
        gsn_define_colormap(wks,clr_map)

        ; plot array for panels 
        plot = new(9, graphic)
        id_land = new(9, graphic)
        id_ice = new(9, graphic)
        ; id_admin = new(9, graphic)

        ; contouring
        ; res@gsnAddCyclic           = False              ; regional data

        ; gsn high-level interfaces ---------------------------------------------------
        res@gsnDraw                = False              ; don't draw
        res@gsnFrame               = False              ; don't advance frame
        res@gsnSpreadColors        = True              ; use total colormap

        ; contour ----------------------------------------------------------------------
        ;res@gsnScalarContour      = True               ; contours desired
        ;res@mpGridLineColor       = "transparent"      ; trick ncl into drawing perimeter
        res@cnInfoLabelOn          = False              ; turn off cn info label
        res@cnFillOn               = True               ; color fill  
        res@cnLinesOn              = False              ; no contour lines
        res@cnLineLabelsOn         = False              ; no contour labels
        res@cnInfoLabelOn          = False              ; no contour info label
        res@cnFillMode             = "CellFill" ; RasterFill" ; or "CellFill"
        res@cnLevelSelectionMode   = "ExplicitLevels" ;

        ; maps -------------------------------------------------------------------------
        res@mpOutlineOn           = False
        res@mpOutlineBoundarySets   = "AllBoundaries" ; AllBoundaries"
        res@mpOutlineSpecifiers     = (/"Canada:provinces", "United States:states"/)
        res@mpDataBaseVersion       = "MediumRes" 
        res@mpDataSetName           = "Earth..1"
        res@mpGeophysicalLineColor = "black"
        res@mpGeophysicalLineThicknessF = 2
        ; res@mpProvincialLineColor = "gray50"
        ; res@mpProvincialLineThicknessF = 2
        ; res@mpCountyLineColor    = "gray60"

        res@mpFillOn               = False       ; turn off map fill
        res@mpGridAndLimbOn        = True      ; Turn on lat/lon grid
        res@mpGridLatSpacingF      = 10.0
        res@mpGridLonSpacingF      = 10.0
        res@mpPerimOn              = True      ; turn on perimeter 
        res@mpPerimLineThicknessF  = 3
        res@mpPerimDrawOrder        = "PostDraw" 

        ; projection
        res@mpProjection           = "LambertConformal" 
        res@mpLambertParallel1F    = 50.0
        res@mpLambertParallel2F    = 50.0
        res@mpLambertMeridianF     = 253.0

        ; plot region
        res@mpLimitMode            = "Corners"          ; choose range of map
        res@mpLeftCornerLatF       = 1
        res@mpLeftCornerLonF       = -145.5
        res@mpRightCornerLatF      = 46.4
        res@mpRightCornerLonF      = -2.6
        ; res@tfDoNDCOverlay         = False

        ; vectors
        res@gsnScalarContour      = True               ; contours desired
        res@vcMinFracLengthF = 0.00001  ;-- length of min vector as fraction of reference vector
        res@vcRefLengthF = 0.05 ;-- ref vec length
        res@vcRefAnnoOrthogonalPosF = -0.11          ; move ref vector up
        res@vcRefAnnoParallelPosF = 0.11          ; move ref vector over
        res@vcGlyphStyle = "CurlyVector" ; "LineArrow" ;  ;-- turn on curly vectors or straight
        ; res@vcGlyphOpacityF = 0.3 ;-- transparency of vector
        res@vcMinDistanceF = 0.02 ; 0.015 ; 0.02 ;-- thin out vectors
        res@vcLineArrowColor = "black" ; "gray20"
        res@vcLineArrowThicknessF = 2.0
        res@vcRefAnnoFontHeightF = 0.01
        res@vcRefAnnoPerimOn = "True"
        res@vcRefAnnoBackgroundColor = "gray95"
        ; res@vcLabelBarEndLabelsOn = "True"


        ; label bar -----------------------------------------------------------------------
        ;res@gsnPanelLabelBar       = True 
        ; res@lbAutoManage           = False
        res@lbLabelBarOn           = True 
        res@pmLabelBarOrthogonalPosF = 0.001
        res@lbLabelFont            = 21
        res@lbLabelFontHeightF     = 0.01
        ;res@gsnPanelBottom         = 0.25
        res@lbLabelAutoStride      = True

        res@lbBoxLineThicknessF    = 2
        res@pmLabelBarWidthF       = 0.5     
        res@pmLabelBarHeightF      = 0.06  

        ; shapefile outlines -------------------------------------------------------
        plres        = True
        plres@gsLineColor = "black"
        plres@gsLineThicknessF= 3
        pires        = True
        pires@gsLineColor = "gray50"
        pires@gsLineThicknessF= 3
        ; pares        = True
        ; pares@gsLineColor = "red"
        ; pares@gsLineThicknessF= 3

        ; plot()  ----------------------------------------------------------------------

        ; different settings among panels

        ; 500mb
        p = 1
        res_hgt500 = res
        res_hgt500@gsnSpreadColorStart     = level_hgt500_begclr
        res_hgt500@gsnSpreadColorEnd       = level_hgt500_endclr 
        res_hgt500@cnLevels                = level_hgt500
        res_hgt500@gsnLeftString = "~F21~ 500 hPa Heights (gpm) & Winds (m s~S~-1~N~)"   
        res_hgt500@gsnLeftStringFontHeightF = 21  
        res_hgt500@gsnRightString = ""  
        res_hgt500@vcRefMagnitudeF = 30.0 
        res_hgt500@cnMissingValFillColor = "gray"     
        plot(p) = gsn_csm_vector_scalar_map(wks,u500(i,:,:),v500(i,:,:),hgt500(i,:,:),res_hgt500)
        id_land(p) = gsn_add_shapefile_polylines(wks,plot(p),land_shp,plres)

        ; omega
        p = 3
        res_omega = res
        res_omega@gsnSpreadColorStart     = level_omega_begclr
        res_omega@gsnSpreadColorEnd       = level_omega_endclr 
        res_omega@cnLevels                = level_omega
        res_omega@gsnLeftString = "~F21~ 700 hPa Vert. Vel. (Pa s~S~-1~N~) & Winds (m s~S~-1~N~)"   
        res_omega@gsnLeftStringFontHeightF = 21  
        res_omega@gsnRightString = ""  
        res_omega@vcRefMagnitudeF = 30.0 
        res_omega@cnMissingValFillColor = "gray"    
        plot(p) = gsn_csm_vector_scalar_map(wks,u700(i,:,:),v700(i,:,:),omega700(i,:,:),res_omega)
        id_land(p) = gsn_add_shapefile_polylines(wks,plot(p),land_shp,plres)

        ; prmsl and 10 U anv V
        p = 2
        res_prmsl = res
        res_prmsl@gsnSpreadColorStart     = level_prmsl_begclr
        res_prmsl@gsnSpreadColorEnd       = level_prmsl_endclr 
        res_prmsl@cnLevels                = level_prmsl
        res_prmsl@gsnLeftString = "~F21~ MSLP (hPa) & 10 m Winds (m s~S~-1~N~)"   
        res_prmsl@gsnLeftStringFontHeightF = 21  
        res_prmsl@gsnRightString = ""  
        res_prmsl@vcRefMagnitudeF = 15.0 
        res_prmsl@cnMissingValFillColor = "gray"    
        plot(p) = gsn_csm_vector_scalar_map(wks,u10m(i,:,:),v10m(i,:,:),prmsl(i,:,:),res_prmsl)
        id_land(p) = gsn_add_shapefile_polylines(wks,plot(p),land_shp,plres)

        ; uqvq_vdiv, uq_vint, and vq_int
        p = 6
        res_uqvq_vdiv = res
        res_uqvq_vdiv@gsnSpreadColorStart     = level_uqvq_vdiv_begclr
        res_uqvq_vdiv@gsnSpreadColorEnd       = level_uqvq_vdiv_endclr 
        res_uqvq_vdiv@cnLevels                = level_uqvq_vdiv
        res_uqvq_vdiv@gsnLeftString = "~F21~  Moisture Flux Divergence (g m~S~-2~N~" + " " +"s~S~-1~N~)"   
        res_uqvq_vdiv@gsnLeftStringFontHeightF = 21  
        res_uqvq_vdiv@gsnRightString = ""  
        res_uqvq_vdiv@vcRefMagnitudeF = 250.0 
        res_uqvq_vdiv@cnMissingValFillColor = "gray"    
        plot(p) = gsn_csm_vector_scalar_map(wks,uq(i,:,:),vq(i,:,:),uqvq_vdiv(i,:,:),res_uqvq_vdiv)
        id_land(p) = gsn_add_shapefile_polylines(wks,plot(p),land_shp,plres)

        ; UVQmag, UQ, and VQ
        p = 7
        res_uvqmag = res
        res_uvqmag@gsnSpreadColorStart     = level_uvqmag_begclr
        res_uvqmag@gsnSpreadColorEnd       = level_uvqmag_endclr 
        res_uvqmag@cnLevels                = level_uvqmag
        res_uvqmag@gsnLeftString = "~F21~ Vertically Integrated Moisture Flux (kg m~S~-1~N~" + " " +"s~S~-1~N~)"   
        res_uvqmag@gsnLeftStringFontHeightF = 21  
        res_uvqmag@gsnRightString = ""  
        res_uvqmag@vcRefMagnitudeF = 250.0 
        res_uvqmag@cnMissingValFillColor = "gray"    
        plot(p) = gsn_csm_vector_scalar_map(wks,uq(i,:,:),vq(i,:,:),uvqmag(i,:,:),res_uvqmag)
        id_land(p) = gsn_add_shapefile_polylines(wks,plot(p),land_shp,plres)

        ; pr_wtr
        p = 8
        res_pr_wtr = res
        res_pr_wtr@gsnSpreadColorStart     = level_pr_wtr_begclr
        res_pr_wtr@gsnSpreadColorEnd       = level_pr_wtr_endclr 
        res_pr_wtr@cnLevels                = level_pr_wtr
        res_pr_wtr@gsnLeftString = "~F21~ Column-Integrated Water Vapor (mm)"   
        res_pr_wtr@gsnLeftStringFontHeightF = 21  
        res_pr_wtr@gsnRightString = ""  
        res_pr_wtr@cnMissingValFillColor = "gray"    
        plot(p) = gsn_csm_contour_map(wks, pr_wtr(i,:,:), res_pr_wtr)
        id_land(p) = gsn_add_shapefile_polylines(wks,plot(p),land_shp,plres)

        ; prate
        p = 4
        res_prate = res
        res_prate@gsnSpreadColorStart     = level_prate_begclr
        res_prate@gsnSpreadColorEnd       = level_prate_endclr 
        res_prate@cnLevels                = level_prate
        res_prate@gsnLeftString = "~F21~ Precipitation Rate (mm d~S~-1~N~)"   
        res_prate@gsnLeftStringFontHeightF = 21  
        res_prate@gsnRightString = ""  
        res_prate@cnMissingValFillColor = "gray"    
        plot(p) = gsn_csm_contour_map(wks, prate(i,:,:), res_prate)
        id_land(p) = gsn_add_shapefile_polylines(wks,plot(p),land_shp,plres)

        ; tas
        p = 5
        res_tas = res
        res_tas@gsnSpreadColorStart     = level_tas_begclr
        res_tas@gsnSpreadColorEnd       = level_tas_endclr 
        res_tas@cnLevels                = level_tas
        res_tas@gsnLeftString           = "2 m Air Temperature (~S~o~N~C~N~)"  
        res_tas@gsnRightString          = "" 
        res_tas@gsnLeftStringFontHeightF = 21
        res_tas@gsnRightString = ""  
        res_tas@cnMissingValFillColor = "gray" 
        plot(p) = gsn_csm_contour_map(wks, tas(i,:,:), res_tas)
        id_land(p) = gsn_add_shapefile_polylines(wks,plot(p),land_shp,plres)

        ; 300mb
        p = 0
        res_vmag300 = res
        res_vmag300@gsnSpreadColorStart     = level_vmag300_begclr
        res_vmag300@gsnSpreadColorEnd       = level_vmag300_endclr 
        res_vmag300@cnLevels                = level_vmag300
        res_vmag300@gsnLeftString = "~F21~ 300 hPa Winds (m s~S~-1~N~)"   
        res_vmag300@gsnLeftStringFontHeightF = 21  
        res_vmag300@gsnRightString = ""  
        res_vmag300@vcRefMagnitudeF = 50.0 
        res_vmag300@cnMissingValFillColor = "gray"     
        plot(p) = gsn_csm_vector_scalar_map(wks,u300(i,:,:),v300(i,:,:),vmag300(i,:,:),res_vmag300)
        id_land(p) = gsn_add_shapefile_polylines(wks,plot(p),land_shp,plres)

        ; panel TextOnly 
        txres1     = True
        txres1@txFontHeightF = 0.015
        txres1@txFont        = 21

       ; plot titles
        title_x_pos = 0.01
        title_y_pos = 0.99
        txres1@txJust        = "TopLeft" 
        gsn_text_ndc(wks,title_l,title_x_pos,title_y_pos,txres1)
        title_x_pos = 0.99
        txres1@txJust        = "TopRight" 
        gsn_text_ndc(wks,title_r,title_x_pos,title_y_pos,txres1)  

        ; panel plot
        resP           = True
        resP@gsnPaperOrientation = "portrait"   
        resP@gsnPanelLeft  = 0.01 ; 0.02
        resP@gsnPanelRight = 0.99 ; 0.98 
        resP@gsnPanelTop   = 0.99 ; 0.9
        resP@gsnPanelBottom = 0.01 ; 0.1  
        resP@txFont             = 21
        resP@gsnPanelYWhiteSpacePercent = 1 ; 2
        resP@txFontHeightF = 0.0

        ; plot = gsn_csm_contour_map(wks,tas,res)                 ; Draw original grid on map
        gsn_panel(wks, plot, (/3,3/), resP)


    end do
end do  

end 
exit()