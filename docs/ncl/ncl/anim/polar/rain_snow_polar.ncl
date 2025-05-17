; NH/SH 4-up plot of a scalar variable

mapfile = "rain_snow_polar30_1991-2020_ltm"
mapvar0 = "tp"
ncvar0 = "tp"
mapvar1 = "rr"
ncvar1 = "rr"
mapvar2 = "sf"
ncvar2 = "sf"
mapvar3 = "sd"
ncvar3 = "sd"
data_path = "/Users/bartlein/Dropbox/WorkCurrent/ERA5/data/ERA5-Atm/ltm_monthly/"
map_path = "/Users/bartlein/Dropbox/WorkCurrent/ERA5/maps/polar/" + mapfile + "/png/"
title_0 = "Rain and Snow"
title_00 = "Precipitation Rate (mm  d~S~-1~N~)"
title_01 = "Rainfall Rate (mm  d~S~-1~N~)"
title_02 = "Snowfall Rate (mm  d~S~-1~N~)"
title_03 = "Snowdepth (mm water equivalent)"
title_2 = "Data: ERA5 Reanalysis"
title_3 = "1991-2020 Long-Term Mean"

infile0 = "ERA5_" + mapvar0 + "_monthly_199101-202012_ltm.nc"
infile1 = "ERA5_" + mapvar1 + "_monthly_199101-202012_ltm.nc"
infile2 = "ERA5_" + mapvar2 + "_monthly_199101-202012_ltm.nc"
infile3 = "ERA5_" + mapvar3 + "_monthly_199101-202012_ltm.nc"

; shapefiles
land_dir = "/Users/bartlein/Dropbox/WorkCurrent/ERA5/shp_files/"
land_file = "ERA5-Atm_land.shp"
land_shp = land_dir + land_file
print(land_shp)
country_dir = "/Users/bartlein/Dropbox/WorkCurrent/ERA5/shp_files/ne_110m_admin_0_countries/"
country_file = "ne_110m_admin_0_countries.shp"
country_shp = country_dir + country_file
print(country_shp)
grat30_dir = "/Users/bartlein/Dropbox/WorkCurrent/ERA5/shp_files/grat30_nopole/"
grat30_file = "grat30_nopole.shp"
grat30_shp = grat30_dir + grat30_file
print(grat30_shp)
equator_dir = "/Users/bartlein/Dropbox/WorkCurrent/ERA5/shp_files/equator/"
equator_file = "equator.shp"
equator_shp = equator_dir + equator_file
print(equator_shp)

; set color scale
clr_map = "ClimA7"

nm = 12
months = (/"Jan", "Feb", "Mar", "Apr","May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov","Dec" /)

begin

; open file and read data
f0 = addfile(data_path + infile0, "r")
pltvar0 = short2flt(f0->$ncvar0$(:,:,:))
pltvar0 = pltvar0 * 1000.0
pltvar0 = where(pltvar0 .le. 0.0, -0.00001, pltvar0)
lon = f0->longitude
lat = f0->latitude
time = f0->time
pltvar0 = lonFlip(pltvar0)
printVarSummary(pltvar0)
printMinMax(pltvar0, 1)

; open file and read data
f1 = addfile(data_path + infile1, "r")
pltvar1 = short2flt(f1->$ncvar1$(:,:,:))
pltvar1 = pltvar1 * 1000.0
pltvar1 = where(pltvar1 .le. 0.0, -0.00001, pltvar1)
pltvar1 = lonFlip(pltvar1)
printVarSummary(pltvar1)
printMinMax(pltvar0, 1)

; open file and read data
f2 = addfile(data_path + infile2, "r")
pltvar2 = short2flt(f2->$ncvar2$(:,:,:))
pltvar2 = pltvar2 * 1000.0
pltvar2 = where(pltvar2 .le. 0.0, -0.00001, pltvar2)
pltvar2 = lonFlip(pltvar2)
printVarSummary(pltvar2)
printMinMax(pltvar2, 1)

; open file and read data
f3 = addfile(data_path + infile3, "r")
pltvar3 = short2flt(f3->$ncvar3$(:,:,:))
pltvar3 = pltvar3 * 1000.0
pltvar3 = where(pltvar3 .le. 0.0, -0.00001, pltvar3)
pltvar3 = lonFlip(pltvar3)
printVarSummary(pltvar3)
printMinMax(pltvar3, 1)

