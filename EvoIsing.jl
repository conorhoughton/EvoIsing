using Random

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

function getProbs(grid,pos,neighbours,temp)
    probs=ones(Float64,4)
    for i in 1:4
        thisE=bigE(grid[neighbours[i][1],neighbours[i][2]],grid[pos[1],pos[2]])
        println(grid[neighbours[i][1],neighbours[i][2]]," ",grid[pos[1],pos[2]],thisE)
        probs[i]=exp(-thisE/temp)
    end
    bigZ=sum(probs)
    
    for i in 1:4
        probs[i]/=bigZ
    end

    probs
end
    

gridSize=GridSize(2,3)

println(makeGrid(gridSize,5))

grid=makeGrid(gridSize,5)

r=[1,1]

neighbours=getNeighbours(gridSize,r)

println(getProbs(grid,r,neighbours,1.0))
