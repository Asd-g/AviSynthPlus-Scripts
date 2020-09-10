# Changelog:
# Added new optional parameters (s_width, s_height, resizer(default Lanczos4Resize)) for scenarios when sup resolution is different than video resolution. s_width, s_height , resize are options of the sup file. Example for 4K video:
#	- SupT("subtitle.sup") - 4K video and 4K resolution of the sup file
#	- SupT("subtitle.sup", s_width=1920, s_height=1080) - 4K video and 1080p resolution of the sup file


# Script for SupTitle http://avisynth.nl/index.php?title=SupTitle high bit-depth support.
# SupT(clip c, string filename, bool "forcedOnly", bool "swapCbCr", bool "relocate", string "relocOffset", int "radius", int "contrast")
# The same usage as SupTitle except "radius" (default=4) which controls mask radius and "contrast" (default=128), both have no effect for 8-bit video
# Support 8...32-bit video, requires SupTitle, dither. The options between "" are optional


Function SupT(clip c, string filename, bool "forcedOnly", bool "swapCbCr", bool "relocate", string "relocOffset", int "radius", int "contrast", int "s_width", int "s_height", string "resizer")
{
	forcedOnly = Default(forcedOnly, false)
	swapCbCr = Default(swapCbCr, false)
	relocate = Default(relocate, true)
	relocOffset = Default(relocOffset, "")
	radius = Default(radius, 4)
	contrast = Default(contrast, 128)
	s_width = Default(s_width, Width(c))
	s_height = Default(s_height, Height(c))
	resizer = Default(resizer, "z_Lanczos4Resize")
		
	c
	b = BitsPerComponent()
	b > 8 ? last : Assert(b == 8 && (radius == 4 && contrast == 128), "radius/contrast has effect only for 10...32 bit video")
	b == 8 ? BlankClip(length = FrameCount(), width = s_width, height = s_height, pixel_type = "YV12", fps = FrameRateNumerator(), fps_denominator = FrameRateDenominator(), audio_rate = 0).SupTitle(filename, forcedOnly, swapCbCr, relocate, relocOffset) : BlankClip(length = FrameCount(), width = s_width, height = s_height, pixel_type = "YV12", fps = FrameRateNumerator(), fps_denominator = FrameRateDenominator(), audio_rate = 0).SupTitle(filename, forcedOnly, swapCbCr, relocate, relocOffset).ConvertBits(b)
	subs = last
	b == 8 ? BlankClip(length = FrameCount(), width = s_width, height = s_height, pixel_type = "YV12", fps = FrameRateNumerator(), fps_denominator = FrameRateDenominator(), audio_rate = 0).SupTitle(filename, forcedOnly, swapCbCr, relocate, relocOffset).Dither_build_gf3_range_mask(radius) : BlankClip(length = FrameCount(), width = s_width, height = s_height, pixel_type = "YV12", fps = FrameRateNumerator(), fps_denominator = FrameRateDenominator(), audio_rate = 0).SupTitle(filename, forcedOnly, swapCbCr, relocate, relocOffset).Dither_build_gf3_range_mask(radius).ConvertBits(b)
	submask = last
	b == 8 ? s_height == Height(c) ? c.SupTitle(filename, forcedOnly, swapCbCr, relocate, relocOffset) : c.Overlay(subs.AutoResize(String(Height(c)), resizer), mask=ColorYUV(submask.AutoResize(String(Height(c)), resizer), cont_y = contrast)) : s_height == Height(c) ? c.Overlay(subs, mask=ColorYUV(submask, cont_y = contrast)) : c.Overlay(subs.AutoResize(String(Height(c)), resizer), mask=ColorYUV(submask.AutoResize(String(Height(c)), resizer), cont_y = contrast))
}