### Detection for red and blue scenes, and for scene exopsure. The video is split by scenes and then every scene is used for the detection.

##### Required filters: RT_Stats, FrameSel, ScenesPack, mvtools2, RoboCrop, AutoResize, grunt.

###### Note: Use firstly a short sample to tune the threshold settings.

###### Steps to follow:

1. Keep settings.avs, sc.avs, det.avs, SCMC_.avs and scDet.bat together (whatever location you prefer).
2. Open settings.avs, and change the relevant settings.
3. Download avsr/avsmeter if you don't have it.\
Place avsr64/avsmeter64.exe in the same location where the files from 1. are or add it to the system path.
4. Open scDet.bat.\
By default folder sc_det will be created in the location where the video file is.\
File containing the scenes will be created in this new folder.\
For every scene there will be created a log file.\
Red and blue scenes detection - if mean/average of the U plane is greater than or equal to the `blue_thr` and mean/average of the V plane is greater than or equal to `red_thr`, the scene will be saved/appended in file "final.txt".\
Scene exposure detection - if the scene exposure matches the chosen `exposure` , the scene will be saved/appended in file "final.txt". Multiply exposure can be choosen - for example `exposure = [0, 1]` will save Very dark and Dark scenes.
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

"statsX.txt" files are the logs for every scene.\
The other file "XXX_SC.txt" contains the scene ranges of the video.\
