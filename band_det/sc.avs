Import("settings.avs")
Import("SCMC_.avs")

RT_Call("cmd /c mkdir " + FolderName, hide=true)
sceneChangeFile = FolderName + "\" + sceneChangeFile

# Create pre-processed detection dClip
src=(ComponentSize(source)>1) ? ConvertBits(source, 8) : source
src=autoresize(src,480, dither_type="none")
dclip=src.RoboCrop(WMod=4,Align=True,laced=false)  # Dont allow common border to 'water down' metrics or affect eg ColorYUV(AutoGain=true)
dclip=dclip.ColorYUV(AutoGain=True).prefetch(num_threads1)
# SCMC requires Motion Compensated Interleaved clip (3 times the number of frames in source clip)
# Might want to use Prefiltered (eg Blur) Super clip (although slower).
prefiltered = dclip.blur(1.0).prefetch(num_threads1)
superfilt   = prefiltered.MSuper(mt=false)         # all levels for MAnalyse
super       = dclip.MSuper(levels=1,mt=false)       # one level is enough for MCompensate
bvec        = superfilt.MAnalyse(isb = true, blksize=BLOCKSIZE,search=1,searchparam=1,mt=false)
fvec        = superfilt.MAnalyse(isb = false,blksize=BLOCKSIZE,search=1,searchparam=1,mt=false)
# use not-prefiltered (super) clip for motion compensation (Use MCompensate or MFlow)
#fcmp       = dclip.MFlow(super, fvec, thSCD1=thSCD1, thSCD2=255)
#bcmp       = dclip.MFlow(super, bvec, thSCD1=thSCD1, thSCD2=255)
fcmp        = dclip.MCompensate(super, fvec, thSCD1=thSCD1, thSCD2=255,mt=false)
bcmp        = dclip.MCompensate(super, bvec, thSCD1=thSCD1, thSCD2=255,mt=false)
dclip       = interleave(fcmp, dclip, bcmp).prefetch(num_threads) # Make FrameCount * 3
################################

return dclip.SCMC(src,src,src,dFact=dFact,dMinim=dMinim,dMinlen=dMinLen,ChromaW=0.1,Show=false,scFile=sceneChangeFile)
