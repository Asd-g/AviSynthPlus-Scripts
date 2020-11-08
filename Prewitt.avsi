### Prewitt algorithm for edge mask. https://en.wikipedia.org/wiki/Prewitt_operator


### Usage ###
###
# Prewitt(clip c, int "thY1", int "thY2", int "thC1", int "thC2", int "y", int "u", int "v", string "chroma")
###
## Parameters ##
#---------------
# clip c: The input clip.
#---------------
# thY1 (default 0): The low threshold for luma. Must be between 0 and 255.
#---------------
# thY2 (default 255): The high threshold for luma. Must be between 0 and 255.
#---------------
# thC1 (default 0): The low threshold for chroma. Must be between 0 and 255.
#---------------
# thC2 (default 255): The high threshold for chroma. Must be between 0 and 255.
#---------------
# y, u, v (default 3, 1, 1): Planes to process. 1: Return garbage. 2: Copy plane. 3: Process plane.
#---------------
# chroma (default ""): When defined, the value contained in this string will overwrite the u & v processing modes. "process": set u = v = 3. "copy"/"copy first": set u = v = 2. "xxx", where xxx is a number: set u = v = -xxx. 


### Changelog ###
# - Initial version.


Function Prewitt(clip c, int "thY1", int "thY2", int "thC1", int "thC2", int "y", int "u", int "v", string "chroma")
{
    thY1 = Default(thY1, 0)
    thY2 = Default(thY2, 255)
    thC1 = Default(thC1, 0)
    thC2 = Default(thC2, 255)
    y = Default(y, 3)
    u = Default(u, 1)
    v = Default(v, 1)
    
    c    
    return mt_lutxy(mt_edge("1 1 1 0 0 0 -1 -1 -1 1", thY1, thY2, thC1, thC2, y, u, v, chroma), mt_edge("1 0 -1 1 0 -1 1 0 -1 1", thY1, thY2, thC1, thC2, y, u, v, chroma), "x 2 ^ y 2 ^ + sqrt", y=y, u=u, v=v, chroma=chroma, use_expr=3)
}
