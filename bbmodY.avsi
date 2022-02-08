/*
Function to apply bbmod from a specific column and row instead of from only the first/last column and row.

It works only on the luma plane.
*/


### Requirements - AviSynth+ 3.6+, bbmod.


### Usage ###
###
# Function bbmodY(clip c, val "column", val "w", val "row", val "h", val "cTop", val "cBottom", val "cLeft", val "cRight", val "thresh", val "blur")
###
## Parameters ##
#---------------
# c: Input clip.
#---------------
# column (default 0): bbmod is applied from this column.
# Count starts from 0.
# It can be single number or array.
# If this is array, all the values must be for the same area of the image (only for left or right, or top, or bottom).
# If this is array, it's recommended that the values order corresponds to lines from the inner to the outer area of the image (for example [3,2,1]).
# Cannot be used together with row > 0.
#---------------
# w (default 0): How much columns are used to apply bbmod.
# 0: All the columns (clip width).
# It can be single number or array.
#---------------
# row (default 0): bbmod is applied from this row.
# Count starts from 0.
# It can be single number or array.
# If this is array, all the values must be for the same area of the image (only for left or right, or top, or bottom).
# If this is array, it's recommended that the values order corresponds to lines from the inner to the outer area of the image (for example [3,2,1]).
# Cannot be used together with column > 0.
#---------------
# h (default 0): How much rows are used to apply bbmod.
# 0: All the rows (clip height).
# It can be single number or array.
#---------------
# cTop, cBottom, cLeft, cRight (default 0): The number of lines to be filtered.
# If the top area of the image is filtered, only cTop can be greater than 0 and it can be array.
# If the bottom area of the image is filtered, only cBottom can be greater than 0 and it can be array.
# If the left area of the image is filtered, only cLeft can be greater than 0 and it can be array.
# If the right area of the image is filtered, only cRight can be greater than 0 and it can be array.
#---------------
# thresh (default 128.0): Threshold of the filtering.
# Higher values: more filtering.
# Lower values: less filtering.
# Recommended values: 0..16.0 or 128.0.
# It can be single number or array.
#---------------
# blur (default 999): Blur strength.
# Higher values: weak blurring.
# Lower values: strong blurring.
# Recommended values: 1..20 or 999.
# It can be single number or array.


### Changelog ###
#---------------
# Allowed column, row, cTop, cBottom, cLeft, cRight to be specified 0 (for example bbmodY(10, 0, 0, 0, 0, 0, 3, 0, 100, 300)).
# Restrictred the usage of cTop, cBottom, cLeft, cRight - only one of them can be greater than 0 or array.
#---------------
# Removed duplicated code.
# Added restriction for using column and row simultaneously.
#---------------
# Fixed nuked _ChromaLocation frame property if available in the source.
#---------------
# Initial version.


