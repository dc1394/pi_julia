include("getdigit_n.jl")
include("myprintf.jl")
using Printf
using .GetDigit_n
using .MyPrintf

const DIGIT = 100
const MAXN = 500

function gaulegofpi(n)
    aₙ = BigFloat(1)
    bₙ = BigFloat(1) / sqrt(BigFloat(2))
    tₙ = parse(BigFloat, "0.25")
    pₙ = BigFloat(1)

    for i = 1:n
        aₙ₊₁ = (aₙ + bₙ) / BigFloat(2)
        bₙ = sqrt(aₙ * bₙ)
        tₙ = tₙ - pₙ * (aₙ - aₙ₊₁) * (aₙ - aₙ₊₁)
        pₙ = BigFloat(2) * pₙ
        aₙ = aₙ₊₁
    end

    return (aₙ + bₙ) * (aₙ + bₙ) / (BigFloat(4) * tₙ)
end

function main()
    n = GetDigit_n.getn(gaulegofpi, MAXN, DIGIT, true)
    precision = GetDigit_n.getdigit(gaulegofpi, n, DIGIT, true)
    precision = GetDigit_n.getdigit_2(gaulegofpi, n, DIGIT, precision)

    setprecision(precision)
    MyPrintf.myprintf("π（計算値） = ", DIGIT, gaulegofpi(n))
    MyPrintf.myprintf("π（厳密値） = ", DIGIT, BigFloat(π))
    @printf("n = %d, 計算%d桁で、%d桁求まりました\n", n, precision, DIGIT)
end

main()
