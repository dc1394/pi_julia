include("getdigit_n.jl")
include("myprintf.jl")
using Printf
using .GetDigit_n
using .MyPrintf

const DIGIT = 5
const MAXN = 1500000

function madhava_leibniz(n)
    result = BigFloat(0)
    for i = 1:n
        if i % 2 == 1
            result += BigFloat(1) / BigFloat(2 * i - 1)
        else
            result -= BigFloat(1) / BigFloat(2 * i - 1)
        end
    end

    return BigFloat(4) * result
end

function main()
    n = GetDigit_n.getn(madhava_leibniz, MAXN, DIGIT, true)
    precision = GetDigit_n.getdigit(madhava_leibniz, n, DIGIT, true)
    precision = GetDigit_n.getdigit_2(madhava_leibniz, n, DIGIT, precision)

    setprecision(precision)
    MyPrintf.myprintf("π（計算値） = ", DIGIT, madhava_leibniz(n))
    MyPrintf.myprintf("π（厳密値） = ", DIGIT, BigFloat(π))
    @printf("n = %d, 計算%d桁で、%d桁求まりました\n", n, precision, DIGIT)
end

main()