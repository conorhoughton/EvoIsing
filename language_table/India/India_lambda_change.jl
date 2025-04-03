using CSV
using DataFrames
using Gadfly
using Statistics
using Cairo,Fontconfig

# Load proximate pairs
df = CSV.read("India_proximate_pairs.csv", DataFrame)

# Compute lambda and midpoint
df.lambda = df.pop2 ./ df.pop1
df.midpoint = sqrt.(df.pop1 .* df.pop2)

# Sort by midpoint
df_sorted = sort(df, :midpoint)

# Moving average window
window = 100
n = nrow(df_sorted)
mu_sigma = DataFrame(midpoint=Float64[], mu=Float64[], sigma=Float64[])

for i in 1:(n - window + 1)
    window_data = df_sorted[i:(i+window-1), :]
    midpoint_avg = mean(window_data.midpoint)
    mu = mean(window_data.lambda)
    sigma = std(window_data.lambda)
    push!(mu_sigma, (midpoint_avg, mu, sigma))
end

# Scale sigma to match mu for dual axis plotting
mu_min, mu_max = extrema(mu_sigma.mu)
σ_min, σ_max = extrema(mu_sigma.sigma)

# Scale σ to μ's range
scale_σ = x -> mu_min + (x - σ_min) * (mu_max - mu_min) / (σ_max - σ_min)
mu_sigma.scaled_sigma = scale_σ.(mu_sigma.sigma)

# Plot
p = plot(
    layer(mu_sigma, x=:midpoint, y=:mu, Geom.line, color=[colorant"blue"]),
    layer(mu_sigma, x=:midpoint, y=:scaled_sigma, Geom.line, color=[colorant"red"], style=[:dash]),
    Scale.x_log10,
    Guide.xlabel("Geometric mean of populations (√p₁·p₂)"),
    Guide.ylabel("Average λ (μ)"),
    Guide.title("μ and σ of λ vs Intermediate Population (σ scaled)"),
    Theme(line_width=1.2pt)
)

draw(PDF("India_lambda_dual_axis.pdf", 8inch, 6inch), p)
