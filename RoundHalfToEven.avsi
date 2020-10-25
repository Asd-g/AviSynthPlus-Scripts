/*
Round half to even - https://en.wikipedia.org/wiki/Rounding#Round_half_to_even

Returned value is float.
*/


Function RoundHalfToEven(float n)
{
    if (Frac(n) == 0.0) { return n }
    else if (Frac(n) == 0.5)
    {
        f = Floor(n)
        return f % 2 == 0 ? f : Ceil(n)
    }    
    else { return Round(n) }
}

Function RoundHalfToEven_mod2(val n)
{
    q = n / 2.0
    
    if (Frac(q) == 0.0) { return n }
    else if (Frac(q) == 0.5)
    {
        f = Floor(q)
        return f % 2 == 0 ? f * 2.0 : Ceil(q) * 2.0
    }
    else { return Round(q) * 2.0 }
}
