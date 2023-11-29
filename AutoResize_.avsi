### AutoResize function for AviSynth - intelligent resize to 1080p, 720p, SD (720px wide) or any custom resolution


/*
Requirements:
AviSynth+ 3.6 or later
avsresize (for z_ resizer, avsresize >=r22), DPID (for dpid/dpidraw resizer)
fmtconv (for fmtc_resample resizer)
SSIM_downsample (for SSIM_downsample resizer)
ResizeShader(for resizeshader resizer)
FillBorders (for fill_margins=true)
avs_libplacebo (for libplacebo_Resample)
RT_Stats (for fmtc_resample and interlaced=true)
*/


### Usage ###
###
# AutoResize(clip c, val mode, int "left", int "top", int "right", int "bottom", string "resizer", string "dither_type", bool "fill_margins", bool "mod2", string "args", int "dmode", bool "interlaced")
###
## Parameters ##
#---------------
# mode: The used mode.
# If this is int: the vertical resolution (e.g. 1080).
# If this is "sd": gives DVD resolution (720xY).
# If this is array of two int [width, height]: no aspect ratio error is introduced.
# Note if this is array: be extra careful for YVU420 formats if there will other resizing afterwards. It could cause bigger aspect ratio error for the next resizing.
#---------------
# left, top, right, bottom (default 0): Crop values.
# Same syntax as Crop (right and bottom must be negative).
# If the values are even, Crop() is used.
# If the values are odd and greater than 1, Crop() even numbers + FillMargins 1 line + Resizer_crop for 1 line are used.
# If the values are equal to 1, FillMargins 1 line + Resizer_crop for 1 line are used.
# If the values are equal to 0, scr_left/src_top/src_width/src_height parameters can be passed as args value.
#---------------
# resizer (default z_Spline36Resize): What resizer to be used.
# Other possibilities: dpid, dpidraw, fmtc_resample, resizeshader, ssim_downsample, libplacebo_Resample...
#---------------
# dither_type (default "ordered"): What dither type to be used.
# Allowed values: "none", "ordered", "error_diffusion".
# It has no effect for resizer other than z_ / fmtc_resample / SSIM_downsample.
#---------------
# fill_margins (default left=top=right=bottom=0 if fill_margins=false): Whether to use FillMargins to fill 1 line on: left; top; right; bottom.
#---------------
# mod2 (default false): Whether to force mod2 calculation for the new size.
# It has effect only for non-420 video.
#---------------
# args (default ""): Specify additional resizer arguments.
#---------------
# dmode (default 0): What dither type to be used for fmtc_resample other than 0/1/6.
#---------------
# interlaced (default false): Whether the video is interlaced (valid only for z_ and fmtc_resample resizers).


### Examples ###
/*
AutoResize(720, 0, 1, 0, -1) # Assume 1920x800_input. It's the same as FillMargins(0, 1, 0, 1).z_Spline36Resize(1280, 532, 0, 1, 0, -1, dither="ordered")
*/
###
/*
AutoResize(720, 0, 1, 0, -1, fill_margins=false) # Assume 1920x800_input. It's the same as z_Spline36Resize(1280, 532, 0, 1, 0, -1, dither="ordered")
*/
###
/*
AutoResize(720, 0, 138, 0, -138) # Assume 1920x1080_input. It's the same as Crop(0, 138, 0, -138).z_Spline36Resize(1280, 536, dither="ordered")
*/
###
/*
AutoResize(720, 0, 139, 0, -139) # Assume 1920x1080_input. It's the same as Crop(0, 138, 0, -138).FillMargins(0, 1, 0, 1).z_Spline36Resize(1280, 534, 0, 1, 0, -1, dither="ordered")
*/
###
/*
AutoResize(720, 0, 138, 0, -139) # Assume 1920x1080_input. It's the same as Crop(0, 138, 0, -138).FillMargins(0, 0, 0, 1).z_Spline36Resize(1280, 536, 0, 0, 0, -1, dither="ordered")
*/
###
/*
AutoResize(720) # Assume 1920x800_input. It's the same as z_Spline36Resize(1280, 534, dither="ordered")
*/
###
/*
AutoResize(720, dither_type="no") # Assume 1920x800_input. It's the same as z_Spline36Resize(1280, 534, dither="none")
*/
###
/*
AutoResize(720, resizer="z_BicubicResize", args="b=-0.25, c=0.125") # Assume 1920x800_input. It's the same as z_BicubicResize(1280, 534, -0.25, 0.125)
*/


