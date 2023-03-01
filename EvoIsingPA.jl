using Random,Distributions
using Plots
plotlyjs()


struct GridSize
    nX::Int64
    nY::Int64
end

struct Grid
    nX::Int64
    nY::Int64
    l::Int64
    grid::Array{}
end

function get(gridSize::GridSize,x::Int64,y::Int64)
    get([gridSize.nX,gridSize.nY],x,y)
end

function get(size::Vector{Int64},x::Int64,y::Int64)

    nX=size[1]
    nY=size[2]
    
    if x<1
        x+=nX
    elseif x>nX
        x-=nX
    end
    
    if y<1
        y+=nY
    elseif y>nY
        y-=nY
    end

    x,y

end

function pick(gridSize::GridSize)
    rand(1:gridSize.nX),rand(1:gridSize.nY)
end

function pick(grid::Grid)
    rand(1:grid.nX),rand(1:grid.nY)
end

function getNeighbours(gridSize::GridSize,r)
    getNeighbours([gridSize.nX,gridSize.nY],r)
end


function getNeighbours(grid::Grid,r)
    getNeighbours([grid.nX,grid.nY],r)
end


function getNeighbours(size::Vector{Int64},r)
    
    neighbours=Vector{Vector{Int64}}()
    
    x,y=get(size,r[1]+1,r[2])
    push!(neighbours,[x,y])
    x,y=get(size,r[1],r[2]+1)
    push!(neighbours,[x,y]) 
    x,y=get(size,r[1]-1,r[2])
    push!(neighbours,[x,y]) 
    x,y=get(size,r[1],r[2]-1)
    push!(neighbours,[x,y]) 

    neighbours
end

function makeGrid(gridSize::GridSize,stateSize::Int64)
    makeGrid([gridSize.nX,gridSize.nY],stateSize)
end


function makeGrid(gridSize::Vector{Int64},stateSize::Int64)
    nX=gridSize[1]
    nY=gridSize[2]
    grid=fill(ones(Int64,stateSize),nX,nY)
    for x in 1:nX
        for y in 1:nY 
            grid[x,y]=rand([-1,1],stateSize)
        end
    end
    Grid(nX,nY,stateSize,grid)
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

    rand([i  for i in 1:length(neighbours) if eValues[i]==best])
    
end

function plotGrid(grid::Grid, filename; kwargs...)
    p=plotGrid(grid; kwards...)
    savefig(p, filename)
end

function plotGrid(gridGrid; kwargs...)
    
    s=Array{Int}(undef,sizeG)
    
    for i in 1:grid.nX
        for j in 1:grid.nY
            s[i,j]=toBinary(grid.grid[i,j])
        end
    end

    Plots.heatmap(s,
            colorbar = false, axis = false
                  )
    
    
end

function magnetization(grid::Grid)

    total=0

    for bit in 1:grid.l
        bitTotal=0
        for x in 1:grid.nX
            for y in 1:grid.nY
                bitTotal+=grid.grid[x,y][bit]
            end
        end
        total+=abs(bitTotal)
    end
    
    total/(grid.l*grid.nX*grid.nY)
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

function countTypes(grid::Grid)

    s=zeros(Int64,2^grid.l)
    
    for i in 1:grid.nX
        for j in 1:grid.nY
            s[toBinary(grid.grid[i,j])+1]+=1
        end
    end

    s
end


function runGrid(tSteps::Int64,grid::Grid,temperature)

    for t in 1:tSteps
        
        oldGrid=copy(grid.grid)
        
        for x in 1:grid.nX
            for y in 1:grid.nY
                r=[x,y]
                neighbours=getNeighbours([grid.nX,grid.nY],r)
                bestN=getBest(oldGrid,r,neighbours)
                    bit=rand(1:grid.l)
                dE=deltaE(grid.grid[r[1],r[2]],oldGrid[neighbours[bestN][1],neighbours[bestN][2]],bit)
                if rand(Uniform(0.0,1.0))<exp(-dE/temperature)
                    grid.grid[r[1],r[2]][bit]*=-1
                end
            end
        end
    end

    grid
    
end


function getMagnetization(tEquilibrium,tResample,nSample,grid,temperature)

    grid=runGrid(tEquilibrium,grid,temperature)
    
    this_Magnetization=magnetization(grid)

    for sample in 1:nSample-1
        grid=runGrid(tResample,grid,temperature)
        this_Magnetization+=magnetization(grid)
    end

    return this_Magnetization/nSample
    
    
end


nX=40

stateL=3



nSample=10
tEquilibrium=10000
tResample=100

restarts=10

temperatures=[0.001,0.01,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1.0,1.1,1.2,1.3,10.0,100.0]


backgroundN=100

backgroundMag=0.0

for _ in 1:backgroundN
    global backgroundMag
    grid=makeGrid([nX,nX],stateL)
    backgroundMag+=magnetization(grid)
end

backgroundMag/=backgroundN

println("background mag=",backgroundMag)

for temperature in temperatures

    global backgroundMag
    
    magnetization=0.0
    
    for _ in 1:restarts
        grid=makeGrid([nX,nX],stateL)
        magnetization+=getMagnetization(tEquilibrium,tResample,nSample,grid,temperature)
    end
    
    println(temperature," ",magnetization/restarts-backgroundMag)

end


#old stuff

#println("initial plot")

#p = plotGrid(grid)
#savefig("initial.png")

#println("starting loop")

#anim = @animate for t in 1:tFinal



#gif(anim, "animation.gif", fps=200)


    