; prate
level0 = new((/ 6 /), float)
level0 = (/ 0.0, 0.5, 1, 2, 5, 10/)
level0_begclr = 21 
level0_endclr = 27 

; snowfall
level1 = new((/ 6 /), float)
level1 = (/ 0.0, 0.5, 1, 2, 5, 10/)
level1_begclr = 115 
level1_endclr = 109 

; snow depth
level2 = new((/ 6 /), float)
level2 = (/ 0.0, 10, 20, 50, 100, 200/)
level2_begclr = 115 
level2_endclr = 109 

; plotting resources

res                        = True  ; plot mods desired
plot = new(8, graphic)
id_land = new(8, graphic)
id_country = new(8, graphic)
id_grat = new(8, graphic)
id_eq = new(8, graphic)

; gsn high-level interfaces ---------------------------------------------------
res@gsnDraw                = False              ; don't draw
res@gsnFrame               = False              ; don't advance frame
res@gsnSpreadColors        = True               ; use total colormap
 
; contour ----------------------------------------------------------------------
;res@gsnScalarContour      = True               ; contours desired
res@mpGridLineColor        = "transparent"      ; trick ncl into drawing perimeter
res@cnInfoLabelOn          = False              ; turn off cn info label
res@cnFillOn               = True               ; color fill  
res@cnLinesOn              = False              ; no contour lines
res@cnLineLabelsOn         = False              ; no contour labels
res@cnInfoLabelOn          = False              ; no contour info label
res@cnFillMode             = "CellFill"; "RasterFill" or "CellFill"
res@cnLevelSelectionMode   = "ExplicitLevels" ;
res@cnMissingValFillColor  = "gray" 

; maps -------------------------------------------------------------------------
res@mpOutlineOn            = False     ; continental outline
res@mpFillOn               = False       ; turn off map fill
res@mpGridAndLimbOn        = False      ; Turn on lat/lon grid
res@mpPerimOn              = True      ; turn off perimeter  

; gsn_csm_contour_map_polar
res@gsnPolar = "NH"
res@gsnPolarLabelFontHeightF  = 0.0
res@mpCenterLonF = -90                    ; center longitude
res@mpMinLatF  = 30                           ; minimum lat to plot

res@mpLimbLineThicknessF    = 2
res@mpGridLineColor         = "gray50"
res@mpGridLineThicknessF    = 1

; label bar --------------------------------------------------------------------
res@lbLabelBarOn            = True            
res@pmLabelBarHeightF       = 0.10 ;0.08
res@lbLabelFontHeightF      = 0.0175 ; 0.0125
res@pmLabelBarOrthogonalPosF= -.001
res@lbBoxLineThicknessF     = 2

; shapefile outlines -------------------------------------------------------
plres        = True
plres@gsLineColor = "black"
plres@gsLineThicknessF= 1.5
pcres        = True
pcres@gsLineColor = "gray50"
pcres@gsLineThicknessF= 1.0
pgres        = True
pgres@gsLineColor = "gray50"
pgres@gsLineThicknessF= 1.0
peqres        = True
peqres@gsLineColor = "black"
peqres@gsLineThicknessF= 2
plresSH = plres
pcresSH = pcres
pgresSH = pgres
peqresSH = peqres

res@gsnLeftString           = ""
res@gsnRightString           = ""
res@gsnLeftStringFontHeightF     = 0.025 ; 0.0175

; add SH resources
resSH = res
resSH@gsnPolar = "SH"
resSH@gsnPolarLabelFontHeightF  = 0.0
resSH@mpCenterLonF = 90                    ; center longitude
resSH@gsnLeftString           = ""
resSH@mpMaxLatF  = -30                           ; maximum lat to plot
resSH@mpMinLatF  = -90 