### Changelog ###
#---------------
# 1.1.1
# Fixed missing variable when mode array is used and no addition crop/shift is required.
#---------------
# 1.1.0
# Added requirement for the avsresize version >=r22.
# Removed parameter crop_values.
# mode: can be array to resize to specific resolution without ar error (based on https://gist.github.com/wiwaz/7d5afee6aadb1dae0131aedc6d1a6440).
#---------------
# 1.0.0
# Added parameter dmode.
# Improved evaluating of the different resizers.
# Added support for libplacebo_Resample.
# Added parameter crop_values.
# Added parameter interlaced.
#---------------
# Added support for some kernels that don't have parameters src_left/src_top/src_width/src_height: DPID, DPIDraw, fmtc_resample, ResizeShader, SSIM_downsample.
#---------------
# Added paramters mod2 and args.
#---------------
# "SD" mode: fixed target resolution when crop values are used.
#---------------
# Moved rounding function as standalone function (RoundHalfToEven.avsi). Don't use mod2 when calculating the height of yv24/yv16.
#---------------
# Round to the nearest even when the fraction is 0.5. Mode is changed to integer when mode "sd" is not used.
#---------------
# Added Crop() for cropping values >(-)1.
#---------------
# Added left, top, right, bottom, fill_margins parameters.
#---------------
# Added dither_type parameter.


