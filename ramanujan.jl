include("getdigit_n.jl")
include("myprintf.jl")
using Printf
using .GetDigit_n
using .MyPrintf

const DIGIT = 100
const MAXN = 100

function factorial(m)
    return m < 2 ? BigFloat(1) : reduce(*, [BigFloat(i) for i in 2:m])
end

function ramanujan(n)
    res = BigFloat(0)
    for k = 0:n
        numerator = factorial(4 * k) * (BigFloat(1103) + BigFloat(26390 * k))
        denominator = (factorial(k) * (BigFloat(396))^(BigFloat(k)))^(BigFloat(4))

        res += numerator / denominator
    end

    return BigFloat(9801) / (res * BigFloat(2) * sqrt(BigFloat(2)))
end

function main()
    n = GetDigit_n.getn(ramanujan, MAXN, DIGIT, true)
    precision = GetDigit_n.getdigit(ramanujan, n, DIGIT, true)
    precision = GetDigit_n.getdigit_2(ramanujan, n, DIGIT, precision)

    setprecision(precision)
    MyPrintf.myprintf("π（計算値） = ", DIGIT, ramanujan(n))
    MyPrintf.myprintf("π（厳密値） = ", DIGIT, BigFloat(π))
    @printf("n = %d, 計算%d桁で、%d桁求まりました\n", n, precision, DIGIT)
end

main()