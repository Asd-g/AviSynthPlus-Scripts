#Drawrect 0.10
#0.10: createrect - added parameter crops (default false) - when true the same syntax as Crop() is used.
#0.9: createrect - fixed chroma processing when the clip is 32-bit.
#0.8: createrect - removed parameter "full_range".
#     Added support for other colorspaces than YUV420.
#     Cached the mask result.
#0.7: Added high bit depth support; optional parameter bool "full_range" (default false) - it works only for high bit depth; it determines how the scaling to the input bit depth->8-bit->input bit depth is done ( http://avisynth.nl/index.php/MaskTools2#Expression_syntax_supporting_bit_depth_independent_expressions )

#Drawrect 0.6 by jmac698
#a script to draw rectangles on top of existing video or create masks
#requires masktools v2a45+ (mode in lutspa) and yv12 video
#0.6:  Added even faster option, bool "chroma", simplified code
#0.5:  Speedup and simplification (thanks Gavino, yet again), new function createrect, improved code
#0.4:  Added calculated named colors, removed old system
#0.3:  Added fully opaque with opacity=256, now default.  Fixed bugs.  Added colors.  Refactored.  Outline option.
#  Bugs:  When opacity=256, the color edges are not merged,
#todo:  finish deepcolor support, more shapes

#Usage:
#createrect(clip c, int x1, int y1, int x2, int y2, int "foreclr" (255), int "backclr" (0), bool "filled" (true), bool "chroma" (false))  This is meant to create a simple rect mask
#drawrect(clip c, int x1, int y1, int x2, int y2, int foreclr, int "opacity" (256), bool "filled" (true), bool "chroma" (false))  This is meant to draw on existing video
#opacity=256 for fully opaque

#colorbars(pixel_type="YV12")
#createrect(400,400,419,419)#Great for making masks, a square with luma=255 and 0 elsewhere.  Note that chroma is untouched by default!
#Now use drawrect to add more shapes onto the first mask
#drawrect(1,1,150,200,named_color("cyn"), filled=false)#a cyan square
#drawrect(1,40,300,40,named_color("red"))#a red horizontal line (notice at y=41 the color overwrites the background)
#drawrect(280,300,319,340,$FF8080,opacity=127)#transparent white rectangle
#drawrect(-10,-10,5,5,$B08080)#test behavior with offscreen coordinates


function drawrect(clip c, int x1, int y1, int x2, int y2, int foreclr, int "opacity", bool "filled", bool "chroma", bool "full_range"){
    #A function to draw a filled rectangle into a YV12 clip, can also draw lines as (1,1,1,200,$7E8080):  a vertical line 1 pixel wide from 1,1 to 1,200
    #Note that chroma will be merged with the input clip; draw on mod 2 boundaries if you need to ensure the given pixel chroma
    #The opacity formula is (opacity*foreground+(255-opacity)*background+128)/256
    #You can't draw 255 on black unless you use opacity=256, because opacity=255 gives output=254
    #If create=true, it just draws a single rectangle
    #chroma=true (default) to process chroma.  This function is meant to draw colored rect's on video, so defaults to true.
    #(It can also build masks with more than one rect)
    filled=default(filled, true)
    opacity=default(opacity, 256)
    chroma=default(chroma, true)
    y=getword(foreclr, 2)#byte=2 (n*65536), wordsize=1
    u=getword(foreclr, 1)
    v=getword(foreclr, 0)
    #"x>=xl & x<=xh & y>=yl & y<= yh ? Y : 16" y is the coordinate y, Y is a variable which is substituted as a number in the expression
    #"x x1 >= & x xh <= y yl >= & y yh <= & & Y 16 ?"
    xl=min(x1, x2)#sort the coordinates
    xh=max(x1, x2)
    yl=min(y1, y2)
    yh=max(y1, y2)
    subsampling_x=IsRGB(c)||Is444(c)?1:IsYV411(c)?4:2
    subsampling_y=Is420(c)?2:1
    xl2=ceil(xl/subsampling_x)
    xh2=ceil(xh/subsampling_x)
    yl2=ceil(yl/subsampling_y)
    yh2=ceil(yh/subsampling_y)
    m = opacity == 256 ? 255 : 256
    chromamode=chroma?3:1
    full_range = Default(full_range, false)
    range = full_range ? "allf" : "all"
    scal = full_range ? "scalef" : "scaleb"
    drawstry2=drawstr(y, m)
    drawstru2=drawstr(u, m)
    drawstrv2=drawstr(v, m)
    drawstrm=buildrectexp(xl, yl, xh, yh, opacity, 0, filled, scal)
    drawstrmuv=buildrectexp(xl2, yl2, xh2, yh2, opacity, 0, filled, scal)
    #mask
    mt_lutspa(c, mode="absolute", yexpr=drawstrm, uexpr=drawstrmuv, vexpr=drawstrmuv, u=chromamode, v=chromamode)
    trim(0,-1)
    mask=loop(FrameCount(c))

    mt_lutxy(c, mask, yexpr=drawstry2, uexpr=drawstru2, vexpr=drawstrv2, u=chromamode, v=chromamode, scale_inputs=range, use_expr=1)
}

