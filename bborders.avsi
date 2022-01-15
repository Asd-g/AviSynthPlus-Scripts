/*
by PL

Функция изменяет значения крайних пикселей клипа так, чтобы они были "более похожи" на соседние,
что, возможно, позволит избежать "сильного" использования Crop() для удаления "неприятных краёв",
не очень сильно отличающихся от "основного" изображения. См. примеры скринов.
 */

/******* bbmod is a balanceborders mod that uses division instead subtraction for the filtering. *******/


### Usage ###
###
# BalanceBorders(clip c, val "cTop", val "cBottom", val "cLeft", val "cRight", val "thresh", val "blur", bool "y", bool "u", bool "v", string "cloc")
###
# bbmod(clip c, val "cTop", val "cBottom", val "cLeft", val "cRight", val "thresh", val "blur", bool "y", bool "u", bool "v", string "cloc")
###
## Parameters ##
#---------------
# c: Input clip.
#---------------
# cTop, cBottom, cLeft, cRight (default 0): The number of lines to be filtered along each edge.
# If single number is used: it's applied for all three planes.
# If array is used: the first number is applied to luma plane, the second number - u plane, the third number - v plane.
# If array of two numbers is used: the first number - luma plane, the second number - u and v planes.
#---------------
# thresh (default 128.0): Threshold of the filtering.
# Higher values: more filtering.
# Lower values: less filtering.
# Recommended values: 0..16.0 or 128.0.
# If single number is used: it's applied for all three planes.
# If array is used: the first number is applied to luma plane, the second number - u plane, the third number - v plane.
# If array of two numbers is used: the first number - luma plane, the second number - u and v planes.
#---------------
# blur (default 999): Blur strength.
# Higher values: weak blurring.
# Lower values: strong blurring.
# Recommended values: 1..20 or 999.
# If single number is used: it's applied for all three planes.
# If array is used: the first number is applied to luma plane, the second number - u plane, the third number - v plane.
# If array of two numbers is used: the first number - luma plane, the second number - u and v planes.
#---------------
# y, u, v (default true): Whether to filter the corresponding plane.
#---------------
# cloc (default "left"): Chroma location of the video.
# Possible values: "left", "center", "top_left".


#СОВЕТЫ:
  #-------------------------------------------------------------------------------------------------------------------------------
  # 1)При значениях по умолчанию thresh=128 blur=999 вы получите ряды пикселей,
  #   изменённые только подбором цвета для каждого ряда целиком, без локального подбора,
  #   т.е. цвета соседних пикселей могут сильно отличатся в некоторых местах,
  #   но при этом не произойдёт изменения характера рисунка.
  #   А при thresh=128 и blur=1 вы получите практически одинаковые ряды пикселей,
  #   т.е. цвета между ними будут совпадать полностью, но оригинальный рисунок потеряется.
  #
  # 2)Остерегайтесь использования большого количества пикселей для изменения в сочетании с большим уровнем "thresh", и маленьким "blur"
  #   это может привести к появлению нежелательных артефактов "на чистом месте".
  #   Старайтесь для каждого вызова функции установить как можно меньшее количество пикселей для изменения и
  #   как можно меньшее значение порога "thresh" (при использовании blur 0..16).
  #-------------------------------------------------------------------------------------------------------------------------------

#ПРИМЕРЫ:
  #-------------------------------------------------------------------------------------------------------------------------------
  #   Минимально необходимый вариант из двух вызовов (количество изменяемых пикселей, естественно, указано для примера):
  #   BalanceBorders(7,6,4,4)
  #   BalanceBorders(7,6,4,4, thresh=4,blur=10)
  #
  #   Вариант нескольких вызовов поряд:
  #   BalanceBorders(7,6,4,4)                      //"общий" подбор цветов
  #   BalanceBorders(5,5,4,4, thresh=2,   blur=10) //совсем чуть-чуть изменяет большую область (с "запасом")
  #   BalanceBorders(3,3,2,2, thresh=8,   blur=4)  //несильно изменяет "основную проблемную область"
  #   BalanceBorders(1,1,0,0, thresh=128, blur=1)  //заменяет верхнюю и нижнюю строку пикселей (для удаления "чёрных полос")
  #-------------------------------------------------------------------------------------------------------------------------------


