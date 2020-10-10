## Changelog:
# Improved scenes with < 100 nits. Changed algo to BT2446 Method A. Added clip8 parameter.
# Removed unnecessary parameters, speed optimization.


# Simple tonemapping script.


### Usage:
## Tonemapper(clip, bool "show", bool "clip8")
# - show (default false) - it's showing the nits value used for the HDR->SDR conversion.
# - clip8 (default true) - when true the output is YUV420P8, otherwise YUV444P16.


Function Tonemapper(clip c, bool "show", bool "clip8")
{
    Assert(Is420(c), "Tonemapper: The input must be YUV 4:2:0")
    
    global show = Default(show, false)
    
    global rgb_ = z_ConvertFormat(c, pixel_type="rgbps", colorspace_op="2020:st2084=>rgb:linear", resample_filter_uv="spline36", chromaloc_op="top_left=>top_left", nominal_luminance=10000.0)
    global clip = c
    
    ScriptClip(ConvertToYUV444(c).ConvertBits(16), """   
    rgb_
    peak_nits = (0.2627 * RPlaneMax() + 0.678 * GPlaneMax() + 0.0593 * BPlaneMax()) * 10000.0
       
    ConvertYUVtoLinearRGB(clip, Color=0, HDRMode=0, OOTF=false, OutputMode=2)
    ConvertLinearRGBtoYUV_BT2446_A_HDRtoSDR(Lhdr=peak_nits, CoeffAdj=max(
    \ peak_nits > 100.0 ?
        \ RPlaneMax(rgb_)  < 0.1 && GPlaneMax(rgb_) < 0.1 && BPlaneMax(rgb_) < 0.1 ?
        \ 10000.0 / peak_nits / 1.5 :
        \ RPlaneMax(rgb_) > GPlaneMax(rgb_) + BPlaneMax(rgb_) ||
        \ GPlaneMax(rgb_) > RPlaneMax(rgb_) + BPlaneMax(rgb_) ||
        \ BPlaneMax(rgb_) > GPlaneMax(rgb_) + RPlaneMax(rgb_) ?
        \ 10000.0 / peak_nits / 2.5 :        
        \ 10000.0 / peak_nits :
    \ 10000.0 / peak_nits / 5.0, 1.0), fastmode=false)
    
    if (show)
    {
        Subtitle("peak_nits: " + String(peak_nits) +
        \ "\n R_max: " + String(RPlaneMax(rgb_)) +
        \ "\n G_max: " + String(GPlaneMax(rgb_)) +
        \ "\n B_max: " + String(BPlaneMax(rgb_)), lsp=1)
    }
    """)
    
    clip8 = Default(clip8, true)
    if (clip8)
    {
        return z_ConvertFormat(pixel_type="yv12", colorspace_op="709:709:2020=>709:709:709", resample_filter_uv="spline36", chromaloc_op="top_left=>left", dither_type="error_diffusion")
    }
    else
    {
        return z_ConvertFormat(colorspace_op="709:709:2020=>709:709:709", resample_filter_uv="spline36")
    }
}
