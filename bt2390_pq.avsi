### Tone mapping using BT.2390 (PQ)


### Usage ###
###
# bt2390_pq(clip c, int "mdmaxl", int "tdmaxl", float "mdminl", float "tdminl", bool "cs", float "cs_weight", bool "use_alternate", bool "output8", bool "peak_compute", int "colors", float "colors_weight", bool "gain", int "gain_factor")
###
## Parameters ##
#---------------
# c: The clip that will be tone mapped.
# Must be in YUV planar format.
#---------------
# mdmaxl: Mastering Display Max Luminance.
# If not specified and frame property "MasteringDisplayMaxLuminance" exist, the values of the frame property is used.
# If not specified and frame property "MasteringDisplayMaxLuminance" doesn't exist, 1000 is used.
#---------------
# tdmaxl (default 300): Target Display Max Luminance.
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
# cs (default true): Whether to perform additional color desaturation of the highlights.
#---------------
# cs_weight (default 0.5): Coeff of desaturation performed by cs.
# Must be between 0.0..1.0.
# Higher values leads to more desaturation.
#---------------
# use_alternate (default true): Whether to perform additional compression of the highlights.
# It allows to preserve more details at the cost of some desaturation.
#---------------
# output8 (default true): When true the output is YUV420P8, otherwise YUV444P16.
#---------------
# peak_compute (default true): Whether to calculate the stats of the frame.
# If true: frame peak nits and average nits are calculated and additional coeff is applied to tdmaxl. It makes the script quite slower compared to peak_compute=false.
#---------------
# colors (default 1): Determines how to process the colors during the display mapping.
# 0: ICtCp is used.
# 1: RGB is used.
# 2: Mix of ICtCp and RGB.
#---------------
# colors_weight (default 0.80): Coeff of mixing ICtCp and RGB.
# Has effect only when colors=2.
# Lower values: more use of ICtCp.
# Higher values: more use of RGB.
#---------------
# gain (default false): Whether to perform additional highlights boosting as last step after tonemapping.
#---------------
# gain_factor: Factor used for paremeter gain.
# When peak_compute=true: default (peak_nits) < 0.1 ? 0 : max(2, Int(RoundHalfToEven(0.8 / peak_nits))).
# When peak_compute=false: default 2.
# Higher values: more aggressive highlights boost. It can lead to clipping.
# Lower values: less aggressive highlights boost.


### Info about usage ###
/*
### If there is clipping that have to be fixed ###
1. Try use_alternate=true.
2. If use_alternate not helping, alongside use_alternate=true try peak_compute=true.

### If there is chroma bleeding ###
1. Try cs=false (most of the cases it wouldn't help) alongside different cs_weight values.
2. If cs=false doesn't help, try colors=1 (using RGB for processing leads to desaturation).
cs could be used too for potentially even further desaturation.
For more fine tuning colors=2 and colors_weight can be used.

### peak_compute ###
This option could be useful when the average nits of the frame is very high and/or close to the peak nits. When average nits are (very) close to peak nits there will be severe clipping.
For the other cases (relatively high peak nits and relatively low average nits) peak_compute wouldn't have significant effect.
It's recommended the video to be cropped for peak_compute=true. The black bars more or less affects average nits.
*/


### Changelog ###
#---------------
# Changed default values of tdmaxl, cs, use_alternate and colors.
#---------------
# Optimized performance when peak_compute=false (~120% higher fps).
#---------------
# Replaced FrameEvalute with ScriptClip because the former doesn't like function objects.
#---------------
# Added parameters colors, colors_weight, gain, gain_factor.
#---------------
# Initial version.


