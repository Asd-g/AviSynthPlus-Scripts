# set float for the default values instead convert int to float
# added high bit depth support
# V3 (all previous versions are buggy, please upgrade)
# Assumes MPEG-2 chroma placement for YV12, use Spline36Resize for MPEG-1 chroma placement.
 
function Spline36ResizeMod(clip c, int target_width, int target_height, float "src_left", float "src_top", float "src_width", float "src_height")
{
    Assert(Is420(c) || IsYV411(c), "Spline36ResizeMod: Supported color formats are YUV 4:2:0 and YV411.")

    src_left      = Default(src_left, 0.0)
    src_top       = Default(src_top, 0.0)
    src_width     = Default(src_width, 0.0)
    src_height    = Default(src_height, 0.0)

    src_width     = Max(src_width, Width(c) - src_left - Sign(src_width)*src_width) # Convert to equivalent positive src_width when src_width <= 0
    height_divide = (Is420(c) ? 2 : 1)
    width_divide  = (IsYV411(c) ? 4 : 2)
    u_plane       = ExtractU(c).Spline36ResizeMT(target_width/width_divide,target_height/height_divide,(-0.5*(width_divide-1)*((src_width/target_width)-1)+src_left)/width_divide,src_top/height_divide,src_width/width_divide,src_height/height_divide)
    v_plane       = ExtractV(c).Spline36ResizeMT(target_width/width_divide,target_height/height_divide,(-0.5*(width_divide-1)*((src_width/target_width)-1)+src_left)/width_divide,src_top/height_divide,src_width/width_divide,src_height/height_divide)
    y_plane       = ExtractY(c).Spline36ResizeMT(target_width,target_height,src_left,src_top,src_width,src_height)

    return CombinePlanes(y_plane, u_plane, v_plane, "YUV", pixel_type=PixelType(c))
}
