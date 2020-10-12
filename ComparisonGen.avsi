## Changelog:
# - removed support for FFMS2 variables
# - Added support for LSMASHSource picture type
# - WriteFile replaced with RT_WriteFile
# - script info changed, fixed ScriptClip error message


# A script for taking images from source and encode video. In the end one has images for source (P/B frame type) vs encode (B frame type) comparison.


## Usage info: ComparisonGen(clip s, clip e, string "frames_file", string "s_image_file", string "e_image_file", bool "pframes_file", int "n", float "offset_coef", string "matrix", string "pixel_type")
# clip s - source clip
# clip e - encode clip
# string "frames_file" - the path+filename for the frames number
# string "s_image_file" (optional) (default "%06dsource.png") - the path+filename of images saved from the source
# string "e_image_file" (optional) (default "%06dencode.png") - the path+filename of images saved from the encode
# bool "pframes_file" (optional) (default "false") - if a predefined file with frames number is supplied. FFMS2/LSMASHSource is required if pframes_file is false.
# int "n" (optional) (default 10) - how many frames will be selected. Note that the final frames number could be smaller if source frame isn't P/B frame type / encode frame isn't B frame type
# float "offset_coef" (optional) (default 0.05 (5% of total frames)) - offset for SelectRangeEvery when selecting the frames
# string "matrix" (optional) (default "709=>rgb") - used matrix for converting to RGB before saving png
# string "pixel_type" (optional) (default "RGBP") - pixel_type when converting to RGB before saving png, if you want to save png with >8-bit use "RGBP16"


## The predefined file with frames number must contain one frame number on one row.
# Example:
# 2
# 48
# 5567
# ...


## Usage examples:
# s=FFVideoSource(source).Crop(0, 148, -0, -148).ffinfo() # LWLibavVideoSource(source).Crop(0, 148, -0, -148).lwlinfo()
# e=FFVideoSource(encode).ffinfo() # LWLibavVideoSource(encode).lwlinfo()
# ComparisonGen(s, e, "rr.txt") # File rr.txt with frames number will be created and after source + encode images will be created. All files will be created in the same folder where the script is located.
###
# s=FFVideoSource(source).Crop(0, 148, -0, -148).ffinfo() # LWLibavVideoSource(source).Crop(0, 148, -0, -148).lwlinfo()
# e=FFVideoSource(encode).ffinfo() # LWLibavVideoSource(encode).lwlinfo()
# ComparisonGen(s, e, "D:\rr.txt", pframes_file=true) # Already created file with name "rr.txt" in D:\ with frames number will be used.
###
# ComparisonGen(s, e, "rr.txt", s_image_file="d:\source%03d.png", e_image_file="d:\encode%03d.png") # Created source images will be saved in D:\ with names "sourcexxx.png" and created encode images will be saved in D:\ with names "encodexxx.png".


## If you don't want to create script then write the commands (like examples above) in AvsPmod/VirtualDub, hit Refresh and wait until you see the message "Done.".
## If you create .avs script then you could open it with:
# - avsr ( https://forum.doom9.org/showthread.php?t=173259 ): avsr(64) script_name.avs;
# - avsmeter ( https://forum.doom9.org/showthread.php?t=174797 ): avsmeter(64) script_name.avs;
# - ffmpeg: ffmpeg -i script_name.avs -f null - ;
# - AvsPmod: 1) import("script_name.avs") and 2) Video->Run analysis pass.
##
# Note - if AvsPmod is used and default s_image_file and e_image_file are used, the images will be saved in the AvsPmod folder instead in the folder where the script *.avs is located.


Function ComparisonGen(clip s, clip e, string "frames_file", string "s_image_file", string "e_image_file", bool "pframes_file", int "n", float "offset_coef", string "matrix", string "pixel_type")
{
    Assert(FrameCount(s) == FrameCount(e), "ComparisonGen: clips must have same total number of frames.")
    Assert(PixelType(s) == PixelType(e), "ComparisonGen: clips must have same pixel type.")
    
    frames_file = Default(frames_file, "")
    s_image_file = Default(s_image_file, "%06dsource.png")
    e_image_file = Default(e_image_file, "%06dencode.png")
    pframes_file = Default(pframes_file, false)  
    matrix = Default(matrix, "709=>rgb")
    pixel_type = Default(pixel_type, "RGBP")

    if (!pframes_file)
    {
        n = Default(n, 10)
        offset_coef = Default(offset_coef, 0.05)
        offset = Int(FrameCount(s) * offset_coef)
        sf = SelectRangeEvery(s, (FrameCount(s) / n), 1, offset)
        ef = SelectRangeEvery(e, (FrameCount(e) / n), 1, offset)
        
        fw(sf, ef, frames_file)
    }
    else
    {
        sf = s
        ef = e
    }
    
    simage(z_ConvertFormat(FrameSel(sf, cmd=frames_file), pixel_type=pixel_type, colorspace_op=matrix, resample_filter_uv="spline36", dither_type="error_diffusion"), s_image_file)
    simage(z_ConvertFormat(FrameSel(ef, cmd=frames_file), pixel_type=pixel_type, colorspace_op=matrix, resample_filter_uv="spline36", dither_type="error_diffusion"), e_image_file)
    
    Return MessageClip("Done.")

}

Function fw (clip s, clip e, string frames_file)
{
    global e = e
    
    for (i = 0, FrameCount(s) -1)
    {
        current_frame = i
            
        ScriptClip(s, """if (String(propGetString("_PictType")) == "P" || String(propGetString("_PictType")) == "B")
            {
                e
                
                if (String(propGetString("_PictType")) == "B")
                {
                    WriteFile(last, frames_file, "i")
                }
            } """, after_frame=true)
                
        AverageLuma()
    }
}

function simage (clip s, string image_file)
{
    s
    
    for (i = 0, FrameCount() - 1)
    {
        current_frame = i
        ImageWriter(image_file, start=i, end=i, type="png")
        ConvertToY8().AverageLuma()
    }
}
