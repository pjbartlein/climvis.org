; 1-up plot of a scalar variable

map_file = "ERA5-Land_elev_conus_clr"
ncvar = "elevation"
mapvar = "elevation"
data_path = "../../data/ERA5-Land/fixed/"
map_path = "../../content/anim/ltm/conus/"
title_0 = "Elevation (m)"
title_2 = "Data: ERA5-Land Reanalysis"
title_3 = "1991-2020 Long-Term Mean"

infile = "ERA5-Land_elev.nc"
maskfile = "ERA5-Land_lsm.nc"

; shapefiles
land_dir = "../../shp_files/ne_50m_coastline/"
land_file = "ne_50m_coastline.shp"
land_shp = land_dir + land_file
print(land_shp)
country_dir = "../../shp_files/ne_50m_admin_0_countries/"
country_file = "ne_50m_admin_0_countries.shp"
country_shp = country_dir + country_file
print(country_shp)
province_dir = "../../shp_files/ne_50m_admin_1_states_provinces/"
province_file = "ne_50m_admin_1_states_provinces.shp"
province_shp = province_dir + province_file
print(province_shp)
lakes_dir = "../../shp_files/ne_50m_lakes/"
lakes_file = "ne_50m_lakes.shp"
lakes_shp = lakes_dir + lakes_file
print(lakes_shp)

; set color scale
clr_map = "ClimA7"


begin

; open files and read data
f0 = addfile(data_path + maskfile, "r")
maskvar = f0->lsm(:,:,:)
f1 = addfile(data_path + infile, "r")
pltvar = short2flt(f1->$ncvar$(:,:,:))
pltvar = where(maskvar .le. 0.5, -0.00001, pltvar)
lon = f1->longitude
lat = f1->latitude
time = f1->time
pltvar = lonFlip(pltvar)
printVarSummary(pltvar)
printMinMax(pltvar, 1)

; elevation
level0 = new((/ 13 /),float)
; level0 = (/0, 50, 100, 200, 400, 600, 800, 1000, 1200, 1400, 1600, 1800, 2000, 2400, 2800, 3000 /) ; 1
level0 = (/0, 100, 200, 300, 400, 500, 750, 1000, 1250, 1500, 2000, 2500, 3000 /) ; 13
level0_begclr = 132 ; 170 ; 
level0_endclr = 151 ; 183 ; 

; plotting resources

res                        = True  ; plot mods desired
plot = new(1, graphic)
id_land = new(1, graphic)
id_country = new(1, graphic)
id_province = new(1, graphic)
id_lakes = new(1, graphic)

; gsn high-level interfaces ---------------------------------------------------
res@gsnDraw                = False              ; don't draw
res@gsnFrame               = False              ; don't advance frame
res@gsnSpreadColors        = True               ; use total colormap
 
; contour ----------------------------------------------------------------------
;res@gsnScalarContour      = True               ; contours desired
; res@mpGridLineColor        = "transparent"      ; trick ncl into drawing perimeter
res@cnInfoLabelOn          = False              ; turn off cn info label
res@cnFillOn               = True               ; color fill  
res@cnLinesOn              = False              ; no contour lines
res@cnLineLabelsOn         = False              ; no contour labels
res@cnInfoLabelOn          = False              ; no contour info label
res@cnFillMode             = "CellFill"; "RasterFill" or "CellFill"
res@cnLevelSelectionMode   = "ExplicitLevels" ;
res@cnMissingValFillColor  = "gray80" 

; maps -------------------------------------------------------------------------
; res@mpOutlineOn           = True
; res@mpOutlineBoundarySets   = "AllBoundaries" ; AllBoundaries"
; res@mpOutlineSpecifiers     = (/"Canada:provinces", "United States:states"/)
; res@mpDataBaseVersion       = "MediumRes" 
; res@mpDataSetName           = "Earth..2"
; res@mpGeophysicalLineColor = "black"
; res@mpGeophysicalLineThicknessF = 1.5
; res@mpProvincialLineColor = "gray50"
; res@mpProvincialLineThicknessF = 0.5
; ; res@mpCountyLineColor    = "gray60"

res@mpFillOn               = False       ; turn off map fill
res@mpOutlineOn            = False     ; continental outline
res@mpFillOn               = False       ; turn off map fill
res@mpGridAndLimbOn        = True      ; Turn on lat/lon grid  

res@mpGridAndLimbDrawOrder = "PostDraw"
res@mpGridAndLimbOn        = True      ; Turn on lat/lon grid
res@mpGridLatSpacingF       = 10
res@mpGridLonSpacingF       = 10 
res@mpGridLineColor         = "gray50"
res@mpGridLineThicknessF    = 0.5

