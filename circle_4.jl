include("getdigit_n.jl")
include("myprintf.jl")
include("simpson_noparallel.jl")
using Printf
using .GetDigit_n
using .MyPrintf
using .Simpson_noparallel

const DIGIT = 11
const MAXN = 60000000

function circle_4(n)
    return BigFloat(4) * Simpson_noparallel.simpson(x::BigFloat -> sqrt(BigFloat(1) - x * x), BigFloat(0), BigFloat(1), n)
end

function main()
    n = GetDigit_n.getn_even(circle_4, MAXN, DIGIT, true)
    precision = GetDigit_n.getdigit(circle_4, n, DIGIT, true)
    precision = GetDigit_n.getdigit_2(circle_4, n, DIGIT, precision)

    setprecision(precision)
    MyPrintf.myprintf("π（計算値） = ", DIGIT, circle_4(n))
    MyPrintf.myprintf("π（厳密値） = ", DIGIT, BigFloat(π))
    @printf("n = %d, 計算%d桁で、%d桁求まりました\n", n, precision, DIGIT)
end

main()