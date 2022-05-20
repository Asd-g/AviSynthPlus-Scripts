/*
Script displaying LSMASHSource/FFMS2/D2VSource... frame properties.

The list below shows what the frame properties values corresponds to:

####### matrix #######
"rgb" (0)
"709" (1)
"unspec" (2)
"fcc" (4)
"470bg" (5)
"170m" (6)
"240m" (7)
"ycgco" (8)
"2020ncl"(9)
"2020cl" (10)
"chromancl" (12)
"chromacl" (13)
"ictcp" (14)

####### transfer #######
"709" (1)
"unspec" (2)
"470m" (4)
"470bg" (5)
"601" (6)
"240m" (7)
"linear" (8)
"log100" (9)
"log316" (10)
"xvycc" (11)
"srgb" (13)
"2020_10" (14)
"2020_12" (15)
"st2084" (16)
"std-b67" (18)

####### primaries #######
"709" (1)
"unspec" (2)
"470m" (4)
"470bg" (5)
"170m" (6)
"240m" (7)
"film" (8)
"2020" (9)
"st428" (10)
"st431-2" (11)
"st432-1" (12)
"jedec-p22" (22)

####### color range #######
"limited" (1)
"full" (0)

####### chroma location #######
"left" (0)
"center" (1)
"top_left" (2)
"top" (3)
"bottom_left" (4)
"bottom" (5)

####### field based #######
"progressive" (0)
"top_field" (2)
"bottom_field" (1)

####### gop closed #######
true (1)
false (0)
*/


