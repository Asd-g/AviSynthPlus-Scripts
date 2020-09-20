## Changelog:
# - allowed adj_val, prot_val, upper, prot_val2 to be non-array when row/column is array (FixCBr([1,2], 8))
# - cosmetic changes
# - added array support for parameters
# - removed full_range parameter, added float prot_val2 parameter for protecting pixels above and below threshold simultaneously
# - processing also Y clips
# - added alias FixRowBrightnessProtect2 / FixColumnBrightnessProtect2 for backward compatibility
# - added an optional parameter bool "full_range" - it works only for high bit depth; it determines how the scaling to the input bit depth->8-bit->input bit depth is done ( http://avisynth.nl/index.php/MaskTools2#Expression_syntax_supporting_bit_depth_independent_expressions )
# - added "upper" option (default true), when true pixels with higher luma than prot_val are protected, false - pixels with lower luma than prot_val are protected; now prot_val (float) = luma threshold; prot_val is in range [0,255] for all bit depth


## Usage of FixRBr/FixCBr(0,100,20,true, prot_val2): 
# - the first number is the row/column
# - the second number is "adj_val" in the range [-100,100], positive values make the line brighter, negative values make the line darker, 0 does nothing
# - the third number is "prot_val" and it's optional, it determines which pixels wouldn't be affected by the filter, it has range [0,255] for all bit depths
# - the fourth option is "upper" and it's optional, when true pixels with higher luma than prot_val are protected, when false - pixels with lower luma than prot_val are protected. If it's not specified, when prot_val is used, default is true.
# - the last parameter is "prot_val2" and it's optional (default doesn't have effect), it determines which pixels below threshold wouldn't be affected by the filter
##
# By default prot_val2 doesn't have effect and there is only one threshold ("upper"->above/below) determinating if the pixel will be filtered. If prot_val2 is specified, "upper" doesn't have effect and prot_val + prot_val2 behaves as limits of bandpass filter - prot_val determines the top threshold and prot_val2 determines the bottom threshold. Any pixel value between thresholds is filtered.


## Example how prot_val is working (only one threshold).
# If pixel has 126 luma and you use FixCBr(20, 50, 126) - pixel remains 126.
# FixCBr(20, 50, 127) - pixel is 137
# FixCBr(20, 50, 128) - pixel is 148
# FixCBr(20, 50, 129) - pixel is 159
# ...
# And the opposite - FixCBr(20, 50, 126, false) - pixel is 126
# FixCBr(20, 50, 125, false) - pixel is 137
# FixCBr(20, 50, 124, false) - pixel is 148
# FixCBr(20, 50, 123, false) - pixel is 159
# ...
# FixCBr(20, 50, 117, false) - pixel is 225
# FixCBr(20, 50, 116, false) - pixel is 235 (no protected).
# There is blend zone of max 10 steps between full protected (untouched) and not protected at all.


## Example with two thresholds simultaneously.
# FixCBr(200, -15, 220, prot_val2=60) # The pixels above 220 luma and below 60 luma are protected (not filtered). The thresholds are not hard and the blend mode used with only one threshold is valid for both thresholds here.


## Example with arrays (AviSynth 3.6.x required)
# FixRBr([100], [100]) # same as FixRBr(100, 100)/FixRBr([100], 100)
# FixRBr([100, 200], [100, -40]) # same as FixRBr(100, 100).FixRBr(200, -40)
# FixRBr([100, 200], [100, -40], [120, 140]) # same as FixRBr(100, 100, 120).FixRBr(200, -40, 140)
# FixRBr([100, 200], [100, -40], [120, 140], [false,true]) # same as FixRBr(100, 100, 120, false).FixRBr(200, -40, 140, true)
# FixRBr([100, 200], [100, -40], [120, 140], [false,true], [20, 100]) # same as FixRBr(100, 100, 120, false, 20).FixRBr(200, -40, 140, true, 100)
# FixRBr([100, 200, 20, 1], [100, -40, 22, -2]) # same as FixRBr(100, 100).FixRBr(200, -40).FixRBr(20, 22).FixRBr(1, -2)


