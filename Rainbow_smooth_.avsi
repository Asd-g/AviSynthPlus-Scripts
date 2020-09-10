# Changelog:
# added optional parameter "mask" ("original", "hprewitt", "prewitt", "kirsch")


# rainbow_smooth is a small spatial derainbow function
# it use smoothuv to for chroma smoothing and reduce the colour-washing with edge masking
#
# needed filters:
#	- SmoothUV
#	- Masktools v2
#
# parameter description:
#	- radius
#			just the smoothing radius	[1...7  ->3]
#	- lthresh/hthresh
#			the low and the high smoothing threshold - use smaller values for saver processing
#			the masking is only used for hthresh, so if you set lthresh>hthresh lthresh will be
#			the overall thresh and no masking will be used (fastest)
#			but if you set lthresh<=0 you disable the basic chromasmoothing and use only the
#			chromasmoothing on edges		[0...255  ->0,220]
#
# links:
#	- http://avisynth.nl/index.php/SmoothUV
#	- http://forum.doom9.org/showthread.php?p=1025503


function rainbow_smooth(clip orig, int "radius", int "lthresh", int "hthresh", string "mask")
{
### parameters ###
radius	= default(radius, 3)
lthresh	= default(lthresh, 0)
hthresh	= default(hthresh, 220)
mask    = default(mask, "original")

Assert(radius >= 1 && radius <= 7, "rainbow_smooth: radius range is 1..7")
Assert(lthresh >= 0 && lthresh <= 255, "rainbow_smooth: lthresh range is 0..255")
Assert(hthresh >= 0 && hthresh <= 255, "rainbow_smooth: hthresh range is 0..255")
Assert(mask == "original" || mask == "hprewitt" || mask == "prewitt" || mask == "kirsch", "rainbow_smooth: mask avaiable options are: 'original', 'hprewitt', 'prewitt', 'kirsch'")

### masking string ###
WORK 	= "x y - 90 > 255 x y - 255 90 / * ?"

### process ###
lderain	= lthresh<1 ? orig : orig.SmoothUV(radius,lthresh,false)
hderain	= orig.SmoothUV(radius,hthresh,false)

mask == "original" ? mt_lutxy(orig.mt_expand(u=1,v=1),orig.mt_inpand(u=1,v=1),WORK,u=1,v=1) : NOP()
mask == "hprewitt" ? mt_edge(orig, mode="hprewitt") : NOP()
mask == "prewitt" ? mt_edge(orig, mode="prewitt") : NOP()
mask == "kirsch" ? Kirsch(orig) : NOP()

hthresh>lthresh ? mt_merge(lderain,hderain,FrameEvaluate("mask"),luma=true,y=2) : lderain

return last
}