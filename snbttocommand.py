import re
# Reads villager.txt with multiple SNBT lines, stops at first empty line
# Appends summon commands for each villager back into villager.txt

FILE = r"D:\desktop\Villager.txt"

def extract_block(text: str, key: str) -> str:
    """Extract { ... } block after 'key:' in SNBT line (brace-aware)."""
    kp = text.find(key)
    if kp == -1:
        return ""
    colon = text.find(":", kp)
    if colon == -1:
        return ""
    brace = text.find("{", colon)
    if brace == -1:
        return ""
    depth, i = 0, brace
    while i < len(text):
        c = text[i]
        if c == "{":
            depth += 1
        elif c == "}":
            depth -= 1
            if depth == 0:
                blk = text[kp:i+1].strip()
                blk = re.sub(r"\s+", " ", blk)  # normalize whitespace
                return blk
        i += 1
    return ""

def main():
    with open(FILE, "r", encoding="utf-8") as f:
        lines = f.read().splitlines()

    commands = []
    for line in lines:
        if line.strip() == "":
            break  # stop at first blank line
        vd = extract_block(line, "VillagerData")
        of = extract_block(line, "Offers")
        if vd and of:
            commands.append(f"/summon villager ~ ~ ~ {{{vd},{of}}}")

    if commands:
        with open(FILE, "a", encoding="utf-8") as f:
            f.write("\n")
            f.write("\n".join(commands))
            f.write("\n")

if __name__ == "__main__":
    main()
