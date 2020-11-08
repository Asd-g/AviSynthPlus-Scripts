/*
This script is port of the VapourSynth GMSD - https://github.com/WolframRhodium/muvsfunc/blob/master/muvsfunc.py#L3373

Gradient Magnitude Similarity Deviation Calculator

GMSD is a new effective and efficient image quality assessment (IQA) model, which utilizes the pixel-wise gradient magnitude similarity (GMS)
between the reference and distorted images combined with standard deviation of the GMS map to predict perceptual image quality.
The distortion degree of the distorted image will be stored as frame property '_PlaneGMSD' in the output clip.
The value of GMSD reflects the range of distortion severities in an image.
The lowerer the GMSD score, the higher the image perceptual quality.
If "clip1" == "clip2", GMSD = 0.
All the internal calculations are done at 32-bit float, only one channel of the image will be processed.

Ref:
    [1] Xue, W., Zhang, L., Mou, X., & Bovik, A. C. (2014). Gradient magnitude similarity deviation:
        A highly efficient perceptual image quality index. IEEE Transactions on Image Processing, 23(2), 684-695.
    [2] http://www4.comp.polyu.edu.hk/~cslzhang/IQA/GMSD/GMSD.htm.
*/


### Requirements - AviSynth+ 3.6+, _IQA_downsample.


### Usage ###
###
# GMSD(clip clip1, clip clip2, bool "downsample", float "c", bool "show_map", bool "show", bool "y", bool "u", bool "v")
###
## Parameters ##
#---------------
# clip1: The distorted clip, will be copied to output if "show_map" is False.
#---------------
# clip2: Reference clip, must be of the same format and dimension as the "clip1".
#---------------
# downsample (default true): Whether to average the clips over local 2x2 window and downsample by a factor of 2 before calculation.
#---------------
# c (default 0.0026): A positive constant that supplies numerical stability. According to the paper, for all the test databases, GMSD shows similar preference to the value of c.
#---------------
# show_map (default false): Whether to return GMS map. If not, "clip1" will be returned.
#---------------
# show (default true): Whether to return subtitle with GMSD value.
#---------------
# y (default true), u (default false), v (default false): Which plane to process.


### Changelog ###
# - Replaced mt_convolution with mt_edge for ~15% speed up.
# - Initial version.


Function GMSD(clip clip1, clip clip2, bool "downsample", float "c", bool "show_map", bool "show", bool "y", bool "u", bool "v")
{
    Assert(PixelType(clip1) == PixelType(clip2), "GMSD: clip1 and clip2 must be of the same format.")
    Assert(Width(clip1) == Width(clip2) && Height(clip1) == Height(clip2), "GMSD: clip1 and clip2 must be of the same width and height.")

    y = Default(y, true)
    u = Default(u, false)
    v = Default(v, false)
    
    Assert(y == true && u == false && v == false ||
    \ y == false && u == true && v == false ||
    \ y == false && u == false && v == true, "GMSD: one plane must be processed.")
    
    clip1_src = clip1
    
    clip1 = y ?
    \ ExtractY(clip1).ConvertBits(32, fulld=true) :
    \ u ?
    \ ExtractU(clip1).ConvertBits(32, fulld=true) :
    \ ExtractV(clip1).ConvertBits(32, fulld=true)
    clip2 = y ?
    \ ExtractY(clip2).ConvertBits(32, fulld=true) :
    \ u ?
    \ ExtractU(clip2).ConvertBits(32, fulld=true) :
    \ ExtractV(clip2).ConvertBits(32, fulld=true)
    
    downsample = Default(downsample, true)
    if (downsample)
    {
        clip1 = _IQA_downsample(clip1)
        clip2 = _IQA_downsample(clip2)
    }
    
    c = Default(c, 0.0026)
    global quality_map = Expr(Expr(mt_edge(clip1, "1 0 -1 1 0 -1 1 0 -1 1", 0, 255), mt_edge(clip1, "1 1 1 0 0 0 -1 -1 -1 1", 0, 255), "x x * y y * +"),
        \ Expr(mt_edge(clip2, "1 0 -1 1 0 -1 1 0 -1 1", 0, 255), mt_edge(clip2, "1 1 1 0 0 0 -1 -1 -1 1", 0, 255), "x x * y y * +"),
        \ "2 x y * sqrt * "+ String(c) +" + x y + "+ String(c) +" + /")
    
    show_map = Default(show_map, false)
    last = show_map ?
    \ ScriptClip(quality_map, """propSet("_PlaneGMSD", Sqrt(AverageLuma(Expr("x "+ String(AverageLuma()) +" - x "+ String(AverageLuma()) +" - *"))), 0)""") :
    \ ScriptClip(clip1_src, """propSet("_PlaneGMSD", Sqrt(AverageLuma(Expr(quality_map, "x "+ String(AverageLuma(quality_map)) +" - x "+ String(AverageLuma(quality_map)) +" - *"))), 0)""")
    
    show = Default(show, true)
    return show ?
    \ ScriptClip("""Subtitle("PlaneGMSD: " + String(propGetFloat("_PlaneGMSD")))""") :
    \ last
}
