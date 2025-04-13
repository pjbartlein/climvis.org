; 4-up plot of scalar + vector variables

mapfile = "eflux_globe_1991-2020_ltm"

mapvar0 = "uv_tef_vint"
ncvar0 = "vint"
ufilename0 = "u_tef"
vfilename0 = "v_tef"
uvecvar0 = "p75.162"
vvecvar0 = "p76.162"

mapvar1 = "uv_hf_vint"
ncvar1 = "vint"
ufilename1 = "u_hf"
vfilename1 = "v_hf"
uvecvar1 = "p69.162"
vvecvar1 = "p70.162"

mapvar2 = "uqvq_vmag"
ncvar2 = "uqvq_vmag"
ufilename2 = "uq"
vfilename2 = "vq"
uvecvar2 = "p71.162"
vvecvar2 = "p72.162"

mapvar3 = "uv_ke_vint"
ncvar3 = "vint"
ufilename3 = "u_ke"
vfilename3 = "v_ke"
uvecvar3 = "p67.162"
vvecvar3 = "p68.162"

data_path = "/Users/bartlein/Dropbox/WorkCurrent/ERA5/data/ERA5-Atm/ltm_monthly/"
map_path = "/Users/bartlein/Dropbox/WorkCurrent/ERA5/maps/globe/" + mapfile + "/png/"
; mask_path = "/Users/bartlein/Dropbox/WorkCurrent/ERA5/data/ERA5-Atm/fixed/"
; maskfile = "ERA5_land-sea_mask.nc"
title_0 = "Atmospheric Energy Fluxes"
title_00 = "Total Energy Flux (W m~S~-1~N~)"
title_01 = "Heat Flux (W m~S~-1~N~)"
title_02 = "Latent Energy Flux (W m~S~-1~N~)"
title_03 = "Kinetic Energy Flux (W m~S~-1~N~)"
title_2 = "Data: ERA5 Reanalysis"
title_3 = "1991-2020 Long-Term Mean"

infile0 = "ERA5_" + mapvar0 + "_monthly_199101-202012_ltm.nc"
infile1 = "ERA5_" + mapvar1 + "_monthly_199101-202012_ltm.nc"
infile2 = "ERA5_" + mapvar2 + "_monthly_199101-202012_ltm.nc"
infile3 = "ERA5_" + mapvar3 + "_monthly_199101-202012_ltm.nc"
uinfile0 = "ERA5_" + ufilename0 + "_monthly_199101-202012_ltm.nc"
vinfile0 = "ERA5_" + vfilename0 + "_monthly_199101-202012_ltm.nc"
uinfile1 = "ERA5_" + ufilename1 + "_monthly_199101-202012_ltm.nc"
vinfile1 = "ERA5_" + vfilename1 + "_monthly_199101-202012_ltm.nc"
uinfile2 = "ERA5_" + ufilename2 + "_monthly_199101-202012_ltm.nc"
vinfile2 = "ERA5_" + vfilename2 + "_monthly_199101-202012_ltm.nc"
uinfile3 = "ERA5_" + ufilename3 + "_monthly_199101-202012_ltm.nc"
vinfile3 = "ERA5_" + vfilename3 + "_monthly_199101-202012_ltm.nc"

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
pltvar0 = pltvar0 
lat = f0->latitude
time = f0->time
pltvar0 = lonFlip(pltvar0)
printVarSummary(pltvar0)
printMinMax(pltvar0, 1)

f1 = addfile(data_path + infile1, "r")
pltvar1 = short2flt(f1->$ncvar1$(:,:,:))
pltvar1 = pltvar1 
pltvar1 = lonFlip(pltvar1)
printVarSummary(pltvar1)
printMinMax(pltvar1, 1)

f2 = addfile(data_path + infile2, "r")
pltvar2 = short2flt(f2->$ncvar2$(:,:,:))
pltvar2 = pltvar2 * 2500 * 1000; transform if necessary
pltvar2 = lonFlip(pltvar2)
pltvar_FillValue = pltvar2@_FillValue
printVarSummary(pltvar2)
printMinMax(pltvar2, 1)

f3 = addfile(data_path + infile3, "r")
pltvar3 = short2flt(f3->$ncvar3$(:,:,:))
pltvar3 = pltvar3 
pltvar3 = lonFlip(pltvar3)
printVarSummary(pltvar3)
printMinMax(pltvar3, 1)

