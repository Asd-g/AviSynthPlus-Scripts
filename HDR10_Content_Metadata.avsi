/*
A script for calculating MaxFall and MaxCLL of HDR10 video.
Reference - https://ieeexplore.ieee.org/document/9508136
*/


### Requirements - AviSynth+ >= r3573, avsresize, RT_Stats.


### Usage ###
###
# Function HDR10_Content_Metadata(clip c, string "log_path", bool "MaxCLL", bool "MaxFALL", float "MaxCLL_percentile", float "MaxFALL_percentile", string "temp_files_suffix")
###
## Parameters ##
#---------------
# c: Input clip.
# Must be in YUV420 format.
# Must have frame properties _Transfer(16) and _Matrix(9).
# Must be cropped.
#---------------
# log_path (default: the script location): The path for the log.
#---------------
# MaxCLL (default: true): Whether to calculate MaxCLL.
#---------------
# MaxFALL (default: true): Whether to calculate MaxFALL.
#---------------
# MaxCLL_percentile (default: 99.5): Compute percentile of the frame's max brightness.
# Must be between 0.0..100.0.
#---------------
# MaxFALL_percentile (default: 99.75): Compute percentile of the frame's max brightness.
# Must be between 0.0..100.0.
#---------------
# temp_files_suffix (default: not specified): Whether to add suffix to the temporary files.
# This will allow to run instances simultaneously.


### Temporary files ###
/*
In order to save some intermediate results, temporary file(s) is created in the same location as log_path. At the end of the analysis this file(s) is deleted.
*/


### How to use ###
/*
Two options:
1.) If you don't want to create a script then open AvsPmod and write the scrript, hit Refresh and wait until you see the message 'Done.'.
Note - in this case if default "log_path" is used, the log will be saved in the AvsPmod folder.
2.) If you create .avs script then you could open it with:
- avsr ( https://forum.doom9.org/showthread.php?t=173259 ): avsr(64) script_name.avs;
- avsmeter ( https://forum.doom9.org/showthread.php?t=174797 ): avsmeter(64) script_name.avs;
- ffmpeg: ffmpeg -i script_name.avs -f null - ;
- AvsPmod: 1) import("script_name.avs") and 2) Video->Run analysis pass or hit Refresh.
*/


### Changelog ###
#---------------
# 1.0.1
# Actually give error message if MaxCLL_percentile / MaxCLL_percentile aren't between 0.0..100.0.
# Added parameter temp_files_suffix - allows multi instances simultaneously.
#---------------
# 1.0.0
# Initial version.


