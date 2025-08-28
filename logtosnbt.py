import re

# Input and output file paths
input_file = r"C:\Users\nishi\AppData\Roaming\.minecraft\instances\Fabric-1.21.4\logs\latest.log"
output_file = r"D:\Desktop\Villager.txt"

# Regex to match villager SNBT lines
pattern = re.compile(r"has the following entity data:")

with open(input_file, "r", encoding="utf-8") as infile, \
     open(output_file, "w", encoding="utf-8") as outfile:
    for line in infile:
        if pattern.search(line):
            outfile.write(line.strip() + "\n")