f4 = addfile(data_path + uinfile0, "r")
u0 = short2flt(f4->$uvecvar0$(:,:,:))
u0 = lonFlip(u0)
f5 = addfile(data_path + vinfile0, "r")
v0 = short2flt(f5->$vvecvar0$(:,:,:))
v0 = lonFlip(v0)

f6 = addfile(data_path + uinfile1, "r")
u1 = short2flt(f6->$uvecvar1$(:,:,:))
u1 = lonFlip(u1)
f7 = addfile(data_path + vinfile1, "r")
v1 = short2flt(f7->$vvecvar1$(:,:,:))
v1 = lonFlip(v1)

f8 = addfile(data_path + uinfile2, "r")
u2 = short2flt(f8->$uvecvar2$(:,:,:))
u2 = u2 * 2500 * 1000
u2 = lonFlip(u2)
f9 = addfile(data_path + vinfile2, "r")
v2 = short2flt(f9->$vvecvar2$(:,:,:))
v2 = v2 * 2500 * 1000
v2 = lonFlip(v2)

f10 = addfile(data_path + uinfile3, "r")
u3 = short2flt(f10->$uvecvar3$(:,:,:))
u3 = lonFlip(u3)
f11 = addfile(data_path + vinfile3, "r")
v3 = short2flt(f11->$vvecvar3$(:,:,:))
v3 = lonFlip(v3)

; ; landmask
; f4 = addfile(mask_path + maskfile, "r")
; maskvar = short2flt(f4->lsm(:,:,:))
; maskvar = lonFlip(maskvar)
; printVarSummary(maskvar)
; maskvar2 = new((/dimsizes(pltvar3)/), float)
; printVarSummary(maskvar2)

; do i = 0, 11
;     maskvar2(i,:,:) = maskvar(0,:,:)
; end do

; pltvar2 = where(maskvar2 .lt. 0.5, pltvar_FillValue, pltvar2)
; pltvar3 = where(maskvar2 .lt. 0.5, pltvar_FillValue, pltvar3)

; tef
level0 = new((/7/),float) 
level0 = (/1e+9,2e+9,5e+9,1e+10,2e+10,5e+10,1e+11/)
level0_begclr = 38
level0_endclr = 45

; hf
level1 = new((/7/),float) 
level1 = (/1e+9,2e+9,5e+9,1e+10,2e+10,5e+10,1e+11/)
level1_begclr = 38
level1_endclr = 45

; lh
level2 = new((/7/),float) 
level2 = (/1e+7,2e+7,5e+7,1e+8,2e+8,5e+8,1e+9/)
level2_begclr = 38
level2_endclr = 45

; ke
level3 = new((/7/),float) 
level3 = (/1e+7,2e+7,5e+7,1e+8,2e+8,5e+8,1e+9/)
level3_begclr = 38
level3_endclr = 45

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

