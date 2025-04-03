using CSV
using DataFrames

input_file = "India_2001.csv"
output_file = "India_2001_clean.csv"

# Updated function to handle any kind of string (String, SubString, etc.)
function proper_case(s::AbstractString)
    if isempty(s)
        return s
    else
        return uppercase(first(s)) * lowercase(s[2:end])
    end
end

# Prepare the DataFrame
df = DataFrame(language=String[], population=Int[], census=Int[])

# Process the file
open(input_file, "r") do file
    for line in eachline(file)
        fields = split(line, ',')
        if length(fields) >= 5 && strip(fields[2]) == "INDIA" && strip(fields[5]) != ""
            lang = proper_case(strip(fields[4]))
            pop = parse(Int, strip(fields[5]))
            push!(df, (lang, pop, 2001))
        end
    end
end

# Save cleaned data
CSV.write(output_file, df)
