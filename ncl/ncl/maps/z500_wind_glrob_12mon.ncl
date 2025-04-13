; 12-panel maps of monthly data 

mapfile = "z500_wind_globe_1991-2020_ltm"
mapvar = "z500"
ncvar = "z"
umapvar = "u10"
vmapvar = "v10"
uvecvar = "u10"
vvecvar = "v10"
panel_type ="12mon"

; cd up to /climvis-figs, then into /data/ERA5-Atm/ltm_monthly/ 
data_path = "../../../data/ERA5-Atm/ltm_monthly/"  
map_path = "../../../content/maps/ltm/global/" + mapfile + "_" + panel_type

title_0 = "500 hPa Height (m) & Winds (m s~S~-1~N~)"
title_2 = "Data: ERA5 Reanalysis"
title_3 = "1991-2020 Long-Term Mean"

infile = "ERA5_" + mapvar + "_monthly_199101-202012_ltm.nc"
uinfile = "ERA5_" + uvecvar + "_monthly_199101-202012_ltm.nc"
vinfile = "ERA5_" + vvecvar + "_monthly_199101-202012_ltm.nc"
print(infile)

; shapefiles
land_dir = "../../../shp_files/"
land_file = "ERA5-Atm_land.shp" ; calculated in R
land_shp = land_dir + land_file
print(land_shp)
country_dir = "../../../shp_files/ne_110m_admin_0_countries/"
country_file = "ne_110m_admin_0_countries.shp"
country_shp = country_dir + country_file
print(country_shp)

; set color scale
clr_map = "ClimA7"

nm = 12
months = (/"Jan", "Feb", "Mar", "Apr","May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" /)

begin

; open file and read data
f1 = addfile(data_path + infile, "r")
pltvar = short2flt(f1->$ncvar$(:,:,:))
pltvar = pltvar / 9.8
lon = f1->longitude
lat = f1->latitude
time = f1->time
; pltvar&lon       = lon
; pltvar&lat       = lat
; pltvar&time      = time
pltvar = lonFlip(pltvar)
printVarSummary(pltvar)
printMinMax(pltvar, 1)
f2 = addfile(data_path + uinfile, "r")
u = short2flt(f2->$uvecvar$(:,:,:))
u = lonFlip(u)
f3 = addfile(data_path + vinfile, "r")
v = short2flt(f3->$vvecvar$(:,:,:))
v = lonFlip(v)

; hgt500
level0 = new((/11/),float)
; level0 = (/5100, 5200, 5300, 5400, 5500, 5600, 5700, 5800, 5900, 6000, 6100 /)
level0 = (/5200, 5280, 5360, 5440, 5520, 5600, 5680, 5760, 5840, 5920, 6000 /)
level0_begclr = 74
level0_endclr = 85

; output format ----------------------------------------------------------------
; wks_type = "pdf"
; wks_type@wkOrientation = "portrait"
wks_type = "png"
wks_type@wkWidth = 1200
wks_type@wkHeight = 1200

wks  = gsn_open_wks (wks_type, map_path)
; drawNDCGrid(wks)               ; Draw an NDC grid for reference.

; plot panels
plot = new(12,graphic)
id_land = new(12, graphic)
id_country = new(12, graphic)

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

; vectors ---------------------------------------------------------------------
res@gsnScalarContour      = True               ; contours desired
res@vcRefMagnitudeF = 10.0
res@vcMinFracLengthF = 0.1  ;-- length of min vector as fraction of reference vector
res@vcRefLengthF = 0.02 ;-- ref vec length
res@vcRefAnnoOrthogonalPosF = -0.11          ; move ref vector up
res@vcRefAnnoParallelPosF = 0.10         ; move ref vector over
res@vcGlyphStyle = "CurlyVector" ; "LineArrow" ;  ;-- turn on curly vectors or straight
res@vcGlyphOpacityF = 0.5 ;-- transparency of vector
res@vcMinDistanceF = 0.012 ;0.015 ; 0.02 ; 0.008 ;  -- thin out vectors
res@vcLineArrowColor = "black" ; "gray40" ; 
res@vcLineArrowThicknessF = 1.5 ; 2.0
res@vcLineArrowHeadMinSizeF = 0.001
res@vcLineArrowHeadMaxSizeF = 0.004
res@vcRefAnnoString1 = "10 m s~S~-1~N~"
res@vcRefAnnoFontHeightF = 0.007
res@vcRefAnnoPerimOn = False ; "True"
res@vcRefAnnoBackgroundColor = "white" ; gray95
; res@vcLabelBarEndLabelsOn = "True"

; label bar --------------------------------------------------------------------
res@lbLabelBarOn            = False            
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
plres@gsLineThicknessF= 0.5
pcres        = True
pcres@gsLineColor = "gray50"
pcres@gsLineThicknessF= 0.5

; plot()  ----------------------------------------------------------------------
res@gsnRightStringFontHeightF   = 0.025
res@gsnLeftStringFontHeightF    = 0.025    
res@gsnLeftStringOrthogonalPosF = -0.07
res@gsnLeftStringParallelPosF = 0.02
res@gsnRightString          = ""            

; plot(0): Dec 
res@gsnLeftString           = months(11) 
; plot(0) = gsn_csm_contour_map(wks,pltvar(11,:,:),res)  
plot(0) = gsn_csm_vector_scalar_map(wks,u(11,::2,::2),v(11,::2,::2),pltvar(11,:,:),res)
id_country(0) = gsn_add_shapefile_polylines(wks,plot(0),country_shp,pcres)
id_land(0) = gsn_add_shapefile_polylines(wks,plot(0),land_shp,plres)

; plot(1-11): Jan-Nov 
i = 0                                        
do nmo=0,10                                
    i = i+1
    res@gsnLeftString = months(nmo)
    ; plot(i) = gsn_csm_contour_map(wks,pltvar(nmo,:,:),res)  
    plot(i) = gsn_csm_vector_scalar_map(wks,u(nmo,::2,::2),v(nmo,::2,::2),pltvar(nmo,:,:),res)
    id_country(i) = gsn_add_shapefile_polylines(wks,plot(i),country_shp,pcres)
    id_land(i) = gsn_add_shapefile_polylines(wks,plot(i),land_shp,plres)
end do

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
title_x_pos = 0.02
title_y_pos = 0.26
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
resP@gsnPanelBottom         = 0.25
resP@lbLabelAutoStride      = True
resP@pmLabelBarOrthogonalPosF  = 0.0075
resP@lbBoxLineThicknessF    = 2
resP@pmLabelBarWidthF       = 0.8    
resP@pmLabelBarHeightF      = 0.06     

; plot the panels --------------------------------------------------------------
gsn_panel(wks,plot,(/4,3/),resP)

end
exit()  