Function bt2390_pq(clip c, int "mdmaxl", int "tdmaxl", float "mdminl", float "tdminl", bool "cs", float "cs_weight", bool "use_alternate", bool "output8", bool "peak_compute", int "colors", float "colors_weight", bool "gain", int "gain_factor")
{
    _cs = Default(cs, true)
    cs_weight = Default(cs_weight, 0.5)
    use_alternate = Default(use_alternate, true)
    output8 = Default(output8, true)
    peak_compute = Default(peak_compute, true)
    colors = Default(colors, 1)
    colors_weight = Default(colors_weight, 0.80)
    gain = Default(gain, false)

    Assert(cs_weight >= 0.0 && cs_weight <= 1.0, "bt2390_pq: cs_weight must be between 0.0..1.0.")
    Assert(colors_weight >= 0.0 && colors_weight <= 1.0, "bt2390_pq: colors_weight must be between 0.0..1.0.")

    return (peak_compute) ? _dynamic(c, mdmaxl, tdmaxl, mdminl, tdminl, _cs, cs_weight, use_alternate, output8, colors, colors_weight, gain, gain_factor) : _static(c, mdmaxl, tdmaxl, mdminl, tdminl, _cs, cs_weight, use_alternate, output8, colors, colors_weight, gain, gain_factor)
}

Function _static(clip c, int "mdmaxl", int "tdmaxl", float "mdminl", float "tdminl", bool "_cs", float "cs_weight", bool "use_alternate", bool "output8", int "colors", float "colors_weight", bool "gain", int "gain_factor")
{
    current_frame = 0
    mdmaxl = Default(mdmaxl, (propGetType(c, "MasteringDisplayMaxLuminance")) > 0 ? propGetFloat(c, "MasteringDisplayMaxLuminance") : 1000.0)
    mdminl = Default(mdminl, (propGetType(c, "MasteringDisplayMinLuminance")) > 0 ? propGetFloat(c, "MasteringDisplayMinLuminance") : 0.005)

    tdmaxl = Default(tdmaxl, 300)
    tdminl = Default(tdminl, mdminl)
    gain_factor = Default(gain_factor, 2)

    Assert(tdmaxl < mdmaxl, "bt2390_pq: tdmaxl must be less than mdmaxl.")
    Assert(tdminl >= mdminl, "bt2390_pq: tdminl must be equal or greater than mdminl.")
    Assert(gain_factor > 0, "bt2390_pq: gain_factor must be greater than 0.")

    _common(c, mdmaxl, tdmaxl, mdminl, tdminl, _cs, cs_weight, use_alternate, output8, colors, colors_weight, gain, gain_factor)

    return last
}

Function _dynamic(clip c, int "mdmaxl", int "tdmaxl", float "mdminl", float "tdminl", bool "_cs", float "cs_weight", bool "use_alternate", bool "output8", int "colors", float "colors_weight", bool "gain", int "gain_factor")
{
    ScriptClip((output8) ? z_ConvertFormat(c, pixel_type="yv12", resample_filter_uv="spline36", chromaloc_op="top_left=>left", dither_type="error_diffusion") :
    \ z_ConvertFormat(c, pixel_type="yuv444p16", chromaloc_op="top_left=>top_left", resample_filter_uv="spline36"), function [c, mdmaxl, tdmaxl, mdminl, tdminl, _cs, cs_weight, use_alternate, output8, colors, colors_weight, gain, gain_factor] ()
        {
            mdmaxl = Default(mdmaxl, (propGetType("MasteringDisplayMaxLuminance") > 0) ? propGetFloat("MasteringDisplayMaxLuminance") : 1000.0)
            mdminl = Default(mdminl, (propGetType("MasteringDisplayMinLuminance") > 0) ? propGetFloat("MasteringDisplayMinLuminance") : 0.005)

            _lin = z_ConvertFormat(c, pixel_type="rgbps", colorspace_op="2020:st2084=>rgb:linear", resample_filter_uv="spline36", chromaloc_op="top_left=>top_left", nominal_luminance=mdmaxl)
            peak_nits = 0.2627 * RPlaneMax(_lin) + 0.678 * GPlaneMax(_lin) + 0.0593 * BPlaneMax(_lin)
            tdmaxl = min(pow((Defined(tdmaxl)) ? tdmaxl : 200.0, 1 + 1 / (peak_nits / (0.2627 * AverageR(_lin) + 0.678 * AverageG(_lin) + 0.0593 * AverageB(_lin)))), mdmaxl / 1.4)
            tdminl = Default(tdminl, mdminl)
            gain_factor = (gain) ? Default(gain_factor, (peak_nits) < 0.1 ? 0 : max(2, RoundHalfToEven(0.8 / peak_nits))) : 0

            Assert(tdmaxl < mdmaxl, "bt2390_pq: tdmaxl must be less than mdmaxl.")
            Assert(tdminl >= mdminl, "bt2390_pq: tdminl must be equal or greater than mdminl.")
            Assert(gain_factor >= 0, "bt2390_pq: gain_factor must be equal to or greater than 0.")

            return _common(c, mdmaxl, tdmaxl, mdminl, tdminl, _cs, cs_weight, use_alternate, output8, colors, colors_weight, gain, gain_factor)
        })
}

