; 12-panel maps of monthly data 

mapvar = "msl"
panel_type = "4mon"

; cd up to /climvis-figs, then into /data/ERA5-Atm/ltm_monthly/ 
data_path = "../../../data/ERA5-Atm/ltm_monthly/"  
map_path = "../../../content/maps/ltm/global/" + mapvar + "_globe_1991-2020_ltm_"

title_0 = "Mean Sea-Level Pressure (hPa)"
title_2 = "Data: ERA5 Reanalysis"
title_3 = "1991-2020 Long-Term Mean"

infile = "ERA5_" + mapvar + "_monthly_199101-202012_ltm.nc"

; shapefiles
land_dir = "../../../shp_files/"
land_file = "ERA5-Atm_land.shp" ; calculated in R
land_shp = land_dir + land_file
print(land_shp)
country_dir = "../../../shp_files/ne_110m_admin_0_countries/"
country_file = "ne_110m_admin_0_countries.shp"
country_shp = country_dir + country_file
print(country_shp)

nm = 12
months = (/"Jan", "Feb", "Mar", "Apr","May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" /)

begin

; open file and read data
f1 = addfile(data_path + infile, "r")
pltvar = short2flt(f1->$mapvar$(:,:,:))
pltvar = pltvar /100.0
lon = f1->longitude
lat = f1->latitude
time = f1->time

pltvar = lonFlip(pltvar)
printVarSummary(pltvar)
printMinMax(pltvar, 1)

; set color scale
clr_map = "ClimA8"

; MSLP 
level0 = new((/ 11 /),float)
; level_prmsl = (/ 960., 970., 980., 990., 1000., 1010., 1020., 1030., 1040./)
level0 = (/ 985., 990., 995., 1000., 1005., 1010., 1015., 1020., 1025., 1030., 1035./)
level0_begclr = 74
level0_endclr = 85

; output format ----------------------------------------------------------------
; wks_type = "pdf"
; wks_type@wkOrientation = "portrait"
wks_type = "png"
wks_type@wkWidth = 1200
wks_type@wkHeight = 1200

wks  = gsn_open_wks (wks_type, map_path + panel_type)
; drawNDCGrid(wks)               ; Draw an NDC grid for reference.

; plot panels
plot = new(4,graphic)
id_land = new(4, graphic)
id_country = new(4, graphic)

; plotting resources -----------------------------------------------------------
res = True 

; set colormap -----------------------------------------------------------------
gsn_define_colormap(wks,clr_map)
res@gsnSpreadColorStart     = level0_begclr
res@gsnSpreadColorEnd       = level0_endclr 
res@cnLevels                = level0 

; gsn high-level interfaces ---------------------------------------------------
res@gsnDraw                = False              ; don't draw
res@gsnFrame               = False              ; don't advance frame
res@gsnSpreadColors        = True               ; use total colormap
 
; contour ----------------------------------------------------------------------
;res@gsnScalarContour      = True               ; contours desired
res@mpGridLineColor        = "transparent"      ; trick ncl into drawing only perimeter
res@cnFillOn               = True               ; color fill  
res@cnLinesOn              = False              ; no contour lines
res@cnLineLabelsOn         = False              ; no contour labels
res@cnInfoLabelOn          = False              ; no contour info label
res@cnFillMode             = "CellFill"; "RasterFill" or "CellFill"
res@cnLevelSelectionMode   = "ExplicitLevels" ;

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
res@lbLabelBarOn            = False            
res@pmLabelBarHeightF       = 0.04
res@lbLabelFontHeightF      = 0.00625
res@pmLabelBarOrthogonalPosF= -.001
res@lbBoxLineThicknessF     = 0.5 

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

; plot()  ----------------------------------------------------------------------
res@gsnRightStringFontHeightF   = 0.0225
res@gsnLeftStringFontHeightF    = 0.0225    
res@gsnLeftStringOrthogonalPosF = -0.07
res@gsnLeftStringParallelPosF = 0.02
res@gsnRightString          = ""            

; plot(0): Jan 
res@gsnLeftString           = months(00) 
plot(0) = gsn_csm_contour_map(wks,pltvar(00,:,:),res)  
id_country(0) = gsn_add_shapefile_polylines(wks,plot(0),country_shp,pcres)
id_land(0) = gsn_add_shapefile_polylines(wks,plot(0),land_shp,plres)

; plot(1): Apr 
res@gsnLeftString           = months(03) 
plot(1) = gsn_csm_contour_map(wks,pltvar(03,:,:),res)  
id_country(1) = gsn_add_shapefile_polylines(wks,plot(1),country_shp,pcres)
id_land(1) = gsn_add_shapefile_polylines(wks,plot(1),land_shp,plres)

; plot(2): Jul 
res@gsnLeftString           = months(06) 
plot(2) = gsn_csm_contour_map(wks,pltvar(06,:,:),res)  
id_country(2) = gsn_add_shapefile_polylines(wks,plot(2),country_shp,pcres)
id_land(2) = gsn_add_shapefile_polylines(wks,plot(2),land_shp,plres)

; plot(3): Oct 
res@gsnLeftString           = months(09) 
plot(3) = gsn_csm_contour_map(wks,pltvar(09,:,:),res)  
id_country(3) = gsn_add_shapefile_polylines(wks,plot(3),country_shp,pcres)
id_land(3) = gsn_add_shapefile_polylines(wks,plot(3),land_shp,plres)


; titles ------------------------------------------------------------------------
txres1     = True
txres1@txFontHeightF = 0.015
txres1@txFont        = 21

; plot titles
txres1@txFont        = 21 
txres1@txFontHeightF = 0.0175
title_x_pos = 0.02
title_y_pos = 0.98
txres1@txJust        = "CenterLeft" 
gsn_text_ndc(wks,title_0,title_x_pos,title_y_pos,txres1)
; title_x_pos = 0.98
; title_y_pos = 0.885
; txres1@txJust        = "TopRight" 
; gsn_text_ndc(wks,title_1,title_x_pos,title_y_pos,txres1)  

txres1@txFontHeightF = 0.010
title_x_pos = 0.01
title_y_pos = 0.425
txres1@txJust        = "BottomLeft" 
gsn_text_ndc(wks,title_2,title_x_pos,title_y_pos,txres1)
title_x_pos = 0.94
txres1@txJust        = "BottomRight" 
gsn_text_ndc(wks,title_3,title_x_pos,title_y_pos,txres1)

; plot panels ------------------------------------------------------------------
resP                        = True
resP@gsnPaperOrientation    = "portrait"   
resP@gsnPanelLeft           = 0.02
resP@gsnPanelRight          = 0.95 
resP@gsnPanelTop            = 0.99
resP@gsnPanelBottom         = 0.1  
resP@txFont                 = 21
resP@gsnPanelYWhiteSpacePercent = 1 ; 2

; single label bar -------------------------------------------------------------
resP@gsnPanelLabelBar       = True 
resP@lbAutoManage           = False
resP@lbLabelFont            = 21
resP@lbLabelFontHeightF     = 0.01
resP@gsnPanelBottom         = 0.40
resP@lbLabelAutoStride      = True
resP@pmLabelBarOrthogonalPosF  = 0.0075
resP@lbBoxLineThicknessF    = 2
resP@pmLabelBarWidthF       = 0.8    
resP@pmLabelBarHeightF      = 0.06     

; plot the panels --------------------------------------------------------------
gsn_panel(wks, plot, (/2,2/), resP)

end
exit()  
