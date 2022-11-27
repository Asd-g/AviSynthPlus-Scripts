# ChromaShiftSP2: Shift U & V chroma separately with subpixel accuracy, based on the ChromaShiftSP function by IanB & McCauley
# https://forum.doom9.org/showthread.php?p=1851933#post1851933


### Changelog ###
#---------------
# Fix incorrect shifting.
#---------------
# Changed UX/UY/VX/VY from chroma pixels to luma pixels.
#---------------
# Added high bit-depth support.


Function ChromaShiftSP2 (clip clp, float "UX",float "UY", float "VX",float "VY", string "ResizeMethod")
{
    UX = default(UX, 0.0) # positive values shift the U chroma to left, negative values to right
    UY = default(UY, 0.0) # positive values shift the U chroma upwards, negative values downwards
    VX = default(VX, 0.0) # positive values shift the V chroma to left, negative values to right
    VY = default(VY, 0.0) # positive values shift the V chroma upwards, negative values downwards
    ResizeMethod = Default(ResizeMethod, "Spline36")

    ucw = (Is420(clp) || Is422(clp)) ? UX / 2.0 : UX
    uch = (Is444(clp) || Is422(clp)) ? UY : UY / 2.0
    vcw = (Is420(clp) || Is422(clp)) ? VX / 2.0 : VX
    vch = (Is444(clp) || Is422(clp)) ? VY : VY / 2.0

    uvw = (!Is444(clp)) ? Width(clp) / 2 : Width(clp)
    uvh = (Is420(clp)) ? Height(clp) / 2 : Height(clp)

    U = ExtractU(clp).Eval(+ ResizeMethod + "Resize(uvw, uvh, src_left=ucw, src_top=uch)")
    V = ExtractV(clp).Eval(+ ResizeMethod + "Resize(uvw, uvh, src_left=vcw, src_top=vch)")

    Return CombinePlanes(clp, U, V, planes="YUV", source_planes="YYY", sample_clip=clp)
}
