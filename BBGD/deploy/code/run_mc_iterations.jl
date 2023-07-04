# Get the path of the file directory
file_dir = dirname(@__FILE__)

include(joinpath(file_dir, "mc_iteration.jl"))

function run_montecarlo_iterations(ite_ini, ite_fin)
    for x in ite_ini:ite_fin
        println("Iteration ", x, ":")
        montecarlo_iteration(x)
    end
end