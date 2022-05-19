# v1.0

# Simple tonemapping script. It tries to keep as much details as possible.


### Requirements - avsresize, HDRTools, AviSynth+ 3.6.


### Usage:
## Tonemapper(clip, bool "show", bool "clip8")
# - show (default false) - it's showing the nits value used for the HDR->SDR conversion.
# - clip8 (default true) - when true the output is YUV420P8, otherwise YUV444P16.


## Changelog:
# Changed to be prefetch friendly.
# Fixed the output when peak_nits=0.
# Improved chroma subsampling.
###
# Improved scenes with < 100 nits. Changed algo to BT2446 Method A. Added clip8 parameter.
###
# Removed unnecessary parameters, speed optimization.


Function Tonemapper(clip c, bool "show", bool "clip8")
{
    Assert(!IsRGB(c), "Tonemapper: The input must be YUV.")

    show = Default(show, false)

    rgb_ = z_ConvertFormat(c, pixel_type="rgbps", colorspace_op="2020:st2084:2020:l=>rgb:linear:2020:f", resample_filter_uv="spline36", chromaloc_op="top_left=>top_left", nominal_luminance=10000.0)

    z_ConvertFormat(c, pixel_type="YUV444P16", colorspace_op="2020:st2084:2020:l=>2020:st2084:2020:l", resample_filter_uv="spline36", chromaloc_op="top_left=>top_left")
    linear = ConvertYUVtoLinearRGB(Color=0, HDRMode=0, OOTF=false, OutputMode=2)

    ScriptClip(function [show, rgb_, linear]()
    {
        rmax = RPlaneMax(rgb_)
        gmax = GPlaneMax(rgb_)
        bmax = BPlaneMax(rgb_)
        peak_nits = (0.2627 * rmax + 0.678 * gmax + 0.0593 * bmax) * 10000.0

        if (peak_nits > 0.001)
        {
            ConvertLinearRGBtoYUV_BT2446_A_HDRtoSDR(linear, Lhdr=max(peak_nits, 0.00001), CoeffAdj=max((peak_nits > 100.0) ? (rmax  < 0.1 && gmax < 0.1 && bmax < 0.1) ? (10000.0 / peak_nits / 1.5) :
                \ ((rmax > gmax + bmax) || (gmax > rmax + bmax) || (bmax > gmax + rmax)) ? (peak_nits / (rmax + gmax + bmax) > 4000.0) ? (10000.0 / peak_nits / 2.5) :
                \ (10000.0 / peak_nits) :
                \ (10000.0 / peak_nits) :
                \ (10000.0 / peak_nits / 5.0), 1.0), fastmode=false)
        }

        if (show)
        {
            Subtitle("peak_nits: " + String(peak_nits) +
            \ "\n R_max: " + String(rmax) +
            \ "\n G_max: " + String(gmax) +
            \ "\n B_max: " + String(bmax), lsp=1)
        }
    })

    clip8 = Default(clip8, true)
    if (clip8)
    {
        return z_ConvertFormat(pixel_type="yv12", colorspace_op="709:709:2020:l=>709:709:709:l", resample_filter_uv="spline36", chromaloc_op="top_left=>left", dither_type="error_diffusion")
    }
    else
    {
        return z_ConvertFormat(colorspace_op="709:709:2020:l=>709:709:709:l", resample_filter_uv="spline36", chromaloc_op="top_left=>top_left")
    }
}
