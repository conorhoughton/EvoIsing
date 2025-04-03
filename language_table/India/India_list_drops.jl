using CSV
using DataFrames

# Load the data
df = CSV.read("India_proximate_pairs.csv", DataFrame)

# Compute lambda (growth ratio)
df.lambda = df.pop2 ./ df.pop1

# Filter rows where lambda < 0.5
df_decline = filter(row -> row.lambda < 0.5, df)

# Print result
println("Languages where reported population dropped by more than half:")
show(df_decline, allrows=true, allcols=true)
