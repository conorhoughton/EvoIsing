using CSV
using DataFrames

# Load data
df = CSV.read("India.csv", DataFrame)

# Filter out 1991 entries for J&K-affected languages

# Group by language and sort by census
grouped = groupby(df_clean, :language)

# Find proximate pairs (1991–2001 and 2001–2011)
proximate_pairs = DataFrame(language=String[], census1=Int[], pop1=Int[], census2=Int[], pop2=Int[])

for g in grouped
    sorted_rows = sort(g, :census)
    for i in 1:(nrow(sorted_rows)-1)
        c1 = sorted_rows.census[i]
        c2 = sorted_rows.census[i+1]
        if c2 - c1 == 10  # only adjacent decades
            push!(proximate_pairs, (
                sorted_rows.language[i],
                c1, sorted_rows.population[i],
                c2, sorted_rows.population[i+1]
            ))
        end
    end
end

# Output
CSV.write("India_proximate_pairs.csv", proximate_pairs)
