import re, csv, os

input_file = r"D:\Desktop\Villager.txt"
output_dir = r"D:\Desktop\Villager.csv"
os.makedirs(output_dir, exist_ok=True)

columns = ["sell_id","sell_count","buyA_id","buyA_count",
           "buyB_id","buyB_count","xp","maxUses","uses",
           "priceMultiplier","demand","enchantments"]

def find_recipes_block(line: str):
    # Return the text inside Recipes: [ ... ] using bracket depth (ignores inner ]}).
    m = re.search(r"Offers:\s*\{[^{}]*Recipes:\s*\[", line)
    if not m:
        return None
    start = m.end()  # position after the '['
    depth, i = 1, start
    in_str, esc = False, False
    while i < len(line):
        ch = line[i]
        if in_str:
            if esc: esc = False
            elif ch == "\\": esc = True
            elif ch == '"': in_str = False
        else:
            if ch == '"': in_str = True
            elif ch == '[': depth += 1
            elif ch == ']':
                depth -= 1
                if depth == 0:
                    return line[start:i]
        i += 1
    return None

def split_top_level_objects(block: str):
    # Split ... , ... into top-level { ... } items (brace-aware; ignores inner {}).
    items, current = [], []
    depth = 0
    in_str, esc = False, False
    for ch in block:
        current.append(ch)
        if in_str:
            if esc: esc = False
            elif ch == "\\": esc = True
            elif ch == '"': in_str = False
        else:
            if ch == '"': in_str = True
            elif ch == '{': depth += 1
            elif ch == '}':
                depth -= 1
                if depth == 0:
                    item = "".join(current).strip()
                    if item.endswith(","): item = item[:-1].rstrip()
                    items.append(item)
                    current = []
    return items

def extract_profession(line: str):
    m = re.search(r'VillagerData:\s*\{.*?profession:\s*"minecraft:(.*?)"', line)
    return m.group(1).capitalize() if m else "Unknown"

def extract_fields(recipe: str):
    def ex(pat, default=""):
        m = re.search(pat, recipe, re.IGNORECASE)
        return m.group(1) if m else default

    sell_id     = ex(r'sell:\s*\{.*?id:\s*"([^"]+)"')
    sell_count  = ex(r'sell:\s*\{.*?count:\s*([-\d]+)')
    buyA_id     = ex(r'buy:\s*\{.*?id:\s*"([^"]+)"')
    buyA_count  = ex(r'buy:\s*\{.*?count:\s*([-\d]+)')
    buyB_id     = ex(r'buyB:\s*\{.*?id:\s*"([^"]+)"')
    buyB_count  = ex(r'buyB:\s*\{.*?count:\s*([-\d]+)')
    xp          = ex(r'\bxp:\s*([-\d]+)')
    maxUses     = ex(r'\bmaxUses:\s*([-\d]+)')
    uses        = ex(r'\buses:\s*([-\d]+)')
    priceMult   = ex(r'\bpriceMultiplier:\s*([-\d\.]+f?)')
    demand      = ex(r'\bdemand:\s*([-\d]+)')

    # enchantments (handles both stored_enchantments and enchantments)
    ench = ""
    em = re.search(r'"minecraft:stored_enchantments"\s*:\s*\{[^{}]*levels\s*:\s*\{([^}]*)\}', recipe, re.IGNORECASE)
    if not em:
        em = re.search(r'"minecraft:enchantments"\s*:\s*\{[^{}]*levels\s*:\s*\{([^}]*)\}', recipe, re.IGNORECASE)
    if em: ench = em.group(1).strip()

    return [sell_id, sell_count, buyA_id, buyA_count, buyB_id, buyB_count,
            xp, maxUses, uses, priceMult, demand, ench]

with open(input_file, "r", encoding="utf-8") as f:
    for idx, line in enumerate(f, start=1):
        if line.strip() == "":
            break  # stop at first blank line
        block = find_recipes_block(line)
        if not block:
            continue
        recipes = split_top_level_objects(block)
        profession = extract_profession(line)
        rows = [extract_fields(r) for r in recipes]
        out = os.path.join(output_dir, f"Villager_{idx}_{profession}.csv")
        with open(out, "w", newline="", encoding="utf-8") as csvfile:
            writer = csv.writer(csvfile)
            writer.writerow(columns)
            writer.writerows(rows)
