Function getnative_main(clip input, string "log", int "frame", string "kernel", float "b", float "c", int "taps", float "ar", int "min_height", int "max_height", int "stepping", string "temp_filename")
{
    log = (Defined(log)) ? (log + "\") : ScriptDir
    frame = Default(frame, FrameCount(input) / 3)
    kernel = Default(kernel, "bicubic")
    b = Default(b, 1.0 / 3)
    c = Default(c, 1.0 / 3)
    taps = Default(taps, 2)
    ar = Default(ar, 16.0 / 9.0)
    min_height = Default(min_height, 500)
    max_height = Default(max_height, 1000)
    stepping = Default(stepping, 1)
    temp_filename = Default(temp_filename, "")

    Assert(min_height <= max_height - 4, "getnative: the difference between min_height and max_height must be at least 4.")
    Assert(stepping >= 1, "getnative: stepping must be equal to or greater than 1.")

    a = (propGetInt(input, "_Matrix") == 0) ? z_ConvertFormat(input, pixel_type="y32", colorspace_op="rgb=>709", use_props=0)
        \ : z_ConvertFormat(input, pixel_type="y32")

    size = Float(Width(a)) / Height(a)

    if (kernel == "bicubic")
    {
        eval_string = "b=b, c=c"
    }
    else if (kernel == "lanczos")
    {
        eval_string = "taps=taps"
    }
    else
    {
        eval_string = ""
    }

    file_log = log + temp_filename + ".txt"

    prev_diff = 0.0

    for (i = min_height, max_height, stepping)
    {
        w = size <= ar ? RoundHalfToEven(i * size, mod=1) : RoundHalfToEven(i * ar, mod=1)
        h = size <= ar ? i : RoundHalfToEven(w / size, mod=1)
        Eval("De" + kernel + "(a, w, h, " + eval_string + ")")
        Eval("z_" + kernel + "Resize(Width(a), Height(a), " + eval_string + ")")

        current_frame = frame
        diff = LumaDifference(a)
        if (i > min_height)
        {
            prev_diff = diff
        }

        diff1 = (i == min_height) ? 0.0 : (prev_diff / diff)

        RT_WriteFile(file_log, "%i%s%i%s%s%s%s", w, "x", h, ",", String(diff), ",", String(diff1), append=true) # Resolution,Luma diff between src and test,Relative diff between previous and current tested resolution
    }
}
