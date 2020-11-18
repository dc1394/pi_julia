module GetDigit_n_xc
    using Printf
    using Roots

    const INITX = BigFloat(5)
    const MAX_PRECISION = 100
    const π_str = "3.14159265358979323846264338327950288419716939937510582097494459230781640628620899862803482534211706798"
    
    function getxc(func, maxn::Int64, digit)
        setprecision(MAX_PRECISION)
        f = x -> func(x, maxn) - BigFloat(π) + BigFloat(10)^(BigFloat(-digit - 1))

        return find_zero(f, INITX, Order8())
    end

    function getxc(func, dh::BigFloat, digit)
        setprecision(MAX_PRECISION)
        f = x -> func(x, dh) - BigFloat(π) + BigFloat(10)^(BigFloat(-digit - 1))

        return find_zero(f, INITX, Order8())
    end


    function getn_linear(func, xc, maxn, digit)
        for n = 1:maxn + 1
            if n == maxn + 1
                return nothing
            end

            setprecision(MAX_PRECISION)
            res = abs(func(xc, n) - BigFloat(π))
            @printf("n = %d, res = %.50f\n", n, res)

            if res < BigFloat(10)^(BigFloat(-digit - 1))
                return n  
            end
        end

        return nhi != MAXN ? nhi : nothing
    end

    function getdigit(func, xc, n, precision)
        plo = precision
        phi = MAX_PRECISION

        # 正しい桁を二分探索で求める
        while phi - plo > 1
            p = (phi + plo) >> 1

            setprecision(p)
            res = abs(func(xc, n) - BigFloat(π))
            if res < BigFloat(10)^(BigFloat(-precision - 1))
                phi = p
            else
                plo = p
            end

            @printf("p = %d, phi = %d, plo = %d, res = %.100f\n", p, plo, phi, res)
        end

        return phi != MAX_PRECISION ? phi : nothing
    end

    function getdigit_2(func, xc, n, digit, precision)
        for p = precision:-1:digit
            setprecision(p)

            s = roundoff(func(xc, n), digit)
            @printf("p = %d, res = %s\n", p, s)
            if s != roundoff(π_str, digit)
                setprecision(p + 1)

                return roundoff(func(xc, n), digit) == roundoff(π_str, digit) ? p + 1 : getdigit_3(func, xc, n, digit, p + 1)
            end
        end

        return nothing
    end
    
    function getdigit_3(func, xc, n, digit, precision)
        p = precision

        while true
            setprecision(p)

            s = roundoff(func(xc, n), digit)
            @printf("p = %d, res = %s\n", p, s)
            if s == roundoff(π_str, digit)
                break
            end

            p += 1
        end

        return p
    end

    function roundoff(value::BigFloat, digit)
        fmt = "%." * string(digit) * "f"
            
        return @eval @sprintf($fmt, $value)
    end
    
    function roundoff(value::String, digit)
        res = collect(value)[1:digit + 3]
        if res[digit + 3] >= '5' && res[digit + 2] == '9'
            res[digit + 2] = '0'
            res[digit + 1] = Char(res[digit + 1] + 1) 
        elseif res[digit + 3] >= '5'
            res[digit + 2] = Char(res[digit + 2] + 1)
        end

        return join(res[1:digit + 2])
    end
end