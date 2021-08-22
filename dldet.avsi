/*
Helper function for finding black/dirty lines on the borders.

The difference between lines could be displayed or the frames above threshold could be saved in txt file.
*/


### Requirements - AviSynth+ >= 3.6, bbmod, solarCurve, LinesLumaDiff, RT_Stats.


### Usage ###
###
# dldet(clip c, string "output", int "left", int "top", int "right", int "bottom", float "tl", float "tt", float "tr", float "tb", int "width", int "height", bool "debug")
###
## Parameters ##
#---------------
# c: Input clip.
# Must be in YUV planar format.
#---------------
# output (default ""): The path of the txt file with frames.
# Must be specified for debug=false.
#---------------
# left, top, right, bottom: How many lines on each side will be checked.
# debug=false: Default left = top = right = bottom = 3.
# debug:true: Not defined. Only one side can be specified.
#---------------
# tl, tt, tr, tb (default 0.14): Threshold.
# debug=false: If the luma difference between the current and the neighbour line is above the threshold, the frame will be saved.
# Must be between 0.0 and 1.0.
#---------------
# width (default 220): The width used for difference cheking.
#---------------
# height (default 100): The height used for difference checking.
#---------------
# debug (default false): Whether to display the difference between the lines.



### Changelog ###
#---------------
# Initial version.



Function dldet(clip c, string "output", int "left", int "top", int "right", int "bottom", float "tl", float "tt", float "tr", float "tb", int "width", int "height", bool "debug")
{
    w = Default(width, 220) / 2
    h = Default(height, 100) / 2
    
    c
    StackVertical(Crop(0, 0, 0, h), Crop(0, Height() - h, 0, 0))
    StackHorizontal(Crop(0, 0, w, 0), Crop(Width() - w, 0, 0, 0))
    
    debug = Default(debug, false)
    
    if (debug)
    {
        Assert((Defined(left) && !Defined(top) && !Defined(right) && !Defined(bottom)) \
        || (Defined(top) && !Defined(left) && !Defined(right) && !Defined(bottom)) \
        || (Defined(right) && !Defined(left) && !Defined(top) && !Defined(bottom)) \
        || (Defined(bottom) && !Defined(left) && !Defined(top) && !Defined(right)), "dldet: When debug=true, only one from the arguments left, top, right, bottom must be defined.")
        
        y = solarCurve(ExtractY())
        peak = BitLShift(1, BitsPerComponent) - 1
        
        ScriptClip(function [top, bottom, left, right, y, peak]()
        {
            if (Defined(left)) { return Subtitle(String(LumaDifference(Crop(y, left, 0, 1, 0), Crop(y, left + 1, 0, 1, 0)) / peak), size=36) }
            if (Defined(top)) { return Subtitle(String(LumaDifference(Crop(y, 0, top, 0, 1), Crop(y, 0, top + 1, 0, 1)) / peak), size=36) }
            if (Defined(right)) { return Subtitle(String(LumaDifference(Crop(y, right, 0, 1, 0), Crop(y, right - 1, 0, 1, 0)) / peak), size=36) }
            if (Defined(bottom)) { return Subtitle(String(LumaDifference(Crop(y, 0, bottom, 0, 1), Crop(y, 0, bottom - 1, 0, 1)) / peak), size=36) }
        })
    }
    else
    {
        left = Default(left, 3)
        top = Default(top, 3)
        right = Default(right, 3)
        bottom = Default(bottom, 3)
        
        ExtractY()
        y = LinesLumaDiff(solarCurve(), left=left, top=top, right=right, bottom=bottom, tl=tl, tt=tt, tr=tr, tb=tb)
        bbmod(ctop=top, cbottom=bottom, cleft=left, cright=right, thresh=1, blur=1)        
        y1 = LinesLumaDiff(solarCurve(), left=left, top=top, right=right, bottom=bottom, tl=tl, tt=tt, tr=tr, tb=tb)
        
        ScriptClip(function [top, bottom, left, right, tl, tt, tr, tb, y, y1, output]()
        {
            y
            
            if (propGetType("_LinesDiff") > 0)
            {
                _prop = propGetFloat("_LinesDiff")
                y1
                
                if (_prop / propGetFloat("_LinesDiff") < 1.2)
                {
                    RT_WriteFile(output, "%i", current_frame, append=true)
                }
            }
        })
    }
}
