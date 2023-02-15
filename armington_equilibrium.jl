

function solve_armington_eq(σ, τ, A, L, a, tol = 1e-5, damp = .1)
    w, λ  = ones(size(A)), zeros(size(a))
    wage_error = 1e5
    while wage_error > tol
        denominator, wL = zeros(size(A)), zeros(size(A))
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

τ = [1. 5; 5. 1.]; 
a = [1. 1.; 1. 1.];
A = [1., 1.];
L = [1., 1.];
σ = 2.;
w, λ = solve_armington_eq(σ, τ, A, L, a);
display(w)
display(λ)

τ = [1. 5; 5. 1.]; 
a = [1. 1.; 1. 1.];
A = [10., 1.];
L = [1., 1.];
σ = 2.;
w, λ = solve_armington_eq(σ, τ, A, L, a);
display(w)
display(λ)