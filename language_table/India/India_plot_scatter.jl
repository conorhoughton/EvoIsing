using CSV
using DataFrames
using Gadfly
using Statistics
using Cairo
using Fontconfig

# Load proximate pairs
df_pairs = CSV.read("India_proximate_pairs.csv", DataFrame)

# Compute lambda and geometric midpoint
df_pairs.lambda = df_pairs.pop2 ./ df_pairs.pop1
df_pairs.midpoint = sqrt.(df_pairs.pop1 .* df_pairs.pop2)

# Load list of scheduled languages
df_sched = CSV.read("India_scheduled.csv", DataFrame)
scheduled_langs = Set(df_sched.language)

# Mark each row as Scheduled or Non-scheduled
df_pairs.category = ifelse.(in.(df_pairs.language, Ref(scheduled_langs)), "Scheduled", "Non-scheduled")



# Plot the scatter with log-log scale
p = plot(df_pairs,
    x = :midpoint,
    y = :lambda,
    color = :category,
    Geom.point,
    Scale.x_log10,
         Scale.y_log10,
         Guide.colorkey(title=""),
    Guide.xlabel("population"),
    Guide.ylabel("ratio"),
    #Guide.title("Language Growth Ratios in India: Scheduled vs Non-scheduled"),
    Theme(point_size=2pt,key_position=:inside,highlight_width=0mm)
)

# Save to PDF using Cairo backend
draw(PDF("India_language_scatter.pdf", 8inch, 6inch), p)
