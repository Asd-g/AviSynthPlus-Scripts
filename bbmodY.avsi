/*
Function to apply bbmod from a specific column and row instead of from only the first/last column and row.

It works only on the luma plane.
*/


### Requirements - AviSynth+ 3.6+, bbmod.


### Usage ###
###
# bbmodY(clip c, val "column", val "w", val "row", val "h", int "cTop", int "cBottom", int "cLeft", int "cRight", float "thresh", int "blur")
###
## Parameters ##
#---------------
# c: Input clip.
#---------------
# column: If defined, bbmod is applied from this column.
# Count starts from 0.
# It can be single number or array.
#---------------
# w (default 0): How much columns are used to apply bbmod.
# 0: All the columns (clip width).
#---------------
# row: If defined, bbmod is applied from this row.
# Count starts from 0.
# It can be single number or array.
#---------------
# h (default 0): How much rows are used to apply bbmod.
# 0: All the rows (clip height).
#---------------
# cTop, cBottom, cLeft, cRight (default 0): The number of lines to be filtered on each border.
#---------------
# thresh (default 128.0): Threshold of the filtering.
# Higher values: more filtering.
# Lower values: less filtering.
# Recommended values: 0..16.0 or 128.0.
#---------------
# blur (default 999): Blur strength.
# Higher values: weak blurring.
# Lower values: strong blurring.
# Recommended values: 1..20 or 999.


### Changelog ###
#---------------
# Removed duplicated code.
# Added restriction for using column and row simultaneously.
#---------------
# Fixed nuked _ChromaLocation frame property if available in the source.
#---------------
# Initial version.


