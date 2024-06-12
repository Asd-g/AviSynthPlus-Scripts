Import("getnative_settings.avs")

final_log = log + "\getnative_result.txt"
if (kernel == "bicubic")
{
    RT_WriteFile(final_log, "%s%f%s%f", "Resize Kernel: bicubic b ", b, " c ", c)
}
else if (kernel == "lanczos")
{
    RT_WriteFile(final_log, "%s%i", "Resize Kernel: lanczos taps ", taps)
}
else
{
    RT_WriteFile(final_log, "%s%s", "Resize Kernel: ", kernel)
}

concat_log = ""
for (i = 1, 4)
{
    file = log + "\getnative_" + String(i) + ".txt"
    concat_log = concat_log + RT_ReadTxtFromFile(file)
}

parsed_log = []
for (i = 0, RT_TxtQueryLines(concat_log) - 1)
{
    string_ = RT_TxtGetLine(concat_log, i)
    parsed_log = ArrayAdd(parsed_log, Value(RightStr(string_, StrLen(string_) - FindStr(string_, ","))))
}

relative_diff = [[parsed_log[0], 0.0]]
diff = [0.0]
for (i = 1, ArraySize(parsed_log) - 1)
{
    rel_diff = parsed_log[i - 1] / parsed_log[i]
    relative_diff = ArrayAdd(relative_diff, [parsed_log[i], rel_diff])
    diff = ArrayAdd(diff, rel_diff)
}

sorted_diff = ArraySort(diff)
biggest_diff = sorted_diff[ArraySize(sorted_diff) - 1]

found_luma_diff = 0.0
for (i = 0, ArraySize(relative_diff) - 1)
{
    if (biggest_diff == relative_diff[i][1])
    {
        found_luma_diff = relative_diff[i][0]
    }
}

best_resolution = RT_TxtGetLine(concat_log, RT_TxtFindStr(concat_log, String(found_luma_diff)))

RT_WriteFile(final_log, "%s%s", "Native resolution(s) (best guess): ", LeftStr(best_resolution, FindStr(best_resolution, ",") - 1), append=true)
RT_WriteFile(final_log, "%s", "Please check the graph manually for more accurate results", append=true)
