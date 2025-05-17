
; 2-up plot of scalar variables

mapfile = "snr_t2m_nz_e5land_1991-2020_ltm"
mapvar1 = "snr"
ncvar1 = "snr"
mapvar2 = "t2m"
ncvar2 = "t2m"
data_path = "/Users/bartlein/Dropbox/WorkCurrent/ERA5/data/ERA5-Land/ltm_monthly/"
map_path = "/Users/bartlein/Dropbox/WorkCurrent/ERA5/maps/nz/" + mapfile + "/png/"
title_01 = "Surface Net Radiation (Wm~S~-2~N~)"
title_02 = "2 m Air Temperature (~S~o~N~C~N~)"
title_0 = "Net Radiation & Temperature"
title_2 = "Data: ERA5-Land Reanalysis"
title_3 = "1991-2020 Long-Term Mean"

infile1 = "ERA5-Land_" + mapvar1 + "_monthly_199101-202012_ltm.nc"
infile2 = "ERA5-Land_" + mapvar2 + "_monthly_199101-202012_ltm.nc"

; shapefiles
land_dir = "/Users/bartlein/Dropbox/WorkCurrent/ERA5/shp_files/ne_10m_coastline/"
land_file = "ne_10m_coastline.shp"
land_shp = land_dir + land_file
print(land_shp)
lakes_dir = "/Users/bartlein/Dropbox/WorkCurrent/ERA5/shp_files/ne_10m_lakes/"
lakes_file = "ne_10m_lakes.shp"
lakes_shp = lakes_dir + lakes_file
print(lakes_shp)
; rivers_dir = "/Users/bartlein/Dropbox/WorkCurrent/ERA5/shp_files/ne_10m_rivers_lake_centerlines/"
; rivers_file = "ne_10m_rivers_lake_centerlines.shp"
; rivers_shp = rivers_dir + rivers_file
; print(rivers_shp)

; set color scale
clr_map = "ClimA8"

nm = 12
months = (/"Jan", "Feb", "Mar", "Apr","May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov","Dec" /)

begin

; open file and read data
f1 = addfile(data_path + infile1, "r")
pltvar1 = short2flt(f1->$mapvar1$(:,:,:))
pltvar1 = pltvar1 / 86400.0
lon = f1->longitude
lat = f1->latitude
time = f1->time
; pltvar&lon       = lon
; pltvar&lat       = lat
; pltvar&time      = time
pltvar1 = lonFlip(pltvar1)
printVarSummary(pltvar1)
printMinMax(pltvar1, 1)

; open file and read data
f2 = addfile(data_path + infile2, "r")
pltvar2 = short2flt(f2->$mapvar2$(:,:,:))
pltvar2 = pltvar2 - 273.15
lat = f2->latitude
time = f2->time
; pltvar&lon       = lon
; pltvar&lat       = lat
; pltvar&time      = time
pltvar2 = lonFlip(pltvar2)
printVarSummary(pltvar2)
printMinMax(pltvar2, 1)

; radiative fluxes
level1 = new((/13/),float)
;level1 = (/-20,-10,-5,-2,-1,-0.5,-0.1,0.1,0.5,1,2,5,10,20/)  
;level1 = (/-20,-10,-5,-2,-1,-0.5,0,0.5,1,2,5,10,20/)  
level1 = (/-400,-200,-100,-50,-20,-10,0,10,20,50,100,200,400/)
level1_begclr = 31
level1_endclr = 44 

; 2 m air temperature
level2 = new((/ 15 /), float)
level2 = (/-35, -30, -25, -20, -15, -10, -5, 0, 5, 10, 15, 20, 25, 30, 35 /)
level2_begclr = 238
level2_endclr = 253

; plotting resources

res                        = True  ; plot mods desired
plot = new(2, graphic)
id_land = new(2, graphic)
id_lakes = new(2, graphic)
; id_rivers = new(2, graphic)

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
res@mpGridLatSpacingF       = 2
res@mpGridLonSpacingF       = 2
res@mpGridLineColor         = "gray50"
res@mpGridLineThicknessF    = 0.5

res@mpPerimOn              = True      ; turn on perimeter 
res@mpPerimLineThicknessF  = 1
res@mpPerimDrawOrder        = "PostDraw" 

; projection
res@mpProjection           = "LambertEqualArea" 
res@mpCenterLatF    = -41.0
res@mpCenterLonF    = 173.0

; plot region
res@mpLimitMode            = "Corners"          ; choose range of map
res@mpLeftCornerLatF       = -47.5
res@mpLeftCornerLonF       = 164.0
res@mpRightCornerLatF      = -33.5
res@mpRightCornerLonF      = 180.0

; label bar --------------------------------------------------------------------
res@lbLabelBarOn            = True            
res@pmLabelBarHeightF       = 0.04
res@lbLabelFontHeightF      = 0.007 ; 0.00625
res@pmLabelBarOrthogonalPosF= -.001
res@lbBoxLineThicknessF     = 1
  
