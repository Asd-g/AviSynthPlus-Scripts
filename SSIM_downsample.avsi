/*
This script is port of the VapourSynth SSIM_downsample - https://github.com/WolframRhodium/muvsfunc/blob/master/muvsfunc.py

SSIM downsampler is an image downscaling technique that aims to optimize for the perceptual quality of the downscaled results.
Image downscaling is considered as an optimization problem where the difference between the input and output images is measured using famous Structural SIMilarity (SSIM) index.
The solution is derived in closed-form, which leads to the simple, efficient implementation.
The downscaled images retain perceptually important features and details, resulting in an accurate and spatio-temporally consistent representation of the high resolution input.

This is an pseudo-implementation of SSIM downsampler with slight modification.
The behaviour of convolution at the border is uniform.
All the internal calculations are done at 32-bit float.
*/


### Requirements - AviSynth+, avsresize, vsTCanny.


### Usage ###
###
# SSIM_downsample(clip c, int target_width, int target_height, val "smooth", string "kernel", float "epsilon", string "resample_args", string "dither")
###
## Parameters ##
#---------------
# c: Source clip.
# 32-bit source clip is assumed full range.
#---------------
# target_width: The width of the output.
#---------------
# target_height: The height of the output.
#---------------
# smooth (default 1.5): The method to smooth the image.
# If it's a float, it specifies the "sigmaX" of vsTCanny.
# If it's function, it acts as a general smoother.
#---------------
# kernel (default "z_BicubicResize"): Resample kernel.
#---------------
# epsilon (default 0.000001)
#---------------
# resample_args (default ""): Additional resizer arguments.
#---------------
# dither (default "none"): Whether to perform dither for the final result.
# It has effect only for < 32-bit clip.


### Examples ###
/*
SSIM_downsample(1280,532)
# Downsampling with default kernel and default smooth (vsTCanny(sigmaX=1.5)).
*/
###
/*
SSIM_downsample(1280,532, resample_args="b=-0.6, c=0", dither="error_diffusion", smooth="""generalconvolution(matrix="1 1 1 1 1 1 1 1 1",chroma=false)""")
# Downsampling with custom kernel arguments, custom smooth function and dither.
*/


### Changelog ###
#---------------
# Fixed smooth when it's float.
#---------------
# Allowed other resizers than avsresize.
#---------------
# Initial version.


Function SSIM_downsample(clip c, int target_width, int target_height, val "smooth", string "kernel", float "epsilon", string "resample_args", string "dither")
{
    smooth = Default(smooth, 1.5)
    kernel = Default(kernel, "z_BicubicResize")
    epsilon = Default(epsilon, 0.000001)
    dither = Default(dither, "none")
    
    c
    _32bits = (BitsPerComponent() == 32)
    
    if (!_32bits)
    {
        ConvertBits(32, fulld=true)
    }   

    resample_args = (Defined(resample_args)) ? ", " + resample_args : ""
    
    l = Eval(kernel + "(" + String(target_width) + "," +  String(target_height) + resample_args + ")")

    if (IsFloat(smooth))
    {
        m = vsTCanny(l, sigmaY=smooth, sigma_vY=smooth, mode=-1)
        r = Expr(vsTCanny(Expr(l, "x dup *"), sigmaY=smooth, sigma_vY=smooth, mode=-1), vsTCanny(Eval(kernel + """(Expr("x x *"),""" + String(target_width) + "," +  String(target_height) + resample_args + ")"), sigmaY=smooth, sigma_vY=smooth, mode=-1), Expr(m, "x dup *"), "x z - "+ String(epsilon) +" < 0 y z - x z - / 0.5 pow ?")
        Expr(vsTCanny(m, sigmaY=smooth, sigma_vY=smooth, mode=-1), vsTCanny(r, sigmaY=smooth, sigma_vY=smooth, mode=-1), l, vsTCanny(Expr(r, m, "x y *"), sigmaY=smooth, sigma_vY=smooth, mode=-1), "x y z * + a -")
    }
    else
    {      
        m = l.Eval(smooth)
        r = Expr(Expr(l, "x dup *").Eval(smooth), Eval(kernel + """(Expr("x x *"),""" + String(target_width) + "," +  String(target_height) + resample_args + ")").Eval(smooth),  Expr(m, "x dup *"), "x z - "+ String(epsilon) +" < 0 y z - x z - / 0.5 pow ?")
        Expr(m.Eval(smooth), r.Eval(smooth), l, Expr(r, m, "x y *").Eval(smooth), "x y z * + a -")        
    }

    if (!_32bits)
    {
        z_ConvertFormat(pixel_type=PixelType(c), dither_type=dither)
    }
}
