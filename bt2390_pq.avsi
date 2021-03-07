### Tone mapping using BT.2390 (PQ)


### Usage ###
###
# bt2390_pq(clip c, int "mdmaxl", int "tdmaxl", float "mdminl", float "tdminl", bool "cs", float "cs_weight", bool "use_alternate", bool "output8", bool "peak_compute")
###
## Parameters ##
#---------------
# c: The clip that will be tone mapped.
#---------------
# mdmaxl: Mastering Display Max Luminance.
# If not specified and frame property "MasteringDisplayMaxLuminance" exist, the values of the frame property is used.
# If not specified and frame property "MasteringDisplayMaxLuminance" doesn't exist, 1000 is used.
#---------------
# tdmaxl (default 200): Target Display Max Luminance.
# Must be less than mdmaxl.
# If peak_compute=true an additional coeff based on the relation peak nits/average nits is applied to tdmaxl. It would prevent severe clipping.
#---------------
# mdminl: Mastering Display Min Luminance.
# If not specified and frame property "MasteringDisplayMinLuminance" exist, the values of the frame property is used.
# If not specified and frame property "MasteringDisplayMinLuminance" doesn't exist, 0.005 is used.
#---------------
# tdminl (default mdminl): Target Display Min Luminance.
# Must be equal or greater than mdminl.
#---------------
# cs (default false): Whether to perform additional color desaturation of the highlights.
#---------------
# cs_weight (default 0.5): Coeff of desaturation performed by cs.
# Must be between 0.0..1.0.
# Higher values leads to more desaturation.
#---------------
# use_alternate (default false): Whether to perform additional compression of the highlights.
# It allows to preserve more details at the cost of some desaturation.
#---------------
# output8 (default true): When true the output is YUV420P8, otherwise YUV444P16.
#---------------
# peak_compute (default true): Whether to calculate the stats of the frame.
# If true: frame peak nits and average nits are calculated and additional coeff is applied to tdmaxl. It makes the script quite slower compared to peak_compute=false.


### NOTE ###
/*
When peak_compute=false:
- If "mdmaxl" and/or "mdminl" not specified a temporary file "_stats.txt" is created in %temp% folder containing the values of the frame properties "MasteringDisplayMaxLuminance"/"MasteringDisplayMaxLuminance".
- This temporary file is automatically deleted when the frame is ready.
*/


Function bt2390_pq(clip c, int "mdmaxl", int "tdmaxl", float "mdminl", float "tdminl", bool "cs", float "cs_weight", bool "use_alternate", bool "output8", bool "peak_compute")
{
    _cs = Default(cs, false)
    cs_weight = Default(cs_weight, 0.5)
    use_alternate = Default(use_alternate, false)
    output8 = Default(output8, true)
    peak_compute = Default(peak_compute, true)
    
    Assert(cs_weight >= 0.0 && cs_weight <= 1.0, "bt2390_pq: cs_weight must be between 0.0..1.0.")    
    
    return (peak_compute) ? _dynamic(c, mdmaxl, tdmaxl, mdminl, tdminl, _cs, cs_weight, use_alternate, output8) : _static(c, mdmaxl, tdmaxl, mdminl, tdminl, _cs, cs_weight, use_alternate, output8)
}

