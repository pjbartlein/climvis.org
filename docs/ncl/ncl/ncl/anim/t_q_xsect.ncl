; 2-up plot of a scalar and vector variable

mapfile = "t_q_xsect_1991-2020_ltm"

ncvar1 = "t"
ncvar2 = "q"
data_path = "/Users/bartlein/Dropbox/WorkCurrent/ERA5/data/ERA5-Atm/ltm_monthly_4D/"
data_path1 = "/Users/bartlein/Dropbox/WorkCurrent/ERA5/data/ERA5-Atm/ltm_monthly/"
map_path = "/Users/bartlein/Dropbox/WorkCurrent/ERA5/maps/xsect/" + mapfile + "/png/"

title_0 = "Air Temperature (~S~o~N~C~N~)"
title_1 = "Specific Humidity (kg kg~S~-1~N~)"
title_2 = "Data: ERA5 Reanalysis"
title_3 = "1991-2020 Long-Term Mean"

tinfile = "ERA5_t_monthly_199101-202012_ltm.nc"
qinfile = "ERA5_q_monthly_199101-202012_ltm.nc"

nm = 12
months = (/"Jan", "Feb", "Mar", "Apr","May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov","Dec" /)

begin

; open file and read data
f0 = addfile(data_path + tinfile, "r")
t = short2flt(f0->$ncvar1$(:,:,:,:))
t = t - 273.15
lon = f0->longitude
lat = f0->latitude
level = f0->level
time = f0->time
printVarSummary(t)
printMinMax(t, 1)

f1 = addfile(data_path + qinfile, "r")
q = short2flt(f1->$ncvar2$(:,:,:,:)) 
printVarSummary(q)
printMinMax(q, 1)

; air temperature
; color table 
clr_tmp = (/ \
"(/1.000, 0.847, 1.000/)", \
"(/1.000, 0.698, 1.000/)", "(/0.898, 0.494, 0.898/)", "(/0.847, 0.404, 0.847/)", \
"(/0.800, 0.318, 0.800/)", "(/0.749, 0.243, 0.749/)", "(/0.698, 0.173, 0.698/)", \
"(/0.600, 0.059, 0.600/)", "(/0.392, 0.000, 0.588/)", "(/0.000, 0.000, 0.749/)", \
"(/0.141, 0.000, 0.847/)", "(/0.094, 0.110, 0.969/)", "(/0.157, 0.341, 1.000/)", \
"(/0.239, 0.529, 1.000/)", "(/0.337, 0.690, 1.000/)", "(/0.459, 0.827, 1.000/)", \
"(/0.600, 0.918, 1.000/)", "(/0.737, 0.976, 1.000/)", "(/1.000, 0.945, 0.737/)", \
"(/1.000, 0.839, 0.600/)", "(/1.000, 0.675, 0.459/)", "(/1.000, 0.471, 0.337/)", \
"(/1.000, 0.239, 0.239/)", "(/0.969, 0.153, 0.208/)", "(/0.847, 0.082, 0.184/)", \
"(/0.647, 0.000, 0.129/)" /) 
; levels
level_tmp = new((/ 25 /), float)
level_tmp = (/-85, -80, -75, -70, -65, -60, -55, -50, -45, -40, -35, -30, -25, -20, -15, \
                 -10, -5, 0, 5, 10, 15, 20, 25, 30, 35 /)

; q
clr_shum = (/ \
"(/0.627, 0.929, 1.000/)", "(/0.522, 0.878, 1.000/)", "(/0.427, 0.820, 1.000/)", \
"(/0.341, 0.753, 1.000/)", "(/0.263, 0.675, 1.000/)", "(/0.192, 0.596, 1.000/)", \
"(/0.129, 0.510, 1.000/)", "(/0.078, 0.424, 1.000/)", "(/0.031, 0.333, 1.000/)", \
"(/0.000, 0.247, 1.000/)", "(/0.008, 0.008, 1.000/)" /)
level_shum = new((/ 10 /), float)
level_shum = (/0.00001, 0.00002, 0.00005, 0.0001, 0.0002, 0.0005, 0.001, 0.002, 0.005, 0.01 /)

; zonal average
tave = dim_avg_Wrap(t)
printVarSummary(tave)
printMinMax(tave, 1)

; zonal average
qave = dim_avg_Wrap(q)
printVarSummary(qave)
printMinMax(qave, 1)

; psi = smth9_Wrap(psi, 0.5, 0.25, True)
; psi = smth9_Wrap(psi, 0.5, 0.25, True)
; printVarSummary(psi)

;  ; plotting resources

res                        = True  ; plot mods desired
plot = new(2, graphic)

; gsn high-level interfaces ---------------------------------------------------
res@gsnDraw                = False              ; don't draw
res@gsnFrame               = False              ; don't advance frame
; res@gsnSpreadColors        = True               ; use total colormap
 
