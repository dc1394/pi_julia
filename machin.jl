include("getdigit_n.jl")
include("myprintf.jl")
using Printf
using .GetDigit_n
using .MyPrintf

const DIGIT = 100
const MAXN = 500

function machin(n)
    result = BigFloat(4) * myatan(BigFloat(1) / BigFloat(5), n) - myatan(BigFloat(1) / BigFloat(239), n)
    return BigFloat(4) * result
end

function myatan(x, n)
    result = BigFloat(0)
    xn = x

    for i = 0:n - 1
        denominator = BigFloat(2 * i + 1)

        if i % 2 != 0
            denominator *= BigFloat(- 1)
        end

        result += xn / denominator

        xn *= (x * x)
    end

    return result
end

function main()
    n = GetDigit_n.getn(machin, MAXN, DIGIT, true)
    precision = GetDigit_n.getdigit(machin, n, DIGIT, true)
    precision = GetDigit_n.getdigit_2(machin, n, DIGIT, precision)

    setprecision(precision)
    MyPrintf.myprintf("π（計算値） = ", DIGIT, machin(n))
    MyPrintf.myprintf("π（厳密値） = ", DIGIT, BigFloat(π))
    @printf("n = %d, 計算%d桁で、%d桁求まりました\n", n, precision, DIGIT)
end

main()