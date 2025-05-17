; 1-up plot of a scalar variable

mapvar = "t2m_abs_max"
mapvar2 = "t2m_max"
data_path = "/Users/bartlein/Dropbox/WorkCurrent/ERA5/data/ERA5-Land/derived/monthly_max_min/"
map_path = "/Users/bartlein/Dropbox/WorkCurrent/ERA5/maps/globe/" + mapvar + "_globe_1991-2020_ltmax/png/"
mask_path = "/Users/bartlein/Dropbox/WorkCurrent/ERA5/data/ERA5-Land_fixed/"
maskfile = "ERA5-Land_lsm.nc"
title_0 = "Absolute Daily Maximum 2-m Air Temperature (~S~o~N~C~N~)"
title_2 = "Data: ERA5-Land Reanalysis (Hourly Data)"
title_3 = "1991-2020 Long-Term Maximum"

infile = "ERA5-Land_" + mapvar2 + "_199101-202012_ltmax.nc" 

; shapefiles
land_dir = "/Users/bartlein/Dropbox/WorkCurrent/ERA5/shp_files/"
land_file = "ERA5-Atm_land.shp"
land_shp = land_dir + land_file
print(land_shp)
country_dir = "/Users/bartlein/Dropbox/WorkCurrent/ERA5/shp_files/ne_110m_admin_0_countries/"
country_file = "ne_110m_admin_0_countries.shp"
country_shp = country_dir + country_file
print(country_shp)

nm = 12
months = (/"Jan", "Feb", "Mar", "Apr","May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov","Dec" /)

begin

; open file and read data
f1 = addfile(data_path + infile, "r")
pltvar = short2flt(f1->$mapvar$(:,:,:))
; pltvar@_FillValue = -32767
pltvar_FillValue = pltvar@_FillValue
pltvar = pltvar ; - 273.15
lon = f1->longitude
lat = f1->latitude
time = f1->time
; pltvar&lon       = lon
; pltvar&lat       = lat
; pltvar&time      = time
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

; air temperature
; color table 
; clr_tmp = (/ \
; "(/1.000, 0.698, 1.000/)", "(/0.898, 0.494, 0.898/)", "(/0.847, 0.404, 0.847/)", \
; "(/0.800, 0.318, 0.800/)", "(/0.749, 0.243, 0.749/)", "(/0.698, 0.173, 0.698/)", \
; "(/0.600, 0.059, 0.600/)", "(/0.392, 0.000, 0.588/)", "(/0.000, 0.000, 0.749/)", \
; "(/0.141, 0.000, 0.847/)", "(/0.094, 0.110, 0.969/)", "(/0.157, 0.341, 1.000/)", \
; "(/0.239, 0.529, 1.000/)", "(/0.337, 0.690, 1.000/)", "(/0.459, 0.827, 1.000/)", \
; "(/0.600, 0.918, 1.000/)", "(/0.737, 0.976, 1.000/)", "(/1.000, 0.945, 0.737/)", \
; "(/1.000, 0.839, 0.600/)", "(/1.000, 0.675, 0.459/)", "(/1.000, 0.471, 0.337/)", \
; "(/1.000, 0.239, 0.239/)", "(/0.969, 0.153, 0.208/)", "(/0.847, 0.082, 0.184/)", \
; "(/0.647, 0.000, 0.129/)", "(/0.698, 0.173, 0.173/)", "(/0.800, 0.318, 0.318/)", \
; "(/0.898, 0.494, 0.494/)" /) 

clr_tmp = (/ \
"(/1.000, 0.698, 1.000/)", "(/0.898, 0.494, 0.898/)", "(/0.847, 0.404, 0.847/)", \
"(/0.800, 0.318, 0.800/)", "(/0.749, 0.243, 0.749/)", "(/0.698, 0.173, 0.698/)", \
"(/0.600, 0.059, 0.600/)", "(/0.392, 0.000, 0.588/)", "(/0.000, 0.000, 0.749/)", \
"(/0.141, 0.000, 0.847/)", "(/0.094, 0.110, 0.969/)", "(/0.157, 0.341, 1.000/)", \
"(/0.239, 0.529, 1.000/)", "(/0.337, 0.690, 1.000/)", "(/0.459, 0.827, 1.000/)", \
"(/0.600, 0.918, 1.000/)", "(/0.737, 0.976, 1.000/)", "(/1.000, 0.945, 0.737/)", \
"(/1.000, 0.839, 0.600/)", "(/1.000, 0.675, 0.459/)", "(/1.000, 0.471, 0.337/)", \
"(/1.000, 0.239, 0.239/)", "(/0.969, 0.153, 0.208/)", "(/0.847, 0.082, 0.184/)", \
"(/0.647, 0.000, 0.129/)", "(/0.800, 0.318, 0.318/)", "(/0.898, 0.494, 0.494/)",  \
"(/1.000, 0.698, 0.698/)" /) 

; levels
level_tmp = new((/ 27 /), float)
level_tmp = (/-80, -75, -70, -65, -60, -55, -50, -45, -40, -35, -30, -25, -20, -15, \
                 -10, -5, 0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50 /)

; plotting resources

res                        = True  ; plot mods desired
plot = new(1, graphic)
id_land = new(1, graphic)
id_country = new(1, graphic)

; gsn high-level interfaces ---------------------------------------------------
res@gsnDraw                = False              ; don't draw
res@gsnFrame               = False              ; don't advance frame
; res@gsnSpreadColors        = True               ; use total colormap

res@cnFillPalette = clr_tmp
res@cnLevels                = level_tmp 
 
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

; res@mpGeophysicalLineColor = "black"    ; make outlines thicker
; res@mpGeophysicalLineThicknessF = 1    ; make outlines thicker
; res@mpDataBaseVersion      = "MediumRes"     ; choose new outline database
; res@mpDataSetName           = "Earth..2"
; res@mpOutlineBoundarySets   = "National"
; res@mpNationalLineColor     = "gray50"

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

do m = 0, nm-1

    ; output format ----------------------------------------------------------------
    ; wks_type = "pdf"
    ; wks_type@wkOrientation = "portrait"
    wks_type = "png"
    wks_type@wkWidth = 1200
    wks_type@wkHeight = 1200

    monthstring  = sprinti("%0.2i", m+1)
    mapfile = mapvar + "_gl_" + monthstring
    wks  = gsn_open_wks (wks_type, map_path + mapfile)
    ; gsn_define_colormap(wks,clr_map)
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