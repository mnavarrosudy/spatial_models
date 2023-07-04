# Monte Carlo for Quantitative Spatial Model
# Constant and increasing returns to scale model
# Regions specification
# Molnar, Navarro, Shilpi. May 2023

# Load the package manager
using Pkg

#=

# This updates all the already installed packages
Pkg.update()

# Add the packages I need to run this code
Pkg.add("LinearAlgebra")
Pkg.add("Images")
Pkg.add("JLD2")
Pkg.add("StatsBase")
Pkg.add("Optim")
Pkg.add("DelimitedFiles")

=#
using LinearAlgebra, Images, JLD2, StatsBase, Optim, DelimitedFiles

# Get the path of the main directory
main_dir = dirname(@__DIR__)

# Get the path of the file directory
file_dir = dirname(@__FILE__)

include(joinpath(file_dir, "effective_distance.jl"))
include(joinpath(file_dir, "solveLw.jl"))
include(joinpath(file_dir, "solveab.jl"))
include(joinpath(file_dir, "pindex.jl"))
include(joinpath(file_dir, "landprice.jl"))
include(joinpath(file_dir, "expectut.jl"))
include(joinpath(file_dir, "welfare.jl"))
include(joinpath(file_dir, "realw.jl"))

function montecarlo_iteration(iteration)

    ########################
    ### Parameterization ###
    ########################

    # Number of locations
    N = 11;

    # Number of observations
    nobs = N * N;

    # Transportation weights
    tt0 = 7.9; # Without bridges
    tt1 = 1; # With bridges

    # Share of goods in consumption expenditure (1-housing share)
    alpha = 0.75

    # Elasticity of substitution
    sigma = 4.0
    Hsigma = 5.0

    # Goods Frechet shape parameter. Controls the dispersion in productivity across goods. Elasticity of trade wrt trade costs. 
    theta = 4.0

    # Worker Frechet shape parameter. Controls the disperson of amenities across workers. Elasticity of population wrt real income.
    epsilon = 3.0

    # Elasticity of costs wrt to effective distance
    phi = 0.33 # Note: The paper says that theta*phi = 1, and for that reason he picks phi = 0.33, but theta = 4 (i.e. if theta = 4 and phi*theta = 1, then phi = 0.25)

    # Vector of parameters
    param = [alpha, theta, epsilon, sigma, Hsigma, phi]

    # Land area
    H = 100.0 * ones(nobs, 1);

    # Aggregate labor supply
    LL = 153889.0;  # US civilian labor force 2010 (Statistical Abstract, millions)

    # Fixed production cost
    F = 1.0;

    # Type of model - 1: constant returns; 2: increasing returns
    model = 1;

    ###################
    ### Trade costs ###
    ###################

    # Effective distance (Type-stability: Checked)
    eff_dist = effective_distance(tt0, tt1, N, nobs);

    # Trade costs are constant elasticity function of effective distance (i.e. a power function)
    dist_0 = eff_dist[1] .^ phi;
    dist_1 = eff_dist[2] .^ phi;

    #####################
    ### Random shocks ###
    #####################

    #iteration = 1;
    data_dir = joinpath(main_dir, "data", "montecarlo_data.jld2")
    mc_data = load_object(data_dir);
    select_rows = mc_data[:, 1] .== iteration;
    random_shocks = mc_data[select_rows, 2:6];
    sigmas = unique(mc_data[select_rows, 2]);

    ##############################
    ### Optimization Functions ###
    ##############################

    # Objective function
    function f(theta_it::Float64)
        param = [alpha, theta_it, epsilon, sigma, Hsigma, phi]
        ab_0 = solveab(param, observe_0, dist_0, nobs, model)
        ab_1 = solveab(param, observe_1, dist_1, nobs, model)
        Q = 0.5*sum((ab_0[1] .- ab_1[1]).^2) + (1-0.5)*sum((ab_0[2] .- ab_1[2]).^2)
        return Q
    end

    # Derivative (Not used yet)
    g(theta_it::Float64) = ForwardDiff.derivative(f, theta_it)

    ##################
    ### Montecarlo ###
    ##################

    # Optimization method
    opt_method = 1; # 1: Brent's method; 2: NelderMead 

    if (opt_method == 1)
        opt_method_name = "Brent's method"
    elseif (opt_method == 2)
        opt_method_name = "Nelder-Mead method"
    end

    # Optimization intermediaries and results matrix
    observe_0 = zeros(nobs, 5);
    observe_1 = zeros(nobs, 5);
    mc_opt_res = zeros(lastindex(sigmas), 5);

    # Optimization auxiliaries
    shock_min = 0.05;

    println("Starting estimation of theta using ", opt_method_name)

    for s in 1:lastindex(sigmas)
        
        sigma = sigmas[s];
        timer = time()

        ##################################################################################
        ### Random draws for the Frechet scale parameters for productivity and amenity ###
        ##################################################################################

        select_sigma_rows = random_shocks[:, 1] .== sigma

        # Log-normal random draw for productivity
        a = random_shocks[select_sigma_rows, 2]
        
        # Log-normal random draw for amanities
        b = random_shocks[select_sigma_rows, 3]

        # Econometric error for period 0
        err_0 = random_shocks[select_sigma_rows, 4]

        # Econometric error for period 1 
        err_1 = random_shocks[select_sigma_rows, 5]

        # Productivity and amenity vectors with econometric error in period 0
        a_0 = a .* err_0 # old: max.(a .+ err_0, shock_min);
        b_0 = b .* err_0 # old: max.(b .+ err_0, shock_min);

        # Productivity and amenity vectors with econometric error in period 1
        a_1 = a .* err_1 # old: max.(a .+ err_1, shock_min);
        b_1 = b .* err_1 # old: max.(b .+ err_1, shock_min);

        #####################################
        ### Solve for Population and Wage ###
        #####################################

        ################
        ### Period 0 ###
        ################

        try
            # Create matrix of productivity, amenity, land supply, total population, and fixed cost of production in period 0
            fund_0 = zeros(nobs, 5);
            fund_0[:, 1] .= a_0;
            fund_0[:, 2] .= b_0;
            fund_0[:, 3] .= H;
            fund_0[:, 4] .= LL;
            fund_0[:, 5] .= F;
            
            # Solve for region populations and wages in period 0
            w_0, L_0, tradesh_0, dtradesh_0, Lconverge_0, wconverge_0, xtic = solveLw(param, fund_0, dist_0, nobs, model);

            # Solve for price index in period 0
            #P_0 = pindex_new(param, fund_0, L_0, w_0, dtradesh_0, F, model)
                
            # Solve for land price in period 0
            #r_0 = landprice(param, fund_0, L_0, w_0)
                
            # Solve for expected utility in period 0
            #EU_0 = expectut_new(param, fund_0, L_0, w_0, P_0, r_0, dtradesh_0, model)

            # Solve for real wages in period 0
            #realwage_0 = realw_new(param, fund_0, L_0, dtradesh_0, model);

            # Solve for welfare in period 0
            #welf_0 = welfare_new(param, fund_0, L_0, dtradesh_0, model);

            # Create matrix of population, wage, land supply, total population, and fixed cost of production in period 0
            observe_0[:, 1] = L_0;
            observe_0[:, 2] = w_0;
            observe_0[:, 3] = H;
            observe_0[:, 4] .= LL;
            observe_0[:, 5] .= F;

            ################
            ### Period 1 ###
            ################

            # Create matrix of productivity, amenity, land supply, total population, and fixed cost of production in period 1
            fund_1 = zeros(nobs, 5);
            fund_1[:, 1] .= a_1;
            fund_1[:, 2] .= b_1;
            fund_1[:, 3] .= H;
            fund_1[:, 4] .= LL;
            fund_1[:, 5] .= F;
                
            # Solve for region populations and wages in period 1
            w_1, L_1, tradesh_1, dtradesh_1, Lconverge_1, wconverge_1, xtic = solveLw(param, fund_1, dist_1, nobs, model);
            
            # Solve for price index in period 1
            #P_1 = pindex_new(param, fund_1, L_1, w_1, dtradesh_1, F, model)

            # Solve for land price in period 1
            #r_1 = landprice(param, fund_1, L_1, w_1)

            # Solve for expected utility in period 1
            #EU_1 = expectut_new(param, fund_1, L_1, w_1, P_1, r_1, dtradesh_1, model)

            # Solve for real wages in period 1
            #realwage_1 = realw_new(param, fund_1, L_1, dtradesh_1, model);

            # Solve for welfare in period 1
            #welf_1 = welfare_new(param, fund_1, L_1, dtradesh_1, model);

            # Create matrix of population, wage, and land supply in period 1
            observe_1[:, 1] .= L_1;
            observe_1[:, 2] .= w_1;
            observe_1[:, 3] .= H;
            observe_1[:, 4] .= LL;
            observe_1[:, 5] .= F;
        catch
            println("Error in the calculation of populations and wages for sigma = ", round(sigma; digits = 2))
            mc_opt_res[s, 1] = sigma;
            mc_opt_res[s, 2] = -99;
            mc_opt_res[s, 3] = 0;
            mc_opt_res[s, 4] = 0;
            timer = time() - timer;
            break
        end

        ####################
        ### Optimization ###
        ####################

        if (opt_method == 1)
            # Univariate functions on Bounded Intervals: Brent's method 
            res = optimize(f, 0.1, 10.0);
            mc_opt_res[s, 1] = sigma;
            mc_opt_res[s, 2] = Optim.minimizer(res)[1];
            mc_opt_res[s, 3] = Optim.minimum(res);
            mc_opt_res[s, 4] = Optim.iterations(res);
            timer = time() - timer;
            mc_opt_res[s, 5] = timer;

        elseif (opt_method == 2)
            # Unconstrained Multivariate Optimization: Nelder-Mead optimizer (gradient-free)
            res = optimize(f, [0.1], NelderMead());
            mc_opt_res[s, 1] = sigma;
            mc_opt_res[s, 2] = Optim.minimizer(res)[1];
            mc_opt_res[s, 3] = Optim.minimum(res);
            mc_opt_res[s, 4] = Optim.iterations(res);
            timer = time() - timer;
            mc_opt_res[s, 5] = timer;

        end

        println("Sigma = ", round(sigma; digits = 2), ". Theta hat = ", round(mc_opt_res[s, 2]; digits = 2), ". Elapsed time in seconds: ", timer)

    end

    println("Saving estimation results.")

    # Export as .jld2 file
    res_julia_file = string("mc_iteration_", iteration, ".jld2")
    res_julia_dir = joinpath(main_dir, "res", "montecarlo_iterations", res_julia_file)
    save_object(res_julia_dir, mc_opt_res)

    # Export as .csv file
    res_csv_file = string("mc_iteration_", iteration, ".csv")
    res_csv_dir = joinpath(main_dir, "res", "montecarlo_iterations", res_csv_file)
    writedlm(res_csv_dir, mc_opt_res, ", ")
end