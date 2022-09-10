### 1.0.0


/*
f3kdb with a simple prefilter by mawen1250 - https://www.nmm-hd.org/newbbs/viewtopic.php?f=7&t=1495#p12163 / https://pastebin.com/Uc4zDfNv.
Since the prefilter is a straight gaussian+average blur, f3kdb's effect becomes very strong, very fast.
Functions more or less like gradfun3 without the detail mask.
*/


### Requirements - AviSynth+ 3.6+, RgTools, masktools2, neo_f3kdb, MasksPack.


### Usage ###
###
# f3kpf(clip src, int "range", int "y", int "c", float "thr", float "elast", bool "tv_range", string "f3kdb_arg", string "limit_arg")
###
## Parameters ##
#---------------
# src: Input clip.
# Must be in Y/YUV 8..16-bit planar format.
#---------------
# range (default min(30, max((Width(src) - 1280) / 160 + 12, (Height(src) - 720) / 90 + 12, 8))): neo_f3kdb banding detection range.
#---------------
# y (default 40): neo_f3kdb banding detection threshold for Y.
# Set this to 0 to copy the src luma.
#---------------
# c (default 40): neo_f3kdb banding detection threshold for U and V.
# Set this to 0 to copy the src chroma.
#---------------
# thr (default 0.3): ex_limitdif thershold.
#---------------
# elast (default 2.5): ex_limitdif elast.
#---------------
# tv_range (default true): neo_f3kdb keep_tv_range.
#---------------
# f3kdb_arg (default non-specified): neo_f3kdb additional arguments.
#---------------
# limit_arg (default non-specified): ex_limitdif additional arguments.


### Changelog ###
#---------------
# Initial version.


Function f3kpf(clip src, int "range", int "y", int "c", float "thr", float "elast", bool "tv_range", string "f3kdb_arg", string "limit_arg")
{
    range = Default(range, min(30, max((Width(src) - 1280) / 160 + 12, (Height(src) - 720) / 90 + 12, 8)))
    y = Default(y, 40)
    c = Default(c, 40)
    thr = Default(thr, 0.3)
    elast = Default(elast, 2.5)
    tv_range = Default(tv_range, true)

    yp = y > 0
    cp = c > 0
    y31 = (yp) ? 3 : 1
    c31 = (cp) ? 3 : 1

    rg = RemoveGrain(src, (yp) ? 11 : -1, (cp) ? 11 : -1)
    rg = RemoveGrain(rg, (yp) ? 20 : -1, (cp) ? 0 : -1)
    noise = mt_makediff(src, rg, y=y31, u=c31, v=c31)
    rg = mt_makediff(src, noise, y=y31, u=c31, v=c31)

    smooth = (Defined(f3kdb_arg)) ? Eval("neo_f3kdb(rg, "+ string(range) +", "+ string(y) +", "+ string(c) +", "+ string(c) +", "+ string(0) +", "+ string(0) +", keep_tv_range="+ string(tv_range) +", "+ f3kdb_arg +")") :
        \ neo_f3kdb(rg, range, y, c, c, 0, 0, keep_tv_range=tv_range)


    if ((thr) > 0)
    {
        smooth = (Defined(limit_arg)) ? Eval("ex_limitdif(smooth, rg, thr="+ string(thr) +", elast="+ string(elast) +", y="+ string(y31) +", uv="+ string(c31) +", "+ limit_arg +")") :
            \ ex_limitdif(smooth, rg, thr=thr, elast=elast, y=y31, uv=c31)
    }

    output = mt_adddiff(smooth, noise, y=y31, u=c31, v=c31)

    return (!yp) ? MergeLuma(output, src) : (!cp) ? MergeChroma(output, src) : output
}
