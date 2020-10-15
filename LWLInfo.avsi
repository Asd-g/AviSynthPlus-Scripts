## Changelog:
# - Added the other frame properties than picture type (_PictType) - _DurationNum, _DurationDen, _AbsoluteTime (FFMS2 only), _ColorRange (LSMASHSource/FFMS2), _Primaries (LSMASHSource/FFMS2), _Transfer (LSMASHSource/FFMS2), _Matrix, _ChromaLocation (LSMASHSource/FFMS2), _FieldBased, _SARNum (LSMASHSource/FFMS2), _SARDen (LSMASHSource/FFMS2), MasteringDisplayPrimariesX (LSMASHSource/FFMS2), MasteringDisplayPrimariesY (LSMASHSource/FFMS2), MasteringDisplayWhitePointX (LSMASHSource/FFMS2), MasteringDisplayWhitePointY (LSMASHSource/FFMS2), MasteringDisplayMinLuminance (LSMASHSource/FFMS2), MasteringDisplayMaxLuminance (LSMASHSource/FFMS2), ContentLightLevelMax (LSMASHSource/FFMS2), ContentLightLevelAverage (LSMASHSource/FFMS2), _AspectRatio (D2VSource), _GOPNumber (D2VSource), _GOPPosition (D2VSource), _GOPClosed (D2VSource), _EncodedFrameTop (D2VSource), _EncodedFrameBottom (D2VSource), _QuantsAverage (D2VSource), _QuantsMin (D2VSource), _QuantsMax (D2VSource).


### Script displaying LSMASHSource/FFMS2/D2VSource frame properties.
## Frame properties have Int type.
## The list below shows what the frame properties values corresponds to:
####### matrix #######
# "rgb" (0)
# "709" (1)
# "unspec" (2)
# "fcc" (4)
# "470bg" (5)
# "170m" (6)
# "240m" (7)
# "ycgco" (8)
# "2020ncl"(9)
# "2020cl" (10)
# "chromancl" (12)
# "chromacl" (13)
# "ictcp" (14)
####### transfer #######
# "709" (1)
# "unspec" (2)
# "470m" (4)
# "470bg" (5)
# "601" (6)
# "240m" (7)
# "linear" (8)
# "log100" (9)
# "log316" (10)
# "xvycc" (11)
# "srgb" (13)
# "2020_10" (14)
# "2020_12" (15)
# "st2084" (16)
# "std-b67" (18)
####### primaries #######
# "709" (1)
# "unspec" (2)
# "470m" (4)
# "470bg" (5)
# "170m" (6)
# "240m" (7)
# "film" (8)
# "2020" (9)
# "st428" (10)
# "st431-2" (11)
# "st432-1" (12)
# "jedec-p22" (22)
####### color range #######
# "limited" (1)
# "full" (0)
####### chroma location #######
# "left" (0)
# "center" (1)
# "top_left" (2)
# "top" (3)
# "bottom_left" (4)
# "bottom" (5)
####### field based #######
# "progressive" (0)
# "top_field" (2)
# "bottom_field" (1)
####### gop closed #######
# true (1)
# false (0)



