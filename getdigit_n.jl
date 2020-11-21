module GetDigit_n
    using Printf

    const MAX_PRECISION = 300
    const π_str = "3.14159265358979323846264338327950288419716939937510582097494459230781640628620899862803482534211706798"
    
    function getn(func, maxn, precision, half_precision)
        nlo = 1
        nhi = maxn

        # 正しいnを二分探索で求める
        while nhi - nlo > 1
            n = (nhi + nlo) >> 1

            setprecision(MAX_PRECISION)
            res = abs(func(n) - BigFloat(π))
            if half_precision && res < BigFloat(5) * BigFloat(10)^(BigFloat(-precision - 1))
                nhi = n
            elseif !half_precision && res < BigFloat(10)^(BigFloat(-precision - 1))
                nhi = n        
            else 
                nlo = n
            end

            @printf("n = %d, nlo = %d, nhi = %d, res = %.100f\n", n, nlo, nhi, res)
        end

        if nhi != maxn 
            return nhi
        else
            throw(DomainError(maxn, "MAXNの値が少なすぎる"))
        end
    end

    function getn_even(func, maxn, precision, half_precision)
        nlo = 2
        nhi = maxn

        # 正しいnを二分探索で求める
        while nhi - nlo > 2
            n = (nhi + nlo) >> 1
            n = n & 1 == 0 ? n : n + 1

            setprecision(MAX_PRECISION)
            res = abs(func(n) - BigFloat(pi))
            if half_precision && res < BigFloat(5) * BigFloat(10)^(BigFloat(-precision - 1))
                nhi = n
            elseif !half_precision && res < BigFloat(10)^(BigFloat(-precision - 1))
                nhi = n         
            else 
                nlo = n
            end

            @printf("n = %d, nlo = %d, nhi = %d, res = %.100f\n", n, nlo, nhi, res)
        end

        if nhi != maxn 
            return nhi
        else
            throw(DomainError(maxn, "MAXNの値が少なすぎる"))
        end
    end

    function getn_linear(func, maxn, precision, half_precision)
        for n = 1:maxn + 1
            if n == maxn + 1
                throw(DomainError(maxn, "MAXNの値が少なすぎる"))
            end

            setprecision(MAX_PRECISION)
            res = abs(func(n) - BigFloat(π))
            @printf("n = %d, res = %.50f\n", n, res)

            if half_precision && res < BigFloat(5) * BigFloat(10)^(BigFloat(-precision - 1))
                return n
            elseif !half_precision && res < BigFloat(10)^(BigFloat(-precision - 1))
                return n  
            end
        end
    end

    function getdigit(func, n, precision, half_precision)
        plo = precision
        phi = MAX_PRECISION

        # 正しい精度を二分探索で求める
        while phi - plo > 1
            p = (phi + plo) >> 1

            setprecision(p)
            res = abs(func(n) - BigFloat(π))
            if half_precision && res < BigFloat(5) * BigFloat(10)^(BigFloat(-precision - 1))
                phi = p
            elseif !half_precision && res < BigFloat(10)^(BigFloat(-precision - 1))
                phi = p
            else
                plo = p
            end

            @printf("p = %d, plo = %d, phi = %d, res = %.100f\n", p, plo, phi, res)
        end

        if phi != MAX_PRECISION 
            return phi
        else
            throw(DomainError(MAX_PRECISION, "MAXNの値が少なすぎる"))
        end
    end

    function getdigit_2(func, n, digit, precision)
        for p = precision:-1:digit
            setprecision(p)

            s = roundoff(func(n), digit)
            @printf("p = %d, res = %s\n", p, s)
            if s != roundoff(π_str, digit)
                setprecision(p + 1)

                return roundoff(func(n), digit) == roundoff(π_str, digit) ? p + 1 : getdigit_3(func, n, digit, p + 1)
            end
        end

        throw(DomainError("謎のエラー"))
    end
    
    function getdigit_3(func, n, digit, precision)
        p = precision

        while true
            setprecision(p)

            s = roundoff(func(n), digit)
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