Function FixRBr(clip c, val row, val adj_val, val "prot_val", val "upper", val "prot_val2")
{
    if (IsArray(row))
    {
        n = row.ArraySize() - 1
        c        
        
        for (i = 0, n)
        {
            adj_val_ = IsArray(adj_val) ? adj_val[i] : adj_val
            prot_val_ = Defined(prot_val) ? IsArray(prot_val) ? prot_val[i] : prot_val : Undefined()
            upper_ = Defined(upper) ? IsArray(upper) ? upper[i] : upper : Undefined()
            prot_val2_ = Defined(prot_val2) ? IsArray(prot_val2) ? prot_val2[i] : prot_val2 : Undefined()

            FixRBr_(row[i], adj_val_, prot_val_, upper_, prot_val2_)
        }
    }
    else
    {
        FixRBr_(c, row, adj_val, prot_val, upper, prot_val2)
    }
}

Function FixCBr(clip c, val column, val adj_val, val "prot_val", val "upper", val "prot_val2")
{
    if (IsArray(column))
    {
        n = column.ArraySize() - 1
        c        
        
        for (i = 0, n)
        {
            adj_val_ = IsArray(adj_val) ? adj_val[i] : adj_val
            prot_val_ = Defined(prot_val) ? IsArray(prot_val) ? prot_val[i] : prot_val : Undefined()
            upper_ = Defined(upper) ? IsArray(upper) ? upper[i] : upper : Undefined()
            prot_val2_ = Defined(prot_val2) ? IsArray(prot_val2) ? prot_val2[i] : prot_val2 : Undefined()

            FixCBr_(column[i], adj_val_, prot_val_, upper_, prot_val2_)
        }
    }
    else
    {
        FixCBr_(c, column, adj_val, prot_val, upper, prot_val2)
    }
}

