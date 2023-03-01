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

function makeGrid(gridSize::GridSize)
    makeGrid([gridSize.nX,gridSize.nY])
end


function makeGrid(gridSize::Vector{Int64})
    nX=gridSize[1]
    nY=gridSize[2]
    grid=fill(1,nX,nY)
    for x in 1:nX
        for y in 1:nY 
            grid[x,y]=rand([-1,1])
        end
    end
    Grid(nX,nY,grid)
end



function deltaE(state1,state2)
    2.0*state1*state2
end

function bigE(grid::Grid)
    energy=0.0
    for x in 1:grid.nX
        for y in 1:grid.nY
            neighbours=getNeighbours(grid,[x,y])
            for n in neighbours
                energy+=-grid.grid[x,y]*grid.grid[n[1],n[2]]
            end
        end
    end
    energy/(grid.nX*grid.nY)
end

function magnetization(grid::Grid)

    total=0.0

    for x in 1:grid.nX
        for y in 1:grid.nY
            total+=grid.grid[x,y]
        end
    end
    
    total/(grid.nX*grid.nY)
end

    


function runGrid(tSteps::Int64,grid::Grid,temperature)

    for t in 1:tSteps
        
        r=pick(grid)
        neighbours=getNeighbours([grid.nX,grid.nY],r)
        dE=0.0
        for n in neighbours
            dE+=deltaE(grid.grid[r[1],r[2]],grid.grid[n[1],n[2]])
        end
        if dE<=0 || rand(Uniform(0.0,1.0))<exp(-dE/temperature)
            grid.grid[r[1],r[2]]*=-1
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


function getEnergy(tEquilibrium,tResample,nSample,grid,temperature)

    grid=runGrid(tEquilibrium,grid,temperature)
    
    thisEnergy=bigE(grid)

    for sample in 1:nSample-1
        grid=runGrid(tResample,grid,temperature)
        thisEnergy+=bigE(grid)
    end

    return thisEnergy/nSample
        
end

function plotGrid(grid::Grid, filename; kwargs...)
    p=plotGrid(grid; kwargs...)
    savefig(p, filename)
end

function plotGrid(gridGrid; kwargs...)

    Plots.heatmap(grid.grid,
            colorbar = false, axis = false
                  )
    
    
end



nX=20

nSample=5
tEquilibrium=20000
tResample=100

restarts=5

temperatures=[0.1*i for i in 1:50]

grid=makeGrid([nX,nX])

for temperature in temperatures

    thisEnergy=0.0
    
    for _ in 1:restarts
        
        thisEnergy+=getEnergy(tEquilibrium,tResample,nSample,grid,temperature)
    end
    
    println(temperature," ",thisEnergy/restarts)

end
