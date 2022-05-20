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
# For HDR video - always resize to 1080.
#source1 = source.Resizer(x, y)


################################
################################

################################
# OPTIONAL SETTINGS
################################


# The location of the generated file containing the range of the scenes.
FolderName = RT_FilenameSplit(VideoFileName, 3) + "band_det"

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


### BANDING DETECTION RELATED


# If CAMBI mean/harmonic_mean of the scene or max of the frame from the scene is above this threshold, the scene will be saved.
# If EOTF is 'pq', lower value would be better (4.0).
threshoold = 5.0

# Whether the threshold is compared to 'mean', 'harmonic_mean', 'max' or 'mix'.
check = "mix"

# Lower values give more weight of the scenes with fast motion.
topk = 0.5

# Lower values give more weight of the dark areas/frames.
# If EOTF is 'pq', lower value should be used (0.01).
tvi_threshold = 0.019

# The EOTF used to compute the visibility thresholds.
# Possible values: bt1886 and pq.
eotf = "bt1886"


################################
################################
