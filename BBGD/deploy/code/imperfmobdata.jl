# Monte Carlo for Quantitative Spatial Model
# Constant and increasing returns to scale model
# Regions specification
# Molnar, Navarro, Shilpi. May 2023

# This loads the package manager
using Pkg

#=

# This updates all the already installed packages
Pkg.update()

# Add the packages I need to run this code
Pkg.add("Random")
Pkg.add("LinearAlgebra")
Pkg.add("Images")
Pkg.add("ImageSegmentation")
Pkg.add("Statistics")
Pkg.add("StatsBase")
Pkg.add("SpecialFunctions")
Pkg.add("CSV")
Pkg.add("DataFrames")
Pkg.add("PyPlot")
Pkg.add("BenchmarkTools")

=#

using Random, LinearAlgebra, Images, ImageSegmentation, Statistics, StatsBase, SpecialFunctions, CSV, DataFrames, BenchmarkTools, Profile

include("solveLw.jl")
include("pindex.jl")
include("landprice.jl")
include("expectut.jl")
include("welfare.jl")
include("realw.jl")
include("solveab.jl")
include("import_data.jl")

# Set default random number stream
Random.seed!(1)

###########################################
### Trade cost matrix (called distance) ###
###########################################

N = 11
NN = N * N

########################
### Parameterization ###
########################

# Share of goods in consumption expenditure (1-housing share)
alpha = 0.75

# Elasticity of substitution
sigma = 4.0
Hsigma = 5.0

# Goods Frechet shape parameter. Controls the dispersion in productivity across goods. Elasticity of trade wrt trade costs. 
theta = 4.0

# Worker Frechet shape parameter. Controls the disperson of amenities across workers. Elasticity of population wrt real income.
epsilon = 3.0

param = [alpha, theta, epsilon, sigma, Hsigma]

###########################
### Import Redding data ###
###########################

dist0, dist1, a, b = import_data()

########################
### Other Parameters ###
########################

# Observations
nobs = NN

# Land area
H = 100.0 * ones(nobs, 1)

# Aggregate labor supply
LL = 153889.0  # US civilian labor force 2010 (Statistical Abstract, millions)

# Fixed production cost
F = 1.0

#############################################################
### Model with no Agglomeration Forces (Constant Returns) ###
#############################################################

fund = zeros(nobs, 5)
fund[:, 1] .= a
fund[:, 2] .= b
fund[:, 3] .= H
fund[:, 4] .= LL
fund[:, 5] .= F
model = 1

# Solve for region populations and wages
w, L, tradesh, dtradesh, Lconverge, wconverge, xtic = solveLw(param, fund, dist0, nobs, model)
println("Wage Convergence: ", wconverge)
println("Population Convergence: ", Lconverge)
println("Elapsed Time in Seconds: ", xtic)

# Check performance of the function solveLw
@code_warntype solveLw(param, fund, dist0, nobs, model)
@btime solveLw(param, fund, dist0, nobs, model)
@profview solveLw(param, fund, dist0, nobs, model)

# Price index
P = pindex(param, fund, L, w, dtradesh, F, model)

# Land price
r = landprice(param, fund, L, w)

# Expected utility
EU = expectut(param, fund, L, w, P, r, dtradesh, model)

# Welfare
welf = welfare(param, fund, L, dtradesh, model)
welf = round.(welf .* (10.0^4))
welf = welf ./ (10.0^4)
unique_welf = unique(welf)

# Real wage
realwage = realw(param, fund, L, dtradesh, model)

# Create matrix of observables
observe = zeros(nobs, 5)
observe[:, 1] .= L
observe[:, 2] .= w
observe[:, 3] .= H
observe[:, 4] .= LL
observe[:, 5] .= F
model = 1  

# Solve for region productivities and amenities
a_i, b_i, abtradesh, abdtradesh, aconverge, bconverge, xtic = solveab(param, observe, dist0, nobs, model)
println("Productivity Convergence: ", aconverge)
println("Amenities Convergence: ", bconverge)
println("Elapsed Time in Seconds: ", xtic)

# Check performance of the function solveab
@code_warntype solveab(param, observe, dist0, nobs, model)
@btime solveab(param, observe, dist0, nobs, model)
@profview solveab(param, observe, dist0, nobs, model)