### Example with arrays (AviSynth 3.6.x required) ###
/*
BalanceBorders/bbmod([60,20], cleft=[40,20], y=true, u=true, v= false)
# same as BalanceBorders/bbmod(60, cleft=40, blur=999, y=true, u=false, v=false).BalanceBorders/bbmod(20, cleft=20, y=false, u=true, v=false)
*/
###
/*
BalanceBorders/bbmod([60], cleft=[40])
# same as BalanceBorders/bbmod(60, cleft=40) or BalanceBorders/bbmod(60, cleft=[40]) or BalanceBorders/bbmod([60], cleft=40)
*/
###
/*
BalanceBorders/bbmod([60,60], cleft=[40,40], thresh=[12,12], blur=[100,100], y=false, u=true, v= true)
# same as BalanceBorders/bbmod(60, cleft=40, thresh=12, blur=100, y=false) or BalanceBorders/bbmod([1,60,60], cleft=[1,40,40], thresh=[1,12,12], blur=[1,100,100], y=false, u=true, v= true)
/*
###
/*
BalanceBorders/bbmod([60,20,40], cleft=[40,20,10], thresh=[12,4,5], blur=[100,999,20])
# same as BalanceBorders/bbmod(60, cleft=40, thresh=12, blur=100, u=false, v=false).BalanceBorders/bbmod(20, cleft=20, thresh=4, y=false, v=false).BalanceBorders/bbmod(40, cleft=10, thresh=5, blur=20, y=false, u=false)
*/
###


### Requirements - AviSynth+ >= 3.6, avsresize


### Changelog ###
#---------------
# Fixed nuked _ChromaLocation frame property if available in the source.
#---------------
# Fixed processing when the clip has only one plane.
#---------------
# Added parameter "cloc".
#---------------
# Code clean up; fixed cBottom assert for chroma; arrays - if a single value is specified, it will be used for all planes, if two values are given then the second value will be used for the third plane as well.
#---------------
# Fixed error when cTop/cBottom/cLeft/cRight=1.
#---------------
# Merged all calculations in one expression that leads to ~15-20% less memory usage, ~10% speedup with 16-bit clips. (BalanceBorders)
# Merged all calculations in one expression that leads to ~20-35% less memory usage, ~20% speedup with 16-bit clips, ~10% speedup with 10-bit clips; fixed output with clips in float bit depth. (bbmod)
#---------------
# Added array support for parameters.
#---------------
# Removed an unnecessary resize call. (bbmod)
#---------------
# Replaced ResampleMT with z_ resizers.
#---------------
# Added usage info; intermediate function name changed; replaced lutxyz -> 8-bit ~15% speedup, 10-bit ~75% speedup, 16-bit ~50% speedup; removed full_range parameter. (BalanceBorders)
# Added usage info, intermediate function name changed; replaced lutxyz for 8/10-bit -> 8-bit 2x less memory usage, 10-bit ~25% speedup; 16-bit ~10% speedup; removed full_range parameter. (bbmod)
#---------------
# Added Y/YUV422/YUV444 processing.
#---------------
# Additional options bool y (true), bool u (true), bool v (true) for processing different planes; renamed to balanceborders_.avsi.
#---------------
# Fixed default thresh value; allowed 32-bit input; added bool full_range parameter (default=false) - it works only for high bit depth; it determines how the scaling to the input bit depth->8-bit->input bit depth is done ( http://avisynth.nl/index.php/MaskTools2#Expression_syntax_supporting_bit_depth_independent_expressions ).
#---------------
# Changed the thresh type int -> float, thresh is always in the range [0,128] (before it was in the range [0,bit depth half range]).
#---------------
# All options are optional (balanceborders/bbmod(2), balanceborders/bbmod(cleft=1) and so on). Added restriction - clip width / height should be > cLeft*4, cRgith*4 / cTop*4, cBottom*4.
#---------------
# Processing only part of the frame.


Function BalanceBorders(clip c, val "cTop", val "cBottom", val "cLeft", val "cRight", val "thresh", val "blur", bool "y", bool "u", bool "v", string "cloc")
{
    if (propGetType(c, "_ChromaLocation") > 0)
    {
        cl = propGetInt(c, "_ChromaLocation")
    }

    bb_process(c, 0, cTop, cBottom, cLeft, cRight, thresh, blur, y, u, v, cloc)

    if (propGetType(c, "_ChromaLocation") > 0)
    {
        propSet("_ChromaLocation", cl)
    }
}

