/*
This function is a port of the VapourSynth _IQA_downsample - https://github.com/WolframRhodium/muvsfunc/blob/master/muvsfunc.py#L3613

Downsampler for image quality assessment model.
The “clip” is first filtered by a 2x2 average filter, and then down-sampled by a factor of 2.
*/


### Requirements - RoundHalfToEven.

    
Function _IQA_downsample(clip c)
{
    return GeneralConvolution(c, matrix="1, 1, 0, 1, 1, 0, 0, 0, 0").z_PointResize(Int(RoundHalfToEven(Width(c) / 2.0)), Int(RoundHalfToEven(Height(c) / 2.0)), src_left=-1, src_top=-1)
}