; aspect ratio
res@vpHeightF = 0.3 
res@vpWidthF = 0.6

; ; contour ----------------------------------------------------------------------
res@cnLevelSelectionMode   = "ExplicitLevels" ;
; res@cnLevelSelectionMode = "ManualLevels" ;
; res@cnLevelSpacingF      = 5.0                  ; contour spacing
; res@cnMinLevelValF       = -40.                 ; min level
; res@cnMaxLevelValF       =  40.                 ; max level 
res@cnLineLabelsOn       = False                 ; turn on line labels
res@cnFillOn             = True                 ; turn on color fill
res@cnLabelMasking             = True     
res@cnLineLabelBackgroundColor = "transparent"
res@cnLineLabelFontHeightF = 0.008
; res@cnSmoothingOn = True 
; res@cnSmoothingTensionF = -2.0

; y-axis labels
res@tiYAxisString = "Pressure Level (hPa)"
res@tiYAxisFontHeightF = 0.012

; tick marks
res@tmXBLabelFontHeightF = 0.01
res@tmYRLabelFontHeightF = 0.01
res@tmYLLabelFontHeightF = 0.01
res@tmXBMajorLengthF = 0.01
res@tmXBMinorLengthF = 0.005
res@tmXBLabelDeltaF = -0.6
res@tmYLLabelDeltaF = -0.6
res@tmYRLabelDeltaF = -0.6
res@tmYLMode             = "Explicit"
res@tmYLMinorOn          = False


; label bar --------------------------------------------------------------------
res@lbLabelBarOn            = True            
res@pmLabelBarHeightF       = 0.05
res@lbLabelFontHeightF      = 0.0075
res@pmLabelBarOrthogonalPosF= -.001
res@lbBoxLineThicknessF     = 2
  
; res@gsnSpreadColorStart     = level0_begclr
; res@gsnSpreadColorEnd       = level0_endclr 
; res@cnLevels                = level0 

; titles---------------------------------------------------------------------- 
res@gsnLeftString           = ""
res@gsnRightString          = "" 
res@gsnLeftStringFontHeightF = 0.015
res@gsnRightStringFontHeightF = 0.015
txres1     = True

do m = 0,nm-1

    ; output format ----------------------------------------------------------------
    ; wks_type = "pdf"
    ; wks_type@wkOrientation = "portrait"
    wks_type = "png"
    wks_type@wkWidth = 750
    wks_type@wkHeight = 750

    monthstring  = sprinti("%0.2i", m+1)
    map_out_file = mapfile + "_" + monthstring

    wks  = gsn_open_wks (wks_type, map_path + map_out_file)
    print("     map_out_file: " + map_out_file + ".png")
    ; drawNDCGrid(wks)                   ; Draw an NDC grid for reference

    txres1@txFontHeightF = 0.010
    title_x_pos = 0.06
    title_y_pos = 0.01
    txres1@txJust        = "BottomLeft" 
    gsn_text_ndc(wks,title_2,title_x_pos,title_y_pos,txres1)
    title_x_pos = 0.94
    txres1@txJust        = "BottomRight" 
    gsn_text_ndc(wks,title_3,title_x_pos,title_y_pos,txres1)

    resp = res
    resp@gsnRightString = months(m)
    resp@gsnLeftString = title_0
    resp@cnFillPalette = clr_tmp
    resp@cnLevels                = level_tmp 
    resp@gsnContourZeroLineThicknessF = 2.0           ; zero-line thinkness
    resp@tmYLValues           = (/1000, 700, 500, 300, 200,  100,  50,  30, 20, 10, 5, 3, 2, 1/)
    resp@tmYLLabels           = "" + resp@tmYLValues
    plot(0) = gsn_csm_pres_hgt(wks,tave(m,:,:),resp)
    delete(resp)

    resp = res
    resp@gsnRightString = months(m)
    resp@gsnLeftString = title_1
    resp@cnFillPalette = clr_shum
    resp@cnLevels                = level_shum
    resp@gsnContourZeroLineThicknessF = 2.0           ; zero-line thinkness
    resp@tmYLValues           = (/1000, 700, 500, 300, 200,  100,  50,  30, 20, 10, 5, 3, 2, 1/)
    resp@tmYLLabels           = "" + resp@tmYLValues
    plot(1) = gsn_csm_pres_hgt(wks,qave(m,:,:),resp)
    delete(resp)

    ; panel plot
    resP           = True
    resP@gsnPaperOrientation = "portrait"   
    resP@gsnPanelLeft  = 0.01 
    resP@gsnPanelRight = 0.99 
    resP@gsnPanelTop   = 0.99 
    resP@gsnPanelBottom = 0.01    
    resP@gsnPanelYWhiteSpacePercent = 1 ; 2

    gsn_panel(wks, plot, (/2,1/), resP)

end do

end 

exit()