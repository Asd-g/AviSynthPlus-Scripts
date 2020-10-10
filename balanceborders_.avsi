## Changelog:
# - code clean up; fixed cBottom assert for chroma; arrays - if a single value is specified, it will be used for all planes, if two values are given then the second value will be used for the third plane as well.
# - fixed error when cTop/cBottom/cLeft/cRight=1.
# - merged all calculations in one expression that leads to ~15-20% less memory usage, ~10% speedup with 16-bit clips.
# - added array support for parameters.
# - replaced ResampleMT with z_ resizers.
# - added usage info; intermediate function name changed; replaced lutxyz -> 8-bit ~15% speedup, 10-bit ~75% speedup, 16-bit ~50% speedup; removed full_range parameter.
# - added Y/YUV422/YUV444 processing.
# - additional options bool y (true), bool u (true), bool v (true) for processing different planes; renamed to balanceborders_.avsi.
# - fixed default thresh value; allowed 32-bit input; added bool full_range parameter (default=false) - it works only for high bit depth; it determines how the scaling to the input bit depth->8-bit->input bit depth is done ( http://avisynth.nl/index.php/MaskTools2#Expression_syntax_supporting_bit_depth_independent_expressions ).
# - changed the thresh type int -> float, thresh is always in the range [0,128] (before it was in the range [0,bit depth half range]).
# - all options are optional (balanceborders(2), balanceborders(cleft=1) and so on). Added restriction - clip width / height should be > cLeft*4, cRgith*4 / cTop*4, cBottom*4.
# - processing only part of the frame.


## Example with arrays (AviSynth 3.6.x required)
# BalanceBorders([60,20], cleft=[40,20], y=true, u=true, v= false) # same as BalanceBorders(60, cleft=40, blur=999, y=true, u=false, v=false).BalanceBorders(20, cleft=20, y=false, u=true, v=false)
# BalanceBorders([60], cleft=[40]) # same as BalanceBorders(60, cleft=40)/BalanceBorders(60, cleft=[40])/BalanceBorders([60], cleft=40)
# BalanceBorders([60,60], cleft=[40,40], thresh=[12,12], blur=[100,100], y=false, u=true, v= true) # same as BalanceBorders(60, cleft=40, thresh=12, blur=100, y=false)/BalanceBorders([x,60,60], cleft=[x,40,40], thresh=[x,12,12], blur=[x,100,100], y=false, u=true, v= true)
# BalanceBorders([60,20,40], cleft=[40,20,10], thresh=[12,4,5], blur=[100,999,20]) # same as BalanceBorders(60, cleft=40, thresh=12, blur=100, u=false, v=false).BalanceBorders(20, cleft=20, thresh=4, y=false, v=false).BalanceBorders(40, cleft=10, thresh=5, blur=20, y=false, u=false)


#ОПИСАНИЕ:
  #------------------------------------------------------------------------------------------------------------------------------
  # function BalanceBorders(clip c, int cTop, int cBottom, int cLeft, int cRight, int "thresh", int "blur")
  #
  # //by PL — [2009.09.25] v0.2 :)
  #
  # Функция изменяет значения крайних пикселей клипа так, чтобы они были "более похожи" на соседние,
  # что, возможно, позволит избежать "сильного" использования Crop() для удаления "неприятных краёв",
  # не очень сильно отличающихся от "основного" изображения. См. примеры скринов.
  #------------------------------------------------------------------------------------------------------------------------------

#ПАРАМЕТРЫ:
  #------------------------------------------------------------------------------------------------------------------------------
  # с - Область изображения "в середине" в процессе обработки не изменяется.
  #
  # cTop, cBottom, cLeft, cRight - range[0..inf]
  #   количество изменяемых пикселей с каждой стороны.
  #   Не случится ничего очень страшного, если указать значения,
  #   больше необходимого в вашем случае минимума,
  #   но, для достижения хорошего результата, "лучше не надо"...
  #
  # "thresh" - range[0..128] default[128] recommended[0..16 или 128]
  #   порог допустимых изменений для локального подбора цвета.
  #
  # "blur" - range[1..inf] default[999] recommended[1..20 или 999]
  #   степень размытия для локального подбора цветов,
  #   меньшие значения дают более точное соответствие цветов,
  #   большие значения дают более точную передачу рисунка.
  #-------------------------------------------------------------------------------------------------------------------------------

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


