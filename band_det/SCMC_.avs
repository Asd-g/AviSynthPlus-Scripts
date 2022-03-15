### Modified for banding detection
# https://forum.doom9.org/showthread.php?p=1728841#post1728841


###############################
# SCMC.avs
# SCMC by StainlessS. Requires RT_Stats
###############################

Function SCMC(clip dclip,clip start,clip end,clip motion,float "dFact",float "dMinim",int "dMinLen", Float "ChromaW",bool "Show",string "scFile") {
/*
 Selects frames depending upon scene change status. Similar-ish to SCSelect().
 Start and End of scene frames detected strictly in pairs, detects on End Of Scene frame.
 Requires pre-prepared MC Interleaved dclip (detection clip) where FrameCount is 3x Motion clip Framecount.

 Multi-Instance capable, Can use multiple instances of this script function despite use of Global Variables.
  Many Thanks to Martin53 and Gavino for development of multi-instance runtime scripts.

 dclip, detection clip. mvTools Interleaved MC clip, 3x number of frames in Motion clip else error.
   Can be different Colorspace, size etc to Motion, Start and End clips.
 Start clip, Frames to use at frame after scene change.
 End clip, Frames to use at frame before scene change.
 Motion clip, Frames for Not a scene change.
   Start, End and Motion must be same size and colorspace, Should all be same length but no check on this.

  dFact, Default 2.0 (greater than 1.0)
  dMinim, Default 2.0, (greater than 0.1) dFact and dMinim , Control how much bigger difference between Curr->Next has to be compared to Prev->Curr
   and Curr->Next to [Next->Next+1], to detect scene change.
   Curr->Next has to be greater than (dFact * 'Prev->Curr' + dMinim), and also greater than (dFact * 'Next->Next+1' + dMinim)
  dMinLen, Default 6 (greater than 1). Minimum frame length of current scene that qualifies for scene change detection.
  ChromaW, Default 0.333333 ChromaWeight range 0.0->1.0. YUV Only, default gives twice as much weight to luma as combined chroma.
  Show, Default False. Show metrics.

 Metrics:
   Row 3 shows difference metrics between interleaved dclip frames, and Row 2 shows "FC->CURR : CURR->BC : FC->NXT : NXT->BC".
     Where row 3 metrics are:-
        FC->Curr is the difference between Forward Compensated previous frame to Current frame.
        Curr->BC is the difference between Current Frame and Backward Compensated Next frame.
        FC->Nxt is the difference between Forward Compensated Current frame and Next frame.
        Nxt->BC is the difference between Next Frame and Backward Compensated 'Next+1' frame.

   Three 'T' conditions must be satified for an End Of Scene to be detected (and therefore the following Start Of Scene, matched pairs only).
    T1) Current Scene must be at least dMinLen frames long.
    T2) 'CURR->BC' diff must be greater than (dFact * 'FC->CURR' + dMinim).
    T3) 'FC->NXT'  diff must be greater than (dFact * 'NXT->BC' + dMinim).
   The True/False (T/F) flags in Row 1 show result of above conditions, in left to right order T1 -> T3.
   dFactHint, also shown on Row 1 is "dFactHint', assists choosing dFact arg (given current dMinim setting).
      dFactHint useful to perhaps lower dFact when currently on last frame in scene that fails to detect scene change.
      dFactHint shows the highest value of dFact that could pass both T2 and T3 conditions,
      0.0 means no setting of dFact could pass T2 and T3 conditions. If dFactHint shows 0.0 on non-detected End of Scene frame, then
      this would suggest that dMinim could be set too high.
      9999.99 means any dFact setting above 1.0 would pass T2 and T3 conditions. (FC->CURR and NXT->BC are so small that
        anything would work). dFactHint does not take T1 condition into account, will be set regardless of whether current Scene is
        dMinLen frames long or not.
      dFactHint is only meaningful on a true End Of Scene frame, whether detected as such or not.
*/
    myName="SCMC: "
    #Assert(RT_FunctionExist("GScriptClip"),myName+"Essential GRunT plugin installed, http://forum.doom9.org/showthread.php?t=139337")
    #Assert(RT_FunctionExist("GScript"),myName+"Essential GScript plugin installed, http://forum.doom9.org/showthread.php?t=147846")
    dFact=Float(Default(dFact,2.0))
    dminim=Float(Default(dMinim,2.0))
    dMinLen=Default(dMinLen,6)
    ChromaWeight=Float(Default(ChromaW,1.0/3.0))
    Show=Default(Show,False)   # True = Show metrics (Default False)
    scFile=Default(scFile, "")
    Assert(dFact>1.0,myName+"dFact MUST be greater than 1.0")
    Assert(dMinim>0.1,myName+"dMinim MUST be greater than 0.1")
    Assert(dMinLen>1,myName+"dMinLen MUST be greater than 1")
    Assert(dclip.FrameCount==3*Motion.FrameCount,myName+"dClip FrameCount Must be 3x Motion Framecount")

    SIZE = Motion.Height / 8
    CENT = Motion.Height / 2
    Start =(Show) ? Start.SubTitle("START OF SCENE",align=5,size=SIZE,y=CENT-SIZE,Text_Color=$00FF00)  : Start
    End   =(Show) ? End.SubTitle("END OF SCENE",align=5,size=SIZE,y=CENT+SIZE,Text_Color=$FF00FF)      : End
    Motion=(Show) ? Motion.SubTitle("MOTION",align=5,size=SIZE)                                        : Motion
    # Make format string only once, not at every frame
    Fmt=(Show)? "%d ] %d#%-4d {\a%c%.1s\a-:\a%c%.1s\a-:\a%c%.1s\a-} dFactHint=%.2f\n" +
            \ "\aRFC->CURR : CURR->BC : FC->NXT : NXT->BC\a-\n" +
            \ "%6.2f   : \a%c%6.2f\a-   : \a%c%6.2f\a-  : %6.2f"
            \ : ""
    FuncS="""
        Function Fn@@@(clip clp,clip start,clip end,clip dclip,float dFact,float dMinim,int dMinLen,Float dChromaW,bool Show,string Fmt,string scFile) {
            clp
            n = current_frame
            If(Prev@@@!=n && Prev@@@ + 1 != n) { # User jumped about, dont you just hate users!
                # We want status at current_frame-1, however to re-detect there we need fill Globals as if at current_frame-2
                # You could Preroll more than 1 for some other reason but need to read Globals @ 1 prior to Preroll count.
                PreRoll = 1
                n = n - PreRoll - 1 # Pretend we are 2 prior to current_frame, we need to fill globals and re-detect
                Global Start@@@ = (Start@@@ > n) ? n : Start@@@
                Global EOS@@@=False
                x = n * 3
                # Get ALL Globals as if n is at correct current_frame, ie D = Curr->Next at n
                # Global A@@@ = RT_FrameDifference(dclip,dclip,n=x  ,n2=x+1,chromaweight=dChromaW) # NOT NEEDED
                # Global B@@@ = RT_FrameDifference(dclip,dclip,n=x+1,n2=x+2,chromaweight=dChromaW) # NOT NEEDED
                Global C@@@ = RT_FrameDifference(dclip,dclip,n=x+3,n2=x+4,chromaweight=dChromaW)
                Global D@@@ = RT_FrameDifference(dclip,dclip,n=x+4,n2=x+5,chromaweight=dChromaW)
                n = n + 1 # Now that Globals are filled, continue as if at the following iteration.
            }
            # A=A@@@ B=B@@@ # NOT NEEDED
            C=C@@@  D=D@@@                  # Get locals, As set by previous iteration
            # Below loop can do a 'Rewind/Preroll' re-detect where SC status is dependent upon previous frames eg user jumped about.
            # In normal (non-jump-about) use, below loop is one iteration only.
            for(n=n,current_frame) {
                x = n * 3                                           # MC Offset
                SOS = EOS@@@                                        # Start Of Scene if Prev frame was End Of Scene
                A=C B=D                                             # Pass the parcel, from previous interation (re-use metrics)
                C = RT_FrameDifference(dclip,dclip,n=x+3,n2=x+4,chromaweight=dChromaW) # New metric
                D = RT_FrameDifference(dclip,dclip,n=x+4,n2=x+5,chromaweight=dChromaW) # New metric
                T1 =((n - Start@@@+1) >= dMinLen)                   # Scene length at least dMinLen frames ?
                T2 =(dFact*A+dMinim) < B                            # CURR->BC sufficiently bigger than 'FC->CURR' (LHS) ?
                T3 =(dFact*D+dMinim) < C                            # FC->NXT  sufficiently bigger than 'NXT->BC'  (RHS) ?
                Global EOS@@@=(T1&&T2&&T3)   # End Of Scene detects HERE & passed on to following iteration via Global.
            }
            n = current_frame           # Restore to current frame, where n = current_frame + 1 after for loop exit.
            SOS_T=(SOS||n==0)           # Take into account if start or end of clip frame.
            EOS_T=(EOS@@@||n==Framecount-1)
            # Below, will ONLY set Start Of Scene if SOS_T and NOT EOS_T, and End of Scene if EOS_T and NOT SOS_T
            # otherwise will show Motion clip frames
            Last = (SOS_T&&!EOS_T)?start:(EOS_T&&!SOS_T)?end:Last     # Choose frame to show to user, Start, End, Motion
            if(Show || scFile != "") {
                # Update Start@@@ and TrimN@@@ only if needed ie Show==True
                Global Start@@@ = (SOS_T&&!EOS_T)?n:Start@@@              # Update Start frame Of Current Scene Change
                if (Show) {
                    LFACT=((B-dMinim)<=A)?0.0:(A<0.000001)?9999.99:((B-dMinim)/A)-0.005
                    RFACT=((C-dMinim)<=D)?0.0:(D<0.000001)?9999.99:((C-dMinim)/D)-0.005
                    dFactHint=Min(LFACT,RFACT)
                    CC=(EOS_T)?33:45              # Hilite or Default color ? (Subtitle Last frame before Scene Change Status)
                    RT_Subtitle(Fmt,n,TrimN@@@,n-Start@@@,CC,T1,CC,T2,CC,T3,dFactHint,A,CC,B,CC,C,D)
                    RT_SubTitle("dFact=%.2f : dMinim=%.2f : dMinLen=%d", dFact,dMinim,dMinlen,align=3)
                }
                if (scFile != "") {
                    if (TrimN@@@ == 1 && n-Start@@@ == 0) {
                        RT_TxtWriteFile("0," + String(n - 1), scFile)
                    }
                    else if (TrimN@@@ > 1 && n-Start@@@ == 0) {
                        prev = RT_ReadTxtFromFile(scFile, 1, RT_FileQueryLines(scFile) - 1)
                        RT_TxtWriteFile(String(Int(Value(RightStr(prev, StrLen(prev) - FindStr(prev, ","))) + 1)) + "," + String(n - 1), scFile, true)
                    }
                    else if (n == FrameCount() - 1) {
                        prev = RT_ReadTxtFromFile(scFile, 1, RT_FileQueryLines(scFile) - 1)
                        RT_TxtWriteFile(String(Int(Value(RightStr(prev, StrLen(prev) - FindStr(prev, ","))) + 1)) + "," + String(n), scFile, true)
                    }
                }
                Global TrimN@@@ = (EOS_T) ? TrimN@@@+1 : TrimN@@@       # Incr for next interation (Scene number, zero rel)
            }
            Global Prev@@@=n                                            # Previous frame (For next interation jump about detect)
            #Global A@@@=A Global B@@@=B    # NOT NEEDED
            Global C@@@=C Global D@@@=D
            Return Last
        }
        #######################################
        # Unique Global Variables Initialization
        #######################################
        # Global A@@@=0.0 Global B@@@=0.0 # NOT NEEDED
        Global C@@@=0.0 Global D@@@=0.0
        Global Start@@@=0
        Global EOS@@@=False     Global TrimN@@@=0   Global Prev@@@= -666 # Init vars, Prev = -666 forces initalize
        #######################################
        # Unique Runtime Call, GScriptClip must be a one-liner:
        #######################################
        ARGS = "start,end,dclip,dFact,dMinim,dMinLen,ChromaWeight,Show,Fmt,scFile"
        Motion.ScriptClip("Fn@@@(last, "+ARGS+")", local=true, args=ARGS)
    """
    #######################################
    # Unique Identifier Definition
    #######################################
    GIFunc ="SCMC"                     # Function Name, Supply unique name for your multi-instance function.
    GIName =GIFunc+"_InstanceNumber"   # Name of the Instance number Global
    RT_IncrGlobal(GIName)              # Increment Instance Global (init to 1 if not already exists)
    GID    = GIFunc + "_" + String(Eval(GIName))
    InstS = RT_StrReplace(FuncS,"@@@","_"+GID)
#   RT_WriteFile("DEBUG_"+GID+".TXT","%s",InstS)
    Return Eval(InstS)
}
