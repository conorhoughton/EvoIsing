using CSV
using DataFrames

input_file = "India_1991.csv"
output_file = "India_1991_clean.csv"

rows = String[]

# Read file and keep only India-level summary
open(input_file, "r") do file
    in_india_section = false
    for line in eachline(file)
        if occursin("I N D I A", line)
            in_india_section = true
            continue  # skip the "I N D I A" header itself
        end
        if in_india_section
            push!(rows, line)
            if occursin("Total of Other Languages", line)
                break
            end
        end
    end
end

# Function to clean number fields and quotes
function clean_line(line::String)
    # Remove commas inside quotes, then remove quotes
    line = replace(line, r"\"[ \d,]+\"" => s -> replace(s, "," => "") |> x -> replace(x, "\"" => ""))
    return line
end

# Prepare DataFrame
df = DataFrame(language=String[], population=Int[], census=Int[])

for raw_line in rows
    if !occursin(r"^\d", raw_line)
        continue
    end
    line = clean_line(raw_line)
    fields = split(line, ',')
    language = strip(fields[2])
    population = parse(Int, strip(fields[3]))
    push!(df, (language, population, 1991))
end

CSV.write(output_file, df)