function createrect(clip c, int x1, int y1, int x2, int y2, int "foreclr", int "backclr", bool "filled", bool "chroma", bool "crops"){
    #chroma=true (default) to process chroma.  This function is meant to draw white rect's for masks, so defaults to false.
    foreclr=default(foreclr, $FF8080)
    backclr=default(backclr, $008080)
    filled=default(filled, true)
    chroma=default(chroma, false)
    crops=default(crops, false)

    yf=getword(foreclr, 2)#byte=2 (n*65536), wordsize=1
    uf=getword(foreclr, 2)
    vf=getword(foreclr, 2)
    yb=getword(backclr, 2)
    ub=getword(backclr, 2)
    vb=getword(backclr, 2)
    if (crops)
    {
        xl=x1
        if (xl==0&&x2==0)
        {
            xh=0
        }
        else
        {
            xh=x2>0?(x1+x2):x2==0?Width(c):(Width(c)+x2)
        }
        yl=y1
        if (yl==0&&y2==0)
        {
            yh=0
        }
        else
        {
            yh=y2>0?(y1+y2):y2==0?Height(c):(Height(c)+y2)
        }
    }
    else
    {
        xl=min(x1, x2)#sort the coordinates
        xh=max(x1, x2)
        yl=min(y1, y2)
        yh=max(y1, y2)
    }
    subsampling_x=IsRGB(c)||Is444(c)?1:IsYV411(c)?4:2
    subsampling_y=Is420(c)?2:1
    xl2=ceil(xl/subsampling_x)
    xh2=ceil(xh/subsampling_x)
    yl2=ceil(yl/subsampling_y)
    yh2=ceil(yh/subsampling_y)
    chromamode=chroma?3:1
    drawstry=buildrectexp(xl, yl, xh, yh, yf, yb, filled, "scalef")
    drawstru=buildrectexp(xl2, yl2, xh2, yh2, uf, ub, filled, "scalef")
    drawstrv=buildrectexp(xl2, yl2, xh2, yh2, vf, vb, filled, "scalef")
    mt_lutspa(c, mode="absolute", yexpr=drawstry, uexpr=drawstru, vexpr=drawstrv, u=chromamode, v=chromamode)
    if (chroma && ComponentSize(c) == 4)
    {
        Expr("", "x 0 > 1 0 ?")
    }
    trim(0,-1)
    return loop(FrameCount(c))
}

function drawstr(int clr, int m) {
    return string(clr)+ " y * "+string(m)+" y - x * + "+string(m)+" /"
}