Function bbmod(clip c, val "cTop", val "cBottom", val "cLeft", val "cRight", val "thresh", val "blur", bool "y", bool "u", bool "v", string "cloc")
{
    if (propGetType(c, "_ChromaLocation") > 0)
    {
        cl = propGetInt(c, "_ChromaLocation")
    }

    bb_process(c, 1, cTop, cBottom, cLeft, cRight, thresh, blur, y, u, v, cloc)

    if (propGetType(c, "_ChromaLocation") > 0)
    {
        propSet("_ChromaLocation", cl)
    }
}

Function bb_process(clip c, int func_name, val "cTop", val "cBottom", val "cLeft", val "cRight", val "thresh", val "blur", bool "y", bool "u", bool "v", string "cloc")
{
    Assert(isYUV(c), "This is not an YUV/Y clip.")

    y = Default(y, true)
    u = Default(u, true)
    v = Default(v, true)

    ctop_a = Defined(cTop) ?
        \ IsArray(cTop) ?
        \ ArraySize(cTop) == 1 ? [cTop[0], cTop[0], cTop[0]] :
        \ ArraySize(cTop) == 2 ? [cTop[0], cTop[1], cTop[1]] :
        \ ArraySize(cTop) == 3 ? [cTop[0], cTop[1], cTop[2]] :
        \ Assert(ArraySize(cTop) == 3, "The cTop values must be no more than three.") :
        \ [cTop, cTop, cTop] :
        \ [0, 0, 0]

    cbottom_a = Defined(cBottom) ?
        \ IsArray(cBottom) ?
        \ ArraySize(cBottom) == 1 ? [cBottom[0], cBottom[0], cBottom[0]] :
        \ ArraySize(cBottom) == 2 ? [cBottom[0], cBottom[1], cBottom[1]] :
        \ ArraySize(cBottom) == 3 ? [cBottom[0], cBottom[1], cBottom[2]] :
        \ Assert(ArraySize(cBottom) == 3, "The cBottom values must be no more than three.") :
        \ [cBottom, cBottom, cBottom] :
        \ [0, 0, 0]

    cleft_a = Defined(cLeft) ?
        \ IsArray(cLeft) ?
        \ ArraySize(cLeft) == 1 ? [cLeft[0], cLeft[0], cLeft[0]] :
        \ ArraySize(cLeft) == 2 ? [cLeft[0], cLeft[1], cLeft[1]] :
        \ ArraySize(cLeft) == 3 ? [cLeft[0], cLeft[1], cLeft[2]] :
        \ Assert(ArraySize(cLeft) == 3, "The cLeft values must be no more than three.") :
        \ [cLeft, cLeft, cLeft] :
        \ [0, 0, 0]

    cright_a = Defined(cRight) ?
        \ IsArray(cRight) ?
        \ ArraySize(cRight) == 1 ? [cRight[0], cRight[0], cRight[0]] :
        \ ArraySize(cRight) == 2 ? [cRight[0], cRight[1], cRight[1]] :
        \ ArraySize(cRight) == 3 ? [cRight[0], cRight[1], cRight[2]] :
        \ Assert(ArraySize(cRight) == 3, "The cRight values must be no more than three.") :
        \ [cRight, cRight, cRight] :
        \ [0, 0, 0]

    thresh_a = Defined(thresh) ?
        \ IsArray(thresh) ?
        \ ArraySize(thresh) == 1 ? [thresh[0], thresh[0], thresh[0]] :
        \ ArraySize(thresh) == 2 ? [thresh[0], thresh[1], thresh[1]] :
        \ ArraySize(thresh) == 3 ? [thresh[0], thresh[1], thresh[2]] :
        \ Assert(ArraySize(thresh) == 3, "The thresh values must be no more than three.") :
        \ [thresh, thresh, thresh] :
        \ [128.0, 128.0, 128.0]

    blur_a = Defined(blur) ?
        \ IsArray(blur) ?
        \ ArraySize(blur) == 1 ? [blur[0], blur[0], blur[0]] :
        \ ArraySize(blur) == 2 ? [blur[0], blur[1], blur[1]] :
        \ ArraySize(blur) == 3 ? [blur[0], blur[1], blur[2]] :
        \ Assert(ArraySize(blur) == 3, "The blur values must be no more than three.") :
        \ [blur, blur, blur] :
        \ [999, 999, 999]

    cloc = Default(cloc, "left")

    Assert(cloc == "left" || cloc == "top_left" || cloc == "center", "cloc must be one of the values 'left', 'top_left', 'center'.")

    source_planes = [y, u, v]
    clip_444 = Is444(c)
    clip_420 = Is420(c)
    chrh = clip_420 ? 1 : 0
    chrw = clip_444 ? 0 : 1
    num_planes = min(NumComponents(c), 3) - 1

    if (func_name == 0)
    {
        for (i = 0, num_planes)
        {
            if (i == 0) { ExtractY(c) }
            else if (i == 1) { ExtractU(c) }
            else { ExtractV(c) }

            if (source_planes[i])
            {
                Assert(blur_a[i] > 0 && blur_a[i] <= 999, "Blur parameter must be between 0..999.")
                Assert(thresh_a[i] > 0.0 && thresh_a[i] <= 128.0, "Thresh parameter must be between 0.0..128.0.")

                if (i == 0)
                {
                    Assert(cleft_a[i] * 4 < Width() && cright_a[i] * 4 < Width(), "cLeft*4, cRight*4 has to be < width.")
                    Assert(ctop_a[i] * 4 < Height() && cbottom_a[i] * 4 < Height(), "cTop*4, cBottom*4 has to be < height.")

                    if (ctop_a[i] > 0)
                    {
                        ctop_crop = ctop_a[i] * 2
                        StackVertical(Crop(0, 0, 0, ctop_crop).BalanceTopBorder(ctop_a[i], thresh_a[i], blur_a[i], i, clip_444, clip_420, cloc), Crop(0, ctop_crop, 0, 0)).TurnRight()
                    }
                    else { TurnRight() }

                    if (cleft_a[i] > 0)
                    {
                        cleft_crop = cleft_a[i] * 2
                        StackVertical(Crop(0, 0, 0, cleft_crop).BalanceTopBorder(cleft_a[i], thresh_a[i], blur_a[i], i, clip_444, clip_420, cloc), Crop(0, cleft_crop, 0, 0)).TurnRight()
                    }
                    else { TurnRight() }

                    if (cbottom_a[i] > 0)
                    {
                        cbottom_crop = cbottom_a[i] * 2
                        StackVertical(Crop(0, 0, 0, cbottom_crop).BalanceTopBorder(cbottom_a[i] , thresh_a[i], blur_a[i], i, clip_444, clip_420, cloc), Crop(0, cbottom_crop, 0, 0)).TurnRight()
                    }
                    else { TurnRight() }

                    if (cright_a[i] > 0)
                    {
                        cright_crop = cright_a[i] * 2
                        StackVertical(Crop(0, 0, 0, cright_crop).BalanceTopBorder(cright_a[i], thresh_a[i], blur_a[i], i, clip_444, clip_420, cloc), Crop(0, cright_crop, 0, 0)).TurnRight()
                    }
                    else { TurnRight() }

                    if (NumComponents(c) == 1) { return last }
                    else { yplane = last }
                }
                else
                {
                    Assert(BitRShiftL(cleft_a[i] * 4, chrw) < Width() && BitRShiftL(cright_a[i] * 4, chrw) < Width(), "cLeft*4, cRight*4 has to be < width.")
                    Assert(BitRShiftL(ctop_a[i] * 4, chrh) < Height() && BitRShiftL(cbottom_a[i] * 4, chrh) < Height(), "cTop*4, cBottom*4 has to be < height.")

                    if (ctop_a[i] > 1)
                    {
                        ctop_crop = BitRShiftL(ctop_a[i] * 2, chrh)
                        StackVertical(Crop(0, 0, 0, ctop_crop).BalanceTopBorder(BitRShiftL(ctop_a[i], chrh), thresh_a[i], blur_a[i], i, clip_444, clip_420, cloc), Crop(0, ctop_crop, 0, 0)).TurnRight()
                    }
                    else { TurnRight() }

                    if (cleft_a[i] > 1)
                    {
                        cleft_crop = BitRShiftL(cleft_a[i] * 2, chrw)
                        StackVertical(Crop(0, 0, 0, cleft_crop).BalanceTopBorder(BitRShiftL(cleft_a[i], chrw), thresh_a[i], blur_a[i], i, clip_444, clip_420, cloc), Crop(0, cleft_crop, 0, 0)).TurnRight()
                    }
                    else { TurnRight() }

                    if (cbottom_a[i] > 1)
                    {
                        cbottom_crop = BitRShiftL(cbottom_a[i] * 2, chrh)
                        StackVertical(Crop(0, 0, 0, cbottom_crop).BalanceTopBorder(BitRShiftL(cbottom_a[i], chrh), thresh_a[i], blur_a[i], i, clip_444, clip_420, cloc), Crop(0, cbottom_crop, 0, 0)).TurnRight()
                    }
                    else { TurnRight() }

                    if (cright_a[i] > 1)
                    {
                        cright_crop = BitRShiftL(cright_a[i] * 2, chrw)
                        StackVertical(Crop(0, 0, 0, cright_crop).BalanceTopBorder(BitRShiftL(cright_a[i], chrw), thresh_a[i], blur_a[i], i, clip_444, clip_420, cloc), Crop(0, cright_crop, 0, 0)).TurnRight()
                    }
                    else { TurnRight() }

                    if (i == 1) { uplane = last }
                    else { vplane = last }
                }
            }
            else
            {
                if (i == 0) { yplane = last }
                else if (i == 1) { uplane = last }
                else { vplane = last }
            }
        }
    }
    else
    {
        for (i = 0, num_planes)
        {
            if (i == 0) { ExtractY(c) }
            else if (i == 1) { ExtractU(c) }
            else { ExtractV(c) }

            if (source_planes[i])
            {
                Assert(blur_a[i] > 0 && blur_a[i] <= 999, "Blur parameter must be between 0..999.")
                Assert(thresh_a[i] > 0.0 && thresh_a[i] <= 128.0, "Thresh parameter must be between 0.0..128.0.")

                if (i == 0)
                {
                    Assert(cleft_a[i] * 4 < Width() && cright_a[i] * 4 < Width(), "cLeft*4, cRight*4 has to be < width.")
                    Assert(ctop_a[i] * 4 < Height() && cbottom_a[i] * 4 < Height(), "cTop*4, cBottom*4 has to be < height.")

                    if (ctop_a[i] > 0)
                    {
                        ctop_crop = ctop_a[i] * 2
                        StackVertical(Crop(0, 0, 0, ctop_crop).btb(ctop_a[i], thresh_a[i], blur_a[i], i, clip_444, clip_420, cloc), Crop(0, ctop_crop, 0, 0)).TurnRight()
                    }
                    else { TurnRight() }

                    if (cleft_a[i] > 0)
                    {
                        cleft_crop = cleft_a[i] * 2
                        StackVertical(Crop(0, 0, 0, cleft_crop).btb(cleft_a[i], thresh_a[i], blur_a[i], i, clip_444, clip_420, cloc), Crop(0, cleft_crop, 0, 0)).TurnRight()
                    }
                    else { TurnRight() }

                    if (cbottom_a[i] > 0)
                    {
                        cbottom_crop = cbottom_a[i] * 2
                        StackVertical(Crop(0, 0, 0, cbottom_crop).btb(cbottom_a[i] , thresh_a[i], blur_a[i], i, clip_444, clip_420, cloc), Crop(0, cbottom_crop, 0, 0)).TurnRight()
                    }
                    else { TurnRight() }

                    if (cright_a[i] > 0)
                    {
                        cright_crop = cright_a[i] * 2
                        StackVertical(Crop(0, 0, 0, cright_crop).btb(cright_a[i], thresh_a[i], blur_a[i], i, clip_444, clip_420, cloc), Crop(0, cright_crop, 0, 0)).TurnRight()
                    }
                    else { TurnRight() }

                    if (NumComponents(c) == 1) { return last }
                    else { yplane = last }
                }
                else
                {
                    Assert(BitRShiftL(cleft_a[i] * 4, chrw) < Width() && BitRShiftL(cright_a[i] * 4, chrw) < Width(), "cLeft*4, cRight*4 has to be < width.")
                    Assert(BitRShiftL(ctop_a[i] * 4, chrh) < Height() && BitRShiftL(cbottom_a[i] * 4, chrh) < Height(), "cTop*4, cBottom*4 has to be < height.")

                    if (ctop_a[i] > 1)
                    {
                        ctop_crop = BitRShiftL(ctop_a[i] * 2, chrh)
                        StackVertical(Crop(0, 0, 0, ctop_crop).btb(BitRShiftL(ctop_a[i], chrh), thresh_a[i], blur_a[i], i, clip_444, clip_420, cloc), Crop(0, ctop_crop, 0, 0)).TurnRight()
                    }
                    else { TurnRight() }

                    if (cleft_a[i] > 1)
                    {
                        cleft_crop = BitRShiftL(cleft_a[i] * 2, chrw)
                        StackVertical(Crop(0, 0, 0, cleft_crop).btb(BitRShiftL(cleft_a[i], chrw), thresh_a[i], blur_a[i], i, clip_444, clip_420, cloc), Crop(0, cleft_crop, 0, 0)).TurnRight()
                    }
                    else { TurnRight() }

                    if (cbottom_a[i] > 1)
                    {
                        cbottom_crop = BitRShiftL(cbottom_a[i] * 2, chrh)
                        StackVertical(Crop(0, 0, 0, cbottom_crop).btb(BitRShiftL(cbottom_a[i], chrh), thresh_a[i], blur_a[i], i, clip_444, clip_420, cloc), Crop(0, cbottom_crop, 0, 0)).TurnRight()
                    }
                    else { TurnRight() }

                    if (cright_a[i] > 1)
                    {
                        cright_crop = BitRShiftL(cright_a[i] * 2, chrw)
                        StackVertical(Crop(0, 0, 0, cright_crop).btb(BitRShiftL(cright_a[i], chrw), thresh_a[i], blur_a[i], i, clip_444, clip_420, cloc), Crop(0, cright_crop, 0, 0)).TurnRight()
                    }
                    else { TurnRight() }

                    if (i == 1) { uplane = last }
                    else { vplane = last }
                }
            }
            else
            {
                if (i == 0) { yplane = last }
                else if (i == 1) { uplane = last }
                else { vplane = last }
            }
        }
    }

    return CombinePlanes(yplane, uplane, vplane, planes="YUV", sample_clip=c)
}

