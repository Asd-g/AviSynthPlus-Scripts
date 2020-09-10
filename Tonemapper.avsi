# Changelog:
# Removed unnecessary parameters, speed optimization.


# A script using PQ->HLG with frame peak nits->709 color space for converting HDR->SDR.

# Usage:
# Tonemapper(clip, bool "show")
# - show (default false) - it's showing the nits value used for the HDR->SDR conversion.


Function Tonemapper(clip c, bool "show")
{
    Assert(Is420(c), "Tonemapper: The input must be YUV 4:2:0")
    
    show = Default(show, false)
    
    yuv444 = z_ConvertFormat(c, pixel_type="yuv444p16", resample_filter_uv="spline36", chromaloc_op="top_left=>top_left")
    linear_rgb = yuv444.ConvertYUVtoLinearRGB(Color=0, OOTF=false, outputmode=2)
    
    ictcp = z_ConvertFormat(c, pixel_type="yuv420p16", colorspace_op="2020:st2084:2020:l=>ictcp:st2084:2020:f")
    
    show ? ScriptClip(c.ConvertBits(8), """ictcp   
    mt_lut("x "+ String(YPlaneMax()) +" < 0 x ?").z_ConvertFormat(pixel_type="rgbps", colorspace_op="ictcp:st2084:2020:f=>rgb:linear:2020:f", resample_filter_uv="spline36", chromaloc_op="top_left=>top_left", nominal_luminance=10000.0)
    peak_nits = max((0.2627 * RPlaneMax() + 0.678 * GPlaneMax() + 0.0593 * BPlaneMax()) * 10000.0, 100.0)    

    ConvertLinearRGBtoYUV(linear_rgb, Color=0, HDRMode=1, HLGLw=peak_nits, HLGColor=0, OOTF=false).z_ConvertFormat(pixel_type="yv12", colorspace_op="2020:709:2020=>709:709:709", resample_filter_uv="spline36", dither_type="error_diffusion", chromaloc_op="top_left=>left").Subtitle("peak_nits: " + String(peak_nits))""", args="c, linear_rgb, ictcp") : \
    ScriptClip(yuv444, """ictcp   
    mt_lut("x "+ String(YPlaneMax()) +" < 0 x ?").z_ConvertFormat(pixel_type="rgbps", colorspace_op="ictcp:st2084:2020:f=>rgb:linear:2020:f", resample_filter_uv="spline36", chromaloc_op="top_left=>top_left", nominal_luminance=10000.0)
    peak_nits = max((0.2627 * RPlaneMax() + 0.678 * GPlaneMax() + 0.0593 * BPlaneMax()) * 10000.0, 100.0)    

    ConvertLinearRGBtoYUV(linear_rgb, Color=0, HDRMode=1, HLGLw=peak_nits, HLGColor=0, OOTF=false)""", args="c, linear_rgb, ictcp").z_ConvertFormat(pixel_type="yv12", colorspace_op="2020:709:2020=>709:709:709", resample_filter_uv="spline36", dither_type="error_diffusion", chromaloc_op="top_left=>left")
}