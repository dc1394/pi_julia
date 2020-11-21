include("getdigit_n.jl")
include("myprintf.jl")
using Printf
using .GetDigit_n
using .MyPrintf

const DIGIT = 5
const MAXN = 500000

function wallis(n)
    res = BigFloat(1)
    for i = 1:div(n, 2)
        res *= BigFloat(4) * BigFloat(i * i) / (BigFloat(4) * BigFloat(i * i) - BigFloat(1))
    end

    return BigFloat(2) * res
end

function main()
    n = GetDigit_n.getn_even(wallis, MAXN, DIGIT, true)
    precision = GetDigit_n.getdigit(wallis, n, DIGIT, true)
    precision = GetDigit_n.getdigit_2(wallis, n, DIGIT, precision)

    setprecision(precision)
    MyPrintf.myprintf("π（計算値） = ", DIGIT, wallis(n))
    MyPrintf.myprintf("π（厳密値） = ", DIGIT, BigFloat(π))
    @printf("n = %d, 計算%d桁で、%d桁求まりました\n", n, precision, DIGIT)
end

main()
