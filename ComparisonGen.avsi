### A script for saving images.


### Requirements - AviSynth+ >= r3573, avsresize, RT_Stats.


### Usage ###
###
# Function ComparisonGen(clip_array c, string_array "image_file", val_array "frame_type", string "pframes_file", int "n", float "offset_coef", string "matrix", string "pixel_type", bool "check_type")
###
## Parameters ##
#---------------
# c: Input clips.
# Type of array.
# If the clips have different length, the shortest length is used for all clips.
#---------------
# image_file (default ["%06d_0.png", "%06d_1.png", "%06d_2.png", "%06d_3.png", "%06d_4.png"]): The path+filename of the new saved images.
# Type of array.
# It must have the same length as 'c'.
#---------------
# frame_type (default [4, 3, 3, 3, 3]): Frame types that will be saved.
# Type of array.
# It must have the same length as 'c'.
# The values must be between 1..5 or "I", "P", "B", "PB", "IPB".
# 1: Corresponds to "I" frame.
# 2: Corresponds to "P" frame.
# 3: Corresponds to "B" frame.
# 4: Corresponds to either "P" or "B" frame ("PB").
# 5: Corresponds to "I" or "P", or "B" frame ("IPB").
# This parameter does nothing when check_type=false.
#---------------
# pframes_file: The path+filename of the file containing the frames that will be saved as images.
# When it's not specified, frames will be automatically picked based on SelectRangeEvery formula.
#---------------
# n (default 10): How many frames will be selected.
# It has effect when pframes_file is not specified.
#---------------
# offset_coef (default 0.05 (5% of total frames)): Offset applied to the beginning of the video.
# It has effect only when pframes_file is not specified.
#---------------
# matrix (default "709=>rgb"): Used matrix for converting to RGB before saving the png files.
# It has effect when clips are in YUV format.
#---------------
# pixel_type (default "RGBP"): Pixel_type when converting to RGB before saving the png files.
# Use "RGBP16" for 16-bit png files.
#---------------
# check_type (default true): Whether to check frame types.
# When pframes_file is not specified, check_type is always true.
# Frame property "_PictType" (FFMS2/LSMASHSource/D2VSource) is required in order to check the frame types.
# When check_type=true and frame is not correct type, the next frame will be checked until correct type is found.


### Note:
/*
Depending on the used parameters different temporary files will be created during the saving process.
They will be automatically deleted once the images are saved.
*/


### Example of pframes_file ###
/*
2
48
5567
95642
*/


### Examples ###
/*
s=FFVideoSource(clip1).Crop(0, 148, -0, -148).LWLinfo()
e=FFVideoSource(clip2).LWLinfo()
ComparisonGen([s, e], pframes_file="rr.txt")
# File rr.txt with frames number will be used and then images from clip1 and clip2 will be saved with default frame_type: P/B for first video and B for second video.
# All images will be saved in the same folder where the script is located.
###
###
s=FFVideoSource(clip1).Crop(0, 148, -0, -148).LWLinfo()
e=FFVideoSource(clip2).LWLinfo()
ComparisonGen([s, e])
# Images from automatically picked frames will be used.
###
###
s=FFVideoSource(clip1).Crop(0, 148, -0, -148).LWLinfo()
e=FFVideoSource(clip2).LWLinfo()
ComparisonGen([s, e], frame_type=["I", "B"])
# Images will be saved when clip1 frame type is 'I' and clip2 frame type is 'B'.
###
###
s=FFVideoSource(clip1).Crop(0, 148, -0, -148).LWLinfo()
e=FFVideoSource(clip2).LWLinfo()
ComparisonGen([s, e], image_file=["d:\clip0%03d.png", "d:\clip1%03d.png"])
# Clip1 images will be saved in D:\ with names "clip0xxx.png" and clip2 images will be saved in D:\ with names "clip1xxx.png".
###
###
s=FFVideoSource(clip1).Crop(0, 148, -0, -148).LWLinfo()
e=FFVideoSource(clip2).LWLinfo()
e1=FFVideoSource(clip3).LWLinfo()
e2=FFVideoSource(clip4).LWLinfo()
e3=FFVideoSource(clip5).LWLinfo()
ComparisonGen([s, e, e1, e2, e3, e4], frame_type=[4, 3, 3, 4, 4], pframes_file="rr.txt", check_type=true)
# Images will be saved when clip1 frame type is 'P/B', clip2 frame type is 'B', clip3 frame type is 'B', clip4 frame type is 'P/B', clip5 frame type is 'P/B'.
# If frame number doesn't have the given frame types, automatically starts a search for frame with correct frame types.
*/


