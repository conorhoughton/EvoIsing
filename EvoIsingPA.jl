using Random,Distributions
using PlotlyJS


struct GridSize
    nX::Int64
    nY::Int64
end

function get(gridSize::GridSize,x::Int64,y::Int64)

    if x<1
        x+=gridSize.nX
    elseif x>gridSize.nX
        x-=gridSize.nX
    end
    
    if y<1
        y+=gridSize.nY
    elseif y>gridSize.nY
        y-=gridSize.nY
    end

    x,y

end

function pick(gridSize::GridSize)
    rand(1:gridSize.nX),rand(1:gridSize.nY)
end

function getNeighbours(gridSize::GridSize,r)
    neighbours=Vector{Vector{Int64}}()
    x,y=get(gridSize,r[1]+1,r[2])
    push!(neighbours,[x,y])
    x,y=get(gridSize,r[1],r[2]+1)
    push!(neighbours,[x,y]) 
    x,y=get(gridSize,r[1]-1,r[2])
    push!(neighbours,[x,y]) 
    x,y=get(gridSize,r[1],r[2]-1)
    push!(neighbours,[x,y]) 

    neighbours
end

function makeGrid(gridSize::GridSize,stateSize::Int64)
    grid=fill(ones(Int64,stateSize),gridSize.nX,gridSize.nY)
    for x in 1:gridSize.nX
        for y in 1:gridSize.nY 
            grid[x,y]=rand([-1,1],stateSize)
        end
    end
    grid
end

function deltaE(state1,state2,bit)
    state1[bit]*state2[bit]/length(state1)
end

function bigE(state1,state2)
    bigE=(0.5*length(state1))::Float64
    for i in 1:length(state1)
        bigE+=-0.5*state1[i]*state2[i]
    end
    bigE/length(state1)
end

function getBest(grid,pos,neighbours)

    eValues=[bigE(grid[neighbours[i][1],neighbours[i][2]],grid[pos[1],pos[2]]) for i in 1:length(neighbours)]
        
    best=minimum(eValues)

    rand([i if eValues[i]==best for i in 1:length(neighbours)])
    
end

function plotGrid(grid, filename; kwargs...)
    
    sizeG=size(grid)
    
    s=Array{Int}(undef,sizeG)
    
    for i in 1:sizeG[1]
        for j in 1:sizeG[2]
            s[i,j]=sum(grid[i,j])
        end
    end

    p=plot(
    heatmap(z=s,
            colorbar = false, axis = false
            )
    )
    savefig(p, filename)
end

function toBinary(state)
    power=1
    total=0
    for s in state
        if s==1
            total+=power
        end
        power*=2
    end

    total
end

function countTypes(grid)

    sizeG=size(grid)
    
    s=zeros(Int64,2^length(grid[1,1]))
    
    for i in 1:sizeG[1]
        for j in 1:sizeG[2]
            s[toBinary(grid[i,j])+1]+=1
        end
    end

    s
end


gridSize=GridSize(20,20)

grid=makeGrid(gridSize,3)


tFinal=100000000

temp=0.1

for t in 1:tFinal
    r=pick(gridSize)
    neighbours=getNeighbours(gridSize,r)
    neighbour=getProbs(grid,r,neighbours)
    grid[r[1],r[2]]=makeCloser(grid[r[1],r[2]],grid[neighbours[neighbour][1],neighbours[neighbour][2]])
    if t%10000==0
        counts=countTypes(grid)
        for c in counts
            print(c," ")
        end
        println()
    end
end



    
