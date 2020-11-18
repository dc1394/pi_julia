include("getdigit_n.jl")
include("myprintf.jl")
include("simpson.jl")
using Printf
using .GetDigit_n
using .MyPrintf
using .Simpson

const DIGIT = 17
const MAXN = 10000

function atan(n)
    return BigFloat(4) * Simpson.simpson(x::BigFloat -> BigFloat(1) / (BigFloat(1) + x * x), BigFloat(0), BigFloat(1), n)
end

function main()
    n = GetDigit_n.getn_even(atan, MAXN, DIGIT, false)
    precision = GetDigit_n.getdigit(atan, n, DIGIT, false)
    precision = GetDigit_n.getdigit_2(atan, n, DIGIT, precision)

    setprecision(precision)
    MyPrintf.myprintf("π（計算値） = ", DIGIT, atan(n))
    MyPrintf.myprintf("π（厳密値） = ", DIGIT, BigFloat(π))
    @printf("n = %d, 計算%d桁で、%d桁求まりました\n", n, precision, DIGIT)
end

main()