# AdaptiveGrain is based on the VapourSynth adaptive_grain_mask ( https://blog.kageru.moe/legacy/adaptivegrain.html ). "For each frame in the input clip, a mask is generated based on the frame's average luma and the individual pixel's value." "Generally, the lower a frame's average luma, the more grain is applied even to the brighter areas. This abuses the fact that our eyes are instinctively drawn to the brighter part of any image, making the grain less necessary in images with an overall very high luma."
# Pure white (235 (8-bit)) pixels are just copied.
# The grain applied on black pixels with values of 18->17 (8-bit) fades out and pixels with value of 16 (8-bit) (pure black) are just copied.


### Usage ###
###
# AdaptiveGrain(clip c, clip "grain", float "luma_scaling", bool "mask8", bool "luma", bool "show", bool "keep_in_range")
###
## Parameters ##
#---------------
# clip c: The input clip.
# Must be in YUV planar format.
# 32-bit input is assumed full range.
#---------------
# clip grain (default AddGrain(c, 0.25, constant=true): The clip on that the grain is applied.
#---------------
# luma_scaling (default 10.0): Grain opacity curve. Lower values will generate more grain even in brighter scenes while higher values will generate less even in dark scenes.
#---------------
# mask8 (default true): Generate the mask in 8-bit even when the clip has > 8 bit depth. The final speed is 2-3x higher without visible difference than if the mask is generated in the clip bit depth.
#---------------
# luma (default false): If true the luma mask is used for chroma too.
#---------------
# show (default false): If true the output is the mask.
#---------------
# keep_in_range (default true): Clipping to valid range.
# 8..16-bit: valid range is TV range.
# 32-bit: valid range is 0.0..1.0. 


### Examples ###
# AdaptiveGrain(grain=GrainFactory3(g1str=20,g2str=20,g3str=20))
# AdaptiveGrain(grain=AddGrain(var=0.3))
# AdaptiveGrain(grain=neo_f3kdb(15,0,0,0,64,0))


### Changelog ###
#---------------
# - Make it work in any AVS, adding keep_in_range. (realfinder)
#---------------
# - Assume the input and the output in full range for YUV float.
#---------------
# - Initial version.


Function AdaptiveGrain(clip c, clip "grain", float "luma_scaling", bool "mask8", bool "luma", bool "show", bool "keep_in_range")
{   
    grain = Default(grain, AddGrain(c, 0.25, constant=true))
    show = Default(show, false)
    luma_scaling = Default(luma_scaling, 10.0)
    mask8 = Default(mask8, true)
    luma = Default(luma, false)
    keep_in_range = Default(keep_in_range, true)

    sisavs26 = !(VersionNumber() < 2.60)
    v=VersionString()
    asdIsAvsNeo=FindStr(v," Neo")!=0
    asdIsAvsPlus=FindStr(v,"AviSynth+")!=0||asdIsAvsNeo
    Off=(!asdIsAvsPlus)?0:FindStr(V,"(r")
    sisphbd = ((Off==0)?0:V.MidStr(Off+2).Value.Int) > 2294
    c_bits = sisphbd ? c.BitsPerComponent() : 8

    Assert(IsYUV(c) || (sisphbd ? IsYUVA(c) : false) || IsYUV(grain) || (sisphbd ? IsYUVA(grain) : false), "AdaptiveGrain: only Y/YUV planar format supported.")
    Assert(Width(c) == Width(grain) || Height(c) == Height(grain), " AdaptiveGrain: clips must have same dimensions.")
    sisphbd ? Assert(c_bits == BitsPerComponent(grain), " AdaptiveGrain: clips must have same bit depth.") : nop()

    sisVfloat = c_bits > 8 ? c.IsVideoFloat() : false

    c_bits == 8 ? eval("""
        sisphbd ? ExtractY(c) : sisavs26 ? ConvertToY8(c) : c
        gScriptClip(" mt_lut("+Chr(34)+"x 16 <= 0 x 235 >= 0 x 17 == 85 x 18 == 170 1.0 x 16 - 219 / 0.994469 min x 16 - 219 / 0.994469 min x 16 - 219 / 0.994469 min x 16 - 219 / 0.994469 min x 16 - 219 / 0.994469 min 18.188 * 45.47 - * 36.624 + * 9.46 - * 1.124 + * - "+Chr(34)+"+ String(AverageLuma()) +"+Chr(34)+" 16 - 219 / 0.994469 min 2 ^ "+Chr(34)+"+ String(luma_scaling) +"+Chr(34)+" * ^ 255.0 * ? ? ? ? 0 255 clip"+Chr(34)+")", args="luma_scaling")
    """) : mask8 ? eval("""
        z_ConvertFormat(c, pixel_type="y8")
        gScriptClip(" mt_lut("+Chr(34)+"x 16 <= 0 x 235 >= 0 x 17 == 85 x 18 == 170 1.0 x 16 - 219 / 0.994469 min x 16 - 219 / 0.994469 min x 16 - 219 / 0.994469 min x 16 - 219 / 0.994469 min x 16 - 219 / 0.994469 min 18.188 * 45.47 - * 36.624 + * 9.46 - * 1.124 + * - "+Chr(34)+"+ String(AverageLuma()) +"+Chr(34)+" 16 - 219 / 0.994469 min 2 ^ "+Chr(34)+"+ String(luma_scaling) +"+Chr(34)+" * ^ 255.0 * ? ? ? ? 0 255 clip"+Chr(34)+")", args="luma_scaling")
        ConvertBits(c_bits)
    """) : eval("""
        ExtractY(c)
        sisVfloat ? gScriptClip(" Expr("+Chr(34)+"x 0.0 <= 0.0 x 1.0 >= 0.0 x 0.00456621 == 0.31506849 x 0.00913242 == 0.70319634 1.0 x 0.994469 min x 0.994469 min x 0.994469 min x 0.994469 min x 0.994469 min 18.188 * 45.47 - * 36.624 + * 9.46 - * 1.124 + * - "+Chr(34)+"+ String(AverageLuma()) +"+Chr(34)+" 0.994469 min 2 ^ "+Chr(34)+"+ String(luma_scaling) +"+Chr(34)+" * ^ ? ? ? ? 0.0 1.0 clip"+Chr(34)+")", args="luma_scaling") :
                  \ gScriptClip(" Expr("+Chr(34)+"x 16 scaleb <= 0 x 235 scaleb >= 0 x 17 scaleb == 85 scalef x 18 scaleb == 170 scalef 1.0 x 16 scaleb - 219 scaleb / 0.994469 min x 16 scaleb - 219 scaleb / 0.994469 min x 16 scaleb - 219 scaleb / 0.994469 min x 16 scaleb - 219 scaleb / 0.994469 min x 16 scaleb - 219 scaleb / 0.994469 min 18.188 * 45.47 - * 36.624 + * 9.46 - * 1.124 + * - "+Chr(34)+"+ String(AverageLuma()) +"+Chr(34)+" 16 scaleb - 219 scaleb / 0.994469 min 2 ^ "+Chr(34)+"+ String(luma_scaling) +"+Chr(34)+" * ^ range_max * ? ? ? ? 0 255 scalef clip"+Chr(34)+")", args="luma_scaling")
    """)

    show ? last : mt_merge(c, grain, last, luma=luma)
    show || !keep_in_range ? last : sisVfloat ? Limiter(0.0, 1.0, -0.5, 0.5) : sisphbd ? Limiter(paramscale=true) : Limiter()
    return last
}
