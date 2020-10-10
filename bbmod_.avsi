## Changelog:
# - code clean up; fixed cBottom assert for chroma; arrays - if a single value is specified, it will be used for all planes, if two values are given then the second value will be used for the third plane as well.
# - fixed error when cTop/cBottom/cLeft/cRight=1.
# - merged all calculations in one expression that leads to ~20-35% less memory usage, ~20% speedup with 16-bit clips, ~10% speedup with 10-bit clips; fixed output with clips in float bit depth.
# - added array support for parameters.
# - removed an unnecessary resize call.
# - replaced ResampleMT with z_ resizers.
# - added usage info, intermediate function name changed; replaced lutxyz for 8/10-bit -> 8-bit 2x less memory usage, 10-bit ~25% speedup; 16-bit ~10% speedup; removed full_range parameter.
# - added Y/YUV422/YUV444 processing.
# - additional options bool y (true), bool u (true), bool v (true) for processing different planes; renamed to balanceborders_.avsi.
# - allowed 32-bit input; added bool full_range parameter (default=false) - it works only for high bit depth; it determines how the scaling to the input bit depth->8-bit->input bit depth is done ( http://avisynth.nl/index.php/MaskTools2#Expression_syntax_supporting_bit_depth_independent_expressions ).
# - changed the thresh type int -> float, thresh is always in the range [0,128] (before it was in the range [0,bit depth half range]).
# - all options are optional (bbmod(2), bbmod(cleft=1) and so on). Added restriction - clip width / height should be > cLeft*4, cRgith*4 / cTop*4, cBottom*4.
# - processing only part of the frame.


# bbmod is balanceborders mod that using division instead subtraction for the filtering.
# See BalanceBorders_.avsi for the usage and parameter description


## Example with arrays (AviSynth 3.6.x required)
# bbmod([60,20], cleft=[40,20], y=true, u=true, v= false) # same as bbmod(60, cleft=40, blur=999, y=true, u=false, v=false).bbmod(20, cleft=20, y=false, u=true, v=false)
# bbmod([60], cleft=[40]) # same as bbmod(60, cleft=40)/bbmod(60, cleft=[40])/bbmod([60], cleft=40)
# bbmod([60,60], cleft=[40,40], thresh=[12,12], blur=[100,100], y=false, u=true, v= true) # same as bbmod(60, cleft=40, thresh=12, blur=100, y=false)/bbmod([x,60,60], cleft=[x,40,40], thresh=[x,12,12], blur=[x,100,100], y=false, u=true, v= true)
# bbmod([60,20,40], cleft=[40,20,10], thresh=[12,4,5], blur=[100,999,20]) # same as bbmod(60, cleft=40, thresh=12, blur=100, u=false, v=false).bbmod(20, cleft=20, thresh=4, y=false, v=false).bbmod(40, cleft=10, thresh=5, blur=20, y=false, u=false)


