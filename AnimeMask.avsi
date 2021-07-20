/*
This script is port of the VapourSynth AnimeMask - https://github.com/WolframRhodium/muvsfunc/blob/master/muvsfunc.py

Generates edge/ringing mask for anime based on gradient operator.
*/


### Requirements - AviSynth+ 3.6+, source filter with frame properties support, avsresize with frame properties support.


### Usage ###
###
# AnimeMask(clip c, float "shift", string "_expr", int "mode")
###
## Parameters ##
#---------------
# c: Source clip. Only the First plane will be processed if planes are > 1.
#---------------
# shift (default 0.0): The distance of translation.
# For Anime's ringing mask, it's recommended to set "shift" between 0.5 and 1.0.
#---------------
# _expr (default ""): Subsequent processing in Expr().
#---------------
# mode (default 1): Type of the kernel, which simply inverts the pixel values and "shift".
# Typically, -1 is for edge, 1 is for ringing. Default is 1.


### Changelog ###
#---------------
# Replaced GeneralConvolution with Expr for >3.5x speed up.
#---------------
# Initial version.


Function AnimeMask(clip c, float "shift", string "_expr", int "mode")
{
    Assert(IsYUV(c) && IsPlanar(c), "AnimeMask: clip must be in YUV planar format.")
    
    shift = Default(shift, 0.0)
    mode = Default(mode, 1)
    
    Assert(shift > -1.5 && shift < 1.5, "AnimeMask: shift must be betwee -1.5..1.5.")
    Assert(mode == -1 || mode == 1, "AnimeMask: mode must be either -1 or 1.")   
    
    input = (NumComponents(c) == 1) ? c : ExtractY(c)
    
    if (mode == -1)
    {
        input = Invert(input)
        shift = -shift
    }
    
    Expr(input, "x[0,0] 2 * x[1,0] -1 * + x[0,1] -1 * +")
    mask1 =  z_ConvertFormat(src_left=shift, src_top=shift, colorspace_op="auto:auto:auto:f=>same:same:same:f", resample_filter="bicubic")
    Expr(input, "x[0,-1] -1 * x[-1,0] -1 * + x[0,0] 2 * +")
    mask2 = z_ConvertFormat(src_left=-shift, src_top=-shift, colorspace_op="auto:auto:auto:f=>same:same:same:f", resample_filter="bicubic")
    Expr(input, "x[0,-1] -1 * x[0,0] 2 * + x[1,0] -1 * +")
    mask3 = z_ConvertFormat(src_left=shift, src_top=-shift, colorspace_op="auto:auto:auto:f=>same:same:same:f", resample_filter="bicubic")
    Expr(input, "x[-1,0] -1 * x[0,0] 2 * + x[0,1] -1 * +")
    mask4 = z_ConvertFormat(src_left=-shift, src_top=shift, colorspace_op="auto:auto:auto:f=>same:same:same:f", resample_filter="bicubic")
    
    calc_expr = (Defined(_expr)) ? ("x x * y y * + z z * + a a * + sqrt " + _expr) : ("x x * y y * + z z * + a a * + sqrt")

    return Expr(mask1, mask2, mask3, mask4, calc_expr)
}
