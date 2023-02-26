using Random,Distributions
using Plots
plotlyjs()


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

    rand([i  for i in 1:length(neighbours) if eValues[i]==best])
    
end

function plotGrid(grid, filename; kwargs...)
    p=plotGrid(grid; kwards...)
    savefig(p, filename)
end

function plotGrid(grid; kwargs...)
    
    sizeG=size(grid)
    
    s=Array{Int}(undef,sizeG)
    
    for i in 1:sizeG[1]
        for j in 1:sizeG[2]
            s[i,j]=toBinary(grid[i,j])
        end
    end

    Plots.heatmap(s,
            colorbar = false, axis = false
                  )
    
    
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

stateL=3

grid=makeGrid(gridSize,stateL)

tFinal=10000
tPrint=tFinal-100

temp=0.1

println("initial plot")

p = plotGrid(grid)
savefig("initial.png")

println("starting loop")

#anim = @animate for t in 1:tFinal

for t in 1:tFinal
    if t%100==0
     	println(t)
    end
    global grid
    oldGrid=copy(grid)

    for x in 1:gridSize.nX
        for y in 1:gridSize.nY
            r=[x,y]
            neighbours=getNeighbours(gridSize,r)
            bestN=getBest(oldGrid,r,neighbours)
            bit=rand(1:stateL)
            dE=deltaE(grid[r[1],r[2]],oldGrid[neighbours[bestN][1],neighbours[bestN][2]],bit)
            if rand(Uniform(0.0,1.0))<exp(-dE/temp)
                grid[r[1],r[2]][bit]*=-1
            end
        end
    end

    if t>tPrint
        p=plotGrid(grid)
        savefig(p,"plot_"*string(t)*".png")
    end

    
    
end


#gif(anim, "animation.gif", fps=200)


    
