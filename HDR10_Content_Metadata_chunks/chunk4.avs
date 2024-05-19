Import("settings.avs")

chunk = BitShR(FrameCount(), 2)

Trim(chunk * 3 + 1, 0)
HDR10_Content_Metadata(log_path=log_path, MaxCLL=MaxCLL, MaxFALL=MaxFALL, MaxCLL_percentile=MaxCLL_percentile , MaxFALL_percentile=MaxFALL_percentile, temp_files_suffix="4", chunks=true)
