### This is meant as a faster version of the retinex-type deband mask.


### Requirements - AviSynth+, masktools2.


### Usage ###
###
# debandmask(clip c, int "lo", int "hi", int "lothr", int "hithr", int "mrad", bool "stack16_in", bool "stack16_out", clip "mask", bool "onlyY")
###
## Parameters ##
#---------------
# c: Clip to process.
#---------------
# lo/hi (default 60/16): Cutoffs.
#---------------
# lothr/hithr (default 4/4): Binarize thresholds of the mask at lo/hi luma levels.
# Values falling between lo and hi are scaled linearly from lothr to hithr.
#---------------
# mrad (default 1): Radius of the internal preprocessing mask.
#---------------
# stack16_in/stack16_out (default false/false): Stacked format.
#---------------
# mask (default not-defined): External preprocessing mask.
#---------------
# onlyY (default true): Whether to return the mask in only Y format.


### Changelog ###
#---------------
# Added paramater onlyY.
#---------------
# Added paramater mask.
#---------------
# Return Y clip.
# 8-bit ~3% speedup (mrad > 1); 10-bit ~10% speedup (mrad > 1); 16-bit ~10x speedup (mrad > 1).
# Changed default values to 60,16,4,4,1.
#---------------
# Added default values that give ~same result as mt_edge("prewitt") but ~2x slower; however debandmask(60,16,4,4,1) with predenoised source gives better result than mt_edge("prewitt").
#---------------
# Added high bit-depth and stack16_in/out support.
#---------------
# Initial version. (ZASTIN)


Function debandmask(clip c, int "lo", int "hi", int "lothr", int "hithr", int "mrad", bool "stack16_in", bool "stack16_out", clip "mask", bool "onlyY")
{
    lo          = Default(lo, 60)
    hi          = Default(hi, 16)
    lothr       = Default(lothr, 4)
    hithr       = Default(hithr, 4)
    mrad        = Default(mrad, 1)
    stack16_in  = Default(stack16_in, false)
    stack16_out = Default(stack16_out, false)
    onlyY       = Default(onlyY, true)

    usee  = BitsPerComponent(c) > 10 ? 3 : 0

    Assert(lo >= 0 && hi >= 0 && lothr >= 0 && hithr >= 0,         "debandmask: lo/hi/lothr/hithr must be >= 0")
    Assert(lo <= 255 && hi <= 255 && lothr <= 255 && hithr <= 255, "debandmask: lo/hi/lothr/hithr must be <= 255")
    Assert(mrad >= 1,                                              "debandmask: mrad must be >= 1")

    !stack16_in ? c : ConvertFromStacked(c)
    s = last
    onlyY ? ExtractY() : s

    if (Defined(mask))
    {
        rmask = onlyY ? ExtractY(mask) : mask
    }
    else
    {
        rmask = mrad > 1 ? mt_lutxy(mt_expand_multi(mode="ellipse", sw=mrad, sh=mrad), mt_inpand_multi(mode="ellipse", sw=mrad, sh=mrad), "x y -", use_expr=1) : mt_edge(mode="min/max", thY1=0, thY2=255)
    }

    #(x < lo) ? ((y >= lothr) ? range_max : 0) : ((x > hi) ? ((y > hithr) ? range_max : 0) : ((y >= ((x - lo)/(hi - lo) * (hithr - lothr) + lothr)) ? range_max : 0))
    mexpr = "x "+ String(lo) +" scalef < y "+ String(lothr) +" scalef >= range_max 0 ? x "+ String(hi) +" scalef > y "+ String(hithr) +" scalef >= range_max  0 ? y x "+ String(lo) +" scalef - "+ String(hi) +" scalef "+ String(lo) +" scalef - / "+ String(hithr)+ " scalef "+ String(lothr) +" scalef - * "+ String(lothr) +" scalef + >= range_max 0 ? ? ?"

    stack16_out ? BitsPerComponent(s) != 16 ? mt_lutxy(rmask, mexpr, use_expr=usee).ConvertBits(16).ConvertToStacked() : mt_lutxy(rmask, mexpr, use_expr=usee).ConvertToStacked() : mt_lutxy(rmask, mexpr, use_expr=usee)
}

/*
### Vapoursynth ###
import vapoursynth as vs
import havsfunc as haf

def debandmask(clip, lo=6144, hi=12288, lothr=320, hithr=384, mrad=2):
    core = vs.core

    f = clip.format
    bits = f.bits_per_sample
    isINT = f.sample_type==vs.INTEGER

    peak = (1 << bits) - 1 if isINT else 1
    clip = clip.std.ShufflePlanes(0, vs.GRAY)

    ma = haf.mt_expand_multi(clip, mode='ellipse', sw=mrad, sh=mrad)
    mi = haf.mt_inpand_multi(clip, mode='ellipse', sw=mrad, sh=mrad)

    rmask = core.std.Expr([ma, mi], 'x y -')

    mexpr = 'x {lo} < y {lothr} >= {peak} 0 ? x {hi} > y {hithr} >= {peak} 0 ? y x {lo} - {r} / {tr} * {lothr} + >= {peak} 0 ? ? ?'.format(lo=lo, hi=hi, lothr=lothr, hithr=hithr, peak=peak, r=hi-lo, tr=hithr-lothr)

    return core.std.Expr([clip, rmask], mexpr)
*/