; vectors ---------------------------------------------------------------------
res@gsnScalarContour      = True               ; contours desired
res@vcMinFracLengthF = 0.1  ;-- length of min vector as fraction of reference vector
res@vcRefLengthF = 0.02 ;-- ref vec length
res@vcRefAnnoOrthogonalPosF = -0.11          ; move ref vector up
res@vcRefAnnoParallelPosF = 0.10         ; move ref vector over
res@vcGlyphStyle = "CurlyVector" ; "LineArrow" ;  ;-- turn on curly vectors or straight
res@vcGlyphOpacityF = 0.5 ;-- transparency of vector
res@vcMinDistanceF = 0.008 ; 0.015 ; 0.02 ;-- thin out vectors
res@vcLineArrowColor = "black" ; "gray40" ; 
res@vcLineArrowThicknessF = 2.0
res@vcLineArrowHeadMinSizeF = 0.001
res@vcLineArrowHeadMaxSizeF = 0.004
; res@vcRefMagnitudeF = 300
; res@vcRefAnnoString1 = "300 kg m~S~-2~N~" + " " +"s~S~-1~N~"
res@vcRefAnnoFontHeightF = 0.007
res@vcRefAnnoPerimOn = False ; "True"
res@vcRefAnnoPerimSpaceF = 0.0
res@vcRefAnnoBackgroundColor = "white" ; gray95
; res@vcLabelBarEndLabelsOn = "True"

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
    title_x_pos = 0.99
    txres1@txJust        = "TopRight" 
    gsn_text_ndc(wks,title_1,title_x_pos,title_y_pos,txres1)  

    txres1@txFontHeightF = 0.009
    title_x_pos = 0.01
    title_y_pos = 0.18
    txres1@txJust        = "BottomLeft" 
    gsn_text_ndc(wks,title_2,title_x_pos,title_y_pos,txres1)
    title_x_pos = 0.99
    txres1@txJust        = "BottomRight" 
    gsn_text_ndc(wks,title_3,title_x_pos,title_y_pos,txres1)

    ; txres1@txFontHeightF = 0.008
    ; label_1 = "conv"
    ; label_x_pos = 0.035
    ; label_y_pos = 0.5225
    ; txres1@txJust        = "BottomRight" 
    ; gsn_text_ndc(wks,label_1,label_x_pos,label_y_pos,txres1)
    ; label_2 = "div"
    ; label_x_pos = 0.475
    ; txres1@txJust        = "BottomLeft" 
    ; gsn_text_ndc(wks,label_2,label_x_pos,label_y_pos,txres1)

    res@gsnRightString           = ""
    res@gsnLeftStringFontHeightF     = 0.0175

    resp = res
    resp@gsnLeftString           = title_00
    resp@gsnSpreadColorStart     = level0_begclr
    resp@gsnSpreadColorEnd       = level0_endclr 
    resp@cnLevels                = level0 
    resp@vcRefMagnitudeF = 1e+11
    resp@vcRefAnnoString1 = "1e+11 W m~S~-1~N~" 
    ; plot(0) = gsn_csm_contour_map(wks, pltvar0(m,:,:), resp)
    ; note thinning of vectors
    plot(0) = gsn_csm_vector_scalar_map(wks,u0(m,::2,::2),v0(m,::2,::2),pltvar0(m,:,:),resp)
    id_country(0) = gsn_add_shapefile_polylines(wks,plot(0),country_shp,pcres)
    id_land(0) = gsn_add_shapefile_polylines(wks,plot(0),land_shp,plres)
    delete(resp)

    resp = res
    resp@gsnLeftString           = title_01
    resp@gsnSpreadColorStart     = level1_begclr
    resp@gsnSpreadColorEnd       = level1_endclr 
    resp@cnLevels                = level1 
    resp@vcRefMagnitudeF = 1e+11
    resp@vcRefAnnoString1 = "1e+11 W m~S~-1~N~" 
    ; plot(1) = gsn_csm_contour_map(wks, pltvar1(m,:,:), resp)
    ; note thinning of vectors
    plot(1) = gsn_csm_vector_scalar_map(wks,u1(m,::2,::2),v1(m,::2,::2),pltvar1(m,:,:),resp)
    id_country(1) = gsn_add_shapefile_polylines(wks,plot(1),country_shp,pcres)
    id_land(1) = gsn_add_shapefile_polylines(wks,plot(1),land_shp,plres)
    delete(resp)

    resp = res
    resp@gsnLeftString           = title_02
    resp@gsnSpreadColorStart     = level2_begclr
    resp@gsnSpreadColorEnd       = level2_endclr 
    resp@cnLevels                = level2 
    resp@vcRefMagnitudeF = 1e+9
    resp@vcRefAnnoString1 = "1e+9 W m~S~-1~N~"
    ; note thinning of vectors
    plot(2) = gsn_csm_vector_scalar_map(wks,u2(m,::2,::2),v2(m,::2,::2),pltvar2(m,:,:),resp)
    id_country(2) = gsn_add_shapefile_polylines(wks,plot(2),country_shp,pcres)
    id_land(2) = gsn_add_shapefile_polylines(wks,plot(2),land_shp,plres)
    delete(resp)

    resp = res
    resp@gsnLeftString           = title_03
    resp@gsnSpreadColorStart     = level3_begclr
    resp@gsnSpreadColorEnd       = level3_endclr 
    resp@cnLevels                = level3 
    resp@vcRefMagnitudeF = 1e+9
    resp@vcRefAnnoString1 = "1e+9 W m~S~-1~N~"
    ; note thinning of vectors
    plot(3) = gsn_csm_vector_scalar_map(wks,u3(m,::2,::2),v3(m,::2,::2),pltvar3(m,:,:),resp)
    id_country(3) = gsn_add_shapefile_polylines(wks,plot(3),country_shp,pcres)
    id_land(3) = gsn_add_shapefile_polylines(wks,plot(3),land_shp,plres)
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