/*
Helper function for finding black/dirty lines on the borders.

The difference between lines could be displayed or the frames above threshold could be saved in txt file.
*/


### Requirements - AviSynth+ >= 3.6, solarCurve, ContinuityFixer, retinex_edgemask, LinesLumaDiff, RT_Stats, ApplyGradationCurves.


### Usage ###
###
# dldet(clip c, string "output", int "n", float "thr", float "thr1", bool "left", bool "top", bool "right", bool "bottom", bool "debug", bool "show", string "prefilter")
###
## Parameters ##
#---------------
# c: Input clip.
# Must be in YUV planar format.
#---------------
# output (default not defined): The path of the txt file with frames.
# Must be specified for debug=false.
#---------------
# n (default 1): The line that will be checked at both sides, top and bottom.
# For example, 1 means that the first column (first line from left), the last column (the first column from right), the first row (the first line from top) and the last row (the first line from bottom) will be checked.
#---------------
# thr (default 0.019607): The threshold of the difference between the checked line and the neighbour one.
# This threshold is applied for the non-filtered video.
#---------------
# thr1 (default 0.352941): The threshold of the difference between the checked line and the neighbour one.
# This threshold is applied for the prefiltered video.
#---------------
# left, top, right, bottom (default true): Whether the line from left, top, right, bottom will be checked.
#---------------
# debug (default false): Whether to display the difference between two lines.
# The first number is the difference from the non-filtered video.
# The second number is the difference from the prefiltered video.
#---------------
# show (default false): Whether to display only the already saved frames.
# It only has effect when debug=false.
#---------------
# prefilter (default """ApplyGradationCurves(lumaPoints="16,16,208,208,235,210").prefetch(2).solarCurve().prefetch(1).retinex_edgemask().prefetch(8)"""): The prefiltered video.
# If "": no prefiltered video.


# Info about the usage
/*
Usually you can firstly use debug=true: find frames with dirty lines (dark and bright) to see what is difference. The difference can be used as threshold.

Next step is to set `output` and set debug=false. Run the script in one of the following ways:
- avsr ( https://forum.doom9.org/showthread.php?t=173259 ): avsr(64) script_name.avs;
- avsmeter ( https://forum.doom9.org/showthread.php?t=174797 ): avsmeter(64) script_name.avs;
- ffmpeg: ffmpeg -i script_name.avs -f null - ;
- AvsPmod: Video->Tools->Run analysis pass.

When you have the saved frames set show=true to see only the saved frames.
*/


### Changelog ###
#---------------
# Disabled prefiltered video with prefilter="".
#---------------
# Changed the type of left, top, right, bottom.
# Added parameter n and prefilter.
# Removed w and h.
# Replaced tl, tt, tr, tb with thr, thr1.
#---------------
# Fixed right, bottom when debug=true.
# Changed default values for threshold.
# Added parameter show.
#---------------
# Initial version.


