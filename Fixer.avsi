# New parameters added: int "uleft", int "utop", int "uright", int "ubottom", int "uradius", int "vleft", int "vtop", int "vright", int "vbottom", int "vradius", bool "u" , bool "v". Default values are the same as cleft, ctop, cright, cbottom, cradius. "u" and "v" give the opportunity to process only u / v plane or both planes with different settings
# all options are optional (Fixer(2), Fixer(right=1) and so on). Added restriction - clip width / height should be > left+2, rgith+2 / top+2, bottom+2 or chroma width / height should be > cleft+1, crgith+1 / ctop+1, cbottom+1 when only chroma is processed
# fixed default chroma radius when only chroma processed
# added optional parameter "luma" (default=true). When luma=false and chroma=true only chroma planes are processed
# changed Fixer radius (2) to max of left/top/right/bottom+2

# Alternative of FixRow(Column)Brightness/FillBorder/BalanceBorders/bbmod(BalanceBorders2)
# EdgeFixer required. High bit-depth supported (8..16-bit).
# For processing both chroma planes with same settings "chroma" option is enough.
# "chroma" and "u" / "v" cannot be true at the same time, when "chroma" is true "u" and "v" are false and vice versa. 
# "chroma", "u", "v" are false by default when luma is processed too but when only c(u)(v)left / c(u)(v)top / c(u)(v)/right / c(u)(v)bottom option(s) is/are used "chroma" / "u" / "v" are true and luma is false

# Some examples:
# Fixer(0,2,1,3) #only luma plane is processed
# Fixer(0,2,1,3,chroma=true) #luma and chroma planes are processed for top, right side and bottom.
# Fixer(0,2,1,3,chroma=true, cbottom=2) = Fixer(0,2,1,3,cbottom=2)
# Fixer(ctop=2) = Fixer(ctop=2, luma=false, chroma=true)
# Fixer(uleft=2, vbottom=4) = Fixer(uleft=2, vbottom=4, luma=false, u=true, v=true)


Function Fixer(clip c, int "left", int "top", int "right", int "bottom", int "radius", int "cleft", int "ctop", int "cright", int "cbottom", int "cradius", int "uleft", int "utop", int "uright", int "ubottom", int "uradius", int "vleft", int "vtop", int "vright", int "vbottom", int "vradius", bool "luma", bool "chroma", bool "u" , bool "v")
{
    Assert(is420(c), "Only 4:2:0 color format is supported")

    left    = Default(left, 0)
    top     = Default(top, 0)
    right   = Default(right, 0)
    bottom  = Default(bottom, 0)
    radius  = Default(radius, Max(left, top, right, bottom) + 2)
    luma    = Default(luma, left > 0 || top > 0 || right > 0 || bottom > 0 ? true : false)
    chroma  = Default(chroma, !Defined(cleft) && !Defined(ctop) && !Defined(cright) && !Defined(cbottom) && !Defined(cradius) ? false : true)
    cleft   = Default(cleft, Floor(left / 2))
    ctop    = Default(ctop, Floor(top / 2))
    cright  = Default(cright, Floor(right / 2))
    cbottom = Default(cbottom, Floor(bottom / 2))
    cradius = Default(cradius, Max(cleft, ctop, cright, cbottom) + 1)
    u       = Default(u, !Defined(uleft) && !Defined(utop) && !Defined(uright) && !Defined(ubottom) && !Defined(uradius) ? false : true)
    uleft   = Default(uleft, Floor(left / 2))
    utop    = Default(utop, Floor(top / 2))
    uright  = Default(uright, Floor(right / 2))
    ubottom = Default(ubottom, Floor(bottom / 2))
    uradius = Default(uradius, Max(uleft, utop, uright, ubottom) + 1)
    v       = Default(v, !Defined(vleft) && !Defined(vtop) && !Defined(vright) && !Defined(vbottom) && !Defined(vradius) ? false : true)
    vleft   = Default(vleft, Floor(left / 2))
    vtop    = Default(vtop, Floor(top / 2))
    vright  = Default(vright, Floor(right / 2))
    vbottom = Default(vbottom, Floor(bottom / 2))
    vradius = Default(vradius, Max(vleft, vtop, vright, vbottom) + 1)
    
    Assert(!chroma && !u && !v || chroma && !u && !v || !chroma && u && v || !chroma && u && !v || !chroma && !u && v, "chroma and u/v cannot be true at the same time")
    
    c
    luma ? Assert(left + 2 <= Width() && right + 2 <= Width(), "left+2, right+2 has to be <= width.") : NOP()
    luma ? Assert(top + 2 <= Height() && bottom + 2 <= Height(), "top+2, bottom+2 has to be <= height.") : NOP()
    Assert(cleft + 1 <= Width() / 2 && cright + 1 <= Width() / 2 && uleft + 1 <= Width() / 2 && uright + 1 <= Width() / 2 && vleft + 1 <= Width() / 2 && vright + 1 <= Width() / 2, "cleft+1, cright+1 has to be <= chroma plane(s) width.")
    Assert(ctop + 1 <= Height() / 2 && cbottom + 1 <= Height() / 2 && utop + 1 <= Height() / 2 && ubottom + 1 <= Height() / 2 && vtop + 1 <= Height() / 2 && vbottom + 1 <= Height() / 2, "ctop+1, cbottom+1 has to be <= chroma plane(s) height.")
    
    ContinuityFixer(left, top, right, bottom, radius)
    l = ExtractY()
    
    up = PlaneToY(c, "U").ContinuityFixer(cleft, ctop, cright, cbottom, cradius)
    vp = PlaneToY(c, "V").ContinuityFixer(cleft, ctop, cright, cbottom, cradius)
    
    u1 = PlaneToY(c, "U").ContinuityFixer(uleft, utop, uright, ubottom, uradius)
    v1 = PlaneToY(c, "V").ContinuityFixer(vleft, vtop, vright, vbottom, vradius)
    
    chroma ? luma ? CombinePlanes(l, up, vp, planes="YUV", sample_clip=c) : CombinePlanes(ExtractY(c), up, vp, planes="YUV", sample_clip=c) : u ? luma ? !v ? CombinePlanes(l, u1, ExtractV(c), planes="YUV", sample_clip=c) : CombinePlanes(l, u1, v1, planes="YUV", sample_clip=c) : v ? CombinePlanes(ExtractY(c), u1, v1, planes="YUV", sample_clip=c) : CombinePlanes(ExtractY(c), u1, ExtractV(c), planes="YUV", sample_clip=c) : luma ? v ? CombinePlanes(l, ExtractU(c), v1, planes="YUV", sample_clip=c) : CombinePlanes(l, ExtractU(c), ExtractV(c), planes="YUV", sample_clip=c) : v ? CombinePlanes(ExtractY(c), ExtractU(c), v1, planes="YUV", sample_clip=c) : c
}