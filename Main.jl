# Sen's Main File For Simulation
cd("$(homedir())/course/Mihai/Simulation/epsilon version")
# install packages#=
#=
Pkg.add("JuMP") Pkg.update("JuMP") Pkg.add("DataFrames") Pkg.add("PyPlot") Pkg.add("MATLAB") Pkg.add("Ipopt")
Pkg.add("Git")
=#

# Using packages
using JuMP
using Ipopt
using DataFrames
using PyPlot
using MATLAB
include("NLP.jl")

# Set parameter
N = [20, 40, 60]; # Horizon length
delta1 = [10, 50, 100];
delta2 = [1, 10, 15];

# Solver Unperturb
for nn = 1:length(N)
    for cc = 1:length(delta1)
        X = Array{Any}(2,3)
        U = Array{Any}(2,3)
        D = Array{Any}(2,3)
        for Id = 1:2 # different function
            for Jd = 1:3 # time
                println([nn, cc, Id, Jd])
                dd = zeros(N[nn],1);
                dd[Int(N[nn]/2)] = 10;

                X[Id, Jd], U[Id, Jd], D[Id, Jd] = NLP(N[nn], delta1[cc], delta2[cc], Id, Jd, dd);
            end
        end
        @mput X
        @mput U
        @mput D
        @mput nn
        @mput cc
        @matlab save(sprintf("./Data/N%dDelta%d.mat",nn,cc))
    end
end