Function FixRBr_(clip c, int row, float adj_val, float "prot_val", bool "upper", float "prot_val2")
{
    Assert(IsYUV(c), "FixRBr: Only YUV/Y clips allowed.")
    Assert(adj_val <= 100, "FixRBr: adj_val max value 100.")
    Assert(adj_val >= -100, "FixRBr: adj_val min value -100.")
    
    if (adj_val == 0)
    {
        return c
    }
    
    if (Defined(prot_val))
    {
        Assert(prot_val <= 255, "FixRBr: prot_val max value 255.")
        Assert(prot_val >= 0, "FixRBr: prot_val min value 0.")
    }    
    if (Defined(prot_val2))
    {
        Assert(prot_val2 <= 255, "FixRBr: prot_val2 max value 255.")
        Assert(prot_val2 >= 0, "FixRBr: prot_val2 min value 0.")      
    }    
    if (Defined(prot_val) && Defined(prot_val2))
    {
        Assert((prot_val - prot_val2) >= 19, "FixRBr: The difference between prot_val and prot_val2 must be >= 19.")
    }
        
    if (Defined(prot_val) && !Defined(upper))
    {
        upper = true
    }
    
    num_comp = NumComponents(c) == 3
    Crop(num_comp ? ExtractY(c) : c, 0, row, 0, 1)
    
    if (!Defined(prot_val) && adj_val > 0)
    {
        Expr("x 16 scaleb - 0 <= 16 scaleb 235 scaleb "+ string(adj_val * 2.19) +" scaleb - 16 scaleb - 0 <= 0.01 235 scaleb "+ string(adj_val * 2.19) +" scaleb - 16 scaleb - ? / 219 scaleb * x 16 scaleb - 235 scaleb "+ string(adj_val * 2.19) +" scaleb - 16 scaleb - 0 <= 0.01 235 scaleb "+ string(adj_val * 2.19) +" scaleb - 16 scaleb - ? / 219 scaleb * 16 scaleb + ? 16 scaleb 235 scaleb clip")
    }
    else if (!Defined(prot_val) && adj_val < 0)
    {
        Expr("x 16 scaleb - 0 <= 16 scaleb 219 scaleb / 235 scaleb "+ string(adj_val * 2.19) +" scaleb + 16 scaleb - * x 16 scaleb - 219 scaleb / 235 scaleb "+ string(adj_val * 2.19) +" scaleb + 16 scaleb - * 16 scaleb + ? 16 scaleb 235 scaleb clip")
    }
    else if (!Defined(prot_val2) && adj_val > 0 && upper == true)
    {
        Expr("x 16 scaleb - 0 <= 16 scaleb 235 scaleb "+ string(adj_val * 2.19) +" scaleb - 16 scaleb - 0 <= 0.01 235 scaleb "+ string(adj_val * 2.19) +" scaleb - 16 scaleb - ? / 219 scaleb * x 16 scaleb - 235 scaleb "+ string(adj_val * 2.19) +" scaleb - 16 scaleb - 0 <= 0.01 235 scaleb "+ string(adj_val * 2.19) +" scaleb - 16 scaleb - ? / 219 scaleb * 16 scaleb + ? x "+ string(prot_val) +" scaleb - -10 scaleb / 0 max 1 min * x x "+ string(prot_val) +" scaleb 10 scaleb - - 10 scaleb / 0 max 1 min * + 16 scaleb 235 scaleb clip")
    }
    else if (!Defined(prot_val2) && adj_val > 0 && upper == false)
    {
        Expr("x 16 scaleb - 0 <= 16 scaleb 235 scaleb "+ string(adj_val * 2.19) +" scaleb - 16 scaleb - 0 <= 0.01 235 scaleb "+ string(adj_val * 2.19) +" scaleb - 16 scaleb - ? / 219 scaleb * x 16 scaleb - 235 scaleb "+ string(adj_val * 2.19) +" scaleb - 16 scaleb - 0 <= 0.01 235 scaleb "+ string(adj_val * 2.19) +" scaleb - 16 scaleb - ? / 219 scaleb * 16 scaleb + ? "+ string(prot_val) +" scaleb x - -10 scaleb / 0 max 1 min * x "+ string(prot_val) +" scaleb 10 scaleb + x - 10 scaleb / 0 max 1 min * + 16 scaleb 235 scaleb clip")
    }
    else if (!Defined(prot_val2) && adj_val < 0 && upper == true)
    {
        Expr("x 16 scaleb - 0 <= 16 scaleb 219 scaleb / 235 scaleb "+ string(adj_val * 2.19) +" scaleb + 16 scaleb - * x 16 scaleb - 219 scaleb / 235 scaleb "+ string(adj_val * 2.19) +" scaleb + 16 scaleb - * 16 scaleb + ? x "+ string(prot_val) +" scaleb - -10 scaleb / 0 max 1 min * x x "+ string(prot_val) +" scaleb 10 scaleb - - 10 scaleb / 0 max 1 min * + 16 scaleb 235 scaleb clip")
    }
    else if (!Defined(prot_val2) && adj_val < 0 && upper == false)
    {
        Expr("x 16 scaleb - 0 <= 16 scaleb 219 scaleb / 235 scaleb "+ string(adj_val * 2.19) +" scaleb + 16 scaleb - * x 16 scaleb - 219 scaleb / 235 scaleb "+ string(adj_val * 2.19) +" scaleb + 16 scaleb - * 16 scaleb + ? "+ string(prot_val) +" scaleb x - -10 scaleb / 0 max 1 min * x "+ string(prot_val) +" scaleb 10 scaleb + x - 10 scaleb / 0 max 1 min * + 16 scaleb 235 scaleb clip")
    }
    else if (Defined(prot_val2) && adj_val > 0)
    {
        Expr("x 16 scaleb - 0 <= 16 scaleb 235 scaleb "+ string(adj_val * 2.19) +" scaleb - 16 scaleb - 0 <= 0.01 235 scaleb "+ string(adj_val * 2.19) +" scaleb - 16 scaleb - ? / 219 scaleb * x 16 scaleb - 235 scaleb "+ string(adj_val * 2.19) +" scaleb - 16 scaleb - 0 <= 0.01 235 scaleb "+ string(adj_val * 2.19) +" scaleb - 16 scaleb - ? / 219 scaleb * 16 scaleb + ? x "+ string(prot_val) +" scaleb - -10 scaleb / 0 max 1 min * x x "+ string(prot_val) +" scaleb 10 scaleb - - 10 scaleb / 0 max 1 min * + "+ string(prot_val2) +" scaleb x - -10 scaleb / 0 max 1 min * x "+ string(prot_val2) +" scaleb 10 scaleb + x - 10 scaleb / 0 max 1 min * + 16 scaleb 235 scaleb clip")
    }
    else if (Defined(prot_val2) && adj_val < 0)
    {
        Expr("x 16 scaleb - 0 <= 16 scaleb 219 scaleb / 235 scaleb "+ string(adj_val * 2.19) +" scaleb + 16 scaleb - * x 16 scaleb - 219 scaleb / 235 scaleb "+ string(adj_val * 2.19) +" scaleb + 16 scaleb - * 16 scaleb + ? x "+ string(prot_val) +" scaleb - -10 scaleb / 0 max 1 min * x x "+ string(prot_val) +" scaleb 10 scaleb - - 10 scaleb / 0 max 1 min * + "+ string(prot_val2) +" scaleb x - -10 scaleb / 0 max 1 min * x "+ string(prot_val2) +" scaleb 10 scaleb + x - 10 scaleb / 0 max 1 min * + 16 scaleb 235 scaleb clip")
    }
    
    if (num_comp)
    {
        Overlay(ExtractY(c), last, 0, row, mode="luma")
        CombinePlanes(last, c, planes="YUV", sample_clip=c)
    }
    else
    {
        Overlay(c, last, 0, row, mode="luma")
    }
}
 
