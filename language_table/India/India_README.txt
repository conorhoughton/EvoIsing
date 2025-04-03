so I had two goes at this, the first from xls data deals individually
with the 1991 2001 and 2011 census data; the second uses a pair of
tables in the pdf called India_languages.pdf. The second is better
because it uses more data, the 1981 and 1971 censuses and it deals
with changes in language names, though there are still some problems,
some figures for smaller languages vary wildly and implausibly between
censuses.

The two python scripts extract the data from the pdf tables, tables 7
and 8. This is placed in long form in two csv's India_[non]scheduled.csv

India_proximate_pairs_2.jl finds proximate pairs for the second attempt.

After that the two attempts use the same code:

India_plot.jl

 and in the second go I overwrite the proximate pairs csv and the various graphs I made for the first go.