Function _static(clip c, int "mdmaxl", int "tdmaxl", float "mdminl", float "tdminl", bool "_cs", float "cs_weight", bool "use_alternate", bool "output8")
{
    _min = !Defined(mdminl)
    _max = !Defined(mdmaxl)
    if (_min || _max)
    {
        temp_dir = RT_GetSystemEnv("temp") + "\" + "_stats.txt"
        
        current_frame=0
        ScriptClip(c, """
            if (_max) { RT_TxtWriteFile((propGetType("MasteringDisplayMaxLuminance")) > 0 ? String(propGetFloat("MasteringDisplayMaxLuminance")) : "1000.0", temp_dir) }
            if (_min) { RT_TxtWriteFile((propGetType("MasteringDisplayMinLuminance")) > 0 ? String(propGetFloat("MasteringDisplayMinLuminance")) : "0.005", temp_dir, true) }
        """, args="temp_dir, _min, _max")
        AverageLuma()
        
        mdmaxl = _max ? Value(RT_ReadTxtFromFile(temp_dir, 1, 0)) : mdmaxl
        mdminl = _min ? _max ? Value(RT_ReadTxtFromFile(temp_dir, 1, 1)) : Value(RT_ReadTxtFromFile(temp_dir, 1, 0)) : mdminl
    }
    
    tdmaxl = Default(tdmaxl, 200)
    tdminl = Default(tdminl, mdminl)
    
    Assert(tdmaxl < mdmaxl, "bt2390_pq: tdmaxl must be less than mdmaxl.")
    Assert(tdminl >= mdminl, "bt2390_pq: tdminl must be equal or greater than mdminl.")
    
    lw = mdmaxl / 10000.0
    pq_lw = pow((((pow(lw, 0.1593017578125) * 18.8515625) + 0.8359375) / ((pow(lw, 0.1593017578125) * 18.6875) + 1)),78.84375)
    
    lb = mdminl / 10000.0
    pq_lb = pow((((pow(lb, 0.1593017578125) * 18.8515625) + 0.8359375) / ((pow(lb, 0.1593017578125) * 18.6875) + 1)),78.84375)
    
    tw = tdmaxl / 10000.0
    pq_tw = pow((((pow(tw, 0.1593017578125) * 18.8515625) + 0.8359375) / ((pow(tw, 0.1593017578125) * 18.6875) + 1)),78.84375)
    
    tb = tdminl / 10000.0
    pq_tb = pow((((pow(tb, 0.1593017578125) * 18.8515625) + 0.8359375) / ((pow(tb, 0.1593017578125) * 18.6875) + 1)), 78.84375)
    
    if (use_alternate)
    {
        maxci = min((pq_lw - pq_lb) / (1.0 - pq_lb), 1.0)
        pq_lw = 1.0    
    }
    else { maxci = 1.0 }
    
    minLum = (pq_tb - pq_lb) / (pq_lw - pq_lb)
    maxi = (pq_tw - pq_lb) / (pq_lw - pq_lb) 
    
    ks = 1.5 * maxi - 0.5
    
    if (maxi <= maxci)
    {
        T = (maxci - ks) / (1.0 - ks)
        s = (maxci - maxi) / (maxci - ((2 * pow(T, 3) - 3 * pow(T, 2) + 1) * KS + (pow(T, 3) - 2 * pow(T, 2) + T) * (1 - KS) + (-2 * pow(T, 3) + 3 * pow(T, 2)) * maxi))
    }
    
    if (_cs)
    {            
        linear = z_ConvertFormat(c, pixel_type="rgbps", colorspace_op="2020:st2084:2020=>rgb:linear:2020", resample_filter_uv="spline36", nominal_luminance=mdmaxl)
        eb = lw / tw
        cs = Expr(linear, "x "+ String(eb) +" *")
        _l = Expr(ExtractR(cs), ExtractG(cs), ExtractB(cs), "0.2627 x * 0.6780 y * + 0.0593 z * +")
        z_ConvertFormat(Merge(cs, Overlay(cs, CombinePlanes(_l, _l, _l, planes="rgb", pixel_type="rgbps"), mask=Expr(ExtractR(cs), ExtractG(cs), ExtractB(cs), " x x * y y * + z z * + x y + z + / 1 - "+ String(eb) +" 1 - / 0 1 clip")), cs_weight), colorspace_op="rgb:linear:2020=>rgb:st2084:2020", nominal_luminance=tdmaxl)
    }
    else { z_ConvertFormat(c, pixel_type="rgbps", colorspace_op="2020:st2084:2020=>rgb:st2084:2020", resample_filter_uv="spline36") }
    
    e1 = Expr(last, "x "+ String(pq_lb) +" - "+ String(pq_lw) +" "+ String(pq_lb) +" - / 0 1 clip")
    t = Expr(e1, "x "+ String(ks) +" - 1 "+ String(ks) +" - /")
    p = Expr(t, "2 x 3 pow * 3 x 2 pow * - 1 + "+ String(ks) +" * 1 "+ String(ks) +" - x 3 pow 2 x 2 pow * - x + * + -2 x 3 pow * 3 x 2 pow * + "+ String(maxi) +" * +")
    
    e2 = Expr(e1, p, "x "+ String(ks) +" < x "+ String(maxi) +" "+ String(maxci) +" <= x x y - "+ String(s) +" * - "+ String(maxi) +" min x "+ String(maxci) +" min ? ?")
    
    e3 = Expr(e2, "x 1 <= "+ String(maxi) +" 1 < x "+ String(minLum) +" 1 x - "+ String(minLum) +" 0 >= 1.0 "+ String(minLum) +" / 4 min 4 ? pow * + "+ String(minLum) +" - "+ String(maxi) +" "+ String(minLum) +" - * "+ String(maxi) +" "+ String(minLum) +" 1 "+ String(maxi) +" - "+ String(minLum) +" 0 >= 1.0 "+ String(minLum) +" / 4 min 4 ? pow * + "+ String(minLum) +" - / "+ String(minLum) +" + x ? x ?")
    
    Expr(e3, "x "+ String(pq_lw) +" "+ String(pq_lb) +" - * "+ String(pq_lb) +" + 0.0 max")

    if (output8) { z_ConvertFormat(pixel_type="yv12", colorspace_op="rgb:st2084:2020=>709:709:709", resample_filter_uv="spline36", chromaloc_op="top_left=>left", nominal_luminance=tdmaxl, dither_type="error_diffusion") }
    else { z_ConvertFormat(pixel_type="yuv444p16", colorspace_op="rgb:st2084:2020=>709:709:709", resample_filter_uv="spline36", nominal_luminance=tdmaxl, dither_type="error_diffusion") }
    
    if (_min || _max) { ScriptClip(""" CallCmd(close="cmd /c del " + temp_dir, hide=true) """, args="temp_dir") }
    
    return last
}

