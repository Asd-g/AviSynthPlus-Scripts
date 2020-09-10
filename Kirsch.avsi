# Changelog:
# added optional additional parameters: u, v, chroma. The same usage as for masktools2


# Kirsch algorithm for edge mask.


Function Kirsch(clip c, int "y", int "u", int "v", string "chroma")
{
    y       = Default(y, 3)
    u       = Default(u, 1)
    v       = Default(v, 1)
    chroma  = Default(chroma)

	c

	mt_logic(mt_logic(mt_logic(mt_edge("5,  5,  5, -3,  0, -3, -3, -3, -3 1", 0, 255, y=y, u=u, v=v, chroma=chroma), mt_edge("-3,  5,  5,  5,  0, -3, -3, -3, -3 1", 0, 255, y=y, u=u, v=v, chroma=chroma), mode="max", y=y, u=u, v=v, chroma=chroma),\
	mt_logic(mt_edge("-3, -3,  5,  5,  0,  5, -3, -3, -3 1", 0, 255, y=y, u=u, v=v, chroma=chroma), mt_edge("-3, -3, -3,  5,  0,  5,  5, -3, -3 1", 0, 255, y=y, u=u, v=v, chroma=chroma), mode="max", y=y, u=u, v=v, chroma=chroma), mode="max", y=y, u=u, v=v, chroma=chroma),\
	mt_logic(mt_logic(mt_edge("-3, -3, -3, -3,  0,  5,  5,  5, -3 1", 0, 255, y=y, u=u, v=v, chroma=chroma), mt_edge("-3, -3, -3, -3,  0, -3,  5,  5,  5 1", 0, 255, y=y, u=u, v=v, chroma=chroma), mode="max", y=y, u=u, v=v, chroma=chroma),\
	mt_logic(mt_edge("5, -3, -3, -3,  0, -3, -3,  5,  5 1", 0, 255, y=y, u=u, v=v, chroma=chroma), mt_edge("5,  5, -3, -3,  0, -3, -3, -3,  5 1", 0, 255, y=y, u=u, v=v, chroma=chroma), mode="max", y=y, u=u, v=v, chroma=chroma), mode="max", y=y, u=u, v=v, chroma=chroma), mode="max", y=y, u=u, v=v, chroma=chroma)
}