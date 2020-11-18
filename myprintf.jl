module MyPrintf
    using Printf

    function myprintf(str, precision, value)
        fmt = str * "%." * string(precision) * "f\n"

        @eval @printf($fmt, $value)
    end
end