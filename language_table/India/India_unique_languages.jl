using CSV
using DataFrames

# Load language names from each census file
function load_languages(path::String)
    df = CSV.read(path, DataFrame)
    return Set(df.language)
end

# Load languages from each census
langs_1991 = load_languages("India_1991_clean.csv")
langs_2001 = load_languages("India_2001_clean.csv")
langs_2011 = load_languages("India_2011_clean.csv")

# Find languages present only in one census
only_1991 = setdiff(langs_1991, union(langs_2001, langs_2011))
only_2001 = setdiff(langs_2001, union(langs_1991, langs_2011))
only_2011 = setdiff(langs_2011, union(langs_1991, langs_2001))

# Output results
println("Languages only in 1991:")
foreach(println, sort(collect(only_1991)))

println("\nLanguages only in 2001:")
foreach(println, sort(collect(only_2001)))

println("\nLanguages only in 2011:")
foreach(println, sort(collect(only_2011)))
