
import csv
import os

# CSV file path
file_path = "My Data File.csv"

# Get filename without extension
filename = os.path.splitext(os.path.basename(file_path))[0]

# Extract the first word
first_word = filename.split("_")[0]

# Output file
output_path = "modified_" + os.path.basename(file_path)

# Read and modify CSV
with open(file_path, "r", newline="", encoding="utf-8-sig") as infile:
    reader = csv.DictReader(infile)
    fieldnames = reader.fieldnames + ["File Name"]

    rows = []
    for row in reader:
        row["File Name"] = first_word
        rows.append(row)

# Write modified CSV
with open(output_path, "w", newline="", encoding="utf-8") as outfile:
    writer = csv.DictWriter(outfile, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(rows)

print(f"Updated CSV saved as: {output_path}")
