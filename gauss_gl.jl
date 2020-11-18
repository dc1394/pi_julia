include("gausslegendre.jl")
include("getdigit_n_xc.jl")
include("myprintf.jl")
using Printf
using .GetDigit_n_xc
using .GaussLegendre
using .MyPrintf

const DIGIT = 15
const MAXN = 500

function gauss_gl(xc::BigFloat, n::Int64)
    res = GaussLegendre.gauleg(x::BigFloat -> exp(- x * x), BigFloat(0), xc, n)

    return BigFloat(4) * res * res
end

function main()
    xc = GetDigit_n_xc.getxc(gauss_gl, MAXN, DIGIT)
    n = GetDigit_n_xc.getn_linear(gauss_gl, xc, MAXN, DIGIT)
    precision = GetDigit_n_xc.getdigit(gauss_gl, xc, n, DIGIT)
    precision = GetDigit_n_xc.getdigit_2(gauss_gl, xc, n, DIGIT, precision)

    setprecision(precision)
    MyPrintf.myprintf("π（計算値） = ", DIGIT, gauss_gl(xc, n))
    MyPrintf.myprintf("π（厳密値） = ", DIGIT, BigFloat(π))
    @printf("xc = %.14f, n = %d, 計算%d桁で、%d桁求まりました\n", xc, n, precision, DIGIT)
end

main()