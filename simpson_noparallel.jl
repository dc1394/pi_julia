module Simpson_noparallel
    function simpson(func, x1::BigFloat, x2::BigFloat, n)
        dh = (x2 - x1) / BigFloat(n)

        # Simpsonの公式によって数値積分する
        m = div(n, 2)
        sum = func(x1)
        @simd for i = 1:m
            fx1 = func(x1 + dh * BigFloat(i * 2 - 1))
            fx2 = func(x1 + dh * BigFloat(i * 2))
      
            sum += BigFloat(4) * fx1 + BigFloat(2) * fx2
        end
        sum -= func(x2)

        return dh / BigFloat(3) * sum
    end
end