Function _common(clip c, val "mdmaxl", val "tdmaxl", float "mdminl", float "tdminl", bool "_cs", float "cs_weight", bool "use_alternate", bool "output8", int "colors", float "colors_weight", bool "gain", int "gain_factor")
{
    if (colors == 0)
    {
        _process_ictcp(c, mdmaxl, tdmaxl, mdminl, tdminl, _cs, cs_weight, use_alternate)

        if (gain)
        {
            mask = Expr(ExtractY(z_ConvertFormat(c, pixel_type="y16", colorspace_op="2020:st2084:2020=>ictcp:st2084:2020")), ExtractY(z_ConvertFormat(pixel_type="y16")), "x y - abs "+ String(gain_factor) +" * 16 - 219 / 255 *")

            if (output8)
            {
                z_ConvertFormat(pixel_type="yuv444p16", colorspace_op="ictcp:st2084:2020=>709:709:709", nominal_luminance=tdmaxl)
                return z_ConvertFormat(mt_merge(last, ColorYUV(autogain=true), mask), pixel_type="yv12", resample_filter_uv="spline36", chromaloc_op="top_left=>left", dither_type="error_diffusion")
            }
            else
            {
                z_ConvertFormat(pixel_type="yuv444p16", colorspace_op="ictcp:st2084:2020=>709:709:709", nominal_luminance=tdmaxl, dither_type="error_diffusion")
                return mt_merge(last, ColorYUV(autogain=true), mask)
            }
        }

        return (output8) ? z_ConvertFormat(pixel_type="yv12", colorspace_op="ictcp:st2084:2020=>709:709:709", resample_filter_uv="spline36", chromaloc_op="top_left=>left", nominal_luminance=tdmaxl, dither_type="error_diffusion") :
        \ z_ConvertFormat(pixel_type="yuv444p16", colorspace_op="ictcp:st2084:2020=>709:709:709", resample_filter_uv="spline36", nominal_luminance=tdmaxl, dither_type="error_diffusion")
    }
    else if (colors == 1)
    {
        _process_rgb(c, mdmaxl, tdmaxl, mdminl, tdminl, _cs, cs_weight, use_alternate)

        if (gain)
        {
            mask = Expr(ExtractY(z_ConvertFormat(c, pixel_type="y16", colorspace_op="2020:st2084:2020=>ictcp:st2084:2020")), ExtractY(z_ConvertFormat(pixel_type="y16", colorspace_op="rgb:st2084:2020=>ictcp:st2084:2020")), "x y - abs "+ String(gain_factor) +" * 16 - 219 / 255 *")

            if (output8)
            {
                z_ConvertFormat(pixel_type="yuv444p16", colorspace_op="rgb:st2084:2020=>709:709:709", nominal_luminance=tdmaxl)
                return z_ConvertFormat(mt_merge(last, ColorYUV(autogain=true), mask), pixel_type="yv12", resample_filter_uv="spline36", chromaloc_op="top_left=>left", dither_type="error_diffusion")
            }
            else
            {
                z_ConvertFormat(pixel_type="yuv444p16", colorspace_op="rgb:st2084:2020=>709:709:709", nominal_luminance=tdmaxl, dither_type="error_diffusion")
                return mt_merge(last, ColorYUV(autogain=true), mask)
            }
        }

        return (output8) ? z_ConvertFormat(pixel_type="yv12", colorspace_op="rgb:st2084:2020=>709:709:709", resample_filter_uv="spline36", chromaloc_op="top_left=>left", nominal_luminance=tdmaxl, dither_type="error_diffusion") :
        \ z_ConvertFormat(pixel_type="yuv444p16", colorspace_op="rgb:st2084:2020=>709:709:709", resample_filter_uv="spline36", nominal_luminance=tdmaxl, dither_type="error_diffusion")
    }
    else
    {
        Merge(_process_ictcp(c, mdmaxl, tdmaxl, mdminl, tdminl, _cs, cs_weight, use_alternate), z_ConvertFormat(_process_rgb(c, mdmaxl, tdmaxl, mdminl, tdminl, _cs, cs_weight, use_alternate), pixel_type="yuv444ps", colorspace_op="rgb:st2084:2020=>ictcp:st2084:2020"), colors_weight)

        if (gain)
        {
            mask = Expr(ExtractY(z_ConvertFormat(c, pixel_type="y16", colorspace_op="2020:st2084:2020=>ictcp:st2084:2020")), ExtractY(z_ConvertFormat(pixel_type="y16")), "x y - abs "+ String(gain_factor) +" * 16 - 219 / 255 *")

            if (output8)
            {
                z_ConvertFormat(pixel_type="yuv444p16", colorspace_op="ictcp:st2084:2020=>709:709:709", nominal_luminance=tdmaxl)
                return z_ConvertFormat(mt_merge(last, ColorYUV(autogain=true), mask), pixel_type="yv12", resample_filter_uv="spline36", chromaloc_op="top_left=>left", dither_type="error_diffusion")
            }
            else
            {
                z_ConvertFormat(pixel_type="yuv444p16", colorspace_op="ictcp:st2084:2020=>709:709:709", nominal_luminance=tdmaxl, dither_type="error_diffusion")
                return mt_merge(last, ColorYUV(autogain=true), mask)
            }
        }

        return (output8) ? z_ConvertFormat(pixel_type="yv12", colorspace_op="ictcp:st2084:2020=>709:709:709", resample_filter_uv="spline36", chromaloc_op="top_left=>left", nominal_luminance=tdmaxl, dither_type="error_diffusion") :
        \ z_ConvertFormat(pixel_type="yuv444p16", colorspace_op="ictcp:st2084:2020=>709:709:709", resample_filter_uv="spline36", nominal_luminance=tdmaxl, dither_type="error_diffusion")
    }
}

