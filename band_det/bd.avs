Import("settings.avs")

sceneChangeFile = FolderName + "\" + sceneChangeFile
final_file = FolderName + "\" + "final.txt"
zero_value = FolderName + "\" + "scene_cambi_zero.txt"

source = (VarExist("source1")) ? source1 : source
opt = "topk=" + String(topk) + " tvi_threshold=" + String(tvi_threshold) + " eotf=" + eotf + " max_log_contrast=" + String(max_log_contrast)

#  Banding detection

for (i = 0, RT_FileQueryLines(sceneChangeFile) - 1)
{
    FrameSel(source, RT_ReadTxtFromFile(sceneChangeFile, 1, i))
    cambi_fn = FolderName + "\" + "cambi" + string(i) + ".txt"
    vmaf(last, cambi_fn, feature=5, cambi_opt=opt) # lower topk gives more weight of the scenes with fast motion, higher tvi_threshold expands the used luma range
    RT_ForceProcess(debug=false)
    MessageClip("release the clip...")
    AllFileString = RT_ReadTxtFromFile(cambi_fn, Lines=0, Start=RT_FileFindStr(cambi_fn, "mean"))

    if (check == "mix")
    {
        thresh_ = Value(RightStr(MidStr(AllFileString, RT_FindStr(AllFileString, "mean"), 14), 8))
        if (thresh_ == 0.0)
        {
            RT_TxtWriteFile(RT_ReadTxtFromFile(sceneChangeFile, 1, i), zero_value, true)
        }
        else if (threshoold <= thresh_ || (thresh_ > 0.1 && thresh_ / Value(RightStr(MidStr(AllFileString, RT_FindStr(AllFileString, "harmonic_mean"), 23), 8)) > 2.0) ||
            \ (thresh_ > 1.0 && Value(RightStr(MidStr(AllFileString, RT_FindStr(AllFileString, "max"), 13), 8)) >= threshoold))
        {
            RT_TxtWriteFile(RT_ReadTxtFromFile(sceneChangeFile, 1, i), final_file, true)
        }
    }
    else if (check == "mean")
    {
        thresh_ = Value(RightStr(MidStr(AllFileString, RT_FindStr(AllFileString, "mean"), 14), 8))
        if (thresh_ == 0.0)
        {
            RT_TxtWriteFile(RT_ReadTxtFromFile(sceneChangeFile, 1, i), zero_value, true)
        }
        if (threshoold <= thresh_)
        {
            RT_TxtWriteFile(RT_ReadTxtFromFile(sceneChangeFile, 1, i), final_file, true)
        }
    }
    else if (check == "harmonic_mean")
    {
        thresh_ = Value(RightStr(MidStr(AllFileString, RT_FindStr(AllFileString, "harmonic_mean"), 23), 8))
        if (thresh_ == 0.0)
        {
            RT_TxtWriteFile(RT_ReadTxtFromFile(sceneChangeFile, 1, i), zero_value, true)
        }
        if (threshoold <= thresh_)
        {
            RT_TxtWriteFile(RT_ReadTxtFromFile(sceneChangeFile, 1, i), final_file, true)
        }
    }
    else
    {
        thresh_ = Value(RightStr(MidStr(AllFileString, RT_FindStr(AllFileString, "max"), 13), 8))
        if (thresh_ == 0.0)
        {
            RT_TxtWriteFile(RT_ReadTxtFromFile(sceneChangeFile, 1, i), zero_value, true)
        }
        if (threshoold <= thresh_)
        {
            RT_TxtWriteFile(RT_ReadTxtFromFile(sceneChangeFile, 1, i), final_file, true)
        }
    }
}

MessageClip("All done.")
