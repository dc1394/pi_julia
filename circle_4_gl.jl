include("gausslegendre.jl")
include("getdigit_n.jl")
include("myprintf.jl")
using Printf
using .GaussLegendre
using .GetDigit_n
using .MyPrintf

const DIGIT = 17
const MAXN = 1000000

const DIGIT2 = 11
const MAXN2 = 10000

function circle_4_gl(n)
    return BigFloat(4) * GaussLegendre.gauleg(x::BigFloat -> sqrt(BigFloat(1) - x * x), BigFloat(0), BigFloat(1), n)
end

function main()
    #n = GetDigit_n.getn(circle_4_gl, MAXN, DIGIT, true)
    #recision = GetDigit_n.getdigit(circle_4_gl, n, DIGIT, true)
    #precision = GetDigit_n.getdigit_2(circle_4_gl, n, DIGIT, precision)

    #setprecision(precision)
    #MyPrintf.myprintf("π（計算値） = ", DIGIT, circle_4_gl(n))
    #MyPrintf.myprintf("π（厳密値） = ", DIGIT, BigFloat(π))
    #@printf("n = %d, 計算%d桁で、%d桁求まりました\n", n, precision, DIGIT)
    
    n2 = GetDigit_n.getn(circle_4_gl, MAXN2, DIGIT2, true)
    precision2 = GetDigit_n.getdigit(circle_4_gl, n2, DIGIT2, true)
    precision2 = GetDigit_n.getdigit_2(circle_4_gl, n2, DIGIT2, precision2)

    setprecision(precision2)
    MyPrintf.myprintf("π（計算値） = ", DIGIT2, circle_4_gl(n2))
    MyPrintf.myprintf("π（厳密値） = ", DIGIT2, BigFloat(π))
    @printf("n = %d, 計算%d桁で、%d桁求まりました\n", n2, precision2, DIGIT2)
end

main()