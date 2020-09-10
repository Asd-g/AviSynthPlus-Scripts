# FixChromaBleedingMod v1.351
# require SmoothLevels, ChromaShiftSP2
# High bit-depth support

Function FixChromaBleedingMod(clip input, int "cxShift", int "cyShift", float "thr", float "strength", float "opacity", bool "n")
{
	xShift = default ( cxShift,       -4 )
	yShift = default ( cyShift,       -4 )
	thr	 = default ( thr,         4.0 )
	stre = default ( strength,      0.8 )
	n =  default ( n,       false )
	opacity = default ( opacity,       1 )
	
	in8 = BitsPerComponent(input) == 8
	m = Pow(2, BitsPerComponent(input))-1
	v = Pow(2, BitsPerComponent(input) - 8)
	i = "i"
	b = String(BitsPerComponent(input))
	
	# prepare to work on the V channel
	vch  = in8 ? input.SmoothTweak(saturation = thr).VtoY8 : input.Tweak(sat = thr, dither = true).PlaneToY("V")
	area = n ? vch.Blur(1) : vch
	
	# select and normalize both extremes of the scale
	red = in8 ? area.SmoothLevels(254,1.0,255,255,0) : area.Levels(m,1.0,m,m,0, dither = true)
	blue = in8 ? area.SmoothLevels(0,1.0,1,0,255) : area.Levels(0,1.0,0,0,m, dither = true)
	
	# merge both masks
	maskc = n ? in8 ? MergeLuma(red, blue, 0.5).Blur(1).SmoothLevels(249,1.0,250,255,0) : MergeLuma(red, blue, 0.5).Blur(1).Levels(250*v,1.0,250*v,m,0, dither = true) : in8 ? MergeLuma(red, blue, 0.5).SmoothLevels(249,1.0,250,255,0) : MergeLuma(red, blue, 0.5).Levels(250*v,1.0,250*v,m,0, dither = true)
	
	# expand to cover beyond the bleeding areas and shift to compensate the resizing
	maskc = maskc.mt_edge("0 0 0 1 0 0 0 0 0", 0,255,0,255, paramscale = i+b).mt_edge("1 1 1 1 1 1 0 0 0", 0,255,0,255, paramscale = i+b)
	
	# binarize (also a trick to expand)
	maskc = in8 ? maskc.SmoothLevels(9,1.0,10,0,255).mt_inflate(paramscale = i+b) : maskc.Levels(10*v,1.0,10*v,0,m, dither = true).mt_inflate(paramscale = i+b)
	
	# prepare a version of the image that has its chroma shifted and less saturated
	input_c = in8 ? input.ChromaShiftSP2(ux = xShift, vx = xShift, uy = yShift, vy = yShift).SmoothTweak(saturation = stre) : input.ChromaShiftSP2(ux = xShift, vx = xShift, uy = yShift, vy = yShift).Tweak(sat = stre, dither = true)
	
	# combine both images using the mask
	fu = input.PlaneToY("U").overlay(input_c.PlaneToY("U"),mask=maskc,mode="blend",opacity=opacity)
	fv = input.PlaneToY("V").overlay(input_c.PlaneToY("V"),mask=maskc,mode="blend",opacity=opacity)
	return CombinePlanes(ExtractY(input), fu, fv, planes = "YUV", sample_clip = input)
}