## Changelog:
# Round to the nearest even when the fraction is 0.5. Mode is changed to integer when mode "sd" is not used.
# Added Crop() for cropping values >(-)1.
# Added left, top, right, bottom, fill_margins parameters.
# Added dither_type parameter.


# AutoResize function for AviSynth - intelligent resize to 1080p, 720p, SD (720px wide) or any custom resolution


### Usage
## AutoResize(clip c, string mode, int "left", int "top", int "right", int "bottom", string "resizer", string "dither_type", bool "fill_margins")
# mode - the vertical resolution (e.g. 1080). "sd" mode gives DVD resolution (720xY). When mode "sd" is not used the expected value is integer.
# left, top, right, bottom - crop values. Same syntax as Crop (right and bottom must be negative). If the values are even, Crop() is used. If the values are odd and greater than 1, Crop() even numbers + FillMargins 1 line + Resizer_crop for 1 line are used. If the values are equal to 1, FillMargins 1 line + Resizer_crop for 1 line are used.
# resizer - what resizer to be used. Default is z_Spline36Resize
# dither_type - what dither type to be used if the resizer has dither option. Currently valid only for z_ resizers
# dither_type="no" must be used if the used resizer doesn't have dither option. Default dither_type is "ordered"
# fill_margins - FillMargins is used to fill 1 line on: left; top; right; bottom. Default - if left=top=right=bottom=0 fill_margins=false, otherwise fill_margins=true.


## Examples
# AutoResize(720, 0, 1, 0, -1) # Assume 1920x800_input. It's the same as FillMargins(0, 1, 0, 1).z_Spline36Resize(1280, 532, 0, 1, 0, -1, dither="ordered")
# AutoResize(720, 0, 1, 0, -1, fill_margins=false) # Assume 1920x800_input. It's the same as z_Spline36Resize(1280, 532, 0, 1, 0, -1, dither="ordered")
# AutoResize(720, 0, 138, 0, -138) # Assume 1920x1080_input. It's the same as Crop(0, 138, 0, -138).z_Spline36Resize(1280, 536, dither="ordered")
# AutoResize(720, 0, 139, 0, -139) # Assume 1920x1080_input. It's the same as Crop(0, 138, 0, -138).FillMargins(0, 1, 0, 1).z_Spline36Resize(1280, 534, 0, 1, 0, -1, dither="ordered")
# AutoResize(720, 0, 138, 0, -139) # Assume 1920x1080_input. It's the same as Crop(0, 138, 0, -138).FillMargins(0, 0, 0, 1).z_Spline36Resize(1280, 536, 0, 0, 0, -1, dither="ordered")
# AutoResize(720) # Assume 1920x800_input. It's the same as z_Spline36Resize(1280, 534, dither="ordered")
# AutoResize(720, dither_type="no") # Assume 1920x800_input. It's the same as z_Spline36Resize(1280, 534, dither="none")


function AutoResize(clip c, val mode, int "left", int "top", int "right", int "bottom", string "resizer", string "dither_type", bool "fill_margins")
{    
    left = default(left, 0)
    top = default(top, 0)
    right = default(right, 0)
    bottom = default(bottom, 0)
    
    Assert(left >= 0, "AutoResize: left must be >= 0.")
    Assert(top >= 0, "AutoResize: top must be >= 0.")
    Assert(right <= 0, "AutoResize: right must be <= 0.")
    Assert(bottom <= 0, "AutoResize: bottom must be <= 0.")    
      
    resizer = default(resizer, "z_Spline36Resize")
    dither_type = default(dither_type,  "ordered")
    
    newsize = IsString(mode) && lcase(mode) == "sd" ? _AutoResizeSD(c) : _AutoResizeHD(c, mode, left, top, right, bottom)    
        
    check_left = left > 0 && left % 2 != 0
    check_top = top > 0 && top % 2 != 0
    check_right = right < 0 && right % 2 != 0
    check_bottom = bottom < 0 && bottom % 2 != 0    
       
    crop_left = check_left ? left - 1 : left
    crop_top = check_top ? top - 1 : top
    crop_right = check_right ? right + 1 : right
    crop_bottom = check_bottom ? bottom + 1 : bottom
    
    if (crop_left > 0 || crop_top > 0 || crop_right > 0 || crop_bottom > 0) { c = Crop(c, crop_left, crop_top, crop_right, crop_bottom) }
    
    fill_margins = default(fill_margins, check_left || check_top || check_right || check_bottom ? true : false)
    
    proc_left = check_left ? 1 : NOP()
    proc_top = check_top ? 1 : NOP()
    proc_right = check_right ? 1 : NOP()
    proc_bottom = check_bottom ? 1 : NOP()
    c = fill_margins ? FillMargins(c, proc_left, proc_top, proc_right, proc_bottom) : c   
    
    if (lcase(dither_type) != "no")
    {
        dither_ = "dither="+"""dither_type"""        
        eval(resizer + "(c," + newsize + ", proc_left, proc_top, -proc_right, -proc_bottom, " + dither_ + ")")
    }
    else
    {
        eval(resizer + "(c," + newsize + ", proc_left, proc_top, -proc_right, -proc_bottom)")
    }
}

function _ResizeRoundClosest(float n)
{
    q = n / 2.0
    
    if (Frac(q) == 0.5)
    {
        f = Floor(q)
        return f % 2 == 0 ? Int(f * 2.0) : Int(Ceil(q) * 2.0)
    }
    else { return Int(Round(q) * 2.0) }
}
 
function _AutoResizeSD(clip c)
{
    return String(720) + "," + String(_ResizeRoundClosest(720 * (Float(Height(c)) / Float(Width(c)))))
}
 
function _AutoResizeHD(clip c, int mode, int left, int top, int right, int bottom)
{
    size = Float(Width(c) - left + right) / Float(Height(c) - top + bottom)
    div = 16.0 / 9.0

    w = size <= div ? _ResizeRoundClosest(mode * size) : _ResizeRoundClosest(mode * div)
 
    return String(w) + "," + String(size <= div ? mode : _ResizeRoundClosest(w / size))
}
