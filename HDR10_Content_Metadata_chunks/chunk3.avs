Import("settings.avs")

chunk = BitShR(FrameCount(), 2)

Trim(chunk * 2 + 1, chunk * 3)
HDR10_Content_Metadata(log_path=log_path, MaxCLL=MaxCLL, MaxFALL=MaxFALL, MaxCLL_percentile=MaxCLL_percentile , MaxFALL_percentile=MaxFALL_percentile, temp_files_suffix="3", chunks=true)
