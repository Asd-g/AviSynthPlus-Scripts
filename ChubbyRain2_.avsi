# http://avisynth.nl/index.php/ChubbyRain2


### Changelog ###
#---------------
# Changed requirements: replaced Cnr2 with vsCnr2.
# Adde support for 10..16-bit clips.
 

function ChubbyRain2(clip c, int "th", int "radius", bool "show", int "sft", bool "interlaced")
{
#based on Mug Funky's ChubbyRain

    Assert(Is420(c), "ChubbyRain2: only clips with chroma subsampling 420 are supported.")

    th = default(th,10)
    radius = default(radius,10)
    show = default(show,false)
    sft = default (sft, 10)
    interlaced = default(interlaced, false)
    
    c = (interlaced) ? c.separatefields() : c
    
    uc = mt_convolution(c, horizontal="1",vertical="1 -2 1",Y=1,U=3,V=3)
    
    mt_convolution(c, horizontal="1",vertical="1 2 1",Y=2,U=3,V=3)
    bifrost(interlaced=false)
    vsCnr2()
    cc = temporalsoften(radius,0,sft,2,2)
    
    mt_lutxy(ExtractU(uc), ExtractV(uc), "x y + "+string(th)+" > 255 0 ?", scale_inputs="allf", use_expr=1)
    z_pointresize(c.width,c.height)
    rainbow = mt_expand(y=3,u=-128,v=-128)#.blur(1.5)
    
    mt_merge(c, cc, rainbow, y=2, luma=true)
    
    return (show) ? rainbow : (interlaced) ? weave() : last
}
