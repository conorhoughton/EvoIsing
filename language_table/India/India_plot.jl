using CSV
using DataFrames
using Statistics
using Gadfly
using Cairo
using Fontconfig

# Load the data
df = CSV.read("India_proximate_pairs.csv", DataFrame)

# Compute lambda and midpoint
df.lambda = df.pop2 ./ df.pop1
df.midpoint = sqrt.(df.lambda) .* df.pop1

# Split into two groups by median midpoint
mid_median = median(df.midpoint)
df.group = ifelse.(df.midpoint .< mid_median, "Low population", "High population")

# --------- Plot 1: Scatter plot of lambda vs midpoint ---------
scatter_plot = plot(df,
    x = :midpoint,
    y = :lambda,
    color = :group,
    Geom.point,
    Scale.x_log10,
    Scale.y_log10,
    Guide.xlabel("Estimated midpoint population (√λ × p₁)"),
    Guide.ylabel("Growth ratio (λ = p₂ / p₁)"),
    Guide.title("Language Growth Ratios by Midpoint Population"),
    Theme(point_size=2pt)
)

draw(PDF("India_scatter_lambda_vs_midpoint.pdf", 8inch, 6inch), scatter_plot)

# --------- Plot 2: KDE of lambda for each group ---------
kde_plot = plot(df,
    x = :lambda,
    color = :group,
    Geom.density,
    Scale.x_log10,
    Guide.xlabel("Growth ratio (λ = p₂ / p₁)"),
    Guide.ylabel("Density"),
    Guide.title("Distribution of Growth Ratios by Population Group")
)

draw(PDF("India_kde_lambda_distribution.pdf", 8inch, 6inch), kde_plot)
