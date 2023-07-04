# This loads the package manager
using Pkg

#=
Pkg.add("Random")
Pkg.add("JLD2")
Pkg.add("Distributions")
Pkg.add("StatsBase")
Pkg.add("DelimitedFiles")
=#

using Random, JLD2, Distributions, StatsBase, DelimitedFiles

# Get the path of the main directory
main_dir = dirname(@__DIR__)

function mc_data_gen()
    # Number of iterations, number of sigmas, and number of observations for a and b shocks
    niterations = 1000
    nsigmas = 4
    nobs = 121

    # Vectors of iterations and sigmas
    iterations = collect(1:niterations)
    sigmas = collect(range(0, 1, length = nsigmas))

    # Initialize Montecarlo dataset indexed by iterations
    mc_data = zeros(niterations*nsigmas*nobs, 6)
    mc_data[:, 1] = repeat(iterations, inner = nsigmas*nobs)

    # For each iteration, we have the range of sigmas to evaluate
    sigmas_seq = repeat(sigmas, inner = nobs)
    mc_data[:, 2] = repeat(sigmas_seq, outer = niterations)

    # Draw independent and identically distributed random vectors for each sigma and iteration

    x = 0
    for i in 1:nsigmas*niterations
        # Productivity shock
        a = zeros(nobs, 1)
        a = exp.(randn(nobs, 1))
        a = a ./ geomean(a)

        # Amenities shock
        b = zeros(nobs, 1)
        b = exp.(randn(nobs, 1))
        b = b ./ geomean(b)

        # Error in period 0
        #err_0 = rand(Normal(0, mc_data[1+x, 2]), nobs)
        err_0 = zeros(nobs, 1)
        err_0 = exp.(rand(Normal(0, mc_data[1+x, 2]), nobs))
        err_0 = err_0 ./ geomean(err_0)

        # Error in period 1
        #err_1 = rand(Normal(0, mc_data[1+x, 2]), nobs)
        err_1 = zeros(nobs, 1)
        err_1 = exp.(rand(Normal(0, mc_data[1+x, 2]), nobs))
        err_1 = err_1 ./ geomean(err_1)
        
        # Store the vectors a, b, err_0, err_1
        mc_data[1+x:nobs+x, 3] = a
        mc_data[1+x:nobs+x, 4] = b
        mc_data[1+x:nobs+x, 5] = err_0
        mc_data[1+x:nobs+x, 6] = err_1
        x = x+nobs
    end

    # Export Montecarlo dataset in Julia File Format (JLD2)
    data_julia_dir = joinpath(main_dir, "data", "montecarlo_data.jld2")
    save_object(data_julia_dir, mc_data)

    # Export Montecarlo dataset in Julia File Format (JLD2)
    data_csv_dir = joinpath(main_dir, "data", "montecarlo_data.csv")
    writedlm(data_csv_dir, mc_data, ", ")

    # Read to test
    # data = load_object(data_dir)
end