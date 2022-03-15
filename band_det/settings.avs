################################
# MANDATORY SETTINGS
################################


# The location and the file name of the video
VideoFileName = "i:\Video.mkv"

# The used source filter for loading the video file
source = FFVideoSource(VideoFileName)

# Crop the video if needed
#source = Crop(source, 0, 0, -0, -0)

# Trim the video if needed
#source = Trim(source, 0,-1000)

# Resize the video if the final resolution for encoding is different
#source1 = source.Resizer(x, y)


################################
################################

################################
# OPTIONAL SETTINGS (Usually you shouldn't change it because defaults should be ok)
################################


# The location of the generated file containing the range of the scenes
FolderName = RT_FilenameSplit(VideoFileName, 3) + "band_det"

# The name of file containing the range of the scenes
sceneChangeFile = RT_FilenameSplit(VideoFileName, 12) + "_SC.txt"


### SCENE CHANGE DETECTION RELATED

dFact = 1.5
dMinim = 4.0
dMinLen = 6

num_threads = Max(2, (Width(source) > 1920) ? (Int(Value(RT_GetSystemEnv("NUMBER_OF_PROCESSORS"))) / 4) : (Int(Value(RT_GetSystemEnv("NUMBER_OF_PROCESSORS"))) / 2 - 2))
num_threads1 = (Width(source) > 1920) ? 1 : (num_threads >= 8) ? 4 : (num_threads >= 4) ? 2 : 1

BLOCKSIZE = 12
thSCD1 = (BLOCKSIZE*BLOCKSIZE) * 64


### BANDING DETECTION RELATED


# If CAMBI mean of the scene or max of the frame from the scene is above this threshold, the scene will be saved
threshoold = 4.0

# Whether the threshold is compared to 'main' or 'max'
# If 'mean' is chosen, there is an additional check - if the CAMBI mean is > 0.1 and if 'mean / harmonic_mean > 2.0' the scene will be saved.
check = "mean"


################################
################################
