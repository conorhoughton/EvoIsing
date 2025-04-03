using CSV
using DataFrames

# Clean language names: split on "/", strip, title-case, remove space after "-"
function clean_language(name::AbstractString)
    parts = split(name, '/')
    cleaned_parts = [uppercase(first(strip(p))) * lowercase(strip(p))[2:end] for p in parts]
    name_cleaned = join(cleaned_parts, '/')
    name_cleaned = replace(name_cleaned, r"-\s+" => "-")
    return name_cleaned
end

# Load and apply language cleaning
function load_and_clean(path::String)
    df = CSV.read(path, DataFrame)
    df.language .= clean_language.(df.language)
    return df
end

# Load datasets
df1991 = load_and_clean("India_1991_clean.csv")
df2001 = load_and_clean("India_2001_clean.csv")
df2011 = load_and_clean("India_2011_clean.csv")

# Merge
df_all = vcat(df1991, df2001, df2011)

# Save to a single CSV
CSV.write("India.csv", df_all)
