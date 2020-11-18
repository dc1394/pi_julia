include("getdigit_n.jl")
include("myprintf.jl")
using Printf
using .GetDigit_n
using .MyPrintf

const DIGIT = 100
const MAXN = 500

function madhava(n)
    result = BigFloat(0)
    for i = 1:n
        if i % 2 == 1
            result += BigFloat(1) / (BigFloat(2 * i - 1) * BigFloat(3)^(BigFloat(i - 1)))
        else
            result -= BigFloat(1) / (BigFloat(2 * i - 1) * BigFloat(3)^(BigFloat(i - 1)))
        end
    end

    return sqrt(BigFloat(12)) * result
end

function main()
    n = GetDigit_n.getn(madhava, MAXN, DIGIT, true)
    precision = GetDigit_n.getdigit(madhava, n, DIGIT, true)
    precision = GetDigit_n.getdigit_2(madhava, n, DIGIT, precision)

    setprecision(precision)
    MyPrintf.myprintf("π（計算値） = ", DIGIT, madhava(n))
    MyPrintf.myprintf("π（厳密値） = ", DIGIT, BigFloat(π))
    @printf("n = %d, 計算%d桁で、%d桁求まりました\n", n, precision, DIGIT)
end

main()