Function FixCBr_(clip c, int column, float adj_val, float "prot_val", bool "upper", float "prot_val2")
{
    Assert(IsYUV(c), "FixCBr: Only YUV/Y clips allowed.")
    Assert(adj_val <= 100, "FixCBr: adj_val max value 100.")
    Assert(adj_val >= -100, "FixCBr: adj_val min value -100.")
    
    if (adj_val == 0)
    {
        return c
    }
    
    if (Defined(prot_val))
    {
        Assert(prot_val <= 255, "FixCBr: prot_val max value 255.")
        Assert(prot_val >= 0, "FixCBr: prot_val min value 0.")
    }    
    if (Defined(prot_val2))
    {
        Assert(prot_val2 <= 255, "FixCBr: prot_val2 max value 255.")
        Assert(prot_val2 >= 0, "FixCBr: prot_val2 min value 0.")      
    }    
    if (Defined(prot_val) && Defined(prot_val2))
    {
        Assert((prot_val - prot_val2) >= 19, "FixCBr: The difference between prot_val and prot_val2 must be >= 19.")
    }
        
    if (Defined(prot_val) && !Defined(upper))
    {
        upper = true
    }
    
    num_comp = NumComponents(c) == 3
    Crop(num_comp ? ExtractY(c) : c, column, 0, 1, 0)
        
    if (!Defined(prot_val) && adj_val > 0)
    {
        Expr("x 16 scaleb - 0 <= 16 scaleb 235 scaleb "+ string(adj_val * 2.19) +" scaleb - 16 scaleb - 0 <= 0.01 235 scaleb "+ string(adj_val * 2.19) +" scaleb - 16 scaleb - ? / 219 scaleb * x 16 scaleb - 235 scaleb "+ string(adj_val * 2.19) +" scaleb - 16 scaleb - 0 <= 0.01 235 scaleb "+ string(adj_val * 2.19) +" scaleb - 16 scaleb - ? / 219 scaleb * 16 scaleb + ? 16 scaleb 235 scaleb clip")
    }
    else if (!Defined(prot_val) && adj_val < 0)
    {
        Expr("x 16 scaleb - 0 <= 16 scaleb 219 scaleb / 235 scaleb "+ string(adj_val * 2.19) +" scaleb + 16 scaleb - * x 16 scaleb - 219 scaleb / 235 scaleb "+ string(adj_val * 2.19) +" scaleb + 16 scaleb - * 16 scaleb + ? 16 scaleb 235 scaleb clip")
    }
    else if (!Defined(prot_val2) && adj_val > 0 && upper == true)
    {
        Expr("x 16 scaleb - 0 <= 16 scaleb 235 scaleb "+ string(adj_val * 2.19) +" scaleb - 16 scaleb - 0 <= 0.01 235 scaleb "+ string(adj_val * 2.19) +" scaleb - 16 scaleb - ? / 219 scaleb * x 16 scaleb - 235 scaleb "+ string(adj_val * 2.19) +" scaleb - 16 scaleb - 0 <= 0.01 235 scaleb "+ string(adj_val * 2.19) +" scaleb - 16 scaleb - ? / 219 scaleb * 16 scaleb + ? x "+ string(prot_val) +" scaleb - -10 scaleb / 0 max 1 min * x x "+ string(prot_val) +" scaleb 10 scaleb - - 10 scaleb / 0 max 1 min * + 16 scaleb 235 scaleb clip")
    }
    else if (!Defined(prot_val2) && adj_val > 0 && upper == false)
    {
        Expr("x 16 scaleb - 0 <= 16 scaleb 235 scaleb "+ string(adj_val * 2.19) +" scaleb - 16 scaleb - 0 <= 0.01 235 scaleb "+ string(adj_val * 2.19) +" scaleb - 16 scaleb - ? / 219 scaleb * x 16 scaleb - 235 scaleb "+ string(adj_val * 2.19) +" scaleb - 16 scaleb - 0 <= 0.01 235 scaleb "+ string(adj_val * 2.19) +" scaleb - 16 scaleb - ? / 219 scaleb * 16 scaleb + ? "+ string(prot_val) +" scaleb x - -10 scaleb / 0 max 1 min * x "+ string(prot_val) +" scaleb 10 scaleb + x - 10 scaleb / 0 max 1 min * + 16 scaleb 235 scaleb clip")
    }
    else if (!Defined(prot_val2) && adj_val < 0 && upper == true)
    {
        Expr("x 16 scaleb - 0 <= 16 scaleb 219 scaleb / 235 scaleb "+ string(adj_val * 2.19) +" scaleb + 16 scaleb - * x 16 scaleb - 219 scaleb / 235 scaleb "+ string(adj_val * 2.19) +" scaleb + 16 scaleb - * 16 scaleb + ? x "+ string(prot_val) +" scaleb - -10 scaleb / 0 max 1 min * x x "+ string(prot_val) +" scaleb 10 scaleb - - 10 scaleb / 0 max 1 min * + 16 scaleb 235 scaleb clip")
    }
    else if (!Defined(prot_val2) && adj_val < 0 && upper == false)
    {
        Expr("x 16 scaleb - 0 <= 16 scaleb 219 scaleb / 235 scaleb "+ string(adj_val * 2.19) +" scaleb + 16 scaleb - * x 16 scaleb - 219 scaleb / 235 scaleb "+ string(adj_val * 2.19) +" scaleb + 16 scaleb - * 16 scaleb + ? "+ string(prot_val) +" scaleb x - -10 scaleb / 0 max 1 min * x "+ string(prot_val) +" scaleb 10 scaleb + x - 10 scaleb / 0 max 1 min * + 16 scaleb 235 scaleb clip")
    }
    else if (Defined(prot_val2) && adj_val > 0)
    {
        Expr("x 16 scaleb - 0 <= 16 scaleb 235 scaleb "+ string(adj_val * 2.19) +" scaleb - 16 scaleb - 0 <= 0.01 235 scaleb "+ string(adj_val * 2.19) +" scaleb - 16 scaleb - ? / 219 scaleb * x 16 scaleb - 235 scaleb "+ string(adj_val * 2.19) +" scaleb - 16 scaleb - 0 <= 0.01 235 scaleb "+ string(adj_val * 2.19) +" scaleb - 16 scaleb - ? / 219 scaleb * 16 scaleb + ? x "+ string(prot_val) +" scaleb - -10 scaleb / 0 max 1 min * x x "+ string(prot_val) +" scaleb 10 scaleb - - 10 scaleb / 0 max 1 min * + "+ string(prot_val2) +" scaleb x - -10 scaleb / 0 max 1 min * x "+ string(prot_val2) +" scaleb 10 scaleb + x - 10 scaleb / 0 max 1 min * + 16 scaleb 235 scaleb clip")
    }
    else if (Defined(prot_val2) && adj_val < 0)
    {
        Expr("x 16 scaleb - 0 <= 16 scaleb 219 scaleb / 235 scaleb "+ string(adj_val * 2.19) +" scaleb + 16 scaleb - * x 16 scaleb - 219 scaleb / 235 scaleb "+ string(adj_val * 2.19) +" scaleb + 16 scaleb - * 16 scaleb + ? x "+ string(prot_val) +" scaleb - -10 scaleb / 0 max 1 min * x x "+ string(prot_val) +" scaleb 10 scaleb - - 10 scaleb / 0 max 1 min * + "+ string(prot_val2) +" scaleb x - -10 scaleb / 0 max 1 min * x "+ string(prot_val2) +" scaleb 10 scaleb + x - 10 scaleb / 0 max 1 min * + 16 scaleb 235 scaleb clip")
    }
    
    if (num_comp)
    {
        Overlay(ExtractY(c), last, column, 0, mode="luma")
        CombinePlanes(last, c, planes="YUV", sample_clip=c)
    }
    else
    {
        Overlay(c, last, column, 0, mode="luma")
    }
}

Function FixRowBrightnessProtect2(clip c, int row, float adj_val, float "prot_val", bool "upper", float "prot_val2")
{
    return FixRBr(c, row, adj_val, prot_val, upper, prot_val2)
}

Function FixColumnBrightnessProtect2(clip c, int row, float adj_val, float "prot_val", bool "upper", float "prot_val2")
{
    return FixCBr(c, row, adj_val, prot_val, upper, prot_val2)
}