Function HDR10_Content_Metadata(clip c, string "log_path", bool "MaxCLL", bool "MaxFALL", float "MaxCLL_percentile", float "MaxFALL_percentile", string "temp_files_suffix")
{
    Assert(Is420(c), "HDR10_Content_Metadata: the clip must be in YUV420 format.")
    Assert(propGetInt(c, "_Transfer") == 16, "HDR10_Content_Metadata: the clip must have _Transfer frame property 16.")
    Assert(propGetInt(c, "_Matrix") == 9, "HDR10_Content_Metadata: the clip must have _Matrix frame property 9.")

    log_path = (Defined(log_path)) ? (log_path + "\") : ScriptDir
    maxcll = Default(MaxCLL, true)
    maxfall = Default(MaxFALL, true)
    maxcll_percentile = Default(MaxCLL_percentile, 99.5)
    maxfall_percentile = Default(MaxFALL_percentile, 99.75)
    temp_files_suffix = Default(temp_files_suffix, "")

    Assert(MaxCLL_percentile >= 0.0 && MaxCLL_percentile <= 100.0, "HDR10_Content_Metadata: MaxCLL_percentile must be between 0.0..100.0.")
    Assert(MaxFALL_percentile >= 0.0 && MaxFALL_percentile <= 100.0, "HDR10_Content_Metadata: MaxFALL_percentile must be between 0.0..100.0.")

    c
    frames_count_minus_1 = FrameCount(c)
    z_ConvertFormat(pixel_type="rgbps", colorspace_op="2020:st2084:2020:l=>rgb:linear:2020:f", chromaloc_op="top_left=>top_left", nominal_luminance=10000)
    Expr("x 0 1 clip")

    if (!maxcll && maxfall)
    {
        current_frame = 0

        pass1_avg_file = log_path + "pass1_avg" + temp_files_suffix + ".txt"
        rmax = RplaneMax()
        gmax = GplaneMax()
        bmax = BplaneMax()
        max_rgb = (rmax >= Max(gmax, bmax)) ? 1
            \ : (gmax >= Max(rmax, bmax)) ? 2
            \ : 3
        RT_WriteFile(pass1_avg_file, "%s", String((max_rgb < 3) ? (max_rgb < 2) ? AverageR() : AverageG() : AverageB()))

        for (i = 1, frames_count_minus_1)
        {
            current_frame = i

            rmax = RplaneMax()
            gmax = GplaneMax()
            bmax = BplaneMax()
            max_rgb = (rmax >= Max(gmax, bmax)) ? 1
                \ : (gmax >= Max(rmax, bmax)) ? 2
                \ : 3
            RT_WriteFile(pass1_avg_file, "%s", String((max_rgb < 3) ? (max_rgb < 2) ? AverageR() : AverageG() : AverageB()), append=true)
        }

        pass1 = RT_ReadTxtFromFile(pass1_avg_file)
        RT_FileDelete(pass1_avg_file)
        sorted_pass = RT_TxtSort(pass1)
        max_avg = RT_TxtGetLine(sorted_pass, (maxfall_percentile < 100.0) ? RoundHalfToEven((maxfall_percentile / 100.0) * (RT_TxtQueryLines(sorted_pass) - 1))
            \ : RT_TxtQueryLines(sorted_pass) - 1)

        RT_WriteFile(log_path + "HDR10_Content_Metadata_MaxFALL.txt", "%s%f%s%i", "MaxFALL: ", Value(max_avg) * 10000, " at frame ", RT_TxtFindStr(pass1, max_avg))
    }
    else if (maxcll && !maxfall)
    {
        maxcll_percentile_100 = maxcll_percentile == 100.0
        threshold_ = (maxcll_percentile_100) ? 0 : 0.01

        current_frame = 0

        pass1_max_file = log_path + "pass1_max" + temp_files_suffix + ".txt"
        RT_WriteFile(pass1_max_file, "%s", String(Max(RplaneMax(threshold=threshold_), GplaneMax(threshold=threshold_), BplaneMax(threshold=threshold_))))

        for (i = 1, frames_count_minus_1)
        {
            current_frame = i
            RT_WriteFile(pass1_max_file, "%s", String(Max(RplaneMax(threshold=threshold_), GplaneMax(threshold=threshold_), BplaneMax(threshold=threshold_))), append=true)
        }

        pass1 = RT_ReadTxtFromFile(pass1_max_file)
        RT_FileDelete(pass1_max_file)
        sorted_pass = RT_TxtSort(pass1)
        max_ = RT_TxtGetLine(sorted_pass, (!maxcll_percentile_100) ? RoundHalfToEven((maxcll_percentile / 100.0) * (RT_TxtQueryLines(sorted_pass) - 1))
            \ : RT_TxtQueryLines(sorted_pass) - 1)

        RT_WriteFile(log_path + "HDR10_Content_Metadata_MaxCLL.txt", "%s%f%s%i", "MaxCLL: ", Value(max_) * 10000, " at frame ", RT_TxtFindStr(pass1, max_))
    }
    else if (maxcll && maxfall)
    {
        maxcll_percentile_100 = maxcll_percentile == 100.0
        threshold_ = (maxcll_percentile_100) ? 0 : 0.01

        current_frame = 0

        pass1_avg_file = log_path + "pass1_avg" + temp_files_suffix + ".txt"
        pass1_max_file = log_path + "pass1_max" + temp_files_suffix + ".txt"

        rmax = RplaneMax()
        gmax = GplaneMax()
        bmax = BplaneMax()
        max_rgb = (rmax >= Max(gmax, bmax)) ? 1
            \ : (gmax >= Max(rmax, bmax)) ? 2
            \ : 3
        RT_WriteFile(pass1_avg_file, "%s", String((max_rgb < 3) ? (max_rgb < 2) ? AverageR() : AverageG() : AverageB()))
        RT_WriteFile(pass1_max_file, "%s", String((maxcll_percentile_100) ? Max(rmax, gmax, bmax)
            \ : Max(RplaneMax(threshold=threshold_), GplaneMax(threshold=threshold_), BplaneMax(threshold=threshold_))))

        for (i = 1, frames_count_minus_1)
        {
            current_frame = i

            rmax = RplaneMax()
            gmax = GplaneMax()
            bmax = BplaneMax()
            max_rgb = (rmax >= Max(gmax, bmax)) ? 1
                \ : (gmax >= Max(rmax, bmax)) ? 2
                \ : 3
            RT_WriteFile(pass1_avg_file, "%s", String((max_rgb < 3) ? (max_rgb < 2) ? AverageR() : AverageG() : AverageB()), append=true)
            RT_WriteFile(pass1_max_file, "%s", String((maxcll_percentile_100) ? Max(rmax, gmax, bmax)
                \ : Max(RplaneMax(threshold=threshold_), GplaneMax(threshold=threshold_), BplaneMax(threshold=threshold_))), append=true)
        }

        pass1_avg = RT_ReadTxtFromFile(pass1_avg_file)
        pass1_max = RT_ReadTxtFromFile(pass1_max_file)
        RT_FileDelete(pass1_avg_file)
        RT_FileDelete(pass1_max_file)
        sorted_pass_avg = RT_TxtSort(pass1_avg)
        sorted_pass_max = RT_TxtSort(pass1_max)

        max_avg = RT_TxtGetLine(sorted_pass_avg, (maxfall_percentile < 100.0) ? RoundHalfToEven((maxfall_percentile / 100.0) * (RT_TxtQueryLines(sorted_pass_avg) - 1))
            \ : RT_TxtQueryLines(sorted_pass_avg) - 1)

        max_ = RT_TxtGetLine(sorted_pass_max, (!maxcll_percentile_100) ? RoundHalfToEven((maxcll_percentile / 100.0) * (RT_TxtQueryLines(sorted_pass_max) - 1))
            \ : RT_TxtQueryLines(sorted_pass_max) - 1)

        RT_WriteFile(log_path + "HDR10_Content_Metadata.txt", "%s%f%s%i%s%s%f%s%i", "MaxCLL: ", Value(max_) * 10000, " at frame ", RT_TxtFindStr(pass1_max, max_), Chr(10), "MaxFALL: ", Value(max_avg) * 10000, " at frame ", RT_TxtFindStr(pass1_avg, max_avg))
    }

    return MessageClip("Done.")
}
