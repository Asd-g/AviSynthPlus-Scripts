################################
# MANDATORY SETTINGS
################################


# The location and the file name of the video
VideoFileName = "i:\video.mkv"

# The used source filter for loading the video file
source = FFVideoSource(VideoFileName)

# Crop the video if needed
#source = Crop(source, 0, 0, -0, -0)

# Trim the video if needed
#source = Trim(source, 0, 3000)


################################
################################

################################
# OPTIONAL SETTINGS
################################


# The location of the generated file containing the range of the scenes.
FolderName = RT_FilenameSplit(VideoFileName, 3) + "sc_det"

# The name of file containing the range of the scenes.
sceneChangeFile = RT_FilenameSplit(VideoFileName, 12) + "_SC.txt"


### SCENE CHANGE DETECTION RELATED

dFact = 1.5
dMinim = 4.0
dMinLen = 6

num_threads = Max(2, (Width(source) > 1920) ? (Int(Value(RT_GetSystemEnv("NUMBER_OF_PROCESSORS"))) / 4) : (Int(Value(RT_GetSystemEnv("NUMBER_OF_PROCESSORS"))) / 2 - 2))
num_threads1 = (Width(source) > 1920) ? 1 : (num_threads >= 8) ? 4 : (num_threads >= 4) ? 2 : 1

BLOCKSIZE = 12
thSCD1 = (BLOCKSIZE*BLOCKSIZE) * 64


### SCENE STATS RELATED


# Threshold for red scenes.
# Must be between 0..255.0.
# Higher values - the scenes must be more reddish.
red_thr = 138.0 # SDR
#red_thr = 130.0 # HDR


# Threshold for blue scenes.
# Must be between 0..255.0.
# Higher values - the scenes must be more blueish.
blue_thr = 138.0 # SDR
#blue_thr = 130.0 # HDR


# Mode.
# 0: Median value of the scene is used to determine if the scene is red/blue.
# 1: Average value of the scene is used to determine if the scene is red/blue.
# 2: The scene is checked for it's exposure.
mode = 0


# Scene exposure (only for SDR).
# Can be single number or array.
# 0: Very dark.
# 1: Dark.
# 2: Balanced.
# 3: Bright.
# 4: Very bright.
exposure = 1


################################
################################