function AutoResize(clip c, val mode, int "left", int "top", int "right", int "bottom", string "resizer", string "dither_type", bool "fill_margins", bool "mod2", string "args", int "dmode", bool "interlaced")
{
    mode_array = IsArray(mode)
    Assert((mode_array && ArraySize(mode) == 2 && IsInt(mode[0]) && IsInt(mode[1])) || IsInt(mode) || (IsString(mode) && mode == "sd"), "AutoResize: mode has wrong value.")

    resizer = default(resizer, "z_Spline36Resize")
    resizer = lcase(resizer)

    z_check = lcase(LeftStr(resizer, 2)) == "z_"
    dither_type = ((z_check) || (resizer == "fmtc_resample")) ? default(dither_type, "ordered") : "no"
    Assert((dither_type == "no") || (dither_type == "none") || (dither_type == "ordered") || (dither_type == "error_diffusion"), "AutoResize: wrong dither_type.")

    mod2 = default(mod2, false)
    left = default(left, 0)
    top = default(top, 0)
    right = default(right, 0)
    bottom = default(bottom, 0)

    Assert(left >= 0, "AutoResize: left must be >= 0.")
    Assert(top >= 0, "AutoResize: top must be >= 0.")
    Assert(right <= 0, "AutoResize: right must be <= 0.")
    Assert(bottom <= 0, "AutoResize: bottom must be <= 0.")

    crop_values = ((left > 0 || top > 0 || right > 0 || bottom > 0) && !mode_array) ? true : false
    if (crop_values)
    {
        check_left = left > 0 && left % 2 != 0
        check_top = top > 0 && top % 2 != 0
        check_right = right < 0 && right % 2 != 0
        check_bottom = bottom < 0 && bottom % 2 != 0

        crop_left = check_left ? left - 1 : left
        crop_top = check_top ? top - 1 : top
        crop_right = check_right ? right + 1 : right
        crop_bottom = check_bottom ? bottom + 1 : bottom

        if (crop_left > 0 || crop_top > 0 || crop_right > 0 || crop_bottom > 0) { c = Crop(c, crop_left, crop_top, crop_right, crop_bottom) }

        fill_margins = default(fill_margins, (check_left || check_top || check_right || check_bottom) ? true : false)

        proc_left = check_left ? 1 : NOP()
        proc_top = check_top ? 1 : NOP()
        proc_right = check_right ? 1 : NOP()
        proc_bottom = check_bottom ? 1 : NOP()
        c = fill_margins ? FillMargins(c, proc_left, proc_top, proc_right, proc_bottom) : c
    }
    else if (mode_array)
    {
        src_w = Float(Width(c))
        dst_w = Float(mode[0])
        src_dar = src_w / Height(c)
        dst_dar = dst_w / mode[1]

        if (src_dar != dst_dar)
        {
            if (src_dar > dst_dar)
            {
                scale = Float(Height(c)) / mode[1]
                crop_ = src_w - (dst_w * scale)

                proc_left = crop_ / 2
                proc_top = 0
                proc_right = (src_w - (src_w - crop_)) / 2
                proc_bottom = 0
            }
            else
            {
                scale = src_w / dst_w
                crop_ = Float(Height(c)) - (mode[1] * scale)

                proc_left = 0
                proc_top = crop_ / 2
                proc_right = 0
                proc_bottom = (Height(c) - (Height(c) - crop_)) / 2
            }
        }
    }

    args = defined(args) ? ", " + args : ""
    interlaced = default(interlaced, false)

    newsize = (IsString(mode) && mode == "sd") ? _AutoResizeSD(c, top, bottom) :
        \ (IsInt(mode)) ? _AutoResizeHD(c, mode, left, top, right, bottom, mod2) : (String(mode[0]) + ", " + String(mode[1]))

    if (z_check)
    {
        if (interlaced)
        {
            return (crop_values || (mode_array && VarExist("proc_left"))) ? eval(resizer + "(c," + newsize + ", src_left=proc_left, src_top=proc_top, src_width=-proc_right, src_height=-proc_bottom, dither=dither_type, interlaced=true" + args + ")") :
            \ eval(resizer + "(c," + newsize + ", dither=dither_type, interlaced=true" + args + ")")
        }
        else
        {
            return (crop_values || (mode_array && VarExist("proc_left"))) ? eval(resizer + "(c," + newsize + ", src_left=proc_left, src_top=proc_top, src_width=-proc_right, src_height=-proc_bottom, dither=dither_type, interlaced=false" + args + ")") :
            \ eval(resizer + "(c," + newsize + ", dither=dither_type, interlaced=false" + args + ")")
        }

    }
    else if (resizer == "fmtc_resample")
    {
        if (interlaced)
        {
            Assert((propGetType(c, "_FieldBased") > 0) && (propGetInt(c, "_FieldBased") > 0), "AutoResize: frame propery '_FieldBased' must be either 1 or 2.")

            SeparateFields(c)
            newsize = LeftStr(newsize, FindStr(newsize, ",")) + String(RT_NumberValue(RightStr(newsize, StrLen(newsize) - FindStr(newsize, ","))) / 2)
            (crop_values || (mode_array && VarExist("proc_left"))) ? eval(resizer + "(" + newsize + ", sx=proc_left, sy=proc_top, sw=-proc_right, sh=-proc_bottom" + args + ")") :
            \ eval(resizer + "(" + newsize + args + ")")
            Weave()
        }
        else
        {
            (crop_values || (mode_array && VarExist("proc_left"))) ? eval(resizer + "(c," + newsize + ", sx=proc_left, sy=proc_top, sw=-proc_right, sh=-proc_bottom, interlaced=0" + args + ")") :
            \ eval(resizer + "(c, interlaced=0," + newsize + args + ")")
        }

        if (BitsPerComponent() != BitsPerComponent(c))
        {
            dmod = (dither_type == "none") ? 1 : (dither_type == "ordered") ? 0 : 6
            dmode = default(dmode, dmod)
            fmtc_bitdepth(BitsPerComponent(c), dmode=dmode)
        }
    }
    else if (resizer == "ssim_downsample")
    {
        return eval(resizer + "(c," + newsize + ", dither=dither_type" + args + ")")
    }
    else if (resizer == "dpid" || resizer == "dpidraw")
    {
        return eval(resizer + "(c," + newsize + args + ")")
    }
    else if (resizer == "resizeshader")
    {
        return eval(resizer + "(c," + newsize + args + ")")
    }
    else if (resizer == "libplacebo_resample")
    {
        return (crop_values || (mode_array && VarExist("proc_left"))) ? eval(resizer + "(c," + newsize + ", sx=proc_left, sy=proc_top, src_width= Width(c)-proc_left-proc_right, src_height=Height(c)-proc_top-proc_bottom" + args + ")") :
        \ eval(resizer + "(c," + newsize + args + ")")
    }
    else # internal avs resizers, ResampleMT resizers
    {
        return (crop_values || (mode_array && VarExist("proc_left"))) ? eval(resizer + "(c," + newsize + ", src_left=proc_left, src_top=proc_top, src_width=-proc_right, src_height=-proc_bottom" + args + ")") :
        \ eval(resizer + "(c," + newsize + args + ")")
    }
}

function _AutoResizeSD(clip c, int top, int bottom)
{
    return String(720) + "," + String(Int(RoundHalfToEven_mod2(720 * (Float(Height(c) - top + bottom) / Width(c)))))
}

function _AutoResizeHD(clip c, int mode, int left, int top, int right, int bottom, bool mod2)
{
    size = Float(Width(c) - left + right) / (Height(c) - top + bottom)
    div = 16.0 / 9.0

    w = size <= div ? RoundHalfToEven_mod2(mode * size) : RoundHalfToEven_mod2(mode * div)

    return String(Int(w)) + "," + String(size <= div ? mode :
        \ mod2 ? Int(RoundHalfToEven_mod2(w / size)) :
            \ !Is420(c) ? RoundHalfToEven(w / size) : Int(RoundHalfToEven_mod2(w / size)))
}
