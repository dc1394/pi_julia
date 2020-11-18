include("getdigit_n_xc.jl")
include("simpson.jl")
include("simpson_2.jl")
using Printf
using .GetDigit_n_xc
using .Simpson
using .Simpson_2

const DIGIT = 15
const MAXDH = BigFloat(1) / BigFloat(60000000)

function gauss(xc::BigFloat, n::Int64)
    res = Simpson.simpson(x::BigFloat -> exp(- x * x), BigFloat(0), xc, n)

    return BigFloat(4) * res * res
end

function gauss(xc::BigFloat, dh::BigFloat)
    res = Simpson_2.simpson(x::BigFloat -> exp(- x * x), BigFloat(0), xc, dh)

    a = BigFloat(4) * res * res
    @printf("%.15f\n", a)
    return a
end


function main()
    xc = GetDigit_n_xc.getxc(gauss, MAXDH, DIGIT)
    @printf("%.100f\n", xc)
    #@printf("%.100f\n", gauss(BigFloat(2), BigFloat(1) / BigFloat(100000), 100) - BigFloat(pi))
    #@printf("%.100f\n", gauss(BigFloat(100), BigFloat(1) / BigFloat(100000), 100) - BigFloat(pi))
    #@printf("%.100f\n", gauss(BigFloat(5), 10000, 100))
    #digit = GetDigit_n_even.getdigit(atan, n, DIGIT)
    #@printf("n = %d, 計算%d桁で、%d桁求まりました\n", n, digit, DIGIT)
end

main()