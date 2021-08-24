/*
Function to apply bbmod from a specific column and row instead of from only the first/last column and row.

It works only on the luma plane.
*/



### Requirements - AviSynth+ 3.6+, bbmod.


### Usage ###
###
# bbmodY(clip c, val "column", val "w", val "row", val "h", val "cTop", val "cBottom", val "cLeft", val "cRight", val "thresh", val "blur")
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
# The rest parameters are the these applied to bbmod. See bbmod_.avsi for more information.


### Changelog ###
#---------------
# Initial version.


Function bbmodY(clip c, val "column", val "w", val "row", val "h", val "cTop", val "cBottom", val "cLeft", val "cRight", val "thresh", val "blur")
{
    ExtractY(c)
    
    if (Defined(column))
    {
        r = Width(c) - 1
        
        if (IsArray(column))
        {
            for (i = 0, ArraySize(column) - 1)
            {
                _w = Defined(w) ? IsArray(w) ? w[i] : w : 0
                _col = column[i] + 1
                
                if (column[i] < Width(c) / 2)
                {
                    if (column[i] == 0)
                    {
                        if (_w == 0) { bbmod(cTop, cBottom, cLeft, cRight, thresh, blur) }
                        else { StackHorizontal(Crop(bbmod(cTop, cBottom, cLeft, cRight, thresh, blur), 0, 0, _w, 0), Crop(_w, 0, 0, 0)) }
                    }
                    else
                    {
                        if (_w == 0) { StackHorizontal(Crop(0, 0, _col, 0), bbmod(Crop(_col, 0, 0, 0), cTop, cBottom, cLeft, cRight, thresh, blur)) }
                        else { StackHorizontal(Crop(0, 0, _col, 0), Crop(bbmod(Crop(_col, 0, 0, 0), cTop, cBottom, cLeft, cRight, thresh, blur), 0, 0, _w, 0), Crop(_col + _w, 0, 0, 0)) }
                    }
                }
                else
                {
                    if (column[i] == r)
                    { 
                        if (_w == 0) { bbmod(cTop, cBottom, cLeft, cRight, thresh, blur) }
                        else
                        {
                            _w1 = _col - _w
                            StackHorizontal(Crop(0, 0, _w1, 0), Crop(bbmod(Crop(0, 0, _col, 0), cTop, cBottom, cLeft, cRight, thresh, blur), _w1, 0, 0, 0))
                        }
                    }
                    else
                    {
                        if (_w == 0) { StackHorizontal(bbmod(Crop(0, 0, _col, 0), cTop, cBottom, cLeft, cRight, thresh, blur), Crop(_col, 0, 0, 0)) }
                        else
                        {
                            _w1 = _col - _w
                            StackHorizontal(Crop(0, 0, _w1, 0), Crop(bbmod(Crop(0, 0, _col, 0), cTop, cBottom, cLeft, cRight, thresh, blur), _w1, 0, 0, 0), Crop(_col, 0, 0, 0))
                        }
                    }
                }
            }
        }
        else
        {
            _w = Default(w, 0)
            _col = column + 1
            
            Assert(column > 0 || (column == 0 && _w != 0), "bbmodY: Use bbmod for column=0 and w=0.")
            Assert(column < r || (column == r && _w != 0), "bbmodY: Use bbmod for column=" + String(r) + " and w=0.")
            
            if (column < Width(c) / 2)
            {
                if (column == 0) { StackHorizontal(Crop(bbmod(cTop, cBottom, cLeft, cRight, thresh, blur), 0, 0, _w, 0), Crop(_w, 0, 0, 0)) }
                else
                {
                    if (_w == 0) { StackHorizontal(Crop(0, 0, _col, 0), bbmod(Crop(_col, 0, 0, 0), cTop, cBottom, cLeft, cRight, thresh, blur)) }
                    else { StackHorizontal(Crop(0, 0, _col, 0), Crop(bbmod(Crop(_col, 0, 0, 0), cTop, cBottom, cLeft, cRight, thresh, blur), 0, 0, _w, 0), Crop(_col + _w, 0, 0, 0)) }
                }
            }
            else
            {
                if (column == r)
                {
                    _w1 = _col - _w
                    StackHorizontal(Crop(0, 0, _w1, 0), Crop(bbmod(Crop(0, 0, _col, 0), cTop, cBottom, cLeft, cRight, thresh, blur), _w1, 0, 0, 0))
                }
                else
                {
                    if (_w == 0) { StackHorizontal(bbmod(Crop(0, 0, _col, 0), cTop, cBottom, cLeft, cRight, thresh, blur), Crop(_col, 0, 0, 0)) }
                    else
                    {
                        _w1 = _col - _w
                        StackHorizontal(Crop(0, 0, _w1, 0), Crop(bbmod(Crop(0, 0, _col, 0), cTop, cBottom, cLeft, cRight, thresh, blur), _w1, 0, 0, 0), Crop(_col, 0, 0, 0))
                    }
                }
            }
        }
    }
    
    if (Defined(row))
    {
        b = Height(c) - 1
        
        if (IsArray(row))
        {
            for (i = 0, ArraySize(row) - 1)
            {
                _h = Defined(h) ? IsArray(h) ? h[i] : h : 0
                _row = row[i] + 1
                
                if (row[i] < Height(c) / 2)
                {
                    if (row[i] == 0)
                    {
                        if (_h == 0) { bbmod(cTop, cBottom, cLeft, cRight, thresh, blur) }
                        else { StackVertical(Crop(bbmod(cTop, cBottom, cLeft, cRight, thresh, blur), 0, 0, 0, _h), Crop(0, _h, 0, 0)) }
                    }
                    else
                    {
                        if (_h == 0) { StackVertical(Crop(0, 0, 0, _row), bbmod(Crop(0, _row, 0, 0), cTop, cBottom, cLeft, cRight, thresh, blur)) }
                        else { StackVertical(Crop(0, 0, 0, _row), Crop(bbmod(Crop(0, _row, 0, 0), cTop, cBottom, cLeft, cRight, thresh, blur), 0, 0, 0, _h), Crop(0, _row + _h, 0, 0)) }
                    }
                }
                else
                {
                    if (row[i] == b)
                    { 
                        if (_h == 0) { bbmod(cTop, cBottom, cLeft, cRight, thresh, blur) }
                        else
                        {
                            _h1 = _row - _h
                            StackVertical(Crop(0, 0, 0, _h1), Crop(bbmod(Crop(0, 0, 0, _row), cTop, cBottom, cLeft, cRight, thresh, blur), 0, _h1, 0, 0))
                        }
                    }
                    else
                    {
                        if (_h == 0) { StackVertical(bbmod(Crop(0, 0, 0, _row), cTop, cBottom, cLeft, cRight, thresh, blur), Crop(0, _row, 0, 0)) }
                        else
                        {
                            _h1 = _row - _h
                            StackVertical(Crop(0, 0, 0, _h1), Crop(bbmod(Crop(0, 0, 0, _row), cTop, cBottom, cLeft, cRight, thresh, blur), 0, _h1, 0, 0), Crop(0, _row, 0, 0))
                        }
                    }
                }
            }
        }
        else
        {
            _h = Default(h, 0)
            _row = row + 1
            
            Assert(row > 0 || (row == 0 && _h != 0), "bbmodY: Use bbmod for row=0 and h=0.")
            Assert(row < b || (row == b && _h != 0), "bbmodY: Use bbmod for row=" + String(b) + " and h=0.")

            if (row < Height(c) / 2)
            {
                if (row == 0) { StackVertical(Crop(bbmod(cTop, cBottom, cLeft, cRight, thresh, blur), 0, 0, 0, _h), Crop(0, _h, 0, 0)) }
                else
                {
                    if (_h == 0) { StackVertical(Crop(0, 0, 0, _row), bbmod(Crop(0, _row, 0, 0), cTop, cBottom, cLeft, cRight, thresh, blur)) }
                    else { StackVertical(Crop(0, 0, 0, _row), Crop(bbmod(Crop(0, _row, 0, 0), cTop, cBottom, cLeft, cRight, thresh, blur), 0, 0, 0, _h), Crop(0, _row + _h, 0, 0)) }
                }
            }
            else
            {
                if (row == b)
                {
                    _h1 = _row - _h
                    StackVertical(Crop(0, 0, 0, _h1), Crop(bbmod(Crop(0, 0, 0, _row), cTop, cBottom, cLeft, cRight, thresh, blur), 0, _h1, 0, 0))
                }
                else
                {
                    if (_h == 0) { StackVertical(bbmod(Crop(0, 0, 0, _row), cTop, cBottom, cLeft, cRight, thresh, blur), Crop(0, _row, 0, 0)) }
                    else
                    {
                        _h1 = _row - _h
                        StackVertical(Crop(0, 0, 0, _h1), Crop(bbmod(Crop(0, 0, 0, _row), cTop, cBottom, cLeft, cRight, thresh, blur), 0, _h1, 0, 0), Crop(0, _row, 0, 0))
                    }
                }
            }
        }
    }
    
    if (NumComponents(c) > 1) { return CombinePlanes(last, c, "yuv", sample_clip=c) }
}
