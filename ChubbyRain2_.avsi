# http://avisynth.nl/index.php/ChubbyRain2


### Changelog ###
#---------------
# Removed restriction for only 420 video.
#---------------
# Fixed interlaced=true.
#---------------
# Changed requirements: replaced Cnr2 with vsCnr2.
# Added support for 10..16-bit clips.
 

Function ChubbyRain2(clip c, int "th", int "radius", bool "show", int "sft", bool "interlaced")
{
#based on Mug Funky's ChubbyRain

    th = default(th,10)
    radius = default(radius,10)
    show = default(show,false)
    sft = default (sft, 10)
    interlaced = default(interlaced, false)
    
    if (interlaced)
    {
        f = GetParity(c)
        b = TDeint(c, mode=1)
        uc = mt_convolution(b, horizontal="1",vertical="1 -2 1",Y=1,U=3,V=3)
        mt_convolution(b, horizontal="1",vertical="1 2 1",Y=2,U=3,V=3)
        bifrost(interlaced=false)
        vsCnr2()
        cc = temporalsoften(radius,0,sft,2,2)
    
        mt_lutxy(ExtractU(uc), ExtractV(uc), "x y + "+string(th)+" > 255 0 ?", scale_inputs="allf", use_expr=1)
        
        AssumeFrameBased()
        ScriptClip("""
        if (propGetType("_FieldBased") > 0)
        {
            _field = propGetInt("_FieldBased")
            propSet("_FieldBased", 0 )
        } """)
        z_PointResize(b.width, b.height)
        rainbow = mt_expand(y=3,u=-128,v=-128) #.blur(1.5)
    
        mt_merge(b, cc, rainbow, y=2, luma=true)        
        
        (show) ? rainbow : last
        
        (f) ? AssumeTFF() : AssumeBFF()
        SeparateFields()
        SelectEvery(4,0,3)
        Weave()
        
        ScriptClip("""
        if (propGetType("_FieldBased") > 0)
        {
            propSet("_FieldBased", _field)
        } """)
    }
    else
    {
        uc = mt_convolution(c, horizontal="1",vertical="1 -2 1",Y=1,U=3,V=3)
        mt_convolution(c, horizontal="1",vertical="1 2 1",Y=2,U=3,V=3)
        bifrost(interlaced=false)
        vsCnr2()
        cc = temporalsoften(radius,0,sft,2,2)
    
        mt_lutxy(ExtractU(uc), ExtractV(uc), "x y + "+string(th)+" > 255 0 ?", scale_inputs="allf", use_expr=1)
        z_PointResize(c.width, c.height)
        rainbow = mt_expand(y=3,u=-128,v=-128) #.blur(1.5)
    
        mt_merge(c, cc, rainbow, y=2, luma=true)
    
        return (show) ? rainbow : last
    }
}
