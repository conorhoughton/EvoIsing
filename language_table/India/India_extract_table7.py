import pdfplumber
import pandas as pd
import re

# PDF input and CSV output
pdf_path = "India_languages.pdf"
output_csv = "India_scheduled.csv"

# Census years
census_years = ["1971", "1981", "1991", "2001", "2011"]
rows = []

# Clean number: remove all non-digit chars, return "" if empty
def clean_number(s):
    digits = re.sub(r'\D', '', s)
    return int(digits) if digits else ""

# Clean language name: remove trailing asterisks (e.g., 'Malayalam**' → 'Malayalam')
def clean_language(name):
    return re.sub(r'[*#]+$', '', name)

with pdfplumber.open(pdf_path) as pdf:
    page = pdf.pages[19]  # 20th page
    lines = page.extract_text().split('\n')

    for line in lines:
        line = line.replace("$", "")  # Remove stray $
        fields = line.strip().split()

        if not fields or not fields[0].isdigit():
            continue  # Skip non-data lines

        fields = fields[1:]  # Drop row number

        if len(fields) < 6:
            continue

        language = clean_language(fields[0])

        if language.isdigit():
            continue  # Skip junk lines like 1981, 2, 3, etc.

        pops_raw = fields[1:6]
        pops_clean = [clean_number(f) for f in pops_raw]

        for year, pop in zip(census_years, pops_clean):
            if pop != "":  # Only include rows with population
                rows.append([language, year, pop])

# Create long-form DataFrame
df = pd.DataFrame(rows, columns=["language", "census", "population"])

# Save
df.to_csv(output_csv, index=False)
print(df.head())