res@mpPerimOn              = True      ; turn on perimeter 
res@mpPerimLineThicknessF  = 1
res@mpPerimDrawOrder        = "PostDraw" 

; projection
res@mpProjection           = "LambertEqualArea" 
res@mpCenterLatF    = 50.0
res@mpCenterLonF    = -100.0

; plot region
res@mpLimitMode            = "Corners"          ; choose range of map
res@mpLeftCornerLatF       = 22.873336
res@mpLeftCornerLonF       = -120.418092
res@mpRightCornerLatF      = 48.231397
res@mpRightCornerLonF      = -62.674409

; label bar --------------------------------------------------------------------
res@lbLabelBarOn            = True            
res@pmLabelBarHeightF       = 0.04
res@lbLabelFontHeightF      = 0.007 ; 0.00625
res@pmLabelBarOrthogonalPosF= -.001
res@lbBoxLineThicknessF     = 1
  
res@gsnSpreadColorStart     = level0_begclr
res@gsnSpreadColorEnd       = level0_endclr 
res@cnLevels                = level0 

; titles---------------------------------------------------------------------- 
res@gsnLeftString           = ""
res@gsnRightString          = "" 
txres1     = True

; shapefile outlines -------------------------------------------------------
plres        = True
plres@gsLineColor = "black"
plres@gsLineThicknessF= 0.5
pcres        = True
pcres@gsLineColor = "gray50"
pcres@gsLineThicknessF= 0.5
ppres        = True
ppres@gsLineColor = "gray50"
ppres@gsLineThicknessF= 0.5
pkres        = True
pkres@gsLineColor = "gray50"
pkres@gsLineThicknessF= 0.5

    m = 0

    ; output format ----------------------------------------------------------------
    wks_type = "pdf"
    wks_type@wkOrientation = "portrait"
    ; wks_type = "png"
    ; wks_type@wkWidth = 800
    ; wks_type@wkHeight = 800

    wks  = gsn_open_wks (wks_type, map_path + map_file + ".png")
    ; print("     map_out_file: " map_path + map_file + ".png")
    gsn_define_colormap(wks,clr_map)
    ; drawNDCGrid(wks)                   ; Draw an NDC grid for reference

    ; title_1         = months(m)

    ; plot titles
    txres1@txFont        = 21 
    txres1@txFontHeightF = 0.022 ;0.0175
    title_x_pos = 0.02
    title_y_pos = 0.87
    txres1@txJust        = "CenterLeft" 
    gsn_text_ndc(wks,title_0,title_x_pos,title_y_pos,txres1)
    ; title_x_pos = 0.98
    ; title_y_pos = 0.885
    ; txres1@txJust        = "TopRight" 
    ; gsn_text_ndc(wks,title_1,title_x_pos,title_y_pos,txres1)  

    txres1@txFontHeightF = 0.012 ; 0.010
    title_x_pos = 0.02
    title_y_pos = 0.135
    txres1@txJust        = "BottomLeft" 
    gsn_text_ndc(wks,title_2,title_x_pos,title_y_pos,txres1)
    title_x_pos = 0.98
    txres1@txJust        = "BottomRight" 
    gsn_text_ndc(wks,title_3,title_x_pos,title_y_pos,txres1)

    plot(0) = gsn_csm_contour_map(wks, pltvar(m,:,:), res)
    ; plot(0) = gsn_csm_contour_map_overlay(wks,pltvar(m,:,:),pltvar(m,:,:),res,res2)
    id_lakes(0) = gsn_add_shapefile_polylines(wks,plot(0),lakes_shp,pkres)
    id_province(0) = gsn_add_shapefile_polylines(wks,plot(0),province_shp,ppres)
    id_country(0) = gsn_add_shapefile_polylines(wks,plot(0),country_shp,pcres)
    id_land(0) = gsn_add_shapefile_polylines(wks,plot(0),land_shp,plres)

    ; panel plot
    resP           = True
    resP@gsnPaperOrientation = "portrait"   
    resP@gsnPanelLeft  = 0.01 
    resP@gsnPanelRight = 0.99 
    resP@gsnPanelTop   = 0.99 
    resP@gsnPanelBottom = 0.01    ; panel TextOnly 
    ; txres1     = True
    ; txres1@txFontHeightF = 0.015
    ; txres1@txFont        = 21 ; 0.1  
    ; resP@txFont             = 21
    resP@gsnPanelYWhiteSpacePercent = 1 ; 2
    ; resP@txFontHeightF = 0.0

    gsn_panel(wks, plot, (/1,1/), resP)

end 

exit()