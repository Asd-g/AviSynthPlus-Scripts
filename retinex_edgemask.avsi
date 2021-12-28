/*
Use retinex to greatly improve the accuracy of the edge detection in dark scenes.

This function is a port of the VapourSynth retinex_edgemask - https://github.com/Irrational-Encoding-Wizardry/kagefunc/blob/master/kagefunc.py
*/


### Requirements - AviSynth+ 3.6+, vsTCanny, Retinex.


### Usage ###
###
# retinex_edgemask(clip c, float "sigma", val "sigma1", float "upper_thr")
###
## Parameters ##
#---------------
# c: Input clip.
# Must be in Y/YUV 8..16-bit planar format.
#---------------
# sigma (default 1.0): sigmaY/sigma_vY of vsTCanny.
# Must be positive value.
#---------------
# sigma1 (default [50, 200, 350]): sigma of MSRCP.
# Must be positive value.
#---------------
# upper_thr (default 0.005): upper_thr of MSRCP.
# Must be positive and less then 1.0.


### Changelog ###
#---------------
# Replaced Kirsch with vsTCanny(sigmaY=0, mode=1, op=5)
#---------------
# Initial version.


Function retinex_edgemask(clip c, float "sigma", val "sigma1", float "upper_thr")
{
    Assert(!IsRGB(c) && ComponentSize(c) < 4, "retinex_edgemask: clip must be in Y/YUV 8..16-bit planar format.")

    sigma = Default(sigma, 1.0)
    sigma1 = Default(sigma1, [50, 200, 350])
    upper_thr = Default(upper_thr, 0.005)

    luma = ExtractY(c)
    MSRCP(luma, sigma=sigma1, upper_thr=upper_thr)
    vsTCanny(sigmaY=sigma, sigma_vY=sigma, mode=1)
    Expr("x[-1,-1] x[1,-1] min x[0,0] min x[-1,1] min x[1,1] min")

    return Expr(vsTCanny(luma, sigmaY=0, mode=1, op=5), last, "x y + "+ String(BitLShift(1, BitsPerComponent()) - 1) +" min")
}
