### Kirsch algorithm for edge mask.


### Usage ###
###
# Kirsch(clip c, int "thY1", int "thY2", int "thC1", int "thC2", int "y", int "u", int "v", string "chroma")
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
# - Added parameters: thY1, thY2, thC1, thC2. Removed default value for 'chroma'.
# - Added optional additional parameters: u, v, chroma. The same usage as for masktools2.
# - Initial version.


Function Kirsch(clip c, int "thY1", int "thY2", int "thC1", int "thC2", int "y", int "u", int "v", string "chroma")
{
    thY1 = Default(thY1, 0)
    thY2 = Default(thY2, 255)
    thC1 = Default(thC1, 0)
    thC2 = Default(thC2, 255)
    y = Default(y, 3)
    u = Default(u, 1)
    v = Default(v, 1)
    
    c
    return mt_logic(
        \ mt_logic(
            \ mt_logic(mt_edge("5,  5,  5, -3,  0, -3, -3, -3, -3 1", thY1, thY2, thC1, thC2, y, u, v, chroma),
                \ mt_edge("-3,  5,  5,  5,  0, -3, -3, -3, -3 1", thY1, thY2, thC1, thC2, y, u, v, chroma), mode="max", y=y, u=u, v=v, chroma=chroma),
            \ mt_logic(mt_edge("-3, -3,  5,  5,  0,  5, -3, -3, -3 1", thY1, thY2, thC1, thC2, y, u, v, chroma),
                \ mt_edge("-3, -3, -3,  5,  0,  5,  5, -3, -3 1", thY1, thY2, thC1, thC2, y, u, v, chroma), mode="max", y=y, u=u, v=v, chroma=chroma),
        \ mode="max", y=y, u=u, v=v, chroma=chroma),
        \ mt_logic(
            \mt_logic(mt_edge("-3, -3, -3, -3,  0,  5,  5,  5, -3 1", thY1, thY2, thC1, thC2, y, u, v, chroma),
                \ mt_edge("-3, -3, -3, -3,  0, -3,  5,  5,  5 1", thY1, thY2, thC1, thC2, y, u, v, chroma), mode="max", y=y, u=u, v=v, chroma=chroma),
            \ mt_logic(mt_edge("5, -3, -3, -3,  0, -3, -3,  5,  5 1", thY1, thY2, thC1, thC2, y, u, v, chroma),
                \ mt_edge("5,  5, -3, -3,  0, -3, -3, -3,  5 1", thY1, thY2, thC1, thC2, y, u, v, chroma), mode="max", y=y, u=u, v=v, chroma=chroma),
        \ mode="max", y=y, u=u, v=v, chroma=chroma),
    \ mode="max", y=y, u=u, v=v, chroma=chroma)
}
