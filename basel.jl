include("getdigit_n.jl")
include("myprintf.jl")
using Printf
using .GetDigit_n
using .MyPrintf

const DIGIT = 5
const MAXN = 500000

function basel(n)
    result = BigFloat(0)
    
    for i = 1:n
        result += BigFloat(1) / (BigFloat(i * i))
    end

    return sqrt(BigFloat(6) * result)
end

function main()
    n = GetDigit_n.getn(basel, MAXN, DIGIT, true)
    precision = GetDigit_n.getdigit(basel, n, DIGIT, true)
    precision = GetDigit_n.getdigit_2(basel, n, DIGIT, precision)

    setprecision(precision)
    MyPrintf.myprintf("π（計算値） = ", DIGIT, basel(n))
    MyPrintf.myprintf("π（厳密値） = ", DIGIT, BigFloat(π))
    @printf("n = %d, 計算%d桁で、%d桁求まりました\n", n, precision, DIGIT)
end

main()