### How to run the created script ###
/*
Two options:
1.) If you don't want to create a script then write the commands (like examples above) in AvsPmod/VirtualDub, hit Refresh and wait until you see the message 'Done.'.
2.) If you create .avs script then you could open it with:
- avsr ( https://forum.doom9.org/showthread.php?t=173259 ): avsr(64) script_name.avs;
- avsmeter ( https://forum.doom9.org/showthread.php?t=174797 ): avsmeter(64) script_name.avs;
- ffmpeg: ffmpeg -i script_name.avs -f null - ;
- AvsPmod: 1) import("script_name.avs") and 2) Video->Run analysis pass or hit Refresh.

Note - if AvsPmod is used and default s_image_file and e_image_file are used, the images will be saved in the AvsPmod folder instead in the folder where the *.avs script is located.
*/


### Changelog ###
#---------------
# 1.0.6
# Added frame_type="IPB"/5.
# Removed redundant frame_type case checks.
# Fixed overlapped frames.
#---------------
# 1.0.5
# Removed redundant ScriptClip call.
#---------------
# 1.0.4
# Moved a loop block from scriptclip.
#---------------
# 1.0.3
# Removed the limit number of the input clips.
#---------------
# 1.0.2
# Check for frame property _PictType every processed frame instead  only the first one.
#---------------
# 1.0.1
# Check for frame property _PictType only if check_type=true.
# Allowed to save images only for one clip.
#---------------
# 1.0.0
# Added check for frame property _PictType.
#---------------
# Allowed clips with different length.
#---------------
# Changed default values of image_file.
# Changed image_file type from val to string_array.
# Changed frame_type from val to val_array.
#---------------
# Replaced FrameEvalute with ScriptClip because the former doesn't like function objects.
#---------------
# Added parameter check_type.
# If frame is not correct type, next frame will be checked until correct type is found.
# Removed parameter frames_file.
# Changed type of paratemer pframes_file from bool to string.
# Added support for string values of paremeter frame_type.
#---------------
# Fixed error when pixel_type="RGBP16".
#---------------
# Added suport for up to 5 clips.
# Added new parameter 'frame_type'.
# Changed clip type to array.
# Merged parameters 's_image_file' and 'e_image_file' to one parameter 'image_file' (type array).
# Allowed RGB clips.
#---------------
# Removed support for FFMS2 variables.
#---------------
# Added support for LSMASHSource picture type.
#---------------
# WriteFile replaced with RT_WriteFile.
#---------------
# Script info changed, fixed ScriptClip error message.
#---------------
# Initial version.