Function BalanceTopBorder(clip c, int cTop, float thresh, int blur, int plane, bool clip_444, bool clip_420, string cloc)
{
    cWidth = c.width
    cHeight = c.height
    cTop = min(cTop,cHeight-1)
    blurWidth = max(4,floor(cWidth/blur))

    c2 = c.z_PointResize(cWidth * 2, cHeight * 2)

    c2.\
    Crop(0, cTop * 2, cWidth * 2, 2)
    z_PointResize(cWidth * 2, cTop * 2)
    z_BilinearResize(blurWidth * 2, cTop * 2)
    Blur(1.5,0.1)
    z_BilinearResize(cWidth * 2, cTop * 2)
    referenceBlur = last

    original = c2.Crop(0, 0, cWidth * 2, cTop * 2)

    original
    z_BilinearResize(blurWidth * 2, cTop * 2)
    Blur(1.5,0.1)
    z_BilinearResize(cWidth * 2, cTop * 2)
    originalBlur = last

    if (plane == 0)
    {
        Expr(original, originalBlur, referenceBlur, "z y - "+ String(thresh) +" scaleb > x "+ String(thresh) +" scaleb + z y - "+ String(-thresh) +" scaleb < x "+ String(thresh) +" scaleb - z y - x + ? ? 16 scaleb 235 scaleb clip")

        StackVertical(last, c2.Crop(0, cTop * 2, cWidth * 2, (cHeight - cTop) * 2))
        z_PointResize(cWidth, cHeight)
    }
    else
    {
        if (BitsPerComponent(c) == 32) { Expr(original, originalBlur, referenceBlur, "z y - "+ String(thresh) +" 128 - scaleb 0.5 + > x "+ String(thresh) +" 128 - scaleb 0.5 + + z y - "+ String(-thresh) +" 128 - scaleb 0.5 + < x "+ String(thresh) +" 128 - scaleb 0.5 + - z y - x + ? ? -0.43921568627 0.43921568627 clip") }
        else { Expr(original, originalBlur, referenceBlur, "z y - "+ String(thresh) +" scaleb > x "+ String(thresh) +" scaleb + z y - "+ String(-thresh) +" scaleb < x "+ String(thresh) +" scaleb - z y - x + ? ? 16 scaleb 240 scaleb clip") }

        StackVertical(last, c2.Crop(0, cTop * 2, cWidth * 2, (cHeight - cTop) * 2))
        chroma_shift_(clip_444, clip_420, cloc)
    }
}

