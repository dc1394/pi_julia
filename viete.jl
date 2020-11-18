include("getdigit_n.jl")
include("myprintf.jl")
using Printf
using .GetDigit_n
using .MyPrintf

const DIGIT = 100
const MAXN = 500

function viete(n)
    numerator = sqrt(BigFloat(2))
    result = BigFloat(1)
    
    for i = 1:n
        result *= (numerator / BigFloat(2))
        numerator = sqrt(BigFloat(2) + numerator)
    end

    return BigFloat(2) / result
end

function main()
    n = GetDigit_n.getn(viete, MAXN, DIGIT, true)
    precision = GetDigit_n.getdigit(viete, n, DIGIT, true)
    precision = GetDigit_n.getdigit_2(viete, n, DIGIT, precision)

    setprecision(precision)
    MyPrintf.myprintf("π（計算値） = ", DIGIT, viete(n))
    MyPrintf.myprintf("π（厳密値） = ", DIGIT, BigFloat(π))
    @printf("n = %d, 計算%d桁で、%d桁求まりました\n", n, precision, DIGIT)
end

main()
