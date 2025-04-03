using CSV
using DataFrames

# Language name cleaning: no regex magic
function clean_language(name::AbstractString)
    parts = split(name, '/')
    cleaned_parts = [uppercase(first(strip(p))) * lowercase(strip(p))[2:end] for p in parts]
    name_cleaned = join(cleaned_parts, '/')
    name_cleaned = replace(name_cleaned, r"-\s+" => "-")
    return name_cleaned
end

# Load and clean CSVs
function load_and_clean(path::String)
    df = CSV.read(path, DataFrame)
    df.language .= clean_language.(df.language)
    return df
end

# Load all datasets
df1991 = load_and_clean("India_1991_clean.csv")
df2001 = load_and_clean("India_2001_clean.csv")
df2011 = load_and_clean("India_2011_clean.csv")

# Combine and deduplicate
df_all = vcat(df1991, df2001, df2011)
unique_languages = sort(unique(df_all.language))

# Print
println("Cleaned, unique languages across all censuses:")
for lang in unique_languages
    println(lang)
end
