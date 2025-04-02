; 2-up plot of a scalar and vector variable polar projection

mapfile = "vmag10_wind_polar_1991-2020_ltm"
mapvar = "vmag10"
ncvar = "vmag10"
umapvar = "u10"
vmapvar = "v10"
uvecvar = "u10"
vvecvar = "v10"
data_path = "/Users/bartlein/Dropbox/WorkCurrent/ERA5/data/ERA5-Atm/ltm_monthly/"
map_path = "/Users/bartlein/Dropbox/WorkCurrent/ERA5/maps/polar/" + mapfile + "/png/"
title_0 = "10 m Wind Speed (m s~S~-1~N~)"
title_2 = "Data: ERA5 Reanalysis"
title_3 = "1991-2020 Long-Term Mean"

infile = "ERA5_" + mapvar + "_monthly_199101-202012_ltm.nc"
uinfile = "ERA5_" + umapvar + "_monthly_199101-202012_ltm.nc"
vinfile = "ERA5_" + vmapvar + "_monthly_199101-202012_ltm.nc"

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

; set color scale
clr_map = "ClimA7"

nm = 12
months = (/"Jan", "Feb", "Mar", "Apr","May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov","Dec" /)

begin

; open file and read data
f1 = addfile(data_path + infile, "r")
pltvar = short2flt(f1->$ncvar$(:,:,:))
pltvar = pltvar
lon = f1->longitude
lat = f1->latitude
time = f1->time
pltvar = lonFlip(pltvar)
printVarSummary(pltvar)
printMinMax(pltvar, 1)
f2 = addfile(data_path + uinfile, "r")
u = short2flt(f2->$uvecvar$(:,:,:))
u = lonFlip(u)
; f3 = addfile(data_path + vinfile, "r")
; v = short2flt(f3->$vvecvar$(:,:,:))
; v = lonFlip(v)
v = u
v = 0.0

; u and v 10 m 
level0 = new((/ 06 /),float)
level0 = (/ 0.0, 0.5, 1.0, 2.0, 5.0, 10.0 /)
level0_begclr = 125
level0_endclr = 131

; plotting resources

res                        = True  ; plot mods desired
plot = new(2, graphic)
id_land = new(2, graphic)
id_country = new(2, graphic)
id_grat = new(2, graphic)

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
; res@mpMinLatF                 =   20.1
res@gsnPolarLabelFontHeightF  = 0.0
res@mpCenterLonF = -90                    ; center longitude

res@mpLimbLineThicknessF    = 2
res@mpGridLineColor         = "gray50"
res@mpGridLineThicknessF    = 1

; vectors ---------------------------------------------------------------------
res@gsnScalarContour      = True               ; contours desired
res@vcRefMagnitudeF = 10.0
res@vcMinFracLengthF = 0.1  ;-- length of min vector as fraction of reference vector
res@vcRefLengthF = 0.02 ;-- ref vec length
res@vcRefAnnoOrthogonalPosF = -0.11          ; move ref vector up
res@vcRefAnnoParallelPosF = 0.10         ; move ref vector over
res@vcGlyphStyle = "CurlyVector" ; "LineArrow" ;  ;-- turn on curly vectors or straight
res@vcGlyphOpacityF = 0.5 ;-- transparency of vector
res@vcMinDistanceF = 0.009 ;0.008 ; -- thin out vectors
res@vcLineArrowColor = "black" ; "gray40" ; 
res@vcLineArrowThicknessF = 2.0
res@vcLineArrowHeadMinSizeF = 0.001
res@vcLineArrowHeadMaxSizeF = 0.004
res@vcRefAnnoString1 = "10 m s~S~-1~N~"
res@vcRefAnnoFontHeightF = 0.010
res@vcRefAnnoPerimOn = False ; "True"
res@vcRefAnnoBackgroundColor = "white" ; gray95"
; res@vcLabelBarEndLabelsOn = "True"

; label bar --------------------------------------------------------------------
res@lbLabelBarOn            = True            
res@pmLabelBarHeightF       = 0.08
res@lbLabelFontHeightF      = 0.0125
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
plres@gsLineThicknessF= 1.5
pcres        = True
pcres@gsLineColor = "gray50"
pcres@gsLineThicknessF= 1.0
pgres        = True
pgres@gsLineColor = "gray50"
pgres@gsLineThicknessF= 1.0
plresSH = plres
pcresSH = pcres
pgresSH = pgres

; add SH resources
resSH = res
resSH@gsnPolar = "SH"
resSH@gsnPolarLabelFontHeightF  = 0.0
resSH@mpCenterLonF = 90                    ; center longitude
resSH@gsnLeftString           = ""

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

    ; note thinning of vectors
    res@gsnLeftString = ""
    plot(0) = gsn_csm_vector_scalar_map_polar(wks,u(m,::2,::2),v(m,::2,::2),pltvar(m,:,:),res)
    ; plot(0) = gsn_csm_vector_scalar_map_polar(wks,u(m,:,:),v(m,:,:),pltvar(m,:,:),res)
    id_country(0) = gsn_add_shapefile_polylines(wks,plot(0),country_shp,pcres)
    id_land(0) = gsn_add_shapefile_polylines(wks,plot(0),land_shp,plres)
    id_grat(0) = gsn_add_shapefile_polylines(wks,plot(0),grat30_shp,pgres)

    res@gsnLeftString = ""
    plot(1) = gsn_csm_vector_scalar_map_polar(wks,u(m,::2,::2),v(m,::2,::2),pltvar(m,:,:),resSH)
    ; plot(1) = gsn_csm_vector_scalar_map_polar(wks,u(m,:,:),v(m,:,:),pltvar(m,:,:),resSH)
    id_country(1) = gsn_add_shapefile_polylines(wks,plot(1),country_shp,pcresSH)
    id_land(1) = gsn_add_shapefile_polylines(wks,plot(1),land_shp,plresSH)
    id_grat(1) = gsn_add_shapefile_polylines(wks,plot(1),grat30_shp,pgresSH)
  

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

    gsn_panel(wks, plot, (/1,2/), resP)

end do
end 

exit()