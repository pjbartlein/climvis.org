; 1-up plot of a scalar variable

mapvar = "sde"
mapstr = "_nz_e5land_1991-2020_ltm"
data_path = "/Users/bartlein/Dropbox/WorkCurrent/ERA5/data/ERA5-Land/derived/ltm_monthly/"
map_path = "/Users/bartlein/Dropbox/WorkCurrent/ERA5/content/anim/ltm/nz/" + mapvar + mapstr + "/png/"
mask_path = "/Users/bartlein/Dropbox/WorkCurrent/ERA5/data/ERA5-Land_fixed/"
maskfile = "ERA5-Land_lsm.nc"
title_0 = "Snowdepth (mm water equivalent)"
title_2 = "Data: ERA5-Land Reanalysis"
title_3 = "1991-2020 Long-Term Mean"

infile = "ERA5-Land_" + mapvar + "_monthly_199101-202012_ltm.nc" 

; shapefiles
land_dir = "/Users/bartlein/Dropbox/WorkCurrent/ERA5/shp_files/ne_10m_coastline/"
land_file = "ne_10m_coastline.shp"
land_shp = land_dir + land_file
print(land_shp)
lakes_dir = "/Users/bartlein/Dropbox/WorkCurrent/ERA5/shp_files/ne_10m_lakes/"
lakes_file = "ne_10m_lakes.shp"
lakes_shp = lakes_dir + lakes_file
print(lakes_shp)

; set color scale
clr_map = "ClimA8"

nm = 12
months = (/"Jan", "Feb", "Mar", "Apr","May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov","Dec" /)

begin

; open file and read data
f1 = addfile(data_path + infile, "r")
pltvar = short2flt(f1->$mapvar$(:,:,:))
pltvar = pltvar * 1000.0
pltvar = where(pltvar .le. 0.0, -0.00001, pltvar)
lon = f1->longitude
lat = f1->latitude
time = f1->time
; pltvar&lon       = lon
; pltvar&lat       = lat
; pltvar&time      = time
pltvar = lonFlip(pltvar)
printVarSummary(pltvar)
printMinMax(pltvar, 1)

; snow depth
level0 = new((/ 6 /), float)
level0 = (/ 0.0, 10, 20, 50, 100, 200/)
level0_begclr = 115 ; 22 ; 91 ; 52
level0_endclr = 109 ; 27 ; 86 ; 46


; plotting resources

res                        = True  ; plot mods desired
plot = new(1, graphic)
id_land = new(1, graphic)
id_country = new(1, graphic)
id_lakes = new(1, graphic)

; gsn high-level interfaces ---------------------------------------------------
res@gsnDraw                = False              ; don't draw
res@gsnFrame               = False              ; don't advance frame
; res@gsnSpreadColors        = True               ; use total colormap

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
res@mpCenterLatF    = -41
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
res@lbLabelFontHeightF      = 0.00625
res@pmLabelBarOrthogonalPosF= -.001
res@lbBoxLineThicknessF     = 2
  
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
plres@gsLineThicknessF= 1
pcres        = True
pcres@gsLineColor = "gray50"
pcres@gsLineThicknessF= 0.5
pkres        = True
pkres@gsLineColor = "black"
pkres@gsLineThicknessF= 1.0
pkres@gsFillIndex = 1
pkres@gsFillColor = "blue"

; ; 0 contour line for temperature
; res2                      = True
; res2@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
; res2@cnMinLevelValF       = -100.              ; set min contour level
; res2@cnMaxLevelValF       =  100.              ; set max contour level
; res2@cnLevelSpacingF      =  100.              ; set contour spacing
; res2@cnLineLabelsOn       = False
; res2@cnInfoLabelOn        = False
; res2@cnLineColor          = "magenta"
; res2@gsnContourZeroLineThicknessF = 1.    ; doubles thickness of zero contour
; res2@tiMainString         = ""
; res2@cnSmoothingOn        = True
; res2@cnSmoothingTensionF  = -0.01

do m = 0, nm-1

    ; output format ----------------------------------------------------------------
    ; wks_type = "pdf"
    ; wks_type@wkOrientation = "portrait"
    wks_type = "png"
    wks_type@wkWidth = 800
    wks_type@wkHeight = 800

    monthstring  = sprinti("%0.2i", m+1)
    mapfile = mapvar + mapstr + "_" + monthstring
    wks  = gsn_open_wks (wks_type, map_path + mapfile)
    gsn_define_colormap(wks,clr_map)
    ; drawNDCGrid(wks)                   ; Draw an NDC grid for reference

    title_1         = months(m)

    ; plot titles
    txres1@txFont        = 21 
    txres1@txFontHeightF = 0.022 ;0.0175
    title_x_pos = 0.145
    title_y_pos = 0.9775
    txres1@txJust        = "TopLeft" 
    gsn_text_ndc(wks,title_0,title_x_pos,title_y_pos,txres1)
    title_x_pos = 0.855
    title_y_pos = 0.9775
    txres1@txJust        = "TopRight" 
    gsn_text_ndc(wks,title_1,title_x_pos,title_y_pos,txres1)  

    txres1@txFontHeightF = 0.012 ; 0.010
    title_x_pos = 0.145  
    title_y_pos = 0.045
    txres1@txJust        = "BottomLeft" 
    gsn_text_ndc(wks,title_2,title_x_pos,title_y_pos,txres1)
    title_x_pos = 0.855
    txres1@txJust        = "BottomRight" 
    gsn_text_ndc(wks,title_3,title_x_pos,title_y_pos,txres1)

    plot(0) = gsn_csm_contour_map(wks, pltvar(m,:,:), res)
    ; plot(0) = gsn_csm_contour_map_overlay(wks,pltvar(m,:,:),pltvar(m,:,:),res,res2)
    id_lakes(0) = gsn_add_shapefile_polylines(wks,plot(0),lakes_shp,pkres)
    id_land(0) = gsn_add_shapefile_polylines(wks,plot(0),land_shp,plres)

    ; panel plot
    resP           = True
    resP@gsnPaperOrientation = "portrait"   
    resP@gsnPanelLeft  = 0.01 
    resP@gsnPanelRight = 0.99 
    resP@gsnPanelTop   = 0.96 
    resP@gsnPanelBottom = 0.05    ; panel TextOnly 
    ; txres1     = True
    ; txres1     = True
    ; txres1@txFontHeightF = 0.015
    ; txres1@txFont        = 21 ; 0.1  
    ; resP@txFont             = 21
    resP@gsnPanelYWhiteSpacePercent = 1 ; 2
    ; resP@txFontHeightF = 0.0

    gsn_panel(wks, plot, (/1,1/), resP)

end do
end 

exit()