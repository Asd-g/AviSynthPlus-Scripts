/*
Round half to even - https://en.wikipedia.org/wiki/Rounding#Round_half_to_even
*/


### Version: 1.0.2


### Changelog ###
#---------------
# 1.0.2
# Removed RoundHalfToEven_mod2.
# Added parameter mod to RoundHalfToEven.
#---------------
# Fixed check for negative numbers.
#---------------
# Initial version.


Function RoundHalfToEven(float n, int "mod")
{
    mod = Default(mod, 1)

    q = n / mod

    if (Frac(q) == 0.0) { return Int(n) }
    else if (Frac(q) == ((n < 0.0) ? -0.5 : 0.5))
    {
        f = Floor(q)
        return (f % 2 == 0) ? (f * mod) : (Ceil(q) * mod)
    }
    else { return Round(q) * mod }
}
