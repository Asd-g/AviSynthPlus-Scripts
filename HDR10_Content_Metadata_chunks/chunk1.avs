Import("settings.avs")

chunk = BitShR(FrameCount(), 2)

Trim(0, chunk)
HDR10_Content_Metadata(log_path=log_path, MaxCLL=MaxCLL, MaxFALL=MaxFALL, MaxCLL_percentile=MaxCLL_percentile , MaxFALL_percentile=MaxFALL_percentile, temp_files_suffix="1", chunks=true)