Function bbmod(clip c, val "cTop", val "cBottom", val "cLeft", val "cRight", val "thresh", val "blur", bool "y", bool "u", bool "v")
{
    Assert(isYUV(c), "bbmod: This is not an YUV/Y clip.")
     
    num_comp_1 = NumComponents(c) == 1
    y = Default(y, true)
    u = Default(u, num_comp_1 ? false : true)
    v = Default(v, num_comp_1 ? false : true)
    
        ctop_a = Defined(cTop) && IsArray(cTop) ?
        \ ArraySize(cTop) == 1 ? [cTop[0], cTop[0], cTop[0]] :
        \ ArraySize(cTop) == 2 ? [cTop[0], cTop[1], cTop[1]] :
        \ ArraySize(cTop) == 3 ? [cTop[0], cTop[1], cTop[2]] :
        \ Assert(ArraySize(cTop) == 3, "bbmod: more cTop given than there are planes.") :
    \ Defined(cTop) ? cTop : 0    
    
    cbottom_a = Defined(cBottom) && IsArray(cBottom) ?
        \ ArraySize(cBottom) == 1 ? [cBottom[0], cBottom[0], cBottom[0]] :
        \ ArraySize(cBottom) == 2 ? [cBottom[0], cBottom[1], cBottom[1]] :
        \ ArraySize(cBottom) == 3 ? [cBottom[0], cBottom[1], cBottom[2]] :
        \ Assert(ArraySize(cBottom) == 3, "bbmod: more cBottom given than there are planes.") :
    \ Defined(cBottom) ? cBottom : 0
    
    cleft_a = Defined(cLeft) && IsArray(cLeft) ?
        \ ArraySize(cLeft) == 1 ? [cLeft[0], cLeft[0], cLeft[0]] :
        \ ArraySize(cLeft) == 2 ? [cLeft[0], cLeft[1], cLeft[1]] :
        \ ArraySize(cLeft) == 3 ? [cLeft[0], cLeft[1], cLeft[2]] :
        \ Assert(ArraySize(cLeft) == 3, "bbmod: more cLeft given than there are planes.") :
    \ Defined(cLeft) ? cLeft : 0
    
    cright_a = Defined(cRight) && IsArray(cRight) ?
        \ ArraySize(cRight) == 1 ? [cRight[0], cRight[0], cRight[0]] :
        \ ArraySize(cRight) == 2 ? [cRight[0], cRight[1], cRight[1]] :
        \ ArraySize(cRight) == 3 ? [cRight[0], cRight[1], cRight[2]] :
        \ Assert(ArraySize(cRight) == 3, "bbmod: more cRight given than there are planes.") :
    \ Defined(cRight) ? cRight : 0
    
    thresh_a = Defined(thresh) && IsArray(thresh) ?
        \ ArraySize(thresh) == 1 ? [thresh[0], thresh[0], thresh[0]] :
        \ ArraySize(thresh) == 2 ? [thresh[0], thresh[1], thresh[1]] :
        \ ArraySize(thresh) == 3 ? [thresh[0], thresh[1], thresh[2]] :
        \ Assert(ArraySize(thresh) == 3, "bbmod: more thresh given than there are planes.") :
    \ Defined(thresh) ? thresh : 128.0
    
    blur_a = Defined(blur) && IsArray(blur) ?
        \ ArraySize(blur) == 1 ? [blur[0], blur[0], blur[0]] :
        \ ArraySize(blur) == 2 ? [blur[0], blur[1], blur[1]] :
        \ ArraySize(blur) == 3 ? [blur[0], blur[1], blur[2]] :
        \ Assert(ArraySize(blur) == 3, "bbmod: more blur given than there are planes.") :
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
            
            Assert(blur_ > 0 && blur_ <= 999, "bbmod: Blur parameter must be between 0..999.")
            Assert(thresh_ > 0.0 && thresh_ <= 128.0, "bbmod: Thresh parameter must be between 0.0..128.0.")

            if (i == 0)
            {
                Assert(cleft_ * 4 < Width() && cright_ * 4 < Width(), "bbmod: cLeft*4, cRight*4 has to be < width.")
                Assert(ctop_ * 4 < Height() && cbottom_ * 4 < Height(), "bbmod: cTop*4, cBottom*4 has to be < height.")
                
                ctop_crop = ctop_ * 2
                cleft_crop = cleft_ * 2
                cbottom_crop = cbottom_ * 2
                cright_crop = cright_ * 2
                
                if (ctop_ > 0) { StackVertical(Crop(0, 0, 0, ctop_crop).btb(ctop_, thresh_, blur_, i, clip_444), Crop(0, ctop_crop, 0, 0)).TurnRight() }
                else { TurnRight() }
                
                if (cleft_ > 0) { StackVertical(Crop(0, 0, 0, cleft_crop).btb(cleft_, thresh_, blur_, i, clip_444), Crop(0, cleft_crop, 0, 0)).TurnRight() }
                else { last.TurnRight() }
                
                if (cbottom_ > 0) { StackVertical(Crop(0, 0, 0, cbottom_crop).btb(cbottom_, thresh_, blur_, i, clip_444), Crop(0, cbottom_crop, 0, 0)).TurnRight() }
                else { last.TurnRight() }
                
                if (cright_ > 0) { StackVertical(Crop(0, 0, 0, cright_crop).btb(cright_, thresh_, blur_, i, clip_444), Crop(0, cright_crop, 0, 0)).TurnRight() }
                else { TurnRight() }

                yplane = last
            }
            else
            {
                Assert(BitRShiftL(cleft_ * 4, chrw) < Width() && BitRShiftL(cright_ * 4, chrw) < Width(), "bbmod: cLeft*4, cRight*4 has to be < width.")
                Assert(BitRShiftL(ctop_ * 4, chrh) < Height() && BitRShiftL(cbottom_ * 4, chrh) < Height(), "bbmod: cTop*4, cBottom*4 has to be < height.")
                
                ctop_crop = BitRShiftL(ctop_ * 2, chrh)
                cleft_crop = BitRShiftL(cleft_ * 2, chrw)
                cbottom_crop = BitRShiftL(cbottom_ * 2, chrh)
                cright_crop = BitRShiftL(cright_ * 2, chrw)
                
                if (ctop_ > 1) { StackVertical(Crop(0, 0, 0, ctop_crop).btb(BitRShiftL(ctop_, chrh), thresh_, blur_, i, clip_444), Crop(0, ctop_crop, 0, 0)).TurnRight() }
                else { TurnRight() }
                
                if (cleft_ > 1) { StackVertical(Crop(0, 0, 0, cleft_crop).btb(BitRShiftL(cleft_, chrw), thresh_, blur_, i, clip_444), Crop(0, cleft_crop, 0, 0)).TurnRight() }
                else { TurnRight() }
                
                if (cbottom_ > 1) { StackVertical(Crop(0, 0, 0, cbottom_crop).btb(BitRShiftL(cbottom_, chrh), thresh_, blur_, i, clip_444), Crop(0, cbottom_crop, 0, 0)).TurnRight() }
                else { TurnRight() }
                
                if (cright_ > 1) { StackVertical(Crop(0, 0, 0, cright_crop).btb(BitRShiftL(cright_, chrw), thresh_, blur_, i, clip_444), Crop(0, cright_crop, 0, 0)).TurnRight() }
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

function btb(clip c, int cTop, float "thresh", int "blur", int "plane", bool "clip_444")
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
        
        StackVertical(last, c2.Crop(0, cTop * 2, cWidth * 2, (cHeight - cTop) * 2)).z_PointResize(cWidth, cHeight)
    }
    else
    {
        if (BitsPerComponent(c) == 32) { Expr(original, originalBlur, referenceBlur, "z y - z 0.5 + y 0.5 + / 8 min 0.4 max x * + x - "+ String(thresh) +" 128 - scaleb 0.5 + > x "+ String(thresh) +" 128 - scaleb 0.5 + + z y - z 0.5 + y 0.5 + / 8 min 0.4 max x * + x - "+ String(-thresh) +" 128 - scaleb 0.5 + < x "+ String(thresh) +" 128 - scaleb 0.5 + - z y - z 0.5 + y 0.5 + / 8 min 0.4 max x * + ? ? -0.43921568627 0.43921568627 clip") }
        else { Expr(original, originalBlur, referenceBlur, "z y - z y / 8 min 0.4 max x 128 scaleb - * 128 scaleb + + x - "+ String(thresh) +" scaleb > x "+ String(thresh) +" scaleb + z y - z y / 8 min 0.4 max x 128 scaleb - * 128 scaleb + + x - "+ String(-thresh) +" scaleb < x "+ String(thresh) +" scaleb - z y - z y / 8 min 0.4 max x 128 scaleb - * 128 scaleb + + ? ? 16 scaleb 240 scaleb clip") }
    
        StackVertical(last, c2.Crop(0, cTop * 2, cWidth * 2, (cHeight - cTop) * 2)).z_PointResize(cWidth, cHeight, !clip_444 ? -0.5 * ((cWidth * 2 / cWidth) - 1) : 0)
    }
}