function buildrectexp(int xl, int yl, int xh, int yh, int clrfore, int clrback, bool filled, string scal){
    #if x=x1 or x=x2 and y>=y1 and y<=y2 or y=y1 or y=y2 and x>=x1 and x<=x2
    #x x1 = x x2 = or y y1 >= y y2 <= and and y y1 = y y2 = or x x1 >= x x2 <= and and or
    filled?"x "+string(xl)+" >= x "+string(xh)+" <=  & y "+string(yl)+" >= y "+string(yh)+" <= & & "+string(clrfore)+" "+string(scal)+" "+string(clrback)+" "+string(scal)+" ?" \
    :"x "+string(xl)+" = x "+string(xh)+" =  | y "+string(yl)+" >= y "+string(yh)+" <= & & y "+ \
    string(yl)+" = y "+string(yh)+" = | x "+string(xl)+" >= x "+string(xh)+" <= & & | "+string(clrfore)+" "+string(scal)+" "+string(clrback)+" "+string(scal)+" ?"
}

function named_color(string color, string "colorspace", float "luma", float "sat", bool "deepcolor") {
    #calculate the named color in yuv with specificed saturation and luminance
    color=lcase(color)
    colorspace=default(colorspace, "rec601")
    luma=default(luma, .75)
    sat=default(sat, .75)
    deepcolor=default(deepcolor, false)
    #Define in rgb, it's easiest
    colorrgb="111"
    colorrgb=color=="yel"||color=="yellow"?"110":colorrgb
    colorrgb=color=="cyn"||color=="cyan"?"011":colorrgb
    colorrgb=color=="grn"||color=="green"?"010":colorrgb
    colorrgb=color=="mag"||color=="magenta"?"101":colorrgb
    colorrgb=color=="red"?"100":colorrgb
    colorrgb=color=="blu"||color=="blue"?"001":colorrgb
    colorrgb=color=="blk"||color=="black"?"000":colorrgb
    r=midstr(colorrgb, 1, 1)=="1"?1:0
    g=midstr(colorrgb, 2, 1)=="1"?1:0
    b=midstr(colorrgb, 3, 1)=="1"?1:0
    #Need to be more flexible.  -I=(-.956295,.272558,1.104744)
    kr601=.299
    kg601=.587
    kb601=.114
    kr709=.2125
    kg709=.7154
    kb709=.0721
    y=colorspace=="rec601"?kr601*r+kg601*g+kb601*b:kr709*r+kg709*g+kb709*b
    pb=colorspace=="rec601"?(b-y)/(1-kb601):(b-y)/(1-kb709)
    pr=colorspace=="rec601"?(r-y)/(1-kr601):(r-y)/(1-kr709)
    scale=deepcolor?65536:256
    yscale=deepcolor?219*219:219*luma
    cscale=deepcolor?112*112:112*sat
    round(y*yscale+scale/16)*scale*scale+round(pb*cscale+scale/2)*scale+round(pr*cscale+scale/2)
}

function hexbyte(int n) {
  #This function returns the lower byte of n as a 2 digit hex string.
  #For example, hex(257)="01".
  n=n%256
  h=floor(n/16)
  l=n%16
  s1=h>9?h+65-10:h+48
  s2=l>9?l+65-10:l+48
  chr(s1)+chr(s2)
}

function hex(int n){
    #returns 3 byte hex string
    d2=floor(n/65536)
    n=n-d2*65536
    d1=floor(n/256)
    n=n-d1*256
    hexbyte(d2)+hexbyte(d1)+hexbyte(n)
}

function getword(int n, int p, int "size"){
    #Get word p of size size from n, limited to p=(0,2)
    #Warning:  due to a bug in avisynth 2.6a3, p=2 and size=2 gives wrong answrs
    size=default(size, 1)
    f=pow(2,8*size*2)
    p2=floor(n/f)
    n=n-p2*f
    f=pow(2,8*size*1)
    p1=floor(n/f)
    n=n-p1*f
    p0=n
    int(p==0?p0:p==1?p1:p2)
}
