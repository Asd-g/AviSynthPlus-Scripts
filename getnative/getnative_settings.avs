Import("getnative.avs")


### Requirements ###
# AviSynth+ >= r4072
# avsresize
# RT_Stats
# RoundHalfToEven
# avsr64


/* set the source */
FFVideoSource("")

# Crop the video if needed
#Crop(0, 0, -0, -0)

/* set the log path */
log = "" # for e.g., "D:\Downloads"

/* specify a frame for the analysis */
frame = FrameCount() / 3

/* resize kernel to be used */
kernel = "bicubic"

/* b, c parameters if bicubic is used */
b = 1.0 / 3.0
c = 1.0 / 3.0

/* taps parameter if lanczos is used */
taps = 2

/* force aspect ratio */
ar = 16.0 / 9.0

/* minimum/maximum height to consider
max_height must be lower than the source */
min_height = 500
max_height = 1000

/* this changes the way getnative will handle resolutions.
Example stepping=3 [500p, 503p, 506p ...] */
stepping = 1
