/*
This script is port of the VapourSynth MDSI - https://github.com/WolframRhodium/muvsfunc/blob/master/muvsfunc.py#L4593

Mean Deviation Similarity Index Calculator

MDSI is a full reference IQA model that utilize gradient similarity (GS), chromaticity similarity (CS), and deviation pooling (DP).
The lowerer the MDSI score, the higher the image perceptual quality.
Larger MDSI values indicate to the more severe distorted images, while an image with perfect quality is assessed by a quality score of zero.
The distortion degree of the distorted image will be stored as frame property '_FrameMDSI' in the output clip.
Note that bilinear downsampling is used in this implementation (but disabled by default), as opposed to the original paper.
The gradient-chromaticity similarity map is saturated before deviation pooling, as described in II.D.
Matrix used by rgb2gray() from MATLAB (similar to BT.601 matrix) is used for computation of luma component.

Ref:
    [1] Nafchi, H. Z., Shahkolaei, A., Hedjam, R., & Cheriet, M. (2016).
        Mean deviation similarity index: Efficient and reliable full-reference image quality evaluator.
        IEEE Access, 4, 5579-5590.
    [2] https://ww2.mathworks.cn/matlabcentral/fileexchange/59809-mdsi-ref-dist-combmethod
*/


### Requirements - AviSynth+ >=3.6, RoundHalfToEven, avsresize.


### Usage ###
###
# MDSI(clip clip1, clip clip2, int "down_scale", float "alpha", bool "show_maps", bool "show")
###
## Parameters ##
#---------------
# clip1: The first clip to be evaluated, will be copied to output.
#---------------
# clip2: The second clip, to be compared with the first one.
#---------------
# down_scale (default 1): Factor of downsampling before quality assessment.
#---------------
# alpha (default 0.6): Weight used to merge gradient similarity (GS) map and chromaticity similarity (CS) map.
#---------------
# show_maps (default false): Whether to return gradient similarity (GS), chromaticity similarity (CS) and GCS (linear combination of CS and GCS) maps. If it is true, interleaved clip of gs, cs, gcs will be returned. If it false, clip1 will be returned.
#---------------
# show (default true): Whether to return subtitle with MDSI value.


Function MDSI(clip clip1, clip clip2, int "down_scale", float "alpha", bool "show_maps", bool "show")
{
    Assert(PixelType(clip1) == PixelType(clip2) && (IsPlanarRGB(clip1) || IsPlanarRGBA(clip1)) , "MDSI: clip1 and clip2 must be in the same format and must be in planar RGB format.")
    Assert(Width(clip1) == Width(clip2) && Height(clip1) == Height(clip2), "MDSI: clip1 and clip2 must be of the same width and height.")
    
    c1 = 140 / pow(255, 2)
    c2 = 55 / pow(255, 2)
    c3 = 550 / pow(255, 2)
    
    down_scale = Default(down_scale, 1)
    down1 = down_scale > 1 || BitsPerComponent(clip1) != 32 ?
    \ z_ConvertFormat(clip1, Int(RoundHalfToEven(Float(Width(clip1)) / down_scale)), Int(RoundHalfToEven(Float(Height(clip1)) / down_scale)), pixel_type="rgbps", resample_filter="bilinear") :
    \ clip1
    
    down2 = down_scale > 1 || BitsPerComponent(clip2) != 32 ?
    \ z_ConvertFormat(clip2, Int(RoundHalfToEven(Float(Width(clip2)) / down_scale)), Int(RoundHalfToEven(Float(Height(clip2)) / down_scale)), pixel_type="rgbps", resample_filter="bilinear") :
    \ clip2
    
    r1 = ExtractR(down1)
    g1 = ExtractG(down1)
    b1 = ExtractB(down1)
    
    r2 = ExtractR(down2)
    g2 = ExtractG(down2)
    b2 = ExtractB(down2)
    
    l1 = Expr(r1, g1, b1, "x 0.2989 * y 0.5870 * + z 0.1140 * +")
    l2 = Expr(r2, g2, b2, "x 0.2989 * y 0.5870 * + z 0.1140 * +")
    f = Merge(l1, l2)
    
    ix_l1 = GeneralConvolution(l1, matrix="1, 0, -1, 1, 0, -1, 1, 0, -1")
    iy_l1 = GeneralConvolution(l1, matrix="1, 1, 1, 0, 0, 0, -1, -1, -1")
    g_r = Expr(ix_l1, iy_l1, "x x * y y * + sqrt")
    
    ix_l2 = GeneralConvolution(l2, matrix="1, 0, -1, 1, 0, -1, 1, 0, -1")
    iy_l2 = GeneralConvolution(l2, matrix="1, 1, 1, 0, 0, 0, -1, -1, -1")
    g_d = Expr(ix_l2, iy_l2, "x x * y y * + sqrt")
    
    ix_f = GeneralConvolution(f, matrix="1, 0, -1, 1, 0, -1, 1, 0, -1")
    iy_f = GeneralConvolution(f, matrix="1, 1, 1, 0, 0, 0, -1, -1, -1")
    g_f = Expr(ix_f, iy_f, "x x * y y * + sqrt")
    
    gs12 = Expr(g_r, g_d, "x y * 2 * "+ String(c1) +" + x x * y y * + "+ String(c1) +" + /")
    gs13 = Expr(g_r, g_f, "x y * 2 * "+ String(c2) +" + x x * y y * + "+ String(c2) +" + /")
    gs23 = Expr(g_d, g_f, "x y * 2 * "+ String(c2) +" + x x * y y * + "+ String(c2) +" + /")
    gs_hvs = Expr(gs12, gs13, gs23, "x y + z -")
    
    h1 = Expr(r1, g1, b1, "x 0.30 * y 0.04 * + z 0.35 * -")
    h2 = Expr(r2, g2, b2, "x 0.30 * y 0.04 * + z 0.35 * -")
    m1 = Expr(r1, g1, b1, "x 0.34 * y 0.60 * - z 0.17 * +")
    m2 = Expr(r2, g2, b2, "x 0.34 * y 0.60 * - z 0.17 * +")
    
    cs = Expr(h1, h2, m1, m2, "x y * z a * + 2 * "+ String(c3) +" + x x * y y * + z z * + a a * + "+ String(c3) +" + /")
    
    alpha = Default(alpha, 0.6)
    global gcs = Expr(gs_hvs, cs, "x "+ String(alpha) +" * y 1.0 "+ String(alpha) +" - * + 0.0 max 1.0 min 0.25 pow")
    
    show_maps = Default(show_maps, false)
    last = show_maps ?
    \ ScriptClip(Interleave(gs_hvs, cs, gcs), """propSet("_FrameMDSI", pow(AverageLuma(Expr(gcs, "x "+ String(AverageLuma(gcs)) +" - abs")), 0.25), 0)""") :
    \ ScriptClip(clip1, """propSet("_FrameMDSI", pow(AverageLuma(Expr(gcs, "x "+ String(AverageLuma(gcs)) +" - abs")), 0.25), 0)""")
    
    show = Default(show, true)
    return show ?
    \ ScriptClip("""Subtitle("FrameMDSI: " + String(propGetFloat("_FrameMDSI")))""") :
    \ last
}