Function dldet(clip c, string "output", int "n", float "thr", float "thr1", bool "left", bool "top", bool "right", bool "bottom", bool "debug", bool "show", string "prefilter")
{
    Assert(!IsRGB(c) && IsPlanar(c), "dldet: the clip must be in YUV planar format.")
    Assert(ComponentSize(c) == 1, "dldet: convert to 8-bit before to use the filter.")

    y = ExtractY(c)

    left = Default(left, true)
    top = Default(top, true)
    right = Default(right, true)
    bottom = Default(bottom, true)
    debug = Default(debug, false)
    n = Default(n, 1)
    prefilter = Default(prefilter, """ ApplyGradationCurves(lumaPoints="16,16,208,208,235,210").prefetch(2).solarCurve().prefetch(1).retinex_edgemask().prefetch(8) """)

    Assert(n > 0, "dldet: n must be greater than 1.")

    if (debug)
    {
        sub = y

        if (left)
        {
            if (prefilter != """""")
            {
                bb2 = Eval(ContinuityFixer(y, left=n, radius=n+3), prefilter)

                sub = ScriptClip(sub, function [y, bb2, n]()
                {
                    return Subtitle(String(LumaDifference(Crop(y, n - 1, 0, 1, 0), Crop(y, n, 0, 1, 0))) + "\n" +\
                        String(LumaDifference(Crop(bb2, n - 1, 0, 1, 0), Crop(bb2, n, 0, 1, 0))), lsp=1, align=4)
                })
            }
            else
            {
                sub = ScriptClip(sub, function [y, n]()
                {
                    return Subtitle(String(LumaDifference(Crop(y, n - 1, 0, 1, 0), Crop(y, n, 0, 1, 0))), lsp=1, align=4)
                })
            }
        }
        if (top)
        {
            if (prefilter != """""")
            {
                bb2 = Eval(ContinuityFixer(y, top=n, radius=n+3), prefilter)

                sub = ScriptClip(sub, function [y, bb2, n]()
                {
                    return Subtitle(String(LumaDifference(Crop(y, 0, n - 1, 0, 1), Crop(y, 0, n, 0, 1))) + "\n" +\
                        String(LumaDifference(Crop(bb2, 0, n - 1, 0, 1), Crop(bb2, 0, n, 0, 1))), lsp=1, align=8)
                })
            }
            else
            {
                sub = ScriptClip(sub, function [y, n]()
                {
                    return Subtitle(String(LumaDifference(Crop(y, 0, n - 1, 0, 1), Crop(y, 0, n, 0, 1))), lsp=1, align=8)
                })
            }


        }
        if (right)
        {
            r = Width(y) - n

            if (prefilter != """""")
            {
                bb2 = Eval(ContinuityFixer(y, right=n, radius=n+3), prefilter)

                sub = ScriptClip(sub, function [y, bb2, r]()
                    {
                        return Subtitle(String(LumaDifference(Crop(y, r, 0, 1, 0), Crop(y, r - 1, 0, 1, 0))) + "\n"+\
                            String(LumaDifference(Crop(bb2, r, 0, 1, 0), Crop(bb2, r - 1, 0, 1, 0))), lsp=1, align=6)
                    })
            }
            else
            {
                sub = ScriptClip(sub, function [y, r]()
                    {
                        return Subtitle(String(LumaDifference(Crop(y, r, 0, 1, 0), Crop(y, r - 1, 0, 1, 0))), lsp=1, align=6)
                    })
            }
        }
        if (bottom)
        {
            b = Height(y) - n

            if (prefilter != """""")
            {
                bb2 = Eval(ContinuityFixer(y, bottom=n, radius=n+3), prefilter)

                sub = ScriptClip(sub, function [y, bb2, b]()
                    {
                        return Subtitle(String(LumaDifference(Crop(y, 0, b, 0, 1), Crop(y, 0, b - 1, 0, 1))) + "\n" +\
                            String(LumaDifference(Crop(bb2, 0, b, 0, 1), Crop(bb2, 0, b - 1, 0, 1))), lsp=1, align=2, y=Height()-18)
                    })
            }
            else
            {
                sub = ScriptClip(sub, function [y, b]()
                    {
                        return Subtitle(String(LumaDifference(Crop(y, 0, b, 0, 1), Crop(y, 0, b - 1, 0, 1))), lsp=1, align=2)
                    })
            }
        }

        return sub
    }
    else
    {
        show = Default(show, false)

        if (!show)
        {
            thr = Default(thr, 0.019607)
            thr1 = Default(thr1, 0.352941)
            leftp = (left) ? n : 0
            topp = (top) ? n : 0
            rightp = (right) ? n : 0
            bottomp = (bottom) ? n : 0

            if (n > 1)
            {
                n_ = n - 1
                cr = Crop(y, n_, n_, -n_, -n_)
            }
            else
            {
                cr = y
            }

            LinesLumaDiff(cr, output, left=leftp, top=topp, right=rightp, bottom=bottomp, tl=thr, tt=thr, tr=thr, tb=thr, flush=true)

            if (prefilter != """""")
            {
                bb2 = ContinuityFixer(cr, left=leftp, top=topp, right=rightp, bottom=bottomp, radius=3)
                bb2 = (Defined(prefilter)) ? (prefilter == """""") ? bb2 : Eval(bb2, prefilter) : ApplyGradationCurves(bb2, lumaPoints="16,16,208,208,235,210").prefetch(2).solarCurve().prefetch(1).retinex_edgemask().prefetch(8)

                bb2 = LinesLumaDiff(bb2, left=leftp, top=topp, right=rightp, bottom=bottomp, tl=thr1, tt=thr1, tr=thr1, tb=thr1)

                ScriptClip(function [bb2, output]()
                {
                    if (propGetType("LinesDiffLeft") == 0 && propGetType("LinesDiffTop") == 0 && propGetType("LinesDiffRight") == 0 && propGetType("LinesDiffBottom") == 0)
                    {
                        if (propGetType(bb2, "LinesDiffLeft") > 0)
                        {
                            RT_WriteFile(output, "%i %s %s", current_frame, "# left, diff:", String(propGetFloat(bb2, "LinesDiffLeft")), append=true)
                        }
                        else if (propGetType(bb2, "LinesDiffTop") > 0)
                        {
                            RT_WriteFile(output, "%i %s %s", current_frame, "# top, diff:", String(propGetFloat(bb2, "LinesDiffTop")), append=true)
                        }
                        else if (propGetType(bb2, "LinesDiffRight") > 0)
                        {
                            RT_WriteFile(output, "%i %s %s", current_frame, "# right, diff:", String(propGetFloat(bb2, "LinesDiffRight")), append=true)
                        }
                        else if (propGetType(bb2, "LinesDiffBottom") > 0)
                        {
                            RT_WriteFile(output, "%i %s %s", current_frame, "# bottom, diff:", String(propGetFloat(bb2, "LinesDiffBottom")), append=true)
                        }
                    }
                }, after_frame=true)
            }
        }
        else
        {
            FrameSel(c, cmd=output, show=true)

            return ScriptClip(function [output]()
                {
                    line_ = RT_ReadTxtFromFile(output, 1, current_frame)
                    line1_ = MidStr(line_, FindStr(line_, "#"))
                    Subtitle(RightStr(line1_, StrLen(line1_) - 2), x=2, y=24)
                }, after_frame=true)
        }
    }
}
