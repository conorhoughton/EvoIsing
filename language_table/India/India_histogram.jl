using CSV
using DataFrames
using Gadfly
using Statistics
using CategoricalArrays
using Cairo
using Fontconfig

# Load datasets
df_sched = CSV.read("India_scheduled.csv", DataFrame)
df_nonsched = CSV.read("India_nonscheduled.csv", DataFrame)
df = vcat(df_sched, df_nonsched)

# Filter for 2011 with valid positive populations
df_2011 = filter(row -> row.census == 2011 && row.population > 0, df)

# Abort if nothing left
if nrow(df_2011) == 0
    error("No valid 2011 population data found.")
end

# Compute log₁₀(population)
df_2011.log_pop = log10.(df_2011.population)

# Create bin edges and centers
bin_edges = collect(range(floor(minimum(df_2011.log_pop)), ceil(maximum(df_2011.log_pop)), length=21))


bin_centers = 0.5 .* (bin_edges[1:end-1] + bin_edges[2:end])

# Bin the data
df_2011.bin = cut(df_2011.log_pop, bin_edges; labels=bin_centers)

# Count and normalize
bin_counts = combine(groupby(df_2011, :bin), nrow => :count)
total = sum(bin_counts.count)
bin_counts.prob_density = bin_counts.count ./ total

# Assign bin centers as Float64
bin_counts.bin_center = parse.(Float64, string.(bin_counts.bin))

# Plot
p = plot(bin_counts,
    x = :bin_center,
    y = :prob_density,
    Geom.bar,
    Guide.xlabel("log₁₀(population)"),
    Guide.ylabel("Probability density"),
    Guide.title("Distribution of Language Population Sizes (2011)"),
    Theme(bar_spacing=0mm)
)

# Save to PDF using Cairo
draw(PDF("India_histogram_2011.pdf", 8inch, 6inch), p)
