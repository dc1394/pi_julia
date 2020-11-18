include("getdigit_n.jl")
include("myprintf.jl")
using Printf
using .GetDigit_n
using .MyPrintf

const DIGIT = 5
const MAXN = 500000

function brounker(n)
    res = BigFloat(2)
    for i = n:-1:1
        res = BigFloat(2) + BigFloat((2 * i  - 1) * (2 * i - 1)) / res 
    end

    return BigFloat(4) / (res - BigFloat(1))
end

function main()
    n = GetDigit_n.getn(brounker, MAXN, DIGIT, true)
    precision = GetDigit_n.getdigit(brounker, n, DIGIT, true)
    precision = GetDigit_n.getdigit_2(brounker, n, DIGIT, precision)

    setprecision(precision)
    MyPrintf.myprintf("π（計算値） = ", DIGIT, brounker(n))
    MyPrintf.myprintf("π（厳密値） = ", DIGIT, BigFloat(π))
    @printf("n = %d, 計算%d桁で、%d桁求まりました\n", n, precision, DIGIT)
end

main()