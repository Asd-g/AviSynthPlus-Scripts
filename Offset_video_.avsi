# Changelog:
# made parameters x, y optional; use crop+addborders(mod) because is a bit faster then manipulating and stacking the frame; file renamed to Offset_video_.avsi; added new optional options: bool "AddBorders" (true), bool "AddBordersMod" (false), float "lsat" (0.88), float "tsat" (0.20), float "rsat" (0.4 when x > 2, otherwise 0.28), float "bsat" (0.20) (see AddBordesMod for lsat, tsat, rsat, bsat description)


# This function allows you to offset the video horizontal or vertical and the pixels that get cut off are placed on the opposite side.
# limitation: the offset has to be mod2.
# https://forum.doom9.org/showthread.php?t=178671


function Offset_video(clip clp, int "x", int "y", bool "AddBorders", bool "AddBordersMod", float "lsat", float "tsat", float "rsat", float "bsat")
{
x = Default(x, 0)
y = Default(y, 0)

Assert(Abs(x) < clp.width,  "Offset_video: Abs(x) must be smaller then the clip width")
Assert(Abs(y) < clp.height, "Offset_video: Abs(y) must be smaller then the clip height")

AddBorders    = Default(AddBorders, Defined(AddBordersMod) && AddBordersMod ? false : true)
AddBordersMod = Default(AddBordersMod, AddBorders ? false : true)
lsat          = Default(lsat, 0.88)
tsat          = Default(tsat, 0.20)
rsat          = Default(rsat, x > 2 ? 0.4 : 0.28)
bsat          = Default(bsat, 0.20)

x > 0 && AddBorders ?    clp.Crop(x, 0, 0, 0).AddBorders(0, 0, x, 0) : \
x > 0 && AddBordersMod ? clp.Crop(x, 0, 0, 0).AddBordersMod(0, 0, x, 0, rsat=rsat) : \
x < 0 && AddBorders ?    clp.AddBorders(Abs(x), 0, 0, 0).Crop(0, 0, x, 0) : \
x < 0 && AddBordersMod ? clp.AddBordersMod(Abs(x), 0, 0, 0, lsat=lsat).Crop(0, 0, x, 0) : \
y > 0 && AddBorders ?    clp.Crop(0, y, 0, 0).AddBorders(0, 0, 0, y) : \
y > 0 && AddBordersMod ? clp.Crop(0, y, 0, 0).AddBordersMod(0, 0, 0, y, bsat=bsat) : \
y < 0 && AddBorders ?    clp.AddBorders(0, Abs(y), 0, 0).Crop(0, 0, 0, y) : \
y < 0 && AddBordersMod ? clp.AddBordersMod(0, Abs(y), 0, 0, tsat=tsat).Crop(0, 0, 0, y) : \
clp
}
