Import("settings.avs")

if (MaxCLL)
{
    pass1_max = ""
    for (i = 1, 4)
    {
        file = log_path + "\pass1_max" + String(i) + ".txt"
        pass1_max_file = RT_ReadTxtFromFile(file)
        pass1_max = pass1_max + pass1_max_file
        RT_FileDelete(file)
    }

    sorted_pass = RT_TxtSort(pass1_max)
    max_ = RT_TxtGetLine(sorted_pass, (MaxCLL_percentile < 100.0) ? RoundHalfToEven((MaxCLL_percentile / 100.0) * (RT_TxtQueryLines(sorted_pass) - 1))
        \ : RT_TxtQueryLines(sorted_pass) - 1)

    RT_WriteFile(log_path + (MaxFALL ? "\HDR10_Content_Metadata.txt" : "\HDR10_Content_Metadata_MaxCLL.txt"), "%s%f%s%i", "MaxCLL: ", Value(max_) * 10000, " at frame ", RT_TxtFindStr(pass1_max, max_))
}
if (MaxFALL)
{
    pass1_avg = ""
    for (i = 1, 4)
    {
        file = log_path + "\pass1_avg" + String(i) + ".txt"
        pass1_avg_file = RT_ReadTxtFromFile(file)
        pass1_avg = pass1_avg + pass1_avg_file
        RT_FileDelete(file)
    }

    sorted_pass = RT_TxtSort(pass1_avg)
    max_avg = RT_TxtGetLine(sorted_pass, (MaxFALL_percentile < 100.0) ? RoundHalfToEven((MaxFALL_percentile / 100.0) * (RT_TxtQueryLines(sorted_pass) - 1))
        \ : RT_TxtQueryLines(sorted_pass) - 1)

    RT_WriteFile(log_path + (MaxCLL ? "\HDR10_Content_Metadata.txt" : "\HDR10_Content_Metadata_MaxFALL.txt"), "%s%f%s%i", "MaxFALL: ", Value(max_avg) * 10000, " at frame ", RT_TxtFindStr(pass1_avg, max_avg), append=(MaxCLL ? true : false))
}

return MessageClip("Done.")
