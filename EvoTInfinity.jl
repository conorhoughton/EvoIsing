using Random,Distributions, LinearAlgebra


stateL=5

trialsN=10000000

totalE=0.0

for _ in 1:trialsN
    global totalE,stateL
    center = rand([-1, 1], stateL)
    thisE=[]
    for _ in 1:4
        neighbour = rand([-1,1],stateL)
        push!(thisE,-dot(center,neighbour)/stateL)
    end
    totalE+=minimum(thisE)
end

println(totalE/trialsN)
        