Function _process_ictcp(clip c, val "mdmaxl", val "tdmaxl", float "mdminl", float "tdminl", bool "_cs", float "cs_weight", bool "use_alternate")
{
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
        z_ConvertFormat(Merge(cs, Overlay(cs, CombinePlanes(_l, _l, _l, planes="rgb", pixel_type="rgbps"), mask=Expr(ExtractR(cs), ExtractG(cs), ExtractB(cs), " x x * y y * + z z * + x y + z + / 1 - "+ String(eb) +" 1 - / 0 1 clip")), cs_weight), pixel_type="yuv444ps", colorspace_op="rgb:linear:2020=>ictcp:st2084:2020", nominal_luminance=tdmaxl)
    }
    else { z_ConvertFormat(c, pixel_type="yuv444ps", colorspace_op="2020:st2084:2020=>ictcp:st2084:2020", resample_filter_uv="spline36") }

    orig = last
    i1 = ExtractY()
    i1

    e1 = Expr(last, "x "+ String(pq_lb) +" - "+ String(pq_lw) +" "+ String(pq_lb) +" - / 0 1 clip")
    t = Expr(e1, "x "+ String(ks) +" - 1 "+ String(ks) +" - /")
    p = Expr(t, "2 x 3 pow * 3 x 2 pow * - 1 + "+ String(ks) +" * 1 "+ String(ks) +" - x 3 pow 2 x 2 pow * - x + * + -2 x 3 pow * 3 x 2 pow * + "+ String(maxi) +" * +")

    e2 = Expr(e1, p, "x "+ String(ks) +" < x "+ String(maxi) +" "+ String(maxci) +" <= x x y - "+ String(s) +" * - "+ String(maxi) +" min x "+ String(maxci) +" min ? ?")

    e3 = Expr(e2, "x 1 <= "+ String(maxi) +" 1 < x "+ String(minLum) +" 1 x - "+ String(minLum) +" 0 >= 1.0 "+ String(minLum) +" / 4 min 4 ? pow * + "+ String(minLum) +" - "+ String(maxi) +" "+ String(minLum) +" - * "+ String(maxi) +" "+ String(minLum) +" 1 "+ String(maxi) +" - "+ String(minLum) +" 0 >= 1.0 "+ String(minLum) +" / 4 min 4 ? pow * + "+ String(minLum) +" - / "+ String(minLum) +" + x ? x ?")

    Expr(e3, "x "+ String(pq_lw) +" "+ String(pq_lb) +" - * "+ String(pq_lb) +" + 0.0 max")

    return CombinePlanes(last, Expr(last, ExtractU(orig), i1, "x z / z x / min y *"), Expr(last, ExtractV(orig), i1, "x z / z x / min y *"), planes="yuv", pixel_type="yuv444ps")
}

