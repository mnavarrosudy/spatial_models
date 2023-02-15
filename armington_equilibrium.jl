
function solve_armington_eq(σ, τ, A, L, a, tol = 1e-5, damp = .1)
    # the equilibrium is defined by two sets of equations: (1) the wages w, and (2) the expenditure shares λ
    w, λ  = ones(size(A)), zeros(size(a))
    wage_error = 1e5
    while wage_error > tol
        # initialize denominator of 
        denominator, wL = zeros(size(A)), zeros(size(A))
        # iterate over 
        for k in eachindex(A)
            denominator .+= a[k,:] .* (τ[k,:] * w[k] / A[k]).^(1 .- σ)
        end
        for i in eachindex(A)
            wL .+= a[:,i] .* (τ[:,i] .* w ./ A).^(1 .- σ) .* w[i] .* L[i] ./ denominator[i]
        end
        wnew = wL ./ L 
        wage_error = maximum(abs.(wnew .- w)./w)
        w = damp .* wnew .+ (1 - damp) .* w
    end
    for o in eachindex(A), d in eachindex(A)
        λ[o,d] = a[o,d] * (τ[o,d] * w[o] / A[o])^(1 - σ) / sum(a[:,d] .* (τ[:,d] .* w[:] ./ A[:]).^(1 .- σ))
    end
    return w, λ
end

# parameters for 2 regions
τ = [1. 5; 5. 1.] # iceberg trade cost
a = [1. 1.; 1. 1.] # taste parameter
A = [1., 1.] # productivity
L = [1., 1.] # labor endowment
σ = 2. # elasticity of substitution

w, λ = solve_armington_eq(σ, τ, A, L, a);
display(w)
display(λ)