Function btb(clip c, int cTop, float thresh, int blur, int plane, bool clip_444, bool clip_420, string cloc)
{
    cWidth = c.width
    cHeight = c.height
    cTop = min(cTop,cHeight-1)
    blurWidth = max(8,floor(cWidth/blur))

    c2 = c.z_PointResize(cWidth * 2, cHeight * 2)

    c2.\
    Crop(0, cTop * 2, cWidth * 2, 2)
    z_PointResize(cWidth * 2, cTop * 2)
    referenceBlur = z_bicubicresize(blurWidth * 2, cTop * 2, b=1, c=0).z_bicubicresize(cWidth * 2, cTop * 2, b=1, c=0)

    original = c2.Crop(0, 0, cWidth * 2, cTop * 2)

    original
    z_bicubicresize(blurWidth * 2, cTop * 2, b=1, c=0)
    originalBlur = z_bicubicresize(blurWidth * 2, cTop * 2, b=1, c=0).z_bicubicresize(cWidth * 2, cTop * 2, b=1, c=0)

    if (plane == 0)
    {
        Expr(original, originalBlur, referenceBlur, "z 16 scaleb - y 16 scaleb - / 8 min 0.4 max x 16 scaleb - * 16 scaleb + x - "+ String(thresh) +" scaleb > x "+ String(thresh) +" scaleb + z 16 scaleb - y 16 scaleb - / 8 min 0.4 max x 16 scaleb - * 16 scaleb + x - "+ String(-thresh) +" scaleb < x "+ String(thresh) +" scaleb - z 16 scaleb - y 16 scaleb - / 8 min 0.4 max x 16 scaleb - * 16 scaleb + ? ? 16 scaleb 235 scaleb clip")

        StackVertical(last, c2.Crop(0, cTop * 2, cWidth * 2, (cHeight - cTop) * 2))
        z_PointResize(cWidth, cHeight)
    }
    else
    {
        if (BitsPerComponent(c) == 32) { Expr(original, originalBlur, referenceBlur, "z y - z 0.5 + y 0.5 + / 8 min 0.4 max x * + x - "+ String(thresh) +" 128 - scaleb 0.5 + > x "+ String(thresh) +" 128 - scaleb 0.5 + + z y - z 0.5 + y 0.5 + / 8 min 0.4 max x * + x - "+ String(-thresh) +" 128 - scaleb 0.5 + < x "+ String(thresh) +" 128 - scaleb 0.5 + - z y - z 0.5 + y 0.5 + / 8 min 0.4 max x * + ? ? -0.43921568627 0.43921568627 clip") }
        else { Expr(original, originalBlur, referenceBlur, "z y - z y / 8 min 0.4 max x 128 scaleb - * 128 scaleb + + x - "+ String(thresh) +" scaleb > x "+ String(thresh) +" scaleb + z y - z y / 8 min 0.4 max x 128 scaleb - * 128 scaleb + + x - "+ String(-thresh) +" scaleb < x "+ String(thresh) +" scaleb - z y - z y / 8 min 0.4 max x 128 scaleb - * 128 scaleb + + ? ? 16 scaleb 240 scaleb clip") }

        StackVertical(last, c2.Crop(0, cTop * 2, cWidth * 2, (cHeight - cTop) * 2))
        chroma_shift_(clip_444, clip_420, cloc)
    }
}

Function chroma_shift_(clip c, bool clip_444, bool clip_420, string cloc)
{
    c

    if (!clip_444)
    {
        if ((clip_420 && cloc == "left") || (!clip_420 && cloc != "center")) { z_PointResize(Width() / 2, Height() / 2, -0.25) }
        else if (clip_420 && cloc == "top_left") { z_PointResize(Width() / 2, Height() / 2, -0.25, -0.25) }
        else { z_PointResize(Width() / 2, Height() / 2) }
    }
    else { z_PointResize(Width() / 2, Height() / 2) }
}