Function ComparisonGen(clip_array c, string_array "image_file", val_array "frame_type", string "pframes_file", int "n", float "offset_coef", string "matrix", string "pixel_type", bool "check_type")
{
    frame_count0 = FrameCount(c[0])
    fnum = [frame_count0]
    c_size = ArraySize(c)
    c_size_minus_1 = c_size - 1
    frame_count_all = fnum
    for (i = 1, c_size_minus_1)
    {
        fnum = ArrayAdd(fnum, frame_count0)
        frame_count_all = ArrayAdd(frame_count_all, FrameCount(c[i]))
    }

    fnum_ch = 0
    for (i = 1, c_size_minus_1)
    {
        if (fnum[0] != frame_count_all[i])
        {
            fnum_ch = 1
            fnum = ArraySet(fnum, frame_count_all[i], i)
        }

        Assert(PixelType(c[0]) == PixelType(c[i]), "ComparisonGen: clips must have same pixel type.")
    }

    if (fnum_ch == 1)
    {
        fnum_min = frame_count0
        for (i = 1, c_size_minus_1)
        {
            fnum_min = Min(fnum_min, fnum[i])
        }
        for (i = 0, c_size_minus_1)
        {
            if (frame_count_all[i] != fnum_min)
            {
                copy_clip = c[i]
                c = ArraySet(c, Trim(copy_clip, 0, fnum_min - 1), i)
            }
        }
        frame_count0 = fnum_min
    }

    if (Defined(image_file))
    {
        Assert(c_size == ArraySize(image_file), "ComparisonGen: more or less 'image_file' given than there are clips.")
        _image = image_file
    }
    else
    {
        _image = []
        for (i = 0, c_size_minus_1)
        {
            _image = ArrayAdd(_image, "%06d_" + String(i) + ".png")
        }
    }

    if (Defined(frame_type))
    {
        Assert(ArraySize(c) == ArraySize(frame_type), "ComparisonGen: more or less 'frame_type' given than there are clips.")
        for (i = 0, ArraySize(frame_type) - 1)
        {
            Assert((IsInt(frame_type[i]) && frame_type[i] > 0 && frame_type[i] <= 5) || (IsString(frame_type[i]) && frame_type[i] == "I") || (IsString(frame_type[i]) && frame_type[i] == "P") || (IsString(frame_type[i]) && frame_type[i] == "B") || (IsString(frame_type[i]) && frame_type[i] == "PB") || (IsString(frame_type[i]) && frame_type[i] == "IPB"), """ComparisonGen: 'frame_type' values must be between 1..5 or "I", "P", "B", "PB", "IPB".""")
        }

        if (IsInt(frame_type[0]))
        {
            frame_types_string = []
            for (i = 0, c_size_minus_1)
            {
                frame_types_string = ArrayAdd(frame_types_string, Select(frame_type[i], "", "I", "P", "B", "PB", "IPB"))
            }

            _types = frame_types_string
        }
        else
        {
            _types = frame_type
        }
    }
    else
    {
        _types = ["PB"]
        for (i = 1, c_size_minus_1)
        {
            _types = ArrayAdd(_types, "B")
        }
    }

    matrix = Default(matrix, "709=>rgb")
    pixel_type = Default(pixel_type, "RGBP")
    check_type = Default(!Defined(pframes_file) ? true : check_type, true)

    if (!Defined(pframes_file) || (Defined(pframes_file) && check_type))
    {
        n = Default(n, 10)
        offset_coef = Default(offset_coef, 0.05)
        offset = Int(frame_count0 * offset_coef)
        frames_file = (!Defined(pframes_file)) ? (RT_GetSystemEnv("temp") + "\" + "frames_file.txt") : pframes_file
        _filedir = RT_FilenameSplit(frames_file, 3)
        if (Exist(_filedir + "_notmatiching.txt"))
        {
            RT_FileDelete(_filedir + "_notmatiching.txt")
        }
        if (Exist(_filedir + "_frames_for_save.txt"))
        {
            RT_FileDelete(_filedir + "_frames_for_save.txt")
        }
        if (Exist(_filedir + "_forsave.txt"))
        {
            RT_FileDelete(_filedir + "_forsave.txt")
        }
        if (Exist(_filedir + "_checkagain.txt"))
        {
            RT_FileDelete(_filedir + "_checkagain.txt")
        }

        if (!Defined(pframes_file))
        {
            _fnw(frame_count0, n, offset, frames_file)
        }

        last_saved_frame = 0

        for (i = 0, RT_FileQueryLines(frames_file) - 1)
        {
            checked_frame = Int(Value(RT_ReadTxtFromFile(frames_file, 1, i)))
            _fwsingle(_selectframes(c, checked_frame, frames_file), _filedir, _types, i)

            if (i > 0)
            {
                last_saved_frame = Int(Value(RT_ReadTxtFromFile(_filedir + "_frames_for_save.txt", 1, i - 1)))
            }
            if (checked_frame <= last_saved_frame)
            {
                if (Exist(_filedir + "_notmatiching.txt"))
                {
                    RT_FileDelete(_filedir + "_notmatiching.txt")
                }

                checked_frame = last_saved_frame + 1
                _fwsingle(_selectframes(c, checked_frame, frames_file), _filedir, _types, i)
            }

            if (Exist(_filedir + "_forsave.txt"))
            {
                RT_WriteFile(_filedir + "_frames_for_save.txt", "%i", checked_frame, append=true)
                RT_FileDelete(_filedir + "_forsave.txt")
            }

            While (Exist(_filedir + "_notmatiching.txt"))
            {
                _checktemp = (!Exist(_filedir + "_checkagain.txt")) ? checked_frame : Int(Value(RT_ReadTxtFromFile(_filedir + "_checkagain.txt", 1, 0)))
                RT_WriteFile(_filedir + "_checkagain.txt", "%i", _checktemp + 1)
                RT_FileDelete(_filedir + "_notmatiching.txt")

                lastframe = Int(Value(RT_ReadTxtFromFile(_filedir + "_checkagain.txt", 1, 0))) <= frame_count0 - 1
                if (!lastframe)
                {
                    RT_FileDelete(_filedir + "_checkagain.txt")
                    RT_FileDelete(frames_file)
                    Assert(false, "ComparisonGen: no frame number matching all frame types found.")
                }

                _fwsingle(_selectframes(c, Int(Value(RT_ReadTxtFromFile(_filedir + "_checkagain.txt", 1, 0))), frames_file), _filedir, _types, i)
            }

            if (Exist(_filedir + "_forsave.txt"))
            {
                RT_WriteFile(_filedir + "_frames_for_save.txt", "%i", Int(Value(RT_ReadTxtFromFile(_filedir + "_checkagain.txt", 1, 0))), append=true)
                RT_FileDelete(_filedir + "_forsave.txt")
                RT_FileDelete(_filedir + "_checkagain.txt")
            }
        }
    }

    _ffs = (check_type) ? _filedir + "_frames_for_save.txt" : pframes_file

    if (IsRGB(c[0])) {
        for (i = 0, c_size_minus_1)
        {
            _simage(z_ConvertFormat(FrameSel(c[i], cmd=_ffs), pixel_type=pixel_type, dither_type="error_diffusion"), _image[i])
        }
    }
    else
    {
        for (i = 0, c_size_minus_1)
        {
            _simage(z_ConvertFormat(FrameSel(c[i], cmd=_ffs), pixel_type=pixel_type, colorspace_op=matrix, resample_filter_uv="spline36", dither_type="error_diffusion"), _image[i])
        }
    }

    if (check_type && Exist(_filedir + "_frames_for_save.txt")) { RT_FileDelete(_filedir + "_frames_for_save.txt") }
    if (!Defined(pframes_file)) { RT_FileDelete(frames_file) }

    Return MessageClip("Done.")
}

Function _fnw(int _framec, int n, int offset, string frames_file)
{
    RT_WriteFile(frames_file, "%i", offset)

    for (i = 1, n - 1)
    {
        RT_WriteFile(frames_file, "%i", Int(Value(RT_ReadTxtFromFile(frames_file, 1, i - 1)) + _framec / n), append=true)
    }
}

Function _selectframes(clip_array c, int framenum, string frames_file)
{
    c_size_minus_1 = ArraySize(c) - 1
    for (i = 0, c_size_minus_1)
    {
        if (propGetType(c[i], "_PictType", offset=framenum) == 0)
        {
            RT_FileDelete(frames_file)
            Assert(false, "ComparisonGen: clip " + String(i + 1) + " frame " + String(framenum) + " doesn't have frame property _PictType.")
        }
    }

    new_clip_size = []
    for (i = 0, c_size_minus_1)
    {
        new_clip_size = ArrayAdd(new_clip_size, Trim(c[i], framenum, -1))
    }

    return new_clip_size
}

Function _fwsingle(clip_array c, string _filedir, string_array frame_types, int _framen)
{
    c_size_minus_1 = ArraySize(c) - 1

    result = 1
    for (i = 1, c_size_minus_1)
    {
        result = result + i
    }

    c[0]
    sI = (frame_types[0] == "I" && propGetString("_PictType") == "I")
    sP = (frame_types[0] == "P" && propGetString("_PictType") == "P")
    sB = (frame_types[0] == "B" && propGetString("_PictType") == "B")
    sPB = (frame_types[0] == "PB" && (propGetString("_PictType") == "P" || propGetString("_PictType") == "B"))
    sIPB = (frame_types[0] == "IPB")

    if (sI || sP || sB || sPB || sIPB)
    {
        check = 1

        for (j = 1, c_size_minus_1)
        {
            c[j]
            eI = (frame_types[j] == "I" && propGetString("_PictType") == "I")
            eP = (frame_types[j] == "P" && propGetString("_PictType") == "P")
            eB = (frame_types[j] == "B" && propGetString("_PictType") == "B")
            ePB = (frame_types[j] == "PB" && (propGetString("_PictType") == "P" || propGetString("_PictType") == "B"))
            eIPB = (frame_types[j] == "IPB")

            if (eI || eP || eB || ePB || eIPB)
            {
                check = check + j
            }
        }

        if (result == check)
        {
            RT_WriteFile(_filedir + "_forsave.txt", "%i", _framen)
        }
        else
        {
            RT_WriteFile(_filedir + "_notmatiching.txt", "%i", _framen)
        }
    }
    else
    {
        RT_WriteFile(_filedir + "_notmatiching.txt", "%i", _framen)
    }
}

function _simage (clip s, string image_file)
{
    s

    for (i = 0, FrameCount() - 1)
    {
        ImageWriter(image_file, start=i, end=i, type="png")
        RT_AverageLuma(ConvertToY(), n=i, w=1, h=1)
    }
}
