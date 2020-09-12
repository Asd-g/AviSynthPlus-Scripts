# AdaptiveGrain is based on the VapourSynth adaptive_grain_mask ( https://blog.kageru.moe/legacy/adaptivegrain.html ). "For each frame in the input clip, a mask is generated based on the frame's average luma and the individual pixel's value." "Generally, the lower a frame's average luma, the more grain is applied even to the brighter areas. This abuses the fact that our eyes are instinctively drawn to the brighter part of any image, making the grain less necessary in images with an overall very high luma."
# Pure white (235 (8-bit)) pixels are just copied.
# The grain applied on black pixels with values of 18->17 (8-bit) fades out and pixels with value of 16 (8-bit) (pure black) are just copied.


### Usage
## AdaptiveGrain(clip c, clip "grain", float "luma_scaling", bool "mask8", bool "luma", bool "show")
# - clip c - the input clip
# - clip grain - the clip on that the grain is applied. Default - AddGrain(c, 0.25, constant=true)
# - luma_scaling - grain opacity curve. Lower values will generate more grain even in brighter scenes while higher values will generate less even in dark scenes. Default - 10.0.
# - mask8 - generate the mask in 8-bit even when the clip has > 8 bit depth. The final speed is 2-3x higher without visible difference than if the mask is generated in the clip bit depth. Default - true.
# - luma - if true the luma mask is used for chroma too. Default - false, only luma is processed.
# - show - if true the output is the mask. Default - false.


## Examples
# AdaptiveGrain(grain=GrainFactory3(g1str=20,g2str=20,g3str=20))
# AdaptiveGrain(grain=AddGrain(var=0.3))
# AdaptiveGrain(grain=neo_f3kdb(15,0,0,0,64,0))


Function AdaptiveGrain(clip c, clip "grain", float "luma_scaling", bool "mask8", bool "luma", bool "show")
{   
    grain = Default(grain, AddGrain(c, 0.25, constant=true))
    
    c_bits = BitsPerComponent(c)
    
    Assert(IsYUV(c) || IsYUVA(c) || IsYUV(grain) || IsYUVA(grain), "AdaptiveGrain: only Y/YUV planar format supported.")
    Assert(Width(c) == Width(grain) || Height(c) == Height(grain), " AdaptiveGrain: clips must have same dimensions.")
    Assert(c_bits == BitsPerComponent(grain), " AdaptiveGrain: clips must have same bit depth.")
    
    global luma_scaling = Default(luma_scaling, 10.0)
    mask8 = Default(mask8, true)
    
    if (c_bits == 8)
    {
        ScriptClip(c, """ mt_lut("x 16 <= 0 x 235 >= 0 x 17 == 85 x 18 == 170 1.0 x 16 - 219 / 0.994469 min x 16 - 219 / 0.994469 min x 16 - 219 / 0.994469 min x 16 - 219 / 0.994469 min x 16 - 219 / 0.994469 min 18.188 * 45.47 - * 36.624 + * 9.46 - * 1.124 + * - "+ String(AverageLuma()) +" 16 - 219 / 0.994469 min 2 ^ "+ String(luma_scaling) +" * ^ 255.0 * ? ? ? ? 0 255 clip") """)       
    }
    else if (mask8)
    {
        z_ConvertFormat(c, pixel_type="y8")
        ScriptClip(""" mt_lut("x 16 <= 0 x 235 >= 0 x 17 == 85 x 18 == 170 1.0 x 16 - 219 / 0.994469 min x 16 - 219 / 0.994469 min x 16 - 219 / 0.994469 min x 16 - 219 / 0.994469 min x 16 - 219 / 0.994469 min 18.188 * 45.47 - * 36.624 + * 9.46 - * 1.124 + * - "+ String(AverageLuma()) +" 16 - 219 / 0.994469 min 2 ^ "+ String(luma_scaling) +" * ^ 255.0 * ? ? ? ? 0 255 clip") """)            
        ConvertBits(BitsPerComponent(c))
    }
    else
    {
        if (NumComponents(c) == 3)
        {
            ScriptClip(c, """ Expr("x 16 scaleb <= 0 x 235 scaleb >= 0 x 17 scaleb == 85 scalef x 18 scaleb == 170 scalef 1.0 x 16 scaleb - 219 scaleb / 0.994469 min x 16 scaleb - 219 scaleb / 0.994469 min x 16 scaleb - 219 scaleb / 0.994469 min x 16 scaleb - 219 scaleb / 0.994469 min x 16 scaleb - 219 scaleb / 0.994469 min 18.188 * 45.47 - * 36.624 + * 9.46 - * 1.124 + * - "+ String(AverageLuma()) +" 16 scaleb - 219 scaleb / 0.994469 min 2 ^ "+ String(luma_scaling) +" * ^ range_max * ? ? ? ? 0 255 scalef clip", "", "") """)
        }
        else
        {
            ScriptClip(c, """ Expr("x 16 scaleb <= 0 x 235 scaleb >= 0 x 17 scaleb == 85 scalef x 18 scaleb == 170 scalef 1.0 x 16 scaleb - 219 scaleb / 0.994469 min x 16 scaleb - 219 scaleb / 0.994469 min x 16 scaleb - 219 scaleb / 0.994469 min x 16 scaleb - 219 scaleb / 0.994469 min x 16 scaleb - 219 scaleb / 0.994469 min 18.188 * 45.47 - * 36.624 + * 9.46 - * 1.124 + * - "+ String(AverageLuma()) +" 16 scaleb - 219 scaleb / 0.994469 min 2 ^ "+ String(luma_scaling) +" * ^ range_max * ? ? ? ? 0 255 scalef clip") """)
        }
    }
    
    show = Default(show, false)
    
    if (show == true)
    {
        return last
    }
    
    luma = Default(luma, false)
    
    return mt_merge(c, grain, last, luma=luma).Limiter(paramscale=true)
}