Function LWLInfo(
\ clip c,
\ bool "framenum",
\ bool "sarnum",
\ bool "sarden",
\ bool "durationnum",
\ bool "durationden",
\ bool "absolutetime",
\ bool "colorrange",
\ bool "primaries",
\ bool "transfer",
\ bool "matrix",
\ bool "chromalocation",
\ bool "picturetype",
\ bool "fieldbased",
\ bool "masteringdisplayprimariesx",
\ bool "masteringdisplayprimariesy",
\ bool "masteringdisplaywhitepointx",
\ bool "masteringdisplaywhitepointy",
\ bool "masteringdisplayminluminance",
\ bool "masteringdisplaymaxluminance",
\ bool "contentlightlevelmax",
\ bool "contentlightlevelaverage",
\ bool "aspectratio",
\ bool "gopnumber",
\ bool "gopposition",
\ bool "gopclosed",
\ bool "encodedframetop",
\ bool "encodedframebottom",
\ bool "quantsavg",
\ bool "quantsmin",
\ bool "quantsmax",
\ float "x",
\ float "y",
\ string "font",
\ float "size",
\ int "textcolor",
\ int "halocolor",
\ int "align",
\ int "spc",
\ int "lsp",
\ float "fontwidth",
\ float "fontangle")
{
    global framenum = Default(framenum, true)
    global sarnum = Default(sarnum, true)
    global sarden = Default(sarden, true)
    global durationnum = Default(durationnum, true)
    global durationden = Default(durationden, true)
    global absolutetime = Default(absolutetime, true)
    global colorrange = Default(colorrange, true)
    global primaries = Default(primaries, true)
    global transfer = Default(transfer, true)
    global matrix = Default(matrix, true)
    global chromalocation = Default(chromalocation, true)
    global picturetype = Default(picturetype, true)
    global fieldbased = Default(fieldbased, true)
    global masteringdisplayprimariesx = Default(masteringdisplayprimariesx, true)
    global masteringdisplayprimariesy = Default(masteringdisplayprimariesy, true)
    global masteringdisplaywhitepointx = Default(masteringdisplaywhitepointx, true)
    global masteringdisplaywhitepointy = Default(masteringdisplaywhitepointy, true)
    global masteringdisplayminluminance = Default(masteringdisplayminluminance, true)
    global masteringdisplaymaxluminance = Default(masteringdisplaymaxluminance, true)
    global contentlightlevelmax = Default(contentlightlevelmax, true)
    global contentlightlevelaverage = Default(contentlightlevelaverage, true)
    global aspectratio = Default(aspectratio, true)
    global gopnumber = Default(gopnumber, true)
    global gopposition = Default(gopposition, true)
    global gopclosed = Default(gopclosed, true)
    global encodedframetop = Default(encodedframetop, true)
    global encodedframebottom = Default(encodedframebottom, true)
    global quantsavg = Default(quantsavg, true)
    global quantsmin = Default(quantsmin, true)
    global quantsmax = Default(quantsmax, true)
    global font = Default(font, "Arial")
    global size = Default(size, 18)
    global textcolor = Default(textcolor, $FFFF00)
    global halocolor = Default(halocolor, $000000)
    global align = Default(align, 7)
    global spc = Default(spc, 0)
    global lsp = Default(lsp, 1)
    global fontwidth = Default(fontwidth, 0)
    global fontangle = Default(fontangle, 0)
    global x = Default(x, Defined(align) ? (align == 1 || align == 4 || align == 7) ? 8 : (align == 2 || align == 5 || align == 8) ? -1 : (align == 3 || align == 6 || align == 9) ? width(c) - 8 : NOP() : 8)
    global y = Default(y, Defined(align) ? (align == 4 || align == 5 || align == 6) ? size : (align == 7 || align == 8 || align == 9) ? 0 : (align == 1 || align == 2 || align == 3) ? height(c) - 1 : NOP() : 0)
    
    ScriptClip(c, """ temp_prop = ""
    if (framenum) { temp_prop = temp_prop + "Frame Number: " + String(current_frame) + " of " + String(FrameCount()) + "\n" }
    if (picturetype) { if (propGetType("_PictType") > 0) { temp_prop = temp_prop + "Picture Type: " + String(propGetString("_PictType")) + "\n" } }
    if (durationnum) { if (propGetType("_DurationNum") > 0) { temp_prop = temp_prop + "Duration Numerator: " + String(propGetInt("_DurationNum")) + "\n" } }
    if (durationden) { if (propGetType("_DurationDen") > 0) { temp_prop = temp_prop + "Duration Denominator: " + String(propGetInt("_DurationDen")) + "\n" } }
    
    if (absolutetime) { if (propGetType("_AbsoluteTime") > 0) { temp_prop = temp_prop + "Absolute Time: " + String(propGetFloat("_AbsoluteTime")) + "\n" } }
    
    if (colorrange) { if (propGetType("_ColorRange") > 0) { temp_prop = temp_prop + "Color Range: " + String(propGetInt("_ColorRange")) + "\n" } }
    if (primaries) { if (propGetType("_Primaries") > 0) { temp_prop = temp_prop + "Primaries: " + String(propGetInt("_Primaries")) + "\n" } }
    if (transfer) { if (propGetType("_Transfer") > 0) { temp_prop = temp_prop + "Transfer: " + String(propGetInt("_Transfer")) + "\n" } }
    if (matrix) { if (propGetType("_Matrix") > 0) { temp_prop = temp_prop + "Matrix: " + String(propGetInt("_Matrix")) + "\n" } }
    if (chromalocation) { if (propGetType("_ChromaLocation") > 0) { temp_prop = temp_prop + "Chroma Location: " + String(propGetInt("_ChromaLocation")) + "\n" } }    
    if (fieldbased) { if (propGetType("_FieldBased") > 0) { temp_prop = temp_prop + "Field Based: " + String(propGetInt("_FieldBased")) + "\n" } }
    if (sarnum) { if (propGetType("_SARNum") > 0) { temp_prop = temp_prop + "SAR Numerator: " + String(propGetInt("_SARNum")) + "\n" } }
    if (sarden) { if (propGetType("_SARDen") > 0) { temp_prop = temp_prop + "SAR Denominator: " + String(propGetInt("_SARDen")) + "\n" } }
    if (masteringdisplayprimariesx) { if (propGetType("MasteringDisplayPrimariesX") > 0) { temp_prop = temp_prop + "Mastering Display Primaries X: " + String(propGetAsArray("MasteringDisplayPrimariesX")[0]) + " " + String(propGetAsArray("MasteringDisplayPrimariesX")[1]) + " " + String(propGetAsArray("MasteringDisplayPrimariesX")[2]) + "\n" } }
    if (masteringdisplayprimariesy) { if (propGetType("MasteringDisplayPrimariesY") > 0) { temp_prop = temp_prop + "Mastering Display Primaries Y: " + String(propGetAsArray("MasteringDisplayPrimariesY")[0]) + " " + String(propGetAsArray("MasteringDisplayPrimariesY")[1]) + " " + String(propGetAsArray("MasteringDisplayPrimariesY")[2]) + "\n" } }
    if (masteringdisplaywhitepointx) { if (propGetType("MasteringDisplayWhitePointX") > 0) { temp_prop = temp_prop + "Mastering Display WhitePoint X: " + String(propGetFloat("MasteringDisplayWhitePointX")) + "\n" } }
    if (masteringdisplaywhitepointy) { if (propGetType("MasteringDisplayWhitePointY") > 0) { temp_prop = temp_prop + "Mastering Display White Point Y: " + String(propGetFloat("MasteringDisplayWhitePointY")) + "\n" } }
    if (masteringdisplayminluminance) { if (propGetType("MasteringDisplayMinLuminance") > 0) { temp_prop = temp_prop + "Mastering Display Min Luminance: " + String(propGetFloat("MasteringDisplayMinLuminance")) + "\n" } }
    if (masteringdisplaymaxluminance) {  if (propGetType("MasteringDisplayMaxLuminance") > 0) { temp_prop = temp_prop + "Mastering Display Max Luminance: " + String(propGetFloat("MasteringDisplayMaxLuminance")) + "\n" } }
    if (contentlightlevelmax) { if (propGetType("ContentLightLevelMax") > 0) { temp_prop = temp_prop + "Content LightLevel Max: " + String(propGetAny("ContentLightLevelMax")) + "\n" } }
    if (contentlightlevelaverage) { if (propGetType("ContentLightLevelAverage") > 0) { temp_prop = temp_prop + "Content Light Level Average: " + String(propGetAny("ContentLightLevelAverage")) + "\n" } }    
    
    if (aspectratio) { if (propGetType("_AspectRatio") > 0) { temp_prop = temp_prop + "Aspect Ratio: " + String(propGetString("_AspectRatio")) + "\n" } }
    if (gopnumber) { if (propGetType("_GOPNumber") > 0) { temp_prop = temp_prop + "GOP Number: " + String(propGetAsArray("_GOPNumber")[0]) + " (" + String(propGetAsArray("_GOPNumber")[1]) + ")" + "\n" } }
    if (gopposition) { if (propGetType("_GOPPosition") > 0) { temp_prop = temp_prop + "GOP Position: " + String(propGetInt("_GOPPosition")) + "\n" } }
    if (gopclosed) { if (propGetType("_GOPClosed") > 0) { temp_prop = temp_prop + "GOP Closed: " + String(propGetInt("_GOPClosed")) + "\n" } }
    if (encodedframetop) { if (propGetType("_EncodedFrameTop") > 0) { temp_prop = temp_prop + "Encoded Frame Top: " + String(propGetInt("_EncodedFrameTop")) + "\n" } }
    if (encodedframebottom) { if (propGetType("_EncodedFrameBottom") > 0) { temp_prop = temp_prop + "Encoded Frame Bottom: " + String(propGetInt("_EncodedFrameBottom")) + "\n" } }
    if (quantsavg) { if (propGetType("_QuantsAverage") > 0) { temp_prop = temp_prop + "Quants Average: " + String(propGetInt("_QuantsAverage")) + "\n" } }
    if (quantsmin) { if (propGetType("_QuantsMin") > 0) { temp_prop = temp_prop + "Quants Min: " + String(propGetInt("_QuantsMin")) + "\n" } }
    if (quantsmax) { if (propGetType("_QuantsMax") > 0) { temp_prop = temp_prop + "Quants Max: " + String(propGetInt("_QuantsMax")) + "\n" } }
    
    return Subtitle(temp_prop, x=x, y=y, font=font, size=size, text_color=textcolor, halo_color=halocolor, align=align, spc=spc, lsp=lsp, font_width=fontwidth, font_angle=fontangle)""", after_frame=true)
}
    