Function bbmodY(clip c, val "column", val "w", val "row", val "h", int "cTop", int "cBottom", int "cLeft", int "cRight", float "thresh", int "blur")
{
    Assert(!(Defined(column) && Defined(row)), "bbmodY: column and row cannot be specified at the same time.")

    c

    if (propGetType("_ChromaLocation") > 0)
    {
        cl = propGetInt("_ChromaLocation")
    }

    ExtractY()

    if (Defined(column))
    {
        r = Width() - 1
        column = (IsArray(column)) ? column : [column]
        size = ArraySize(column) - 1

        for (i = 0, size)
        {
            w_ = (Defined(w)) ? (IsArray(w)) ? w[i] : w : 0
            col_ = column[i] + 1

            Assert(!(size == 0 && column[i] == 0 && w_ == 0), "bbmodY: Use bbmod for column=0 and w=0.")
            Assert(!(size == 0 && column[i] == r && w_ == 0), "bbmodY: Use bbmod for column=" + String(r) + " and w=0.")

            if (column[i] < Width() / 2)
            {
                Assert(!Defined(cRight), "bbmodY: cRight cannot be specified when column is smaller than half of the clip width.")

                if (column[i] == 0)
                {
                    if (w_ == 0) { bbmod(cTop, cBottom, cLeft, 0, thresh, blur) }
                    else { StackHorizontal(Crop(bbmod(cTop, cBottom, cLeft, 0, thresh, blur), 0, 0, w_, 0), Crop(w_, 0, 0, 0)) }
                }
                else
                {
                    if (w_ == 0) { StackHorizontal(Crop(0, 0, col_, 0), bbmod(Crop(col_, 0, 0, 0), cTop, cBottom, cLeft, 0, thresh, blur)) }
                    else { StackHorizontal(Crop(0, 0, col_, 0), Crop(bbmod(Crop(col_, 0, 0, 0), cTop, cBottom, cLeft, 0, thresh, blur), 0, 0, w_, 0), Crop(col_ + w_, 0, 0, 0)) }
                }
            }
            else
            {
                Assert(!Defined(cLeft), "bbmodY: cLeft cannot be specified when column is bigger than half of the clip width.")

                if (column[i] == r)
                {
                    if (w_ == 0) { bbmod(cTop, cBottom, 0, cRight, thresh, blur) }
                    else
                    {
                        w_1 = col_ - w_
                        StackHorizontal(Crop(0, 0, w_1, 0), Crop(bbmod(Crop(0, 0, col_, 0), cTop, cBottom, 0, cRight, thresh, blur), w_1, 0, 0, 0))
                    }
                }
                else
                {
                    if (w_ == 0) { StackHorizontal(bbmod(Crop(0, 0, col_, 0), cTop, cBottom, 0, cRight, thresh, blur), Crop(col_, 0, 0, 0)) }
                    else
                    {
                        w_1 = col_ - w_
                        StackHorizontal(Crop(0, 0, w_1, 0), Crop(bbmod(Crop(0, 0, col_, 0), cTop, cBottom, 0, cRight, thresh, blur), w_1, 0, 0, 0), Crop(col_, 0, 0, 0))
                    }
                }
            }
        }
    }

    if (Defined(row))
    {
        b = Height() - 1
        row = (IsArray(row)) ? row : [row]
        size = ArraySize(row) - 1

        for (i = 0, size)
        {
            h_ = (Defined(h)) ? (IsArray(h)) ? h[i] : h : 0
            row_ = row[i] + 1

            Assert(!(size == 0 && row[i] == 0 && h_ == 0), "bbmodY: Use bbmod for row=0 and h=0.")
            Assert(!(size == 0 && row[i] == b && h_ == 0), "bbmodY: Use bbmod for row=" + String(b) + " and h=0.")

            if (row[i] < Height() / 2)
            {
                Assert(!Defined(cBottom), "bbmodY: cBottom cannot be specified when row is smaller than half of the clip height.")

                if (row[i] == 0)
                {
                    if (h_ == 0) { bbmod(cTop, 0, cLeft, cRight, thresh, blur) }
                    else { StackVertical(Crop(bbmod(cTop, 0, cLeft, cRight, thresh, blur), 0, 0, 0, h_), Crop(0, h_, 0, 0)) }
                }
                else
                {
                    if (h_ == 0) { StackVertical(Crop(0, 0, 0, row_), bbmod(Crop(0, row_, 0, 0), cTop, 0, cLeft, cRight, thresh, blur)) }
                    else { StackVertical(Crop(0, 0, 0, row_), Crop(bbmod(Crop(0, row_, 0, 0), cTop, 0, cLeft, cRight, thresh, blur), 0, 0, 0, h_), Crop(0, row_ + h_, 0, 0)) }
                }
            }
            else
            {
                Assert(!Defined(cTop), "bbmodY: cTop cannot be specified when row is bigger than half of the clip height.")

                if (row[i] == b)
                {
                    if (h_ == 0) { bbmod(0, cBottom, cLeft, cRight, thresh, blur) }
                    else
                    {
                        h_1 = row_ - h_
                        StackVertical(Crop(0, 0, 0, h_1), Crop(bbmod(Crop(0, 0, 0, row_), 0, cBottom, cLeft, cRight, thresh, blur), 0, h_1, 0, 0))
                    }
                }
                else
                {
                    if (h_ == 0) { StackVertical(bbmod(Crop(0, 0, 0, row_), 0, cBottom, cLeft, cRight, thresh, blur), Crop(0, row_, 0, 0)) }
                    else
                    {
                        h_1 = row_ - h_
                        StackVertical(Crop(0, 0, 0, h_1), Crop(bbmod(Crop(0, 0, 0, row_), 0, cBottom, cLeft, cRight, thresh, blur), 0, h_1, 0, 0), Crop(0, row_, 0, 0))
                    }
                }
            }
        }
    }

    if (NumComponents(c) > 1)
    {
        CombinePlanes(last, c, "yuv", sample_clip=c)

        if (propGetType(c, "_ChromaLocation") > 0)
        {
            propSet("_ChromaLocation", cl)
        }
    }
}
