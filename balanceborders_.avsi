## Changelog:
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
# BalanceBorders([60,60,60], cleft=[40,40,40]) # same as BalanceBorders(60, cleft=40)
# BalanceBorders([0,60,60], cleft=[0,40,40], thresh=[0,12,12], blur=[0,100,100], y=false, u=true, v= true) # same as BalanceBorders(60, cleft=40, thresh=12, blur=100, y=false)
# BalanceBorders([60,20,40], cleft=[40,20,10], thresh=[12,4,5], blur=[100,999,20]) # same as BalanceBorders(60, cleft=40, thresh=12, blur=10, u=false, v=false).BalanceBorders(20, cleft=20, thresh=4, y=false, v=false).BalanceBorders(40, cleft=10, thresh=5, y=false, u=false)


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
    
    planecount = min(NumComponents(c), 3) - 1
    clip_444 = Is444(c)
       
    if (IsArray(cTop) || IsArray(cBottom) || IsArray(cLeft) || IsArray(cRight) || IsArray(thresh) || IsArray(blur))
    {
        source_planes = [y, u, v]

        for (i = 0, planecount)
        {
            i == 0 ? ExtractY(c) : i == 1 ? ExtractU(c) : ExtractV(c)

            if (source_planes[i])
            {
                ctop_ = Defined(cTop) ? IsArray(cTop) ? cTop[i] : cTop : 0
                cbottom_ = Defined(cBottom) ? IsArray(cBottom) ? cBottom[i] : cBottom : 0
                cleft_ = Defined(cLeft) ? IsArray(cLeft) ? cLeft[i] : cLeft : 0
                cright_ = Defined(cRight) ? IsArray(cRight) ? cRight[i] : cRight : 0
                thresh_ = Defined(thresh) ? IsArray(thresh) ? thresh[i] : thresh : i == 0 && BitsPerComponent(c) == 32 ? 127.5 : 128.0
                blur_ = Defined(blur) ? IsArray(blur) ? blur[i] : blur : 999

                chrh = Is420(c) ? 1 : 0
                chrw = clip_444 ? 0 : 1
            
                Assert((i == 0 ? cleft_ * 4 : BitRShiftL(cleft_ * 4, chrw)) < Width() && (i == 0 ? cright_ * 4 : BitRShiftL(cright_ * 4, chrw)) < Width(), "BalanceBorders: cLeft*4, cRight*4 has to be < width.")
                Assert((i == 0 ? ctop_ * 4 : BitRShiftL(ctop_ * 4, chrh)) < Height() && (i == 0 ? cbottom_ * 4 : BitRShiftL(cbottom_, chrh)) < Height(), "BalanceBorders: cTop*4, cBottom*4 has to be < height.")
                Assert(blur_ > 0, "BalanceBorders: Blur parameter must be > 0")
                Assert(thresh_ > 0 && thresh_ <= 128, "BalanceBorders: Thresh parameter must be > 0 and <= 128")
                
                param_scale = i == 0 ? 0 : 1
                ctop_crop = i == 0 ? ctop_ * 2 : BitRShiftL(ctop_ * 2, chrh)
                cleft_crop = i == 0 ? cleft_ * 2 : BitRShiftL(cleft_ * 2, chrw)
                cbottom_crop = i == 0 ? cbottom_ * 2 : BitRShiftL(cbottom_ * 2, chrh)
                cright_crop = i == 0 ? cright_ * 2 : BitRShiftL(cright_ * 2, chrw)
                
                ctop_ > param_scale ? StackVertical(Crop(0, 0, 0, ctop_crop).BalanceTopBorder(i == 0 ? ctop_ : BitRShiftL(ctop_, chrh), thresh_, blur_, i, clip_444), Crop(0, ctop_crop, 0, 0)).TurnRight() : last.TurnRight()
                cleft_ > param_scale ? StackVertical(Crop(0, 0, 0, cleft_crop).BalanceTopBorder(i == 0 ? cleft_ : BitRShiftL(cleft_, chrw), thresh_, blur_, i, clip_444), Crop(0, cleft_crop, 0, 0)).TurnRight() : last.TurnRight()
                cbottom_ > param_scale ? StackVertical(Crop(0, 0, 0, cbottom_crop).BalanceTopBorder(i == 0 ? cbottom_ : BitRShiftL(cbottom_, chrh), thresh_, blur_, i, clip_444), Crop(0, cbottom_crop, 0, 0)).TurnRight() : last.TurnRight()
                cright_ > param_scale ? StackVertical(Crop(0, 0, 0, cright_crop).BalanceTopBorder(i == 0 ? cright_ : BitRShiftL(cright_, chrw), thresh_, blur_, i, clip_444), Crop(0, cright_crop, 0, 0)).TurnRight() : last.TurnRight()
                
                if (i == 0)
                {
                    yplane = last
                }
                else if (i == 1)
                {
                    uplane = last
                }
                else
                {
                    vplane = last
                }
            }
            else
            {
                if (i == 0)
                {
                    yplane = last
                }
                else if (i == 1)
                {
                    uplane = last
                }
                else
                {
                    vplane = last
                }
            }
        }
        
        CombinePlanes(yplane, uplane, vplane, planes="YUV", sample_clip=c)
    }
    else
    {
        cTop = Default(cTop, 0)
        cBottom = Default(cBottom, 0)
        cLeft = Default(cLeft, 0)
        cRight = Default(cRight, 0)
        thresh = Default(thresh, 128.0)
        blur = Default(blur, 999)
        
        Assert(blur > 0, "BalanceBorders: Blur parameter must be > 0")
        Assert(thresh > 0 && thresh <= 128, "BalanceBorders: Thresh parameter must be > 0 and <= 128")

        if (planecount == 0)
        {
            Assert(y && !u && !v || !y && u && !v || !y && !u && v, "BalanceBorders: the number of the source planes is different than the target planes.")
        }
                
        if (y)
        {
            planecount > 0 ? ExtractY(c) : c
            
            Assert(cLeft * 4 < Width() && cRight * 4 < Width(), "BalanceBorders: cLeft*4, cRight*4 has to be < width.")
            Assert(cTop * 4 < Height() && cBottom * 4 < Height(), "BalanceBorders: cTop*4, cBottom*4 has to be < height.")

            cTop > 0 ? StackVertical(Crop(0, 0, 0, cTop * 2).BalanceTopBorder(cTop, thresh, blur, 0, clip_444), Crop(0, cTop * 2, 0, 0)).TurnRight() : last.TurnRight()
            cLeft > 0 ? StackVertical(Crop(0, 0, 0, cLeft * 2).BalanceTopBorder(cLeft, thresh, blur, 0, clip_444), Crop(0, cLeft * 2, 0, 0)).TurnRight() : last.TurnRight()
            cBottom > 0 ? StackVertical(Crop(0, 0, 0, cBottom * 2).BalanceTopBorder(cBottom, thresh, blur, 0, clip_444), Crop(0, cBottom * 2, 0, 0)).TurnRight() : last.TurnRight()
            cRight > 0 ? StackVertical(Crop(0, 0, 0, cRight * 2).BalanceTopBorder(cRight, thresh, blur, 0, clip_444), Crop(0, cRight * 2, 0, 0)).TurnRight() : last.TurnRight()
            
            if (planecount == 0)
            {
                return last
            }
            else
            {
                yplane_ = last
            }
        }
        else if (!y)
        {
            yplane_ = ExtractY(c)
        }
        if (u)
        {
            planecount > 0 ? ExtractU(c) : c
            
            chrh = Is420(c) ? 1 : 0
            chrw = clip_444 ? 0 : 1
            
            Assert(BitRShiftL(cLeft * 4, chrw) < Width() && BitRShiftL(cRight * 4, chrw) < Width(), "BalanceBorders: cLeft*4, cRight*4 has to be < width.")
            Assert(BitRShiftL(cTop * 4, chrh) < Height() && BitRShiftL(cBottom, chrh) < Height(), "BalanceBorders: cTop*4, cBottom*4 has to be < height.")
            
            cTop > 1 ? StackVertical(Crop(0, 0, 0, BitRShiftL(cTop * 2, chrh)).BalanceTopBorder(BitRShiftL(cTop, chrh), thresh, blur, 1, clip_444), Crop(0, BitRShiftL(cTop * 2, chrh), 0, 0)).TurnRight() : last.TurnRight()
            cLeft > 1 ? StackVertical(Crop(0, 0, 0, BitRShiftL(cLeft * 2, chrw)).BalanceTopBorder(BitRShiftL(cLeft, chrw), thresh, blur, 1, clip_444), Crop(0, BitRShiftL(cLeft * 2, chrw), 0, 0)).TurnRight() : last.TurnRight()
            cBottom > 1 ? StackVertical(Crop(0, 0, 0, BitRShiftL(cBottom * 2, chrh)).BalanceTopBorder(BitRShiftL(cBottom, chrh), thresh, blur, 1, clip_444), Crop(0, BitRShiftL(cBottom * 2, chrh), 0, 0)).TurnRight() : last.TurnRight()
            cRight > 1 ? StackVertical(Crop(0, 0, 0, BitRShiftL(cRight * 2, chrw)).BalanceTopBorder(BitRShiftL(cRight, chrw), thresh, blur, 1, clip_444), Crop(0, BitRShiftL(cRight * 2, chrw), 0, 0)).TurnRight() : last.TurnRight()
            
            if (planecount == 0)
            {
                return last
            }
            else
            {
                uplane_ = last
            }
        }
        else if (!u)
        {
            uplane_ = ExtractU(c)
        }
        if (v)
        {
            planecount > 0 ? ExtractV(c) : c
            
            chrh = Is420(c) ? 1 : 0
            chrw = clip_444 ? 0 : 1
            
            Assert(BitRShiftL(cLeft * 4, chrw) < Width() && BitRShiftL(cRight * 4, chrw) < Width(), "BalanceBorders: cLeft*4, cRight*4 has to be < width.")
            Assert(BitRShiftL(cTop * 4, chrh) < Height() && BitRShiftL(cBottom, chrh) < Height(), "BalanceBorders: cTop*4, cBottom*4 has to be < height.")
            
            cTop > 1 ? StackVertical(Crop(0, 0, 0, BitRShiftL(cTop * 2, chrh)).BalanceTopBorder(BitRShiftL(cTop, chrh), thresh, blur, 1, clip_444), Crop(0, BitRShiftL(cTop * 2, chrh), 0, 0)).TurnRight() : last.TurnRight()
            cLeft > 1 ? StackVertical(Crop(0, 0, 0, BitRShiftL(cLeft * 2, chrw)).BalanceTopBorder(BitRShiftL(cLeft, chrw), thresh, blur, 1, clip_444), Crop(0, BitRShiftL(cLeft * 2, chrw), 0, 0)).TurnRight() : last.TurnRight()
            cBottom > 1 ? StackVertical(Crop(0, 0, 0, BitRShiftL(cBottom * 2, chrh)).BalanceTopBorder(BitRShiftL(cBottom, chrh), thresh, blur, 1, clip_444), Crop(0, BitRShiftL(cBottom * 2, chrh), 0, 0)).TurnRight() : last.TurnRight()
            cRight > 1 ? StackVertical(Crop(0, 0, 0, BitRShiftL(cRight * 2, chrw)).BalanceTopBorder(BitRShiftL(cRight, chrw), thresh, blur, 1, clip_444), Crop(0, BitRShiftL(cRight * 2, chrw), 0, 0)).TurnRight() : last.TurnRight()
            
            if (planecount == 0)
            {
                return last
            }
            else
            {
                vplane_ = last
            }
        }
        else if (!v)
        {
            vplane_ = ExtractV(c)
        }
        
        CombinePlanes(yplane_, uplane_, vplane_, planes="YUV", sample_clip=c)
    }
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
        if (BitsPerComponent(c) == 32)
        {
            Expr(original, originalBlur, referenceBlur, "z y - "+ String(thresh) +" 128 - scaleb 0.5 + > x "+ String(thresh) +" 128 - scaleb 0.5 + + z y - "+ String(-thresh) +" 128 - scaleb 0.5 + < x "+ String(thresh) +" 128 - scaleb 0.5 + - z y - x + ? ? -0.43921568627 0.43921568627 clip")
        }
        else
        {
            Expr(original, originalBlur, referenceBlur, "z y - "+ String(thresh) +" scaleb > x "+ String(thresh) +" scaleb + z y - "+ String(-thresh) +" scaleb < x "+ String(thresh) +" scaleb - z y - x + ? ? 16 scaleb 240 scaleb clip")
        }
        
        StackVertical(last, c2.Crop(0, cTop * 2, cWidth * 2, (cHeight - cTop) * 2)).z_PointResize(cWidth, cHeight, !clip_444 ? -0.5 * ((cWidth * 2 / cWidth) - 1) : 0)
    }
}
