Import("settings.avs")

sceneChangeFile = FolderName + "\" + sceneChangeFile
final_file = FolderName + "\" + "final.txt"

if (BitsPerComponent(source) > 8)
{
    source = ConvertBits(source, 8, dither=-1)
}


#  Banding detection

for (i = 0, RT_FileQueryLines(sceneChangeFile) - 1)
{
    FrameSel(source, RT_ReadTxtFromFile(sceneChangeFile, 1, i))

    propSet("_SceneRange", [0, FrameCount() - 1])
    ScriptClip(""" propSet("_SceneChangePrev", (current_frame == 0) ? 1 : 0) """)

    if (mode == 2)
    {
        exposure = (IsArray(exposure)) ? exposure : [exposure]

        SceneStats("range+exposure")
        RT_WriteFile(FolderName + "\" + "stats" + string(i) + ".txt", "%i", propGetInt("_SceneExposure"), append=true)

        for (j = 0, ArraySize(exposure) - 1)
        {
            if (propGetInt("_SceneExposure") == exposure[j])
            {
                RT_TxtWriteFile(RT_ReadTxtFromFile(sceneChangeFile, 1, i), final_file, true)
            }
        }
    }
    else
    {
        mode = (mode == 0) ? 5 : 4

        SceneStats("stats", y=false, uv=true, interval=0.0)
        RT_WriteFile(FolderName + "\" + "stats" + string(i) + ".txt", "%f / %f", propGetAsArray("_SceneStatsU")[mode], propGetAsArray("_SceneStatsV")[mode], append=true)

        if (propGetAsArray("_SceneStatsV")[mode] >= red_thr && propGetAsArray("_SceneStatsU")[mode] < 128.0)
        {
            if (propGetAsArray("_SceneStatsU")[mode] < 100.0)
            {
                if (red_thr >= 179.0)
                {
                    RT_TxtWriteFile(RT_ReadTxtFromFile(sceneChangeFile, 1, i), final_file, true)
                }
            }
            else
            {
                RT_TxtWriteFile(RT_ReadTxtFromFile(sceneChangeFile, 1, i), final_file, true)
            }
        }

        if (propGetAsArray("_SceneStatsU")[mode] >= blue_thr && propGetAsArray("_SceneStatsV")[mode] < 128.0)
        {
            if (propGetAsArray("_SceneStatsV")[mode] < 100.0)
            {
                if (blue_thr >= 179.0)
                {
                    RT_TxtWriteFile(RT_ReadTxtFromFile(sceneChangeFile, 1, i), final_file, true)
                }
            }
            else
            {
                RT_TxtWriteFile(RT_ReadTxtFromFile(sceneChangeFile, 1, i), final_file, true)
            }
        }
    }
}

MessageClip("All done.")
