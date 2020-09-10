# return Y clip; 8-bit ~3% speedup (mrad > 1); 10-bit ~10% speedup (mrad > 1); 16-bit ~10x speedup (mrad > 1); changed default values to 60,16,4,4,1
# added default values that give ~same result as mt_edge("prewitt") but ~2x slower; however debandmask(60,16,4,4,1) with predenoised source gives better result than mt_edge("prewitt")
# high bit-depth and stack16_in/out support
# processing only luma (Avs+)
# meant as a faster version of the retinex-type deband mask
# lo and hi are the cutoffs for luma
# lothr and hithr are the Binarize thresholds of the mask at lo/hi luma levels
# luma values falling between lo and hi are scaled linearly from lothr to hithr

/* ### Vapoursynth ###
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
    
    return core.std.Expr([clip, rmask], mexpr) */


### Avisynth+ ###
Function debandmask(clip c, int "lo", int "hi", int "lothr", int "hithr", int "mrad", bool "stack16_in", bool "stack16_out")
{
    lo          = Default(lo, 60)
    hi          = Default(hi, 16)
    lothr       = Default(lothr, 4)
    hithr       = Default(hithr, 4)
    mrad        = Default(mrad, 1)
    stack16_in  = Default(stack16_in, false)
    stack16_out = Default(stack16_out, false)    
    
    usee  = BitsPerComponent(c) > 10 ? 3 : 0
    
    Assert(lo >= 0 && hi >= 0 && lothr >= 0 && hithr >= 0,         "debandmask: lo/hi/lothr/hithr must be >= 0")
    Assert(lo <= 255 && hi <= 255 && lothr <= 255 && hithr <= 255, "debandmask: lo/hi/lothr/hithr must be <= 255")
    Assert(mrad >= 1,                                              "debandmask: mrad must be >= 1")
    
    stack16_in == false ? c : ConvertFromStacked(c)
    s = last
    ExtractY()
    
    ma = mt_expand_multi(mode="ellipse", sw=mrad, sh=mrad)
    mi = mt_inpand_multi(mode="ellipse", sw=mrad, sh=mrad)
    
    rmask = mrad > 1 ? mt_lutxy(ma, mi, "x y -", use_expr=1) : mt_edge(mode="min/max", thY1=0, thY2=255)
    
    mexpr = "x "+ String(lo) +" scaleb < y "+ String(lothr) +" scaleb >= range_max 0 ? x "+ String(hi) +" scaleb > y "+ String(hithr) +" scaleb >= range_max  0 ? y x "+ String(lo) +" scaleb - "+ String(hi) +" scaleb "+ String(lo) +" scaleb - / "+ String(hithr)+ " scaleb "+ String(lothr) +" scaleb - * "+ String(lothr) +" scaleb + >= range_max 0 ? ? ?"
    
    stack16_out ? BitsPerComponent(s) != 16 ? mt_lutxy(rmask, mexpr, use_expr=usee).ConvertBits(16).ConvertToStacked() : mt_lutxy(rmask, mexpr, use_expr=usee).ConvertToStacked() : mt_lutxy(rmask, mexpr, use_expr=usee)
}