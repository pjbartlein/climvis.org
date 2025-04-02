; 1-up plot of a scalar variable

mapfile = "ds2_globe_1991-2020_ltm"
ncvar = "ds"
mapvar = "ds2"
data_path = "/Users/bartlein/Dropbox/WorkCurrent/ERA5/data/ERA5-Atm/ltm_monthly/"
map_path = "/Users/bartlein/Dropbox/WorkCurrent/ERA5/maps/globe/" + mapfile + "/png/"
mask_path = "/Users/bartlein/Dropbox/WorkCurrent/ERA5/data/ERA5-Atm/fixed/"
maskfile = "ERA5_land-sea_mask.nc"
title_0 = "~F33~D~F21~S = Rain + Snowmelt - Evaporation - Runoff (mm  d~S~-1~N~)" 
title_2 = "Data: ERA5 Reanalysis"
title_3 = "1991-2020 Long-Term Mean"

infile = "ERA5_" + mapvar + "_monthly_199101-202012_ltm.nc"

; shapefiles
land_dir = "/Users/bartlein/Dropbox/WorkCurrent/ERA5/shp_files/"
land_file = "ERA5-Atm_land.shp"
land_shp = land_dir + land_file
print(land_shp)
country_dir = "/Users/bartlein/Dropbox/WorkCurrent/ERA5/shp_files/ne_110m_admin_0_countries/"
country_file = "ne_110m_admin_0_countries.shp"
country_shp = country_dir + country_file
print(country_shp)

; set color scale
clr_map = "ClimA7"

nm = 12
months = (/"Jan", "Feb", "Mar", "Apr","May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov","Dec" /)

begin

; open file and read data
f0 = addfile(data_path + infile, "r")
pltvar = short2flt(f0->$ncvar$(:,:,:))
pltvar = pltvar * 1000.0 * -1.0
lon = f0->longitude
lat = f0->latitude
time = f0->time
pltvar_FillValue = pltvar@_FillValue
print(pltvar_FillValue)
pltvar = lonFlip(pltvar)
printVarSummary(pltvar)
printMinMax(pltvar, 1)

; landmask
f1 = addfile(mask_path + maskfile, "r")
maskvar = short2flt(f1->lsm(:,:,:))
maskvar = lonFlip(maskvar)
printVarSummary(maskvar)
maskvar2 = new((/dimsizes(pltvar)/), float)
printVarSummary(maskvar2)

do i = 0, 11
    maskvar2(i,:,:) = maskvar(0,:,:)
end do

pltvar = where(maskvar2 .lt. 0.5, pltvar_FillValue, pltvar)

; dS
level0 = new((/ 11 /), float)
level0 = (/ -10, -5, -2, -1, -0.5, 0.0, 0.5, 1, 2, 5, 10/)
level0_begclr = 27 
level0_endclr = 16 

; plotting resources
res                        = True  ; plot mods desired
plot = new(1, graphic)
id_land = new(1, graphic)
id_country = new(1, graphic)

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
res@mpGridAndLimbOn        = True      ; Turn on lat/lon grid
res@mpPerimOn              = False      ; turn off perimeter  
res@mpProjection           = "Robinson"       ; choose map projection

res@mpLimbLineThicknessF    = 2
res@mpGridLatSpacingF       = 30
res@mpGridLonSpacingF       = 30 
res@mpGridLineColor         = "gray50"
res@mpGridLineThicknessF    = 1

res@mpLimitMode             = "LatLon" ; use lat/lon coordinates to limit area
res@mpMinLatF               =  -90. 
res@mpMaxLatF               =   90. 
res@mpMinLonF               =  -180. 
res@mpMaxLonF               =   180.

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

; 0 contour line for temperature
res2                      = True
res2@cnLevelSelectionMode = "ManualLevels"     ; set manual contour levels
res2@cnMinLevelValF       = -100.              ; set min contour level
res2@cnMaxLevelValF       =  100.              ; set max contour level
res2@cnLevelSpacingF      =  100.              ; set contour spacing
res2@cnLineLabelsOn       = False
res2@cnInfoLabelOn        = False
res2@cnLineColor          = "magenta"
res2@gsnContourZeroLineThicknessF = 1.    ; doubles thickness of zero contour
res2@tiMainString         = ""
res2@cnSmoothingOn        = True
res2@cnSmoothingTensionF  = -0.01

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
    txres1@txFont        = 21 
    txres1@txFontHeightF = 0.0175
    title_x_pos = 0.01
    title_y_pos = 0.8
    txres1@txJust        = "CenterLeft" 
    gsn_text_ndc(wks,title_0,title_x_pos,title_y_pos,txres1)
    title_y_pos = 0.81
    title_x_pos = 0.99
    txres1@txJust        = "TopRight" 
    gsn_text_ndc(wks,title_1,title_x_pos,title_y_pos,txres1)  

    txres1@txFontHeightF = 0.010
    title_x_pos = 0.01
    title_y_pos = 0.22
    txres1@txJust        = "BottomLeft" 
    gsn_text_ndc(wks,title_2,title_x_pos,title_y_pos,txres1)
    title_x_pos = 0.99
    txres1@txJust        = "BottomRight" 
    gsn_text_ndc(wks,title_3,title_x_pos,title_y_pos,txres1)

    plot(0) = gsn_csm_contour_map(wks, pltvar(m,:,:), res)
    ; plot(0) = gsn_csm_contour_map_overlay(wks,pltvar(m,:,:),pltvar(m,:,:),res,res2)
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

end do
end 

exit()