Function BalanceBorders(clip c, val "cTop", val "cBottom", val "cLeft", val "cRight", val "thresh", val "blur", bool "y", bool "u", bool "v")
{
    Assert(isYUV(c), "BalanceBorders: This is not an YUV/Y clip.")
     
    num_comp_1 = NumComponents(c) == 1
    y = Default(y, true)
    u = Default(u, num_comp_1 ? false : true)
    v = Default(v, num_comp_1 ? false : true) 
    
    ctop_a = Defined(cTop) && IsArray(cTop) ?
        \ ArraySize(cTop) == 1 ? [cTop[0], cTop[0], cTop[0]] :
        \ ArraySize(cTop) == 2 ? [cTop[0], cTop[1], cTop[1]] :
        \ ArraySize(cTop) == 3 ? [cTop[0], cTop[1], cTop[2]] :
        \ Assert(ArraySize(cTop) == 3, "BalanceBorders: more cTop given than there are planes.") :
    \ Defined(cTop) ? cTop : 0    
    
    cbottom_a = Defined(cBottom) && IsArray(cBottom) ?
        \ ArraySize(cBottom) == 1 ? [cBottom[0], cBottom[0], cBottom[0]] :
        \ ArraySize(cBottom) == 2 ? [cBottom[0], cBottom[1], cBottom[1]] :
        \ ArraySize(cBottom) == 3 ? [cBottom[0], cBottom[1], cBottom[2]] :
        \ Assert(ArraySize(cBottom) == 3, "BalanceBorders: more cBottom given than there are planes.") :
    \ Defined(cBottom) ? cBottom : 0
    
    cleft_a = Defined(cLeft) && IsArray(cLeft) ?
        \ ArraySize(cLeft) == 1 ? [cLeft[0], cLeft[0], cLeft[0]] :
        \ ArraySize(cLeft) == 2 ? [cLeft[0], cLeft[1], cLeft[1]] :
        \ ArraySize(cLeft) == 3 ? [cLeft[0], cLeft[1], cLeft[2]] :
        \ Assert(ArraySize(cLeft) == 3, "BalanceBorders: more cLeft given than there are planes.") :
    \ Defined(cLeft) ? cLeft : 0
    
    cright_a = Defined(cRight) && IsArray(cRight) ?
        \ ArraySize(cRight) == 1 ? [cRight[0], cRight[0], cRight[0]] :
        \ ArraySize(cRight) == 2 ? [cRight[0], cRight[1], cRight[1]] :
        \ ArraySize(cRight) == 3 ? [cRight[0], cRight[1], cRight[2]] :
        \ Assert(ArraySize(cRight) == 3, "BalanceBorders: more cRight given than there are planes.") :
    \ Defined(cRight) ? cRight : 0
    
    thresh_a = Defined(thresh) && IsArray(thresh) ?
        \ ArraySize(thresh) == 1 ? [thresh[0], thresh[0], thresh[0]] :
        \ ArraySize(thresh) == 2 ? [thresh[0], thresh[1], thresh[1]] :
        \ ArraySize(thresh) == 3 ? [thresh[0], thresh[1], thresh[2]] :
        \ Assert(ArraySize(thresh) == 3, "BalanceBorders: more thresh given than there are planes.") :
    \ Defined(thresh) ? thresh : 128.0
    
    blur_a = Defined(blur) && IsArray(blur) ?
        \ ArraySize(blur) == 1 ? [blur[0], blur[0], blur[0]] :
        \ ArraySize(blur) == 2 ? [blur[0], blur[1], blur[1]] :
        \ ArraySize(blur) == 3 ? [blur[0], blur[1], blur[2]] :
        \ Assert(ArraySize(blur) == 3, "BalanceBorders: more blur given than there are planes.") :
    \ Defined(blur) ? blur : 999
    
    source_planes = [y, u, v]
    clip_444 = Is444(c)
    chrh = Is420(c) ? 1 : 0
    chrw = clip_444 ? 0 : 1
    planecount = min(NumComponents(c), 3) - 1
    
    for (i = 0, planecount)
    {
        if (i == 0) { ExtractY(c) }
        else if (i == 1) { ExtractU(c) }
        else { ExtractV(c) }
    
        if (source_planes[i])
        {
            ctop_ = IsArray(ctop_a) ? ctop_a[i] : ctop_a
            cbottom_ = IsArray(cbottom_a) ? cbottom_a[i] : cbottom_a
            cleft_ = IsArray(cleft_a) ? cleft_a[i] : cleft_a
            cright_ = IsArray(cright_a) ? cright_a[i] : cright_a
            thresh_ = IsArray(thresh_a) ? thresh_a[i] : thresh_a
            blur_ = IsArray(blur_a) ? blur_a[i] : blur_a
            
            Assert(blur_ > 0 && blur_ <= 999, "BalanceBorders: Blur parameter must be between 0..999.")
            Assert(thresh_ > 0.0 && thresh_ <= 128.0, "BalanceBorders: Thresh parameter must be between 0.0..128.0.")
                
            if (i == 0)
            {
                Assert(cleft_ * 4 < Width() && cright_ * 4 < Width(), "BalanceBorders: cLeft*4, cRight*4 has to be < width.")
                Assert(ctop_ * 4 < Height() && cbottom_ * 4 < Height(), "BalanceBorders: cTop*4, cBottom*4 has to be < height.")                
                
                ctop_crop = ctop_ * 2
                cleft_crop = cleft_ * 2
                cbottom_crop = cbottom_ * 2
                cright_crop = cright_ * 2
                
                if (ctop_ > 0) { StackVertical(Crop(0, 0, 0, ctop_crop).BalanceTopBorder(ctop_, thresh_, blur_, i, clip_444), Crop(0, ctop_crop, 0, 0)).TurnRight() }
                else { TurnRight() }            
                
                if (cleft_ > 0) { StackVertical(Crop(0, 0, 0, cleft_crop).BalanceTopBorder(cleft_, thresh_, blur_, i, clip_444), Crop(0, cleft_crop, 0, 0)).TurnRight() }
                else { TurnRight() }
                
                if (cbottom_ > 0) { StackVertical(Crop(0, 0, 0, cbottom_crop).BalanceTopBorder(cbottom_ , thresh_, blur_, i, clip_444), Crop(0, cbottom_crop, 0, 0)).TurnRight() }
                else { TurnRight() }
                
                if (cright_ > 0) { StackVertical(Crop(0, 0, 0, cright_crop).BalanceTopBorder(cright_, thresh_, blur_, i, clip_444), Crop(0, cright_crop, 0, 0)).TurnRight() }
                else { TurnRight() }
                
                yplane = last
            }
            else
            {
                Assert(BitRShiftL(cleft_ * 4, chrw) < Width() && BitRShiftL(cright_ * 4, chrw) < Width(), "BalanceBorders: cLeft*4, cRight*4 has to be < width.")
                Assert(BitRShiftL(ctop_ * 4, chrh) < Height() && BitRShiftL(cbottom_ * 4, chrh) < Height(), "BalanceBorders: cTop*4, cBottom*4 has to be < height.")
                
                ctop_crop = BitRShiftL(ctop_ * 2, chrh)
                cleft_crop = BitRShiftL(cleft_ * 2, chrw)
                cbottom_crop = BitRShiftL(cbottom_ * 2, chrh)
                cright_crop = BitRShiftL(cright_ * 2, chrw)
                
                if (ctop_ > 1) { StackVertical(Crop(0, 0, 0, ctop_crop).BalanceTopBorder(BitRShiftL(ctop_, chrh), thresh_, blur_, i, clip_444), Crop(0, ctop_crop, 0, 0)).TurnRight() }
                else { TurnRight() }
                
                if (cleft_ > 1) { StackVertical(Crop(0, 0, 0, cleft_crop).BalanceTopBorder(BitRShiftL(cleft_, chrw), thresh_, blur_, i, clip_444), Crop(0, cleft_crop, 0, 0)).TurnRight() }
                else { TurnRight() }
                
                if (cbottom_ > 1) { StackVertical(Crop(0, 0, 0, cbottom_crop).BalanceTopBorder(BitRShiftL(cbottom_, chrh), thresh_, blur_, i, clip_444), Crop(0, cbottom_crop, 0, 0)).TurnRight() }
                else { TurnRight() }
                
                if (cright_ > 1) { StackVertical(Crop(0, 0, 0, cright_crop).BalanceTopBorder(BitRShiftL(cright_, chrw), thresh_, blur_, i, clip_444), Crop(0, cright_crop, 0, 0)).TurnRight() }
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
    
    return CombinePlanes(yplane, uplane, vplane, planes="YUV", sample_clip=c)
}

function BalanceTopBorder(clip c, int cTop, float "thresh", int "blur", int "plane", bool "clip_444")
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
        
        StackVertical(last, c2.Crop(0, cTop * 2, cWidth * 2, (cHeight - cTop) * 2)).z_PointResize(cWidth, cHeight)
    }
    else
    {
        if (BitsPerComponent(c) == 32) { Expr(original, originalBlur, referenceBlur, "z y - "+ String(thresh) +" 128 - scaleb 0.5 + > x "+ String(thresh) +" 128 - scaleb 0.5 + + z y - "+ String(-thresh) +" 128 - scaleb 0.5 + < x "+ String(thresh) +" 128 - scaleb 0.5 + - z y - x + ? ? -0.43921568627 0.43921568627 clip") }
        else { Expr(original, originalBlur, referenceBlur, "z y - "+ String(thresh) +" scaleb > x "+ String(thresh) +" scaleb + z y - "+ String(-thresh) +" scaleb < x "+ String(thresh) +" scaleb - z y - x + ? ? 16 scaleb 240 scaleb clip") }
        
        StackVertical(last, c2.Crop(0, cTop * 2, cWidth * 2, (cHeight - cTop) * 2)).z_PointResize(cWidth, cHeight, !clip_444 ? -0.5 * ((cWidth * 2 / cWidth) - 1) : 0)
    }
}
