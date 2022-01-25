/* removed global variables
   fixed default value of y when align 4/5/6 */

/* added new options: - frametypenos - doesn't display the frametype string (Intra, Bi-dir predicted and so on), default=false. When frametype=false frametypenos=true and vice versa. To disable completely frametype - frametype=disable and frametypenos=disable;
- font;
- size;
- textcolor - http://avisynth.nl/index.php/Preset_colors (the values are HEX);
- halocolor - again HEX values;
- align *;
- spc *;
- lsp *;
- fontwidth *;
- fontangle *;
- x *;
- y *;
 * for more information check the equivalent options http://avisynth.nl/index.php/Subtitle */

# FFmpegSource 2.22 helper functions
# Created by TheFluff

function FFFormatTime(int ms) {

	s = ms / 1000
	ms = ms % 1000
	m = s / 60
	s = s % 60
	h = m / 60
	m = m % 60

	return ms < 0 ? "<Unknown>" : string(h) + ":" + string(m,"%02.0f") + ":" + string(s,"%02.0f") + "." + string(ms,"%03.0f")
}

function FFColorSpace(int i) {
    i=(i<0||i>10) ? 2 : i
    return Select(i,"RGB","BT709 (ITU-R Rec.709)","Unspecified","Unspecified","FCC","BT470BG (ITU-R Rec.601)","SMPTE 170M (ITU-R Rec.601)","SMPTE 240M","YCoCg","BT2020 NCL","BT2020 NC")
}

function FFColorRange(int i) {
    i=(i<0||i>2) ? 0 : i
    return Select(i,"Unknown/Unspecified","Limited range","Full range")
}

function FFCropping(int l, int t, int r, int b) {
    return "Left="+String(l)+" Top="+String(t)+" Right="+String(r)+" Bottom="+String(b)
}

function FFSampAR(int num, int den) {
    return num > 0 ? String(num)+":"+String(den)+((num<=0 || den<=0)?"":string(Float(num)/den," (%.3f)")) : "Unknown/Unspecified"
}

function FFPictType(int ch) {
    s=chr(ch)
    s = s + (
        \ ch==73?" (Intra)":ch==80?" (Predicted)":ch==66?" (Bi-dir predicted)":ch==83?" (S(GMC)-VOP MPEG4)"
        \ : ch==105?" (Switching Intra)":ch==112?" (Switching Predicted)":ch==98?" (FF_BI_TYPE)"
        \ : " (Unknown)")
    return s
}

function FFPictType_nos(int ch) {
    s=chr(ch)
    return s
}

function FFInfo(clip c, bool "framenum", bool "frametype", bool "frametypenos", bool "cfrtime", bool "vfrtime", string "varprefix",
    \ bool "colorspace",bool "colorrange",bool "cropping",bool "sar",bool "version",bool "showprefix", float "x", float "y", string "font", float "size", int "textcolor", int "halocolor", int "align", int "spc", int "lsp", float "fontwidth", float "fontangle") {

    framenum     = default(framenum,true)
    frametype    = default(frametype,true)
    frametypenos = default(frametypenos, frametype ? false : true)
    cfrtime      = default(cfrtime,true)
    vfrtime      = default(vfrtime,true)
    varprefix    = default(varprefix, FFVAR_PREFIX)
    colorSpace   = default(colorspace,true)
    colorrange   = default(colorrange,true)
    cropping     = default(cropping,true)
    sar          = default(sar,true)
    version      = default(version,true)
    showprefix   = default(showprefix,false)
    font         = default(font, "Arial")
    size         = default(size, 18)
    textcolor    = default(textcolor, $FFFF00)
    halocolor    = default(halocolor, $000000)
    align        = default(align, 7)
    spc          = default(spc, 0)
    lsp          = default(lsp, 1)
    fontwidth    = default(fontwidth, 0)
    fontangle    = default(fontangle, 0)
    x            = default(x, Defined(align) ? (align == 1 || align == 4 || align == 7) ? 8 : (align == 2 || align == 5 || align == 8) ? -1 : (align == 3 || align == 6 || align == 9) ? width(c) - 8 : NOP() : 8)
    y            = default(y, Defined(align) ? (align == 4 || align == 5 || align == 6) ? -1 : (align == 7 || align == 8 || align == 9) ? 0 : (align == 1 || align == 2 || align == 3) ? height(c) - 1 : NOP() : 0)

    c.frameevaluate("""
        fftempstring = ""
        varprefix = """" + varprefix + """"

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
    """)

    version      ? frameevaluate("""fftempstring = fftempstring + "Version: " + FFGetVersion + "\n" """, after_frame=true) : nop()
    framenum     ? frameevaluate("""fftempstring = fftempstring + "Frame Number: " + string(current_frame) + " of " + string(framecount()) + "\n" """, after_frame=true) : nop()
    frametype    ? frameevaluate("""fftempstring = fftempstring + "Picture Type: " + FFPictType(eval(varprefix + "FFPICT_TYPE")) + "\n" """, after_frame=true) : nop()
    frametypenos ? frameevaluate("""fftempstring = fftempstring + "Picture Type: " + FFPictType_nos(eval(varprefix + "FFPICT_TYPE")) + "\n" """, after_frame=true) : nop()
    cfrtime      ? frameevaluate("""fftempstring = fftempstring + "CFR Time: " + FFFormatTime(round((current_frame * 1000) / framerate())) + "\n" """, after_frame=true) : nop()
    vfrtime      ? frameevaluate("""fftempstring = fftempstring + "VFR Time: " + FFFormatTime(eval(varprefix + "FFVFR_TIME")) + "\n" """, after_frame=true) : nop()
    colorspace   ? frameevaluate("""fftempstring = fftempstring + "ColorSpace: " + FFColorSpace(eval(varprefix + "FFCOLOR_SPACE")) + "\n" """, after_frame=true) : nop()
    colorrange   ? frameevaluate("""fftempstring = fftempstring + "Color Range: " + FFColorRange(eval(varprefix + "FFCOLOR_RANGE")) + "\n" """, after_frame=true) : nop()
    cropping     ? frameevaluate("""fftempstring = fftempstring + "Cropping: " + FFCropping(eval(varprefix + "FFCROP_LEFT"),eval(varprefix + "FFCROP_TOP"),eval(varprefix + "FFCROP_RIGHT"),eval(varprefix + "FFCROP_BOTTOM")) + "\n" """, after_frame=true) : nop()
    sar          ? frameevaluate("""fftempstring = fftempstring + "SAR: " + FFSampAR(eval(varprefix + "FFSAR_NUM"),eval(varprefix + "FFSAR_DEN")) + "\n" """, after_frame=true) : nop()
    showprefix   ? frameevaluate("""fftempstring = fftempstring + "Prefix: '" + varprefix + "'\n" """, after_frame=true) : nop()

    return scriptclip("subtitle(fftempstring, x = x_, y = y_, font = font_, size = size_, text_color = textcolor_, halo_color = halocolor_, align = align_, spc = spc_, lsp = lsp_, font_width = fontwidth_, font_angle = fontangle_)", after_frame=true)
}