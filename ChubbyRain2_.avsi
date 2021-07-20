# http://avisynth.nl/index.php/ChubbyRain2


### NOTE ###
/*
Only progressive clips supported.
If you have interlaced clip make sure you deinterlaced before using this function.
*/


### Changelog ###
#---------------
# Replaced GeneralConvolution with Expr for >30% speed up.
# Added note for supporting only progressive clips.
#---------------
# Replaced mt_convolution with GeneralConvolution for >10% speed up.
#---------------
# Made parameter "interlaced" dummy.
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
    
    uc = Expr(c, "", "x[0,-1] x[0,0] -2 * + x[0,1] +")
    Expr(c, "", "x[0,-1] x[0,0] 2 * + x[0,1] + 0.250001 *")
    bifrost(interlaced=false)
    vsCnr2()
    cc = temporalsoften(radius,0,sft,2,2)
    
    mt_lutxy(ExtractU(uc), ExtractV(uc), "x y + "+string(th)+" > 255 0 ?", scale_inputs="allf", use_expr=1)
    z_PointResize(c.width, c.height)
    rainbow = mt_expand(y=3,u=-128,v=-128) #.blur(1.5)
    
    mt_merge(c, cc, rainbow, y=2, luma=true)
    
    return (show) ? rainbow : last
}