; res@gsnSpreadColorStart     = level0_begclr
; res@gsnSpreadColorEnd       = level0_endclr 
; res@cnLevels                = level0 

; titles---------------------------------------------------------------------- 
res@gsnLeftString           = ""
res@gsnRightString          = "" 
txres1     = True

; shapefile outlines -------------------------------------------------------
plres        = True
plres@gsLineColor = "black"
plres@gsLineThicknessF= 2.0 ; 0.5
pcres        = True
pcres@gsLineColor = "gray50"
pcres@gsLineThicknessF= 0.5
ppres        = True
ppres@gsLineColor = "gray50"
ppres@gsLineThicknessF= 0.5
prres        = True
prres@gsLineColor = "black"
prres@gsLineThicknessF= 1.0
pkres        = True
pkres@gsLineColor = "black"
pkres@gsLineThicknessF= 1.0
pkres@gsFillIndex = 1
pkres@gsFillColor = "blue"

do m = 0, nm-1

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
    txres1@txFont        = 21 
    txres1@txFontHeightF = 0.0175
    title_x_pos = 0.01
    title_y_pos = 0.86
    txres1@txJust        = "TopLeft" 
    gsn_text_ndc(wks,title_0,title_x_pos,title_y_pos,txres1)
    title_x_pos = 0.98
    title_y_pos = 0.86
    txres1@txJust        = "TopRight" 
    gsn_text_ndc(wks,title_1,title_x_pos,title_y_pos,txres1)  

    txres1@txFontHeightF = 0.008
    title_x_pos = 0.015  
    title_y_pos = 0.195
    txres1@txJust        = "BottomLeft" 
    gsn_text_ndc(wks,title_2,title_x_pos,title_y_pos,txres1)
    title_x_pos = 0.98
    txres1@txJust        = "BottomRight" 
    gsn_text_ndc(wks,title_3,title_x_pos,title_y_pos,txres1)

    ; plot(0) = gsn_csm_contour_map(wks, pltvar(m,:,:), res)
    ; ; plot(0) = gsn_csm_contour_map_overlay(wks,pltvar(m,:,:),pltvar(m,:,:),res,res2)
    ; id_lakes(0) = gsn_add_shapefile_polylines(wks,plot(0),lakes_shp,pkres)
    ; ; id_province(0) = gsn_add_shapefile_polylines(wks,plot(0),province_shp,ppres)
    ; ; id_country(0) = gsn_add_shapefile_polylines(wks,plot(0),country_shp,pcres)
    ; id_land(0) = gsn_add_shapefile_polylines(wks,plot(0),land_shp,plres)
    ; ; id_rivers(0) = gsn_add_shapefile_polylines(wks,plot(0),rivers_shp,prres)

    resp = res
    resp@txFontHeightF = 0.015
    title_x_pos = 0.012
    title_y_pos = 0.83
    resp@txJust        = "TopLeft" 
    gsn_text_ndc(wks,title_01,title_x_pos,title_y_pos,resp)
    resp@gsnSpreadColorStart     = level1_begclr
    resp@gsnSpreadColorEnd       = level1_endclr 
    resp@cnLevels                = level1 
    plot(0) = gsn_csm_contour_map(wks, pltvar1(m,:,:), resp)
    id_lakes(0) = gsn_add_shapefile_polylines(wks,plot(0),lakes_shp,pcres)
    id_land(0) = gsn_add_shapefile_polylines(wks,plot(0),land_shp,plres)
    delete(resp)

    resp = res
    resp@txFontHeightF = 0.015
    title_x_pos = 0.505
    title_y_pos = 0.83
    resp@txJust        = "TopLeft" 
    gsn_text_ndc(wks,title_02,title_x_pos,title_y_pos,resp)
    resp@gsnSpreadColorStart     = level2_begclr
    resp@gsnSpreadColorEnd       = level2_endclr 
    resp@cnLevels                = level2 
    plot(1) = gsn_csm_contour_map(wks, pltvar2(m,:,:), resp)
    id_lakes(1) = gsn_add_shapefile_polylines(wks,plot(1),lakes_shp,pcres)
    id_land(1) = gsn_add_shapefile_polylines(wks,plot(1),land_shp,plres)
    delete(resp)

    ; panel plot
    resP           = True
    resP@gsnPaperOrientation = "portrait"   
    resP@gsnPanelLeft  = 0.01 
    resP@gsnPanelRight = 0.99 
    resP@gsnPanelTop   = 0.96 
    resP@gsnPanelBottom = 0.05    ; panel TextOnly 
    resP@gsnPanelYWhiteSpacePercent = 0 ; 2
    resP@gsnPanelxWhiteSpacePercent = 1 ; 2

    gsn_panel(wks, plot, (/1,2/), resP)

end do
end 

exit()