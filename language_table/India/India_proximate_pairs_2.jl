using CSV
using DataFrames

# Load scheduled and non-scheduled datasets
df_scheduled = CSV.read("India_scheduled.csv", DataFrame)
df_nonscheduled = CSV.read("India_nonscheduled.csv", DataFrame)

# Combine into one DataFrame
df_all = vcat(df_scheduled, df_nonscheduled)

# Group by language
grouped = groupby(df_all, :language)

# Prepare result DataFrame
proximate_pairs = DataFrame(language=String[], census1=Int[], pop1=Int[], census2=Int[], pop2=Int[])

# Find adjacent-decade pairs
for g in grouped
    sorted_rows = sort(g, :census)
    for i in 1:(nrow(sorted_rows)-1)
        c1 = sorted_rows.census[i]
        c2 = sorted_rows.census[i+1]
        if c2 - c1 == 10
            push!(proximate_pairs, (
                sorted_rows.language[i],
                c1, sorted_rows.population[i],
                c2, sorted_rows.population[i+1]
            ))
        end
    end
end

# Save output
CSV.write("India_proximate_pairs.csv", proximate_pairs)
