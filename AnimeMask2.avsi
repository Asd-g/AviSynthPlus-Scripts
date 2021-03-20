/*
This script is port of the VapourSynth AnimeMask2 - https://github.com/WolframRhodium/muvsfunc/blob/master/muvsfunc.py

Yet another filter to generate edge/ringing mask for anime.

More specifically, it's an approximatation of the difference of gaussians filter based on resampling.
*/


### Requirements - AviSynth+ 3.6+, avsresize, RoundHalfToEven.


### Usage ###
###
# AnimeMask2(clip c, float "r", string "_expr", int "mode")
###
## Parameters ##
#---------------
# c: Source clip. Only the First plane will be processed if planes are > 1.
#---------------
# r (default 1.2): Radius of resampling coefficient.
# Must be positive.
#---------------
# _expr (default ""): Subsequent processing in Expr().
#---------------
# mode (default 1): Type of the kernel, which simply inverts the pixel values and "shift".
# Typically, -1 is for edge, 1 is for ringing. Default is 1.


### Changelog ###
#---------------
# Initial version.


Function AnimeMask2(clip c, float "r", string "_expr", int "mode")
{
    Assert(IsYUV(c) && IsPlanar(c), "AnimeMask: clip must be in YUV planar format.")
    
    r = Default(r, 1.2)
    mode = Default(mode, 1)
    
    Assert(r > 0.0, "AnimeMask2: r must be positive value.")
    Assert(mode == -1 || mode == 1, "AnimeMask2: mode must be either -1 or 1.")
    
    input = (NumComponents(c) == 1) ? c : ExtractY(c)
    
    w = Width(input)
    h = Height(input)
    
    z_BicubicResize(input, Int(RoundHalfToEven(w / r)), Int(RoundHalfToEven(h / r)), 1.0 / 3.0, 1.0 / 3.0)
    smooth = z_BicubicResize(w, h, 1, 0)
    smoother = z_BicubicResize(w, h, 1.5, -0.25)
    
    calc_expr = (Defined(_expr)) ? (mode == 1) ? ("x y - " + _expr) : ("y x - " + _expr) :
    \ (mode == 1) ? ("x y -") : ("y x -")
    
    return Expr(smooth, smoother, calc_expr)
}
