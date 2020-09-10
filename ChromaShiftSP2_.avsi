#ChromaShiftSP2: Shift U & V chroma separately with subpixel accuracy, based on the ChromaShiftSP function by IanB & McCauley
#High bit-depth support

function ChromaShiftSP2 (clip clp, float "UX",float "UY", float "VX",float "VY", string "ResizeMethod") {

UX = default(UX, 0.0) # positive values shift the U chroma to left, negative values to right
UY = default(UY, 0.0) # positive values shift the U chroma upwards, negative values downwards
VX = default(VX, 0.0) # positive values shift the V chroma to left, negative values to right
VY = default(VY, 0.0) # positive values shift the V chroma upwards, negative values downwards
ResizeMethod = Default(ResizeMethod, "Spline36")

L = clp.ExtractY()

U = clp.PlaneToY("U")
U = Eval("U." + ResizeMethod + "Resize(U.Width(), U.Height(), UX, UY, U.Width()+UX, U.Height()+UY)")

V = clp.PlaneToY("v")
V = Eval("V." + ResizeMethod + "Resize(V.Width(), V.Height(), VX, VY, V.Width()+VX, V.Height()+VY)")


CombinePlanes(L, U, V, planes="YUV", sample_clip=clp) }