### Changelog ###
# - Fixed missed default values.
####
# - Added new D2VSource frame properties (_FieldOperation, _FieldOrder, _Film, _ProgressiveFrame, _RFF, _TFF).
# - Updated _AspectRatio type for the latest D2VSource.
####
# - Changed the default value of y when align 4/5/6.
####
# - Allowed user defined runtime variables.
####
# - Changed parameters from global to local. Changed default values - only framenum and picturetype are true.
####
# - Added the other frame properties than picture type (_PictType) - _DurationNum, _DurationDen, _AbsoluteTime (FFMS2 only), _ColorRange (LSMASHSource/FFMS2), _Primaries (LSMASHSource/FFMS2), _Transfer (LSMASHSource/FFMS2), _Matrix, _ChromaLocation (LSMASHSource/FFMS2), _FieldBased, _SARNum (LSMASHSource/FFMS2), _SARDen (LSMASHSource/FFMS2), MasteringDisplayPrimariesX (LSMASHSource/FFMS2), MasteringDisplayPrimariesY (LSMASHSource/FFMS2), MasteringDisplayWhitePointX (LSMASHSource/FFMS2), MasteringDisplayWhitePointY (LSMASHSource/FFMS2), MasteringDisplayMinLuminance (LSMASHSource/FFMS2), MasteringDisplayMaxLuminance (LSMASHSource/FFMS2), ContentLightLevelMax (LSMASHSource/FFMS2), ContentLightLevelAverage (LSMASHSource/FFMS2), _AspectRatio (D2VSource), _GOPNumber (D2VSource), _GOPPosition (D2VSource), _GOPClosed (D2VSource), _EncodedFrameTop (D2VSource), _EncodedFrameBottom (D2VSource), _QuantsAverage (D2VSource), _QuantsMin (D2VSource), _QuantsMax (D2VSource).
####
# - Initial version.


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
\ bool "fieldoperation",
\ bool "fieldorder",
\ bool "film",
\ bool "progressiveframe",
\ bool "rff",
\ bool "tff",
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
    framenum = Default(framenum, true)
    sarnum = Default(sarnum, false)
    sarden = Default(sarden, false)
    durationnum = Default(durationnum, false)
    durationden = Default(durationden, false)
    absolutetime = Default(absolutetime, false)
    colorrange = Default(colorrange, false)
    primaries = Default(primaries, false)
    transfer = Default(transfer, false)
    matrix = Default(matrix, false)
    chromalocation = Default(chromalocation, false)
    picturetype = Default(picturetype, true)
    fieldbased = Default(fieldbased, false)
    masteringdisplayprimariesx = Default(masteringdisplayprimariesx, false)
    masteringdisplayprimariesy = Default(masteringdisplayprimariesy, false)
    masteringdisplaywhitepointx = Default(masteringdisplaywhitepointx, false)
    masteringdisplaywhitepointy = Default(masteringdisplaywhitepointy, false)
    masteringdisplayminluminance = Default(masteringdisplayminluminance, false)
    masteringdisplaymaxluminance = Default(masteringdisplaymaxluminance, false)
    contentlightlevelmax = Default(contentlightlevelmax, false)
    contentlightlevelaverage = Default(contentlightlevelaverage, false)
    aspectratio = Default(aspectratio, false)
    gopnumber = Default(gopnumber, false)
    gopposition = Default(gopposition, false)
    gopclosed = Default(gopclosed, false)
    encodedframetop = Default(encodedframetop, false)
    encodedframebottom = Default(encodedframebottom, false)
    quantsavg = Default(quantsavg, false)
    quantsmin = Default(quantsmin, false)
    quantsmax = Default(quantsmax, false)
    fieldoperation = Default(fieldoperation, false)
    fieldorder = Default(fieldorder, false)
    film = Default(film, false)
    progressiveframe = Default(progressiveframe, false)
    rff = Default(rff, false)
    tff = Default(tff, false)
    font = Default(font, "Arial")
    size = Default(size, 18)
    textcolor = Default(textcolor, $FFFF00)
    halocolor = Default(halocolor, $000000)
    align = Default(align, 7)
    spc = Default(spc, 0)
    lsp = Default(lsp, 1)
    fontwidth = Default(fontwidth, 0)
    fontangle = Default(fontangle, 0)
    x = Default(x, Defined(align) ? (align == 1 || align == 4 || align == 7) ? 8 : (align == 2 || align == 5 || align == 8) ? -1 : (align == 3 || align == 6 || align == 9) ? width(c) - 8 : NOP() : 8)
    y = Default(y, Defined(align) ? (align == 4 || align == 5 || align == 6) ? -1 : (align == 7 || align == 8 || align == 9) ? 0 : (align == 1 || align == 2 || align == 3) ? height(c) - 1 : NOP() : 0)

    ScriptClip(c, """
        font_ = """"+ font +""""
        size_ = """+ String(size) +"""
        textcolor_ = """+ String(textcolor) +"""
        halocolor_ = """+ String(halocolor) +"""
        align_ = """+ String(align) +"""
        spc_ = """+ String(spc) +"""
        lsp_ = """+ String(lsp) +"""
        fontwidth_ = """+ String(fontwidth) +"""
        fontangle_ = """+ String(fontangle) +"""
        x_ = """+ String(x) +"""
        y_ = """+ String(y) +"""

        temp_prop = ""

        if ("""+ String(framenum) +""") { temp_prop = temp_prop + "Frame Number: " + String(current_frame) + " of " + String(FrameCount()) + "\n" }
        if ("""+ String(picturetype) +""") { if (propGetType("_PictType") > 0) { temp_prop = temp_prop + "Picture Type: " + String(propGetString("_PictType")) + "\n" } }

        if ("""+ String(durationnum) +""") { if (propGetType("_DurationNum") > 0) { temp_prop = temp_prop + "Duration Numerator: " + String(propGetInt("_DurationNum")) + "\n" } }
        if ("""+ String(durationden) +""") { if (propGetType("_DurationDen") > 0) { temp_prop = temp_prop + "Duration Denominator: " + String(propGetInt("_DurationDen")) + "\n" } }
        if ("""+ String(absolutetime) +""") { if (propGetType("_AbsoluteTime") > 0) { temp_prop = temp_prop + "Absolute Time: " + String(propGetFloat("_AbsoluteTime")) + "\n" } }

        if ("""+ String(colorrange) +""") { if (propGetType("_ColorRange") > 0) { temp_prop = temp_prop + "Color Range: " + String(propGetInt("_ColorRange")) + "\n" } }
        if ("""+ String(primaries) +""") { if (propGetType("_Primaries") > 0) { temp_prop = temp_prop + "Primaries: " + String(propGetInt("_Primaries")) + "\n" } }
        if ("""+ String(transfer) +""") { if (propGetType("_Transfer") > 0) { temp_prop = temp_prop + "Transfer: " + String(propGetInt("_Transfer")) + "\n" } }
        if ("""+ String(matrix) +""") { if (propGetType("_Matrix") > 0) { temp_prop = temp_prop + "Matrix: " + String(propGetInt("_Matrix")) + "\n" } }
        if ("""+ String(chromalocation) +""") { if (propGetType("_ChromaLocation") > 0) { temp_prop = temp_prop + "Chroma Location: " + String(propGetInt("_ChromaLocation")) + "\n" } }

        if ("""+ String(fieldbased) +""") { if (propGetType("_FieldBased") > 0) { temp_prop = temp_prop + "Field Based: " + String(propGetInt("_FieldBased")) + "\n" } }

        if ("""+ String(sarnum) +""") { if (propGetType("_SARNum") > 0) { temp_prop = temp_prop + "SAR Numerator: " + String(propGetInt("_SARNum")) + "\n" } }
        if ("""+ String(sarden) +""") { if (propGetType("_SARDen") > 0) { temp_prop = temp_prop + "SAR Denominator: " + String(propGetInt("_SARDen")) + "\n" } }

        if ("""+ String(masteringdisplayprimariesx) +""") { if (propGetType("MasteringDisplayPrimariesX") > 0) { temp_prop = temp_prop + "Mastering Display Primaries X: " + String(propGetAsArray("MasteringDisplayPrimariesX")[0]) + " " + String(propGetAsArray("MasteringDisplayPrimariesX")[1]) + " " + String(propGetAsArray("MasteringDisplayPrimariesX")[2]) + "\n" } }
        if ("""+ String(masteringdisplayprimariesy) +""") { if (propGetType("MasteringDisplayPrimariesY") > 0) { temp_prop = temp_prop + "Mastering Display Primaries Y: " + String(propGetAsArray("MasteringDisplayPrimariesY")[0]) + " " + String(propGetAsArray("MasteringDisplayPrimariesY")[1]) + " " + String(propGetAsArray("MasteringDisplayPrimariesY")[2]) + "\n" } }
        if ("""+ String(masteringdisplaywhitepointx) +""") { if (propGetType("MasteringDisplayWhitePointX") > 0) { temp_prop = temp_prop + "Mastering Display WhitePoint X: " + String(propGetFloat("MasteringDisplayWhitePointX")) + "\n" } }
        if ("""+ String(masteringdisplaywhitepointy) +""") { if (propGetType("MasteringDisplayWhitePointY") > 0) { temp_prop = temp_prop + "Mastering Display White Point Y: " + String(propGetFloat("MasteringDisplayWhitePointY")) + "\n" } }
        if ("""+ String(masteringdisplayminluminance) +""") { if (propGetType("MasteringDisplayMinLuminance") > 0) { temp_prop = temp_prop + "Mastering Display Min Luminance: " + String(propGetFloat("MasteringDisplayMinLuminance")) + "\n" } }
        if ("""+ String(masteringdisplaymaxluminance) +""") {  if (propGetType("MasteringDisplayMaxLuminance") > 0) { temp_prop = temp_prop + "Mastering Display Max Luminance: " + String(propGetFloat("MasteringDisplayMaxLuminance")) + "\n" } }
        if ("""+ String(contentlightlevelmax) +""") { if (propGetType("ContentLightLevelMax") > 0) { temp_prop = temp_prop + "Content LightLevel Max: " + String(propGetAny("ContentLightLevelMax")) + "\n" } }
        if ("""+ String(contentlightlevelaverage) +""") { if (propGetType("ContentLightLevelAverage") > 0) { temp_prop = temp_prop + "Content Light Level Average: " + String(propGetAny("ContentLightLevelAverage")) + "\n" } }

        if ("""+ String(aspectratio) +""") { if (propGetType("_AspectRatio") > 0) { temp_prop = temp_prop + "Aspect Ratio: " + String(propGetAsArray("_AspectRatio")[0]) + " " + String(propGetAsArray("_AspectRatio")[1]) + "\n" } }
        if ("""+ String(gopnumber) +""") { if (propGetType("_GOPNumber") > 0) { temp_prop = temp_prop + "GOP Number: " + String(propGetAsArray("_GOPNumber")[0]) + " (" + String(propGetAsArray("_GOPNumber")[1]) + ")" + "\n" } }
        if ("""+ String(gopposition) +""") { if (propGetType("_GOPPosition") > 0) { temp_prop = temp_prop + "GOP Position: " + String(propGetInt("_GOPPosition")) + "\n" } }
        if ("""+ String(gopclosed) +""") { if (propGetType("_GOPClosed") > 0) { temp_prop = temp_prop + "GOP Closed: " + String(propGetInt("_GOPClosed")) + "\n" } }
        if ("""+ String(encodedframetop) +""") { if (propGetType("_EncodedFrameTop") > 0) { temp_prop = temp_prop + "Encoded Frame Top: " + String(propGetInt("_EncodedFrameTop")) + "\n" } }
        if ("""+ String(encodedframebottom) +""") { if (propGetType("_EncodedFrameBottom") > 0) { temp_prop = temp_prop + "Encoded Frame Bottom: " + String(propGetInt("_EncodedFrameBottom")) + "\n" } }
        if ("""+ String(quantsavg) +""") { if (propGetType("_QuantsAverage") > 0) { temp_prop = temp_prop + "Quants Average: " + String(propGetInt("_QuantsAverage")) + "\n" } }
        if ("""+ String(quantsmin) +""") { if (propGetType("_QuantsMin") > 0) { temp_prop = temp_prop + "Quants Min: " + String(propGetInt("_QuantsMin")) + "\n" } }
        if ("""+ String(quantsmax) +""") { if (propGetType("_QuantsMax") > 0) { temp_prop = temp_prop + "Quants Max: " + String(propGetInt("_QuantsMax")) + "\n" } }
        if ("""+ String(fieldoperation) +""") { if (propGetType("_FieldOperation") > 0) { temp_prop = temp_prop + "Field Operation: " + String(propGetInt("_FieldOperation")) + "\n" } }
        if ("""+ String(fieldorder) +""") { if (propGetType("_FieldOrder") > 0) { temp_prop = temp_prop + "Field Order: " + String(propGetInt("_FieldOrder")) + "\n" } }
        if ("""+ String(film) +""") { if (propGetType("_Film") > 0) { temp_prop = temp_prop + "Film: " + String(propGetInt("_Film")) + "\n" } }
        if ("""+ String(progressiveframe) +""") { if (propGetType("_ProgressiveFrame") > 0) { temp_prop = temp_prop + "Progressive Frame: " + String(propGetInt("_ProgressiveFrame")) + "\n" } }
        if ("""+ String(rff) +""") { if (propGetType("_RFF") > 0) { temp_prop = temp_prop + "RFF: " + String(propGetInt("_RFF")) + "\n" } }
        if ("""+ String(tff) +""") { if (propGetType("_TFF") > 0) { temp_prop = temp_prop + "TFF: " + String(propGetInt("_TFF")) + "\n" } }

    return Subtitle(temp_prop, x=x_, y=y_, font=font_, size=size_, text_color=textcolor_, halo_color=halocolor_, align=align_, spc=spc_, lsp=lsp_, font_width=fontwidth_, font_angle=fontangle_) """, after_frame=true)
}
