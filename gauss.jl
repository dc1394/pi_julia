include("getdigit_n_xc.jl")
include("simpson_2.jl")
include("simpson_noparallel.jl")
include("myprintf.jl")
using Printf
using .GetDigit_n_xc
using .Simpson_2
using .Simpson_noparallel
using .MyPrintf

const DIGIT = 17
const MAXDH = BigFloat(1) / BigFloat(500)
const MAXN = 1000

function gauss(xc::BigFloat, dh::BigFloat)
    res = Simpson_2.simpson(x::BigFloat -> exp(- x * x), BigFloat(0), xc, dh)

    return BigFloat(4) * res * res
end

function gauss(xc::BigFloat, n::Int64)
    res = Simpson_noparallel.simpson(x::BigFloat -> exp(- x * x), BigFloat(0), xc, n)
    return BigFloat(4) * res * res
end

function main()
    xc = GetDigit_n_xc.getxc(gauss, MAXDH, DIGIT, true)
    n = GetDigit_n_xc.getn_even_linear(gauss, xc, MAXN, DIGIT, true)
    precision = GetDigit_n_xc.getdigit(gauss, xc, n, DIGIT, true)
    precision = GetDigit_n_xc.getdigit_2(gauss, xc, n, DIGIT, precision)

    setprecision(precision)
    MyPrintf.myprintf("π（計算値） = ", DIGIT, gauss(xc, n))
    MyPrintf.myprintf("π（厳密値） = ", DIGIT, BigFloat(π))
    @printf("xc = %.14f, n = %d, 計算%d桁で、%d桁求まりました\n", xc, n, precision, DIGIT)
end

main()