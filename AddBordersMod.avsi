#Due to MPEG-2 subsampling dirty lines / chroma bleeding could appear when AddBorders is used (more visible when the area is very saturared). This script should mitigate those effects.
#
#Usage: - AddBordersMod(clip c, int "left", int "top", int "right", int "bottom", float "lsat", float "tsat", float "rsat", float "bsat", int "color");
#- all parameters are optional;
#- lsat (left side, default 0.88), tsat (top, default 0.20), rsat (right side, default 0.2 for 2px borders / 0.4 for >2px borders), bsat (bottom, default 0.20) - those parameters control the saturation;
#- the default saturation values are set for extreme cases (solid colors) so for more real case scenario lsat=1, tsat=0.4/0.5, rsat=0.4/0.5 (for both cases: bordes > 2px and borders = 2px), bsat=0.4/0.5 should be a good starting point;
#- color parameter (default black);
#- only 4:2:0 color format is supported.


Function AddBordersMod(clip c, int "left", int "top", int "right", int "bottom", float "lsat", float "tsat", float "rsat", float "bsat", int "color")
{
    Assert(is420(c), "Only 4:2:0 color format is supported")

    left        = Default(left, 0)
    top         = Default(top, 0)
    right       = Default(right, 0)
    bottom      = Default(bottom, 0)
    lsat        = Default(lsat, 0.88)
    tsat        = Default(tsat, 0.20)
    rsat        = Default(rsat, right > 2 ? 0.4 : 0.28)
    bsat        = Default(bsat, 0.20)
    color       = Default(color, $000000)
    
    c
    left    > 0 ? lsat != 1 ? StackHorizontal(AddBorders(left, 0, 0, 0, color).crop(0, 0, left, 0), crop(0, 0, 2, 0).Tweak(sat=lsat), crop(2, 0, 0, 0)) : AddBorders(left, 0, 0, 0, color) : last
    top     > 2 ? StackVertical(AddBorders(0, top, 0, 0, color).crop(0, 0, 0, top-2), crop(0, 0, 0, 2).Tweak(sat=tsat).FixRBr(0, -100).FixRBr(1, -100), last) : top == 2 ? StackVertical(crop(0, 0, 0, 2).Tweak(sat=tsat).FixRBr(0, -100).FixRBr(1, -100), last) : last
    right   > 2 ? StackHorizontal(last, crop(width-2, 0, 0, 0).Tweak(sat=rsat).FixCBr(0,-100).FixCBr(1,-100), AddBorders(0, 0, right, 0, color).crop(width+2, 0, 0, 0)) : right == 2 ? StackHorizontal(last, crop(width-2, 0, 0, 0).Tweak(sat=rsat).FixCBr(0,-100).FixCBr(1,-100)) : last
    bottom  > 2 ? StackVertical(last, crop(0, height-2, 0, 0).Tweak(sat=bsat).FixRBr(0, -100).FixRBr(1, -100), AddBorders(0, 0, 0, bottom, color).crop(0, height+2, 0, 0)) : bottom == 2 ? StackVertical(last, crop(0, height-2, 0, 0).Tweak(sat=bsat).FixRBr(0, -100).FixRBr(1, -100)) : last
}