Function bbmodY(clip c, val "column", val "w", val "row", val "h", val "cTop", val "cBottom", val "cLeft", val "cRight", val "thresh", val "blur")
{
    cl = (Defined(column)) ? (IsArray(column)) ? 1 : Default(column, 0) : -1
    rw = (Defined(row)) ? (IsArray(row)) ? 1 : Default(row, 0) : -1

    Assert(!(cl > 0 && rw > 0), "bbmodY: column and row cannot be specified at the same time.")

    c

    if (propGetType("_ChromaLocation") > 0)
    {
        cloc = propGetInt("_ChromaLocation")
    }

    ExtractY()

    if (Defined(column))
    {

        if (cl > 0)
        {
            r = Width() - 1
            column = (IsArray(column)) ? column : [column]
            size = ArraySize(column) - 1

            for (i = 0, size)
            {
                w_ = (Defined(w)) ? (IsArray(w)) ? w[i] : w : 0
                thresh_ = (Defined(thresh)) ? (IsArray(thresh)) ? thresh[i] : thresh : 128.0
                blur_ = (Defined(blur)) ? (IsArray(blur)) ? blur[i] : blur : 999
                col_ = column[i] + 1

                Assert(!(size == 0 && column[i] == 0 && w_ == 0), "bbmodY: Use bbmod for column=0 and w=0.")
                Assert(!(size == 0 && column[i] == r && w_ == 0), "bbmodY: Use bbmod for column=" + String(r) + " and w=0.")

                if (column[i] < Width() / 2)
                {
                    r_ = (Defined(cRight)) ? (IsArray(cRight)) ? 1 : Default(cRight, 0) : -1
                    t_ = (Defined(cTop)) ? (IsArray(cTop)) ? 1 : Default(cTop, 0) : -1
                    b_ = (Defined(cBottom)) ? (IsArray(cBottom)) ? 1 : Default(cBottom, 0) : -1

                    Assert(!(r_ > 0), "bbmodY: cRight cannot be greater than 0 when column is smaller than half of the clip width.")
                    Assert(!(t_ > 0), "bbmodY: cTop cannot be greater than 0 when column is specified.")
                    Assert(!(b_ > 0), "bbmodY: cBottom cannot be greater than 0 when column is specified.")

                    cLeft_ = (Defined(cLeft)) ? (IsArray(cLeft)) ? cLeft[i] : cLeft : 0

                    if (column[i] == 0)
                    {
                        if (w_ == 0) { bbmod(cTop, cBottom, cLeft_, 0, thresh_, blur_) }
                        else { StackHorizontal(Crop(bbmod(cTop, cBottom, cLeft_, 0, thresh_, blur_), 0, 0, w_, 0), Crop(w_, 0, 0, 0)) }
                    }
                    else
                    {
                        if (w_ == 0) { StackHorizontal(Crop(0, 0, col_, 0), bbmod(Crop(col_, 0, 0, 0), cTop, cBottom, cLeft_, 0, thresh_, blur_)) }
                        else { StackHorizontal(Crop(0, 0, col_, 0), Crop(bbmod(Crop(col_, 0, 0, 0), cTop, cBottom, cLeft_, 0, thresh_, blur_), 0, 0, w_, 0), Crop(col_ + w_, 0, 0, 0)) }
                    }
                }
                else
                {
                    l_ = (Defined(cLeft)) ? (IsArray(cLeft)) ? 1 : Default(cLeft, 0) : -1
                    t_ = (Defined(cTop)) ? (IsArray(cTop)) ? 1 : Default(cTop, 0) : -1
                    b_ = (Defined(cBottom)) ? (IsArray(cBottom)) ? 1 : Default(cBottom, 0) : -1

                    Assert(!(l_ > 0), "bbmodY: cLeft cannot be greater than 0 when column is bigger than half of the clip width.")
                    Assert(!(t_ > 0), "bbmodY: cTop cannot be greater than 0 when column is specified.")
                    Assert(!(b_ > 0), "bbmodY: cBottom cannot be greater than 0 when column is specified.")

                    cRight_ = (Defined(cRight)) ? (IsArray(cRight)) ? cRight[i] : cRight : 0

                    if (column[i] == r)
                    {
                        if (w_ == 0) { bbmod(cTop, cBottom, 0, cRight_, thresh_, blur_) }
                        else
                        {
                            w_1 = col_ - w_
                            StackHorizontal(Crop(0, 0, w_1, 0), Crop(bbmod(Crop(0, 0, col_, 0), cTop, cBottom, 0, cRight_, thresh_, blur_), w_1, 0, 0, 0))
                        }
                    }
                    else
                    {
                        if (w_ == 0) { StackHorizontal(bbmod(Crop(0, 0, col_, 0), cTop, cBottom, 0, cRight_, thresh_, blur_), Crop(col_, 0, 0, 0)) }
                        else
                        {
                            w_1 = col_ - w_
                            StackHorizontal(Crop(0, 0, w_1, 0), Crop(bbmod(Crop(0, 0, col_, 0), cTop, cBottom, 0, cRight_, thresh_, blur_), w_1, 0, 0, 0), Crop(col_, 0, 0, 0))
                        }
                    }
                }
            }
        }
    }

    if (Defined(row))
    {
        if (rw > 0)
        {
            b = Height() - 1
            row = (IsArray(row)) ? row : [row]
            size = ArraySize(row) - 1

            for (i = 0, size)
            {
                h_ = (Defined(h)) ? (IsArray(h)) ? h[i] : h : 0
                thresh_ = (Defined(thresh)) ? (IsArray(thresh)) ? thresh[i] : thresh : 128.0
                blur_ = (Defined(blur)) ? (IsArray(blur)) ? blur[i] : blur : 999
                row_ = row[i] + 1

                Assert(!(size == 0 && row[i] == 0 && h_ == 0), "bbmodY: Use bbmod for row=0 and h=0.")
                Assert(!(size == 0 && row[i] == b && h_ == 0), "bbmodY: Use bbmod for row=" + String(b) + " and h=0.")

                if (row[i] < Height() / 2)
                {
                    b_ = (Defined(cBottom)) ? (IsArray(cBottom)) ? 1 : Default(cBottom, 0) : -1
                    l_ = (Defined(cLeft)) ? (IsArray(cLeft)) ? 1 : Default(cLeft, 0) : -1
                    r_ = (Defined(cRight)) ? (IsArray(cRight)) ? 1 : Default(cRight, 0) : -1

                    Assert(!(b_ > 0), "bbmodY: cBottom cannot be greater than 0 when row is smaller than half of the clip height.")
                    Assert(!(l_ > 0), "bbmodY: cLeft cannot be greater than 0 when row is specified.")
                    Assert(!(r_ > 0), "bbmodY: cRight cannot be greater than 0 when row is specified.")

                    cTop_ = (Defined(cTop)) ? (IsArray(cTop)) ? cTop[i] : cTop : 0

                    if (row[i] == 0)
                    {
                        if (h_ == 0) { bbmod(cTop_, 0, cLeft, cRight, thresh_, blur_) }
                        else { StackVertical(Crop(bbmod(cTop_, 0, cLeft, cRight, thresh_, blur_), 0, 0, 0, h_), Crop(0, h_, 0, 0)) }
                    }
                    else
                    {
                        if (h_ == 0) { StackVertical(Crop(0, 0, 0, row_), bbmod(Crop(0, row_, 0, 0), cTop_, 0, cLeft, cRight, thresh_, blur_)) }
                        else { StackVertical(Crop(0, 0, 0, row_), Crop(bbmod(Crop(0, row_, 0, 0), cTop_, 0, cLeft, cRight, thresh_, blur_), 0, 0, 0, h_), Crop(0, row_ + h_, 0, 0)) }
                    }
                }
                else
                {
                    t_ = (Defined(cTop)) ? (IsArray(cTop)) ? 1 : Default(cTop, 0) : -1
                    l_ = (Defined(cLeft)) ? (IsArray(cLeft)) ? 1 : Default(cLeft, 0) : -1
                    r_ = (Defined(cRight)) ? (IsArray(cRight)) ? 1 : Default(cRight, 0) : -1

                    Assert(!(t_ > 0), "bbmodY: cTop cannot be greater than 0 when row is bigger than half of the clip height.")
                    Assert(!(l_ > 0), "bbmodY: cLeft cannot be greater than 0 when row is specified.")
                    Assert(!(r_ > 0), "bbmodY: cRight cannot be greater than 0 when row is specified.")

                    cBottom_ = (Defined(cBottom)) ? (IsArray(cBottom)) ? cBottom[i] : cBottom : 0

                    if (row[i] == b)
                    {
                        if (h_ == 0) { bbmod(0, cBottom_, cLeft, cRight, thresh_, blur_) }
                        else
                        {
                            h_1 = row_ - h_
                            StackVertical(Crop(0, 0, 0, h_1), Crop(bbmod(Crop(0, 0, 0, row_), 0, cBottom_, cLeft, cRight, thresh_, blur_), 0, h_1, 0, 0))
                        }
                    }
                    else
                    {
                        if (h_ == 0) { StackVertical(bbmod(Crop(0, 0, 0, row_), 0, cBottom_, cLeft, cRight, thresh_, blur_), Crop(0, row_, 0, 0)) }
                        else
                        {
                            h_1 = row_ - h_
                            StackVertical(Crop(0, 0, 0, h_1), Crop(bbmod(Crop(0, 0, 0, row_), 0, cBottom_, cLeft, cRight, thresh_, blur_), 0, h_1, 0, 0), Crop(0, row_, 0, 0))
                        }
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
            propSet("_ChromaLocation", cloc)
        }
    }
}
