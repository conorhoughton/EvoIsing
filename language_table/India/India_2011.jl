using CSV
using DataFrames

input_file = "India_2011.csv"
output_file = "India_2011_clean.csv"

# Helper: check if the language field is of the form "N NAME" with NAME in all caps
function is_valid_language(entry::AbstractString)
    return occursin(r"^\d+ [A-Z]+$", entry)
end

# Helper: convert "1 ASSAMESE" → "Assamese"
function clean_language(entry::AbstractString)
    parts = split(entry, ' ')
    return uppercase(first(parts[2])) * lowercase(join(parts[2:end], ' ')[2:end])
end

# Prepare DataFrame
df = DataFrame(language=String[], population=Int[], census=Int[])

# Read and process each valid line
open(input_file, "r") do file
    for line in eachline(file)
        fields = split(line, ',')
        if length(fields) >= 8 && strip(fields[5]) == "INDIA"
            lang_entry = strip(fields[7])
            if is_valid_language(lang_entry)
                language = clean_language(lang_entry)
                population = parse(Int, strip(fields[8]))
                push!(df, (language, population, 2011))
            end
        end
    end
end

# Write to output CSV
CSV.write(output_file, df)
