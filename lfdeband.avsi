### 1.0.1


### A script that applies f3kdb only on the low frequencies https://pastebin.com/Uc4zDfNv.


### Requirements - AviSynth+ 3.6+, masktools2, neo_f3kdb, avsresize.


### Usage ###
###
# lfdeband(clip clp, int "range",  int "y", int "c", string "f3kdb_arg", int "dither")
###
## Parameters ##
#---------------
# src: Input clip.
# Must be in Y/YUV 8..16-bit planar format.
#---------------
# range (default 30): neo_f3kdb banding detection range.
#---------------
# y (default 80): neo_f3kdb banding detection threshold for Y.
# Set this to 0 to copy the src luma.
#---------------
# c (default 80): neo_f3kdb banding detection threshold for U and V.
# Set this to 0 to copy the src chroma.
#---------------
# f3kdb_arg (default non-specified): neo_f3kdb additional arguments.
#---------------
# dither (default -1): Whether to add dither if clip bit depth is different than 16-bit.
# -1: do not add dither.
# 0: add ordered dither.
# 1: add error diffusion dither.


### Changelog ###
#---------------
# Changed internal bit depth to 16-bit.
# Added parameter dither.
#---------------
# Initial version.


function lfdeband(clip clp, int "range",  int "y", int "c", string "f3kdb_arg", int "dither")
{
    range = Default(range, 30)
    y = Default(y, 80)
    c = Default(c, 80)
    dither = Default(dither, -1)

    hss = (IsY(clp) || Is444(clp) || IsYV411(clp)) ? 1 : 2
    vss = (IsY(clp) || Is444(clp) || Is422(clp)) ? 1 : (IsYV411(clp)) ? 4 : 2

    if (BitsPerComponent(clp) < 16)
    {
        bits = BitsPerComponent(clp)
        clp = ConvertBits(clp, 16)
    }

    lo = z_Spline64Resize(clp, Round((Float(Width(clp)) / 2.0) / Float(hss)) * hss, Round((Float(Height(clp)) / 2.0) / Float(vss)) * vss)
    lof = (Defined(f3kdb_arg)) ? Eval("neo_f3kdb(lo, range="+ string(range) +", y="+ string(y) +", cb="+ string(c) +", cr="+ string(c) +", grainy="+ string(0) +", grainc="+ string(0) +", "+ f3kdb_arg +")") :
        \ neo_f3kdb(lo, range=range, y=y, cb=c, cr=c, grainy=0, grainc=0)
    f = mt_makediff(lof, lo, y=(y > 0) ? 3 : 1, u=(c > 0) ? 3 : 1, v=(c > 0) ? 3 : 1)
    f = z_Spline64Resize(f, Width(clp),Height(clp))

    if (VarExist("bits"))
    {
        mt_adddiff(clp, f, y=(y > 0) ? 3 : 2, u=(c > 0) ? 3 : 2, v=(c > 0) ? 3 : 2)
        return ConvertBits(bits, dither=dither)
    }
    else
    {
        return mt_adddiff(clp, f, y=(y > 0) ? 3 : 2, u=(c > 0) ? 3 : 2, v=(c > 0) ? 3 : 2)
    }
}
