; 2-up plot of scalar variables

mapfile = "t2m_snr_globe_1991-2020_ltm"
mapvar0 = "snr"
ncvar0 = "snr"
mapvar2 = "t2m"
ncvar2 = "t2m"
data_path = "/Users/bartlein/Dropbox/WorkCurrent/ERA5/data/ERA5-Atm/ltm_monthly/"
map_path = "/Users/bartlein/Dropbox/WorkCurrent/ERA5/maps/globe/" + mapfile + "/png/"
title_0 = "Net Radiative Components"
title_00 = "Surface Net Shortwave Radiation (Wm~S~-2~N~)"
title_02 = "2 m Air Temperature (~S~o~N~C~N~)"
title_2 = "Data: ERA5 Reanalysis"
title_3 = "1991-2020 Long-Term Mean"

infile0 = "ERA5_" + mapvar0 + "_monthly_199101-202012_ltm.nc"
infile2 = "ERA5_" + mapvar2 + "_monthly_199101-202012_ltm.nc"

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

; open files and read data
f0 = addfile(data_path + infile0, "r")
pltvar0 = short2flt(f0->$ncvar0$(:,:,:))
pltvar0 = pltvar0 / 86400.0
lon = f0->longitude
lat = f0->latitude
time = f0->time
pltvar0 = lonFlip(pltvar0)
printVarSummary(pltvar0)
printMinMax(pltvar0, 1)

f2 = addfile(data_path + infile2, "r")
pltvar2 = short2flt(f2->$ncvar2$(:,:,:))
pltvar2 = pltvar2 -273.15
pltvar2 = lonFlip(pltvar2)
printVarSummary(pltvar2)
printMinMax(pltvar2, 1)

; radiative fluxes
level0 = new((/13/),float)
;level0 = (/-20,-10,-5,-2,-1,-0.5,-0.1,0.1,0.5,1,2,5,10,20/)  
;level0 = (/-20,-10,-5,-2,-1,-0.5,0,0.5,1,2,5,10,20/)  
level0 = (/-400,-200,-100,-50,-20,-10,0,10,20,50,100,200,400/)
level0_begclr = 31
level0_endclr = 44 

; 2 m air temperature
level2 = new((/ 15 /), float)
level2 = (/-35, -30, -25, -20, -15, -10, -5, 0, 5, 10, 15, 20, 25, 30, 35 /)
level2_begclr = 238
level2_endclr = 253

; plotting resources

res                        = True  ; plot mods desired
plot = new(4, graphic)
id_land = new(4, graphic)
id_country = new(4, graphic)

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
res@pmLabelBarHeightF       = 0.05
res@lbLabelFontHeightF      = 0.009   ; 0.00625
res@pmLabelBarOrthogonalPosF= -.001
res@lbBoxLineThicknessF     = 2

; shapefile outlines -------------------------------------------------------
plres        = True
plres@gsLineColor = "black"
plres@gsLineThicknessF= 1
pcres        = True
pcres@gsLineColor = "gray50"
pcres@gsLineThicknessF= 0.5

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
    txres1     = True
    txres1@txFont        = 21 
    txres1@txFontHeightF = 0.0175
    ; title_x_pos = 0.01
    ; title_y_pos = 0.8
    ; txres1@txJust        = "CenterLeft" 
    ; gsn_text_ndc(wks,title_0,title_x_pos,title_y_pos,txres1)
    title_y_pos = 0.805
    title_x_pos = 0.49
    txres1@txJust        = "TopRight" 
    gsn_text_ndc(wks,title_1,title_x_pos,title_y_pos,txres1)  

    txres1@txFontHeightF = 0.009
    title_x_pos = 0.01
    title_y_pos = 0.18
    txres1@txJust        = "BottomLeft" 
    gsn_text_ndc(wks,title_2,title_x_pos,title_y_pos,txres1)
    title_x_pos = 0.49
    txres1@txJust        = "BottomRight" 
    gsn_text_ndc(wks,title_3,title_x_pos,title_y_pos,txres1)

    res@gsnRightString           = ""
    res@gsnLeftStringFontHeightF     = 0.0175

    resp = res
    resp@gsnLeftString           = title_00
    resp@gsnSpreadColorStart     = level0_begclr
    resp@gsnSpreadColorEnd       = level0_endclr 
    resp@cnLevels                = level0 
    plot(0) = gsn_csm_contour_map(wks, pltvar0(m,:,:), resp)
    id_country(0) = gsn_add_shapefile_polylines(wks,plot(0),country_shp,pcres)
    id_land(0) = gsn_add_shapefile_polylines(wks,plot(0),land_shp,plres)
    delete(resp)

    resp = res
    resp@gsnLeftString           = title_02
    resp@gsnSpreadColorStart     = level2_begclr
    resp@gsnSpreadColorEnd       = level2_endclr 
    resp@cnLevels                = level2 
    plot(2) = gsn_csm_contour_map(wks, pltvar2(m,:,:), resp)
    id_country(2) = gsn_add_shapefile_polylines(wks,plot(2),country_shp,pcres)
    id_land(2) = gsn_add_shapefile_polylines(wks,plot(2),land_shp,plres)
    delete(resp)

    ; panel plot
    resP           = True
    resP@gsnPaperOrientation = "portrait"   
    resP@gsnPanelLeft  = 0.01 
    resP@gsnPanelRight = 0.99 
    resP@gsnPanelTop   = 0.99 
    resP@gsnPanelBottom = 0.01    ; panel TextOnly 
    resP@gsnPanelCenter = False
    resP@gsnPanelYWhiteSpacePercent = 0.0 ; 1 ; 2

    gsn_panel(wks, plot, (/2,2/), resP)

end do
end 

exit()