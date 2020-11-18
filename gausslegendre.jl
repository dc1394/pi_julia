module GaussLegendre
	using LinearAlgebra
	using Printf

	function gausslegendre(n)
		# COMPUTE GAUSS-LEGENDRE NODES AND WEIGHTS USING ASYMPTOTIC EXPANSIONS.
		# COMPLEXITY O(n).
	
		# Nodes and weights:
		m = (n + 1) >> 1
		a = besselZeroRoots(m)
		rmul!(a, BigFloat(1) / (BigFloat(n) + BigFloat(1) / BigFloat(2)))
		x = legpts_nodes(n, a)
		w = legpts_weights(n, m, a)
		# Use symmetry to get the others:
		resize!(x, n)
		resize!(w, n)
		@inbounds for i in 1:m
			x[n + 1 - i] = x[i]
			w[n + 1 - i] = w[i]
		end
		@inbounds for i in 1:m
			x[i] = -x[i]
		end
		@inbounds mod(n, 2) == 1 && (x[m] = 0.0)
		x, w
	end

	function legpts_nodes(n, a)
		# ASYMPTOTIC EXPANSION FOR THE GAUSS-LEGENDRE NODES.
		vn = BigFloat(1) / (BigFloat(n) + BigFloat(1) / BigFloat(2))
		m = length(a)
		nodes = cot.(a)
		vn² = vn * vn
		vn⁴ = vn² * vn²
		@inbounds if n <= 255
			vn⁶ = vn⁴ * vn²
			for i in 1:m
				u = nodes[i]
				u² = u^2
				ai = a[i]
				ai² = ai * ai
				ai³ = ai² * ai
				ai⁵ = ai² * ai³
				node = ai + (u - BigFloat(1) / ai) / BigFloat(8) * vn²
				v1 = (BigFloat(6) * (BigFloat(1) + u²) / ai + BigFloat(25) / ai³ - u * muladd(BigFloat(31), u², BigFloat(33))) / BigFloat(384)
				v2 = u * @evalpoly(u², BigFloat(2595) / BigFloat(15360), BigFloat(6350) / BigFloat(15360), BigFloat(3779) / BigFloat(15360))
				v3 = (1 + u²) * (-muladd(BigFloat(31) / BigFloat(1024), u², BigFloat(11) / BigFloat(1024)) / ai +
								 u / BigFloat(512) / ai² + BigFloat(-25) / BigFloat(3072) / ai³)
				v4 = (v2 - BigFloat(1073) / BigFloat(5120) / ai⁵ + v3)
				node = muladd(v1, vn⁴, node)
				node = muladd(v4, vn⁶, node)
				nodes[i] = node
			end
		elseif n <= 3950
			for i in 1:m
				u = nodes[i]
				u² = u^2
				ai = a[i]
				ai² = ai * ai
				ai³ = ai² * ai
				node = ai + (u - 1 / ai) / 8 * vn²
				v1 = (BigFloat(6) * (BigFloat(1) + u²) / ai + BigFloat(25) / ai³ - u * muladd(BigFloat(31), u², BigFloat(33))) / BigFloat(384)
				node = muladd(v1, vn⁴, node)
				nodes[i] = node
			end
		else
			for i in 1:m
				u = nodes[i]
				ai = a[i]
				node = ai + (u - BigFloat(1) / ai) / BigFloat(8) * vn²
				nodes[i] = node
			end
		end
		@inbounds for jj = 1:m
			nodes[jj] = cos(nodes[jj])
		end
		nodes
	end
	
	function legpts_weights(n, m, a)
		# ASYMPTOTIC EXPANSION FOR THE GAUSS-LEGENDRE WEIGHTS.
		vn = BigFloat(1) / (BigFloat(n) + BigFloat(1) / BigFloat(2))
		vn² = vn^2
		weights = Array{Float64}(undef, m)
		if n <= 850000
			@inbounds for i in 1:m
				weights[i] = cot(a[i])
			end
		end
		# Split out the part that can be vectorized by llvm
		@inbounds if n <= 170
			for i in 1:m
				u = weights[i]
				u² = u^2
				ai = a[i]
				ai⁻¹ = 1 / ai
				ai² = ai^2
				ai⁻² = 1 / ai²
				ua = u * ai
				W1 = muladd(ua - BigFloat(1), ai⁻², BigFloat(1)) / BigFloat(8)
				W2 = @evalpoly(ai⁻², @evalpoly(u², BigFloat(-27), BigFloat(-84), BigFloat(-56)),
							   muladd(BigFloat(-3), muladd(u², BigFloat(-2), BigFloat(1)), BigFloat(6) * ua),
							   muladd(ua, BigFloat(-31), BigFloat(81))) / BigFloat(384)
				W3 = @evalpoly(ai⁻¹, @evalpoly(u², BigFloat(153) / BigFloat(1024), BigFloat(295) / BigFloat(256), BigFloat(187) / BigFloat(96),
											   BigFloat(151) / BigFloat(160)),
							   @evalpoly(u², BigFloat(-65) / BigFloat(1024), BigFloat(-119) / BigFloat(768), BigFloat(-35) / BigFloat(384)) * u,
							   @evalpoly(u², BigFloat(5) / BigFloat(512), BigFloat(15) / BigFloat(512), BigFloat(7) / BigFloat(384)),
							   muladd(u², BigFloat(1) / BigFloat(512), BigFloat(-13) / BigFloat(1536)) * u,
							   muladd(u², BigFloat(-7) / BigFloat(384), + BigFloat(53) / BigFloat(3072)),
							   BigFloat(3749) / BigFloat(15360) * u, BigFloat(-1125) / BigFloat(1024))
				weights[i] = @evalpoly(vn², BigFloat(1) / vn² + W1, W2, W3)
			end
		elseif n <= 1500
			for i in 1:m
				u = weights[i]
				u² = u^2
				ai = a[i]
				ai² = ai^2
				ai⁻² = 1 / ai²
				ua = u * ai
				W1 = muladd(ua - BigFloat(1), ai⁻², BigFloat(1)) / BigFloat(8)
				W2 = @evalpoly(ai⁻², @evalpoly(u², BigFloat(-27), BigFloat(-84), BigFloat(-56)),
							   muladd(BigFloat(-3), muladd(u², BigFloat(-2), BigFloat(1)), BigFloat(6) * ua),
							   muladd(ua, BigFloat(-31), BigFloat(81))) / BigFloat(384)
				weights[i] = muladd(vn², W2, 1 / vn² + W1)
			end
		elseif n <= 850000
			for i in 1:m
				u = weights[i]
				u² = u^2
				ai = a[i]
				ai² = ai^2
				ai⁻² = BigFloat(1) / ai²
				ua = u * ai
				W1 = muladd(ua - BigFloat(1), ai⁻², BigFloat(1)) / BigFloat(8)
				weights[i] = BigFloat(1) / vn² + W1
			end
		else
			for i in 1:m
				weights[i] = BigFloat(1) / vn²
			end
		end
		bJ1 = besselJ1(m)
		@inbounds for i in 1:m
			weights[i] = BigFloat(2) / (bJ1[i] * (a[i] / sin(a[i])) * weights[i])
		end
		return weights
	end
	
	const besselZeros_20 = [parse(BigFloat, "2.40482555769577244220158718235325068235397338867188"),
							parse(BigFloat, "5.52007811028631056871063265134580433368682861328125"),
							parse(BigFloat, "8.65372791291100718069628783268854022026062011718750"),
							parse(BigFloat, "11.7915344390142813324473536340519785881042480468750"),
							parse(BigFloat, "14.9309177084877866548140445956960320472717285156250"),
							parse(BigFloat, "18.0710639679109235089526919182389974594116210937500"),
							parse(BigFloat, "21.2116366298792584643706504721194505691528320312500"),
							parse(BigFloat, "24.3524715307493018201512313680723309516906738281250"),
							parse(BigFloat, "27.4934791320402531766831089043989777565002441406250"),
							parse(BigFloat, "30.6346064684319756565855641383677721023559570312500"),
							parse(BigFloat, "33.7758202135735672300143050961196422576904296875000"),
                        	parse(BigFloat, "36.9170983536640449074184289202094078063964843750000"),
							parse(BigFloat, "40.0584257646282395626258221454918384552001953125000"),
							parse(BigFloat, "43.1997917131767295018107688520103693008422851562500"),
							parse(BigFloat, "46.3411883716618149264832027256488800048828125000000"),
							parse(BigFloat, "49.4826098973978147910202096682041883468627929687500"),
							parse(BigFloat, "52.6240518411149977850982395466417074203491210937500"),
							parse(BigFloat, "55.7655107550199815591440710704773664474487304687500"),
							parse(BigFloat, "58.9069839260809402503582532517611980438232421875000"),
							parse(BigFloat, "62.0484691902267044838481524493545293807983398437500")]

	function besselZeroRoots(m)
		# BESSEL0ROOTS ROOTS OF BESSELJ(0,x). USE ASYMPTOTICS.
		# Use McMahon's expansion for the remainder (NIST, 10.21.19):
		jk = Array{BigFloat}(undef, m)
		p = (BigFloat(1071187749376) / BigFloat(315), BigFloat(0), BigFloat(-401743168) / BigFloat(105), BigFloat(0), BigFloat(120928) / BigFloat(15),
			 BigFloat(0), BigFloat(-124) / BigFloat(3), BigFloat(0), BigFloat(1), BigFloat(0))
		# First 20 are precomputed:
		@inbounds for jj = 1:min(m, 20)
			jk[jj] = besselZeros_20[jj]
		end
		@inbounds for jj = 21:min(m, 47)
			ak = BigFloat(π) * (jj - BigFloat(1) / BigFloat(4))
			ak82 = (BigFloat(1) / BigFloat(8) / ak)^2
			jk[jj] = ak + BigFloat(1) / BigFloat(8) / ak * @evalpoly(ak82, BigFloat(1), p[7], p[5], p[3])
		end
		@inbounds for jj = 48:min(m, 344)
			ak = BigFloat(π) * (jj - BigFloat(1) / BigFloat(4))
			ak82 = (BigFloat(1) / BigFloat(8) / ak)^2
			jk[jj] = ak + BigFloat(1) / BigFloat(8) / ak * @evalpoly(ak82, BigFloat(1), p[7], p[5])
		end
		@inbounds for jj = 345:min(m,13191)
			ak = BigFloat(π) * (jj - BigFloat(1) / BigFloat(4))
			ak82 = (BigFloat(1) / BigFloat(8) / ak)^2
			jk[jj] = ak + BigFloat(1) / BigFloat(8) / ak * muladd(ak82, p[7], BigFloat(1))
		end
		@inbounds for jj = 13192:m
			ak = BigFloat(π) * (jj - BigFloat(1) / BigFloat(4))
			jk[jj] = ak + BigFloat(1) / BigFloat(8) / ak
		end
		return jk
	end

	const besselJ1_10 = [parse(BigFloat, "0.26951412394191699930425603831096479552416724046623932"),
						 parse(BigFloat, "0.11578013858220369920087677406869183804800006055233685"),
						 parse(BigFloat, "0.07368635113640830090795457351166741709059792271399662"),
						 parse(BigFloat, "0.05403757319811628461998670001810067913900791658910733"),
						 parse(BigFloat, "0.04266142901724308722505899310539410056259036644129061"),
						 parse(BigFloat, "0.03524210349099609759173136127110351041151336643781974"),
						 parse(BigFloat, "0.03002107010305467407541978396539677780280158649895994"),
                     	 parse(BigFloat, "0.02614739149530809055943469810813860988716164552883349"),
						 parse(BigFloat, "0.02315912182469139499312285631116841466379136562175513"),
						 parse(BigFloat, "0.02078382912226785687257060668341061486452086057459184")]

	function besselJ1(m)
		# BESSELJ1 EVALUATE BESSELJ(1,x)^2 AT ROOTS OF BESSELJ(0,x).
		# USE ASYMPTOTICS. Use Taylor series of (NIST, 10.17.3) and McMahon's
		# expansion (NIST, 10.21.19):
		Jk2 = Array{Float64}(undef, m)
		c = (BigFloat(-171497088497) / BigFloat(15206400), BigFloat(461797) / BigFloat(1152), BigFloat(-172913) / BigFloat(8064),
			 BigFloat(151) / BigFloat(80), BigFloat(-7) / BigFloat(24), BigFloat(0), BigFloat(2))
		# First 10 are precomputed:
		@inbounds for jj = 1:min(m, 10)
			Jk2[jj] = besselJ1_10[jj]
		end
		@inbounds for jj = 11:min(m, 15)
			ak = BigFloat(π) * (jj - BigFloat(1) / BigFloat(4))
			ak2 = (1 / ak)^2
			Jk2[jj] = 1 / (BigFloat(π) * ak) * muladd(@evalpoly(ak2, c[5], c[4], c[3],
													  c[2], c[1]), ak2^2, c[7])
		end
		@inbounds for jj = 16:min(m, 21)
			ak = BigFloat(π) * (jj - BigFloat(1) / BigFloat(4))
			ak2 = (1 / ak)^2
			Jk2[jj] = 1 / (BigFloat(π) * ak) * muladd(@evalpoly(ak2, c[5], c[4], c[3], c[2]),
											ak2^2, c[7])
		end
		@inbounds for jj = 22:min(m,55)
			ak = BigFloat(π) * (jj - BigFloat(1) / BigFloat(4))
			ak2 = (1 / ak)^2
			Jk2[jj] = 1 / (BigFloat(π) * ak) * muladd(@evalpoly(ak2, c[5], c[4], c[3]),
											ak2^2, c[7])
		end
		@inbounds for jj = 56:min(m,279)
			ak = BigFloat(π) * (jj - BigFloat(1) / BigFloat(4))
			ak2 = (BigFloat(1) / ak)^2
			Jk2[jj] = BigFloat(1) / (BigFloat(π) * ak) * muladd(muladd(ak2, c[4], c[5]), ak2^2, c[7])
		end
		@inbounds for jj = 280:min(m,2279)
			ak = BigFloat(π) * (jj - BigFloat(1) / BigFloat(4))
			ak2 = (BigFloat(1) / ak)^2
			Jk2[jj] = BigFloat(1) / (BigFloat(π) * ak) * muladd(ak2^2, c[5], c[7])
		end
		@inbounds for jj = 2280:m
			ak = BigFloat(π) * (jj - BigFloat(1) / BigFloat(4))
			Jk2[jj] = BigFloat(1) / (BigFloat(π) * ak) * c[7]
		end
		return Jk2
	end

    function gaulegtemp(x1::BigFloat, x2::BigFloat, n, digit)
        setprecision(digit)

        m = div(n + 1, 2)
	    xm = BigFloat(1) / BigFloat(2) * (x2 + x1)
	    xl = BigFloat(1) / BigFloat(2) * (x2 - x1)
	
		x = zeros(BigFloat, n)
		w = zeros(BigFloat, n)

		pp = BigFloat(0)
		@inbounds for i = 1:m
			z = cos(BigFloat(pi) * (BigFloat(i) - BigFloat(1) / BigFloat(4)) / (BigFloat(n) + BigFloat(1) / BigFloat(2)))
		
        	while true
				p1 = BigFloat(1)
				p2 = BigFloat(0)

				for j = 1:n
					p3 = p2
					p2 = p1
					p1 = (BigFloat(2 * j - 1) * z * p2 - BigFloat(j - 1) * p3) / BigFloat(j)
				end

				pp = BigFloat(n) * (z * p1 - p2) / (z * z - BigFloat(1))
				z1 = z
				z = z1 - p1 / pp
				
				if abs(z - z1) <= BigFloat(10)^(-BigFloat(3))
                	break
            	end
			end
	
			func = function (a)
				p1a = BigFloat(1)
				p2a = a

				for j = 1:n
					p3a = p2a
					p2a = p1a
					p1a = (BigFloat(2 * j - 1) * a * p2a - BigFloat(j - 1) * p3a) / BigFloat(j)
				end

				return p1a
			end

			z = find_zero(func, z)
			
			x[i] = xm - xl * z
			x[n + 1 - i] = xm + xl * z
			w[i] = BigFloat(2) * xl / ((BigFloat(1) - z * z ) * pp * pp)
			w[n + 1 - i] = w[i]
		end

        return x, w
	end

    function gauleg(func, x1::BigFloat, x2::BigFloat, n)
		x, w = gausslegendre(n)
		
		xm = BigFloat(1) / BigFloat(2) * (x1 + x2)
    	xr = BigFloat(1) / BigFloat(2) * (x2 - x1)
		
		return sum(i -> w[i] * func(xm + xr * x[i]), eachindex(x)) * xr
    end
end

    