do m = 0,nm-1

    ; output format ----------------------------------------------------------------
    ; wks_type = "pdf"
    ; wks_type@wkOrientation = "portrait"
    wks_type = "png"
    wks_type@wkWidth = 1200
    wks_type@wkHeight = 1200

    monthstring  = sprinti("%0.2i", m+1)
    map_out_file = mapfile + "_" + monthstring
    wks  = gsn_open_wks (wks_type, map_path + map_out_file)
    print("     map_out_file: " + map_out_file + ".png")
    gsn_define_colormap(wks,clr_map)
    ; drawNDCGrid(wks)                   ; Draw an NDC grid for reference

    title_1         = months(m)

    ; plot titles
    txres1 = True
    txres1@txFont        = 21 
    txres1@txFontHeightF = 0.0175

    title_y_pos = 0.80
    title_x_pos = 0.99
    txres1@txJust        = "TopRight" 
    gsn_text_ndc(wks,title_1,title_x_pos,title_y_pos,txres1)  

    txres1@txFontHeightF = 0.009
    title_x_pos = 0.01
    title_y_pos = 0.20
    txres1@txJust        = "BottomLeft" 
    gsn_text_ndc(wks,title_2,title_x_pos,title_y_pos,txres1)
    title_x_pos = 0.99
    txres1@txJust        = "BottomRight" 
    gsn_text_ndc(wks,title_3,title_x_pos,title_y_pos,txres1)

    ; res@gsnRightString           = ""
    ; res@gsnLeftStringFontHeightF     = 0.0175
    txres1@txFontHeightF = 0.015
    title_x_pos = 0.01
    title_y_pos = 0.795
    txres1@txJust        = "CenterLeft" 
    gsn_text_ndc(wks,title_00,title_x_pos,title_y_pos,txres1)

    resp = res
    ; resp@gsnLeftString           = title_00
    resp@gsnSpreadColorStart     = level0_begclr
    resp@gsnSpreadColorEnd       = level0_endclr 
    resp@cnLevels                = level0 
    plot(0) = gsn_csm_contour_map(wks, pltvar0(m,:,:), resp)
    id_country(0) = gsn_add_shapefile_polylines(wks,plot(0),country_shp,pcres)
    id_land(0) = gsn_add_shapefile_polylines(wks,plot(0),land_shp,plres)
    id_grat(0) = gsn_add_shapefile_polylines(wks,plot(0),grat30_shp,pgres)
    id_eq(0) = gsn_add_shapefile_polylines(wks,plot(0),equator_shp,pgres)
    delete(resp)

    resp = resSH
    resp@gsnLeftString           = ""
    resp@gsnRightString          = ""
    resp@gsnSpreadColorStart     = level0_begclr
    resp@gsnSpreadColorEnd       = level0_endclr 
    resp@cnLevels                = level0 
    plot(1) = gsn_csm_contour_map(wks, pltvar0(m,:,:), resp)
    id_country(1) = gsn_add_shapefile_polylines(wks,plot(1),country_shp,pcresSH)
    id_land(1) = gsn_add_shapefile_polylines(wks,plot(1),land_shp,plresSH)
    id_grat(1) = gsn_add_shapefile_polylines(wks,plot(1),grat30_shp,pgresSH)
    id_eq(1) = gsn_add_shapefile_polylines(wks,plot(1),equator_shp,pgresSH)
    delete(resp)

    title_x_pos = 0.51
    title_y_pos = 0.795
    txres1@txJust        = "CenterLeft" 
    gsn_text_ndc(wks,title_01,title_x_pos,title_y_pos,txres1)

    resp = res
    ; resp@gsnLeftString           = title_00
    resp@gsnSpreadColorStart     = level0_begclr
    resp@gsnSpreadColorEnd       = level0_endclr 
    resp@cnLevels                = level0 
    plot(2) = gsn_csm_contour_map(wks, pltvar1(m,:,:), resp)
    id_country(2) = gsn_add_shapefile_polylines(wks,plot(2),country_shp,pcres)
    id_land(2) = gsn_add_shapefile_polylines(wks,plot(2),land_shp,plres)
    id_grat(2) = gsn_add_shapefile_polylines(wks,plot(2),grat30_shp,pgres)
    id_eq(2) = gsn_add_shapefile_polylines(wks,plot(2),equator_shp,pgres)
    delete(resp)

    resp = resSH
    resp@gsnLeftString           = ""
    resp@gsnRightString          = ""
    resp@gsnSpreadColorStart     = level0_begclr
    resp@gsnSpreadColorEnd       = level0_endclr 
    resp@cnLevels                = level0 
    plot(3) = gsn_csm_contour_map(wks, pltvar1(m,:,:), resp)
    id_country(3) = gsn_add_shapefile_polylines(wks,plot(3),country_shp,pcresSH)
    id_land(3) = gsn_add_shapefile_polylines(wks,plot(3),land_shp,plresSH)
    id_grat(3) = gsn_add_shapefile_polylines(wks,plot(3),grat30_shp,pgresSH)
    id_eq(3) = gsn_add_shapefile_polylines(wks,plot(3),equator_shp,pgresSH)
    delete(resp)

    title_x_pos = 0.01
    title_y_pos = 0.495
    txres1@txJust        = "CenterLeft" 
    gsn_text_ndc(wks,title_02,title_x_pos,title_y_pos,txres1)

    resp = res
    ; resp@gsnLeftString           = title_00
    resp@gsnSpreadColorStart     = level1_begclr
    resp@gsnSpreadColorEnd       = level1_endclr 
    resp@cnLevels                = level1 
    plot(4) = gsn_csm_contour_map(wks, pltvar2(m,:,:), resp)
    id_country(4) = gsn_add_shapefile_polylines(wks,plot(4),country_shp,pcres)
    id_land(4) = gsn_add_shapefile_polylines(wks,plot(4),land_shp,plres)
    id_grat(4) = gsn_add_shapefile_polylines(wks,plot(4),grat30_shp,pgres)
    id_eq(4) = gsn_add_shapefile_polylines(wks,plot(4),equator_shp,pgres)
    delete(resp)

    resp = resSH
    resp@gsnLeftString           = ""
    resp@gsnRightString          = ""
    resp@gsnSpreadColorStart     = level1_begclr
    resp@gsnSpreadColorEnd       = level1_endclr 
    resp@cnLevels                = level1 
    plot(5) = gsn_csm_contour_map(wks, pltvar2(m,:,:), resp)
    id_country(5) = gsn_add_shapefile_polylines(wks,plot(5),country_shp,pcresSH)
    id_land(5) = gsn_add_shapefile_polylines(wks,plot(5),land_shp,plresSH)
    id_grat(5) = gsn_add_shapefile_polylines(wks,plot(5),grat30_shp,pgresSH)
    id_eq(5) = gsn_add_shapefile_polylines(wks,plot(5),equator_shp,pgresSH)
    delete(resp)

    title_x_pos = 0.51
    title_y_pos = 0.495
    txres1@txJust        = "CenterLeft" 
    gsn_text_ndc(wks,title_03,title_x_pos,title_y_pos,txres1)

    resp = res
    ; resp@gsnLeftString           = title_03
    resp@gsnSpreadColorStart     = level2_begclr
    resp@gsnSpreadColorEnd       = level2_endclr 
    resp@cnLevels                = level2 
    plot(6) = gsn_csm_contour_map(wks, pltvar3(m,:,:), resp)
    id_country(6) = gsn_add_shapefile_polylines(wks,plot(6),country_shp,pcres)
    id_land(6) = gsn_add_shapefile_polylines(wks,plot(6),land_shp,plres)
    id_grat(6) = gsn_add_shapefile_polylines(wks,plot(6),grat30_shp,pgres)
    id_eq(6) = gsn_add_shapefile_polylines(wks,plot(6),equator_shp,pgres)
    delete(resp)

    resp = resSH
    resp@gsnLeftString           = ""
    resp@gsnRightString          = ""
    resp@gsnSpreadColorStart     = level2_begclr
    resp@gsnSpreadColorEnd       = level2_endclr 
    resp@cnLevels                = level2 
    plot(7) = gsn_csm_contour_map(wks, pltvar3(m,:,:), resp)
    id_country(7) = gsn_add_shapefile_polylines(wks,plot(7),country_shp,pcresSH)
    id_land(7) = gsn_add_shapefile_polylines(wks,plot(7),land_shp,plresSH)
    id_grat(7) = gsn_add_shapefile_polylines(wks,plot(7),grat30_shp,pgresSH)
    id_eq(7) = gsn_add_shapefile_polylines(wks,plot(7),equator_shp,pgresSH)
    delete(resp)
  
    ; panel plot
    resP           = True
    resP@gsnPaperOrientation = "portrait"   
    resP@gsnPanelLeft  = 0.01 
    resP@gsnPanelRight = 0.99 
    resP@gsnPanelTop   = 0.99 
    resP@gsnPanelBottom = 0.01    
    resP@gsnPanelYWhiteSpacePercent = 5 ; 1 ; 2

    gsn_panel(wks, plot, (/2,4/), resP)

end do
end 

exit()