Function _process_rgb(clip c, val "mdmaxl", val "tdmaxl", float "mdminl", float "tdminl", bool "_cs", float "cs_weight", bool "use_alternate")
{
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
        z_ConvertFormat(Merge(cs, Overlay(cs, CombinePlanes(_l, _l, _l, planes="rgb", pixel_type="rgbps"), mask=Expr(ExtractR(cs), ExtractG(cs), ExtractB(cs), " x x * y y * + z z * + x y + z + / 1 - "+ String(eb) +" 1 - / 0 1 clip")), cs_weight), pixel_type="rgbps", colorspace_op="rgb:linear:2020=>rgb:st2084:2020", nominal_luminance=tdmaxl)
    }
    else { z_ConvertFormat(c, pixel_type="rgbps", colorspace_op="2020:st2084:2020=>rgb:st2084:2020", resample_filter_uv="spline36") }

    e1 = Expr(last, "x "+ String(pq_lb) +" - "+ String(pq_lw) +" "+ String(pq_lb) +" - / 0 1 clip")
    t = Expr(e1, "x "+ String(ks) +" - 1 "+ String(ks) +" - /")
    p = Expr(t, "2 x 3 pow * 3 x 2 pow * - 1 + "+ String(ks) +" * 1 "+ String(ks) +" - x 3 pow 2 x 2 pow * - x + * + -2 x 3 pow * 3 x 2 pow * + "+ String(maxi) +" * +")

    e2 = Expr(e1, p, "x "+ String(ks) +" < x "+ String(maxi) +" "+ String(maxci) +" <= x x y - "+ String(s) +" * - "+ String(maxi) +" min x "+ String(maxci) +" min ? ?")

    e3 = Expr(e2, "x 1 <= "+ String(maxi) +" 1 < x "+ String(minLum) +" 1 x - "+ String(minLum) +" 0 >= 1.0 "+ String(minLum) +" / 4 min 4 ? pow * + "+ String(minLum) +" - "+ String(maxi) +" "+ String(minLum) +" - * "+ String(maxi) +" "+ String(minLum) +" 1 "+ String(maxi) +" - "+ String(minLum) +" 0 >= 1.0 "+ String(minLum) +" / 4 min 4 ? pow * + "+ String(minLum) +" - / "+ String(minLum) +" + x ? x ?")

    return Expr(e3, "x "+ String(pq_lw) +" "+ String(pq_lb) +" - * "+ String(pq_lb) +" + 0.0 max")
}
