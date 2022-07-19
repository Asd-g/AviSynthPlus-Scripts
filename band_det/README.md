### Banding detection with CAMBI. The video is split by scenes and then every scene is used for the detection.

##### Required filters: RT_Stats, FrameSel, VMAF, mvtools2, RoboCrop, AutoResize, grunt.

###### Note: Use firstly a short sample with banding to tune the cambi settings.

###### Note1: For HDR video you need to change in "BANDING DETECTION RELATED" section in settings.avs: `threshoold`, `tvi_threshold`, `eotf`.

###### Steps to follow:

1. Keep settings.avs, sc.avs, bd.avs, SCMC_.avs and bandDet.bat together (whatever location you prefer).
2. Open settings.avs, and change the relevant settings.
3. Download avsr/avsmeter if you don't have it.\
Place avsr64/avsmeter64.exe in the same location where the files from 1. are or add it to the system path.
4. Open bandDet.bat.\
By default folder band_det will be created in the location where the video file is.\
File containing the scenes will be created in this new folder.\
For every scene cambi will run and it will create a log file.\
If mean/max is 0, there will be file "scene_cambi_zero.txt". Too high "tvi_threshold" could be the reason for cambi metrics to be 0. Other reason could be grainy video. It's recommend this scene (cambi metrics 0) to be checked manually.\
If mean/max is above the threshold, the scene will be saved/appended in file "final.txt".
5. After the process complete:

- if there is "final.txt", you can:
    - load all scenes from "final.txt":
        ```
        source
        FrameSel(cmd="path_to_final.txt", show=true)
        ```
    - load specific scene from "final.txt":
        ```
        source
        sc = RT_ReadTxtFromFile("path_to_final.txt", 1, x) # x - the number of the line with the scene (starting from 0)
        FrameSel(scmd=sc, show=true)
        ```
    - load the source with filered only the frames from "final.txt"
        ```
        source
        fr = FrameSel(cmd="path_to_final.txt").some_filter # some_filter is applied only for the scenes in "final.txt"
        FrameRep(fr, cmd="path_to_final.txt", show=true) # return full video with the filtered scenes from above line. show=true will display subtitle with the frame number and the filtered scenes will have additional text ("Using x")
        ```

##### Info about the rest created files:

"cambiX.txt" files are the logs from cambi for every scene.\
At the bottom of these files there is `<metric name="cambi" min="xxx" max="xxx" mean="xxx" harmonic_mean="xxx" />`.\
The rest lines are metrics for every single frame in the scene.\
Higher score - more likely there is visible banding.\
The other file "XXX_SC.txt" contains the scene ranges of the video.\