Function _dynamic(clip c, int "mdmaxl", int "tdmaxl", float "mdminl", float "tdminl", bool "_cs", float "cs_weight", bool "use_alternate", bool "output8")
{
    ScriptClip((output8) ? z_ConvertFormat(c, pixel_type="yv12", resample_filter_uv="spline36", chromaloc_op="top_left=>left", dither_type="error_diffusion") :
    \ z_ConvertFormat(c, pixel_type="yuv444p16", chromaloc_op="top_left=>top_left", resample_filter_uv="spline36"), """
        
        mdmaxl = Default(mdmaxl, (propGetType("MasteringDisplayMaxLuminance") > 0) ? propGetFloat("MasteringDisplayMaxLuminance") : 1000.0)
        mdminl = Default(mdminl, (propGetType("MasteringDisplayMinLuminance") > 0) ? propGetFloat("MasteringDisplayMinLuminance") : 0.005)
        
        _lin = z_ConvertFormat(c, pixel_type="rgbps", colorspace_op="2020:st2084=>rgb:linear", resample_filter_uv="spline36", chromaloc_op="top_left=>top_left", nominal_luminance=mdmaxl)
        tdmaxl = min(pow((Defined(tdmaxl)) ? tdmaxl : 200.0, 1 + 1 / ((0.2627 * RPlaneMax(_lin) + 0.678 * GPlaneMax(_lin) + 0.0593 * BPlaneMax(_lin)) / (0.2627 * AverageR(_lin) + 0.678 * AverageG(_lin) + 0.0593 * AverageB(_lin)))), mdmaxl / 1.4)
        tdminl = Default(tdminl, mdminl)
        
        Assert(tdmaxl < mdmaxl, "bt2390_pq: tdmaxl must be less than mdmaxl.")
        Assert(tdminl >= mdminl, "bt2390_pq: tdminl must be equal or greater than mdminl.")
        
        lw = mdmaxl / 10000.0
        pq_lw = pow((((pow(lw, 0.1593017578125) * 18.8515625) + 0.8359375) / ((pow(lw, 0.1593017578125) * 18.6875) + 1)),78.84375)
    
        lb = mdminl / 10000.0
        pq_lb = pow((((pow(lb, 0.1593017578125) * 18.8515625) + 0.8359375) / ((pow(lb, 0.1593017578125) * 18.6875) + 1)),78.84375)
    
        tw = tdmaxl / 10000.0
        pq_tw = pow((((pow(tw, 0.1593017578125) * 18.8515625) + 0.8359375) / ((pow(tw, 0.1593017578125) * 18.6875) + 1)),78.84375)
    
        tb = tdminl / 10000.0
        pq_tb = pow((((pow(tb, 0.1593017578125) * 18.8515625) + 0.8359375) / ((pow(tb, 0.1593017578125) * 18.6875) + 1)), 78.84375)
            
        if (use_alternate)
        {
            maxci = min((pq_lw - pq_lb) / (1.0 - pq_lb), 1.0)
            pq_lw = 1.0    
        }
        else { maxci = 1.0 }
    
        minLum = (pq_tb - pq_lb) / (pq_lw - pq_lb)
        maxi = (pq_tw - pq_lb) / (pq_lw - pq_lb) 
    
        ks = 1.5 * maxi - 0.5
    
        if (maxi <= maxci)
        {
            T = (maxci - ks) / (1.0 - ks)
            s = (maxci - maxi) / (maxci - ((2 * pow(T, 3) - 3 * pow(T, 2) + 1) * KS + (pow(T, 3) - 2 * pow(T, 2) + T) * (1 - KS) + (-2 * pow(T, 3) + 3 * pow(T, 2)) * maxi))
        }
        
        if (_cs)
        {            
            linear = z_ConvertFormat(c, pixel_type="rgbps", colorspace_op="2020:st2084:2020=>rgb:linear:2020", resample_filter_uv="spline36", nominal_luminance=mdmaxl)
            eb = lw / tw
            cs = Expr(linear, "x "+ String(eb) +" *")
            _l = Expr(ExtractR(cs), ExtractG(cs), ExtractB(cs), "0.2627 x * 0.6780 y * + 0.0593 z * +")
            z_ConvertFormat(Merge(cs, Overlay(cs, CombinePlanes(_l, _l, _l, planes="rgb", pixel_type="rgbps"), mask=Expr(ExtractR(cs), ExtractG(cs), ExtractB(cs), " x x * y y * + z z * + x y + z + / 1 - "+ String(eb) +" 1 - / 0 1 clip")), cs_weight), colorspace_op="rgb:linear:2020=>rgb:st2084:2020", nominal_luminance=tdmaxl)
        }
        else { z_ConvertFormat(c, pixel_type="rgbps", colorspace_op="2020:st2084:2020=>rgb:st2084:2020", resample_filter_uv="spline36") }
    
        e1 = Expr(last, "x "+ String(pq_lb) +" - "+ String(pq_lw) +" "+ String(pq_lb) +" - / 0 1 clip")
        t = Expr(e1, "x "+ String(ks) +" - 1 "+ String(ks) +" - /")
        p = Expr(t, "2 x 3 pow * 3 x 2 pow * - 1 + "+ String(ks) +" * 1 "+ String(ks) +" - x 3 pow 2 x 2 pow * - x + * + -2 x 3 pow * 3 x 2 pow * + "+ String(maxi) +" * +")
        
        e2 = Expr(e1, p, "x "+ String(ks) +" < x "+ String(maxi) +" "+ String(maxci) +" <= x x y - "+ String(s) +" * - "+ String(maxi) +" min x "+ String(maxci) +" min ? ?")
        
        e3 = Expr(e2, "x 1 <= "+ String(maxi) +" 1 < x "+ String(minLum) +" 1 x - "+ String(minLum) +" 0 >= 1.0 "+ String(minLum) +" / 4 min 4 ? pow * + "+ String(minLum) +" - "+ String(maxi) +" "+ String(minLum) +" - * "+ String(maxi) +" "+ String(minLum) +" 1 "+ String(maxi) +" - "+ String(minLum) +" 0 >= 1.0 "+ String(minLum) +" / 4 min 4 ? pow * + "+ String(minLum) +" - / "+ String(minLum) +" + x ? x ?")
        
        Expr(e3, "x "+ String(pq_lw) +" "+ String(pq_lb) +" - * "+ String(pq_lb) +" + 0.0 max")
  
        return (output8) ? z_ConvertFormat(pixel_type="yv12", colorspace_op="rgb:st2084:2020=>709:709:709", resample_filter_uv="spline36", chromaloc_op="top_left=>left", nominal_luminance=tdmaxl, dither_type="error_diffusion") :
        \ z_ConvertFormat(pixel_type="yuv444p16", colorspace_op="rgb:st2084:2020=>709:709:709", resample_filter_uv="spline36", nominal_luminance=tdmaxl, dither_type="error_diffusion")

    """, args="c, mdmaxl, tdmaxl, mdminl, tdminl, _cs, cs_weight, use_alternate, output8")
}
