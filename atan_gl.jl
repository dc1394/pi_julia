include("gausslegendre.jl")
include("getdigit_n.jl")
include("myprintf.jl")
using Printf
using .GaussLegendre
using .GetDigit_n
using .MyPrintf

const DIGIT = 17
const MAXN = 1000

function atan_gl(n)
    return BigFloat(4) * GaussLegendre.gauleg(x::BigFloat -> BigFloat(1) / (BigFloat(1) + x * x), BigFloat(0), BigFloat(1), n)
end

function main()
    n = GetDigit_n.getn_linear(atan_gl, MAXN, DIGIT, true)
    precision = GetDigit_n.getdigit(atan_gl, n, DIGIT, true)
    precision = GetDigit_n.getdigit_2(atan_gl, n, DIGIT, precision)

    setprecision(precision)
    MyPrintf.myprintf("π（計算値） = ", DIGIT, atan_gl(n))
    MyPrintf.myprintf("π（厳密値） = ", DIGIT, BigFloat(π))
    @printf("n = %d, 計算%d桁で、%d桁求まりました\n", n, precision, DIGIT)
end

main()