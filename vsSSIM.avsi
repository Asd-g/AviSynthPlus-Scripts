/*
This script is port of the VapourSynth SSIM - https://github.com/WolframRhodium/muvsfunc/blob/master/muvsfunc.py#L3481

Structural SIMilarity Index Calculator

The Structural SIMilarity (SSIM) index is a method for measuring the similarity between two images.
It is based on the hypothesis that the HVS is highly adapted for extracting structural information,
which compares local patterns of pixel intensities that have been normalized for luminance and contrast.
The mean SSIM (MSSIM) index value of the distorted image will be stored as frame property '_PlaneSSIM' in the output clip.
The value of SSIM measures the structural similarity in an image.
The higher the SSIM score, the higher the image perceptual quality.
If "clip1" == "clip2", SSIM = 1.
All the internal calculations are done at 32-bit float, only one channel of the image will be processed.

Ref:
    [1] Wang, Z., Bovik, A. C., Sheikh, H. R., & Simoncelli, E. P. (2004). Image quality assessment: from error visibility to structural similarity.
        IEEE transactions on image processing, 13(4), 600-612.
    [2] https://ece.uwaterloo.ca/~z70wang/research/ssim/.
*/


### Requirements - AviSynth+ 3.6+, vsTCanny,  _IQA_downsample.


### Usage ###
###
# vsSSIM(clip clip1, clip clip2, bool "downsample", float "k1", float "k2", float "stddev", float "dynamic_range", bool "show_map", bool "show", bool "y", bool "u", bool "v")
###
## Parameters ##
#---------------
# clip1: The distorted clip, will be copied to output if "show_map" is False.
#---------------
# clip2: Reference clip, must be of the same format and dimension as the "clip1".
#---------------
# downsample (default true): Whether to average the clips over local 2x2 window and downsample by a factor of 2 before calculation.
#---------------
# k1 (default 0.01), k2 (default 0.03) : Constants in the SSIM index formula. According to the paper, the performance of the SSIM index algorithm is fairly insensitive to variations of these values.
#---------------
# stddev (default 1.5): It specifies the standard deviation of the gaussian filter. (sigma in vsTCanny). According to the paper, the quality map calculated from gaussian filter exhibits a locally isotropic property, which prevents the present of undesirable “blocking” artifacts in the resulting SSIM index map.
#---------------
# dynamic_range (default 1.0): Dynamic range of the internal float point clip.
#---------------
# show_map (default false): Whether to return SSIM index map. If not, "clip1" will be returned.
#---------------
# show (default true): Whether to return subtitle with SSIM value.
#---------------
# y (default true), u (default false), v (default false): Which plane to process.


Function vsSSIM(clip clip1, clip clip2, bool "downsample", float "k1", float "k2", float "stddev", float "dynamic_range", bool "show_map", bool "show", bool "y", bool "u", bool "v")
{
    Assert(PixelType(clip1) == PixelType(clip2), "SSIM: clip1 and clip2 must be of the same format.")
    Assert(Width(clip1) == Width(clip2) && Height(clip1) == Height(clip2), "SSIM: clip1 and clip2 must be of the same width and height.")

    y = Default(y, true)
    u = Default(u, false)
    v = Default(v, false)
    
    Assert(y == true && u == false && v == false ||
    \ y == false && u == true && v == false ||
    \ y == false && u == false && v == true, "SSIM: one plane must be processed.")
    
    k1 = Default(k1, 0.01)
    k2 = Default(k2, 0.03)
    dynamic_range = Default(dynamic_range, 1.0)
    c1 = Pow(k1 * dynamic_range, 2.0)
    c2 = Pow(k2 * dynamic_range, 2.0)
        
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
    
    stddev = Default(stddev, 1.5)
    mu1 = vsTCanny(clip1, sigmay=stddev, mode=-1)
    mu2 = vsTCanny(clip2, sigmay=stddev, mode=-1)
    mu1_sq = Expr(mu1, "x x *")
    mu2_sq = Expr(mu2, "x x *")
    mu1_mu2 = Expr(mu1, mu2, "x y *")
    sigmay1_sq_pls_mu1_sq = vsTCanny(Expr(clip1, "x x *"), sigmay=stddev, mode=-1)
    sigmay2_sq_pls_mu2_sq = vsTCanny(Expr(clip2, "x x *"), sigmay=stddev, mode=-1)
    sigmay12_pls_mu1_mu2 = vsTCanny(Expr(clip1, clip2, "x y *"), sigmay=stddev, mode=-1)
    
    global ssim_map = c1 > 0.0 && c2 > 0.0 ?
    \ Expr(mu1_mu2, sigmay12_pls_mu1_mu2, mu1_sq, mu2_sq, sigmay1_sq_pls_mu1_sq, mu1_sq, sigmay2_sq_pls_mu2_sq, mu2_sq, "2.0 x * "+ String(c1) +" + 2.0 y x - * "+ String(c2) +" + * z a + "+ String(c1) +" + b c - d e - + "+ String(c2) +" + * /") :
    \ Expr(Expr(mu1_sq, mu2_sq, "x y + "+ String(c1) +" +"), Expr(sigmay1_sq_pls_mu1_sq, mu1_sq, sigmay2_sq_pls_mu2_sq, mu2_sq, "x y - z a - + "+ String(c2) +" +"), mu1_mu2, sigmay12_pls_mu1_mu2, "'x y * 0 > 2 z * "+ String(c1) +" + 2 a z - * "+ String(c2) +" + * x y * / x 0 = not y 0 = and 2 z * "+ String(c1) +" + x / 1.0 ? ?")
    
    show_map = Default(show_map, false)
    last = show_map ?
    \ ScriptClip(ssim_map, """propSet("_PlaneSSIM", AverageLuma(), 0)""") :
    \ ScriptClip(clip1_src, """propSet("_PlaneSSIM", AverageLuma(ssim_map), 0)""")
    
    show = Default(show, true)
    return show ?
    \ ScriptClip("""Subtitle("PlaneSSIM: " + String(propGetFloat("_PlaneSSIM")))""") :
    \ last
}
