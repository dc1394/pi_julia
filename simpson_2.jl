module Simpson_2
    function simpson(func, x1::BigFloat, x2::BigFloat, dh::BigFloat)
        n = ceil(Int, (x2 - x1) / dh)
        n = n & 1 == 0 ? n : n + 1

        # Simpsonの公式によって数値積分する
        m = div(n, 2)

        sum = func(x1)
        @simd for i = 1:div(n, 2)
            fx1 = func(x1 + dh * BigFloat(i * 2 - 1))
            fx2 = func(x1 + dh * BigFloat(i * 2))
      
            sum += BigFloat(4) * fx1 + BigFloat(2) * fx2
        end
        sum -= func(x2)
        
        return dh / BigFloat(3) * sum
    end
end