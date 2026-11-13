import sys

# Target and mob EXP values
MAX_EXP = 58000
MOBS = {
    598: "Lair Of Death",
    92:  "Grounded Swordsman",
    8:   "Bat",
    215: "Lair Of Death (Only First Boss)",
    115: "Flying Mage",
    38:  "Flying Swordsman"
}
COINS = [598, 215, 92, 8, 115, 38]

# Costs strictly prioritize our preferred loop.
# 115 and 38 are penalized heavily so they are ONLY used for dead zones.
COSTS = {
    598: 1,
    92:  1,
    8:   1,
    215: 100,   # 1st backup
    115: 1000,  # 2nd backup
    38:  10000  # 3rd backup
}

def main():
    try:
        current_exp = int(input(f"Enter your current EXP (Target: {MAX_EXP}): "))
    except ValueError:
        print("Please enter a valid integer.")
        sys.exit(1)

    target = MAX_EXP - current_exp

    if target < 0:
        print(f"You are already over {MAX_EXP} by {-target} EXP.")
        sys.exit(0)
    elif target == 0:
        print(f"You are exactly at {MAX_EXP} EXP. Run 'Death's Lair'then collect the exp sacks")
        sys.exit(0)

    # Dynamic Programming to find the absolute minimum number of kills
    dp = [float('inf')] * (target + 1)
    dp[0] = 0
    choice = [0] * (target + 1)

    for i in range(1, target + 1):
        for coin in COINS:
            if i >= coin and dp[i - coin] + COSTS[coin] < dp[i]:
                dp[i] = dp[i - coin] + COSTS[coin]
                choice[i] = coin

    if dp[target] == float('inf'):
        print(f"\nError: Could not find an exact mathematical match for {target} EXP.")
        print("You have hit a dead zone. The target is too small or impossible to form with available mobs.")
        sys.exit(1)

    # Backtrack to count the required kills for each mob
    counts = {coin: 0 for coin in COINS}
    curr = target
    while curr > 0:
        c = choice[curr]
        counts[c] += 1
        curr -= c

    # Output the optimized strategy
    print(f"\nTarget EXP required: {target}")
    print("-" * 64)
    for coin in [598, 215, 92, 8, 115, 38]: # Ordered for clean output
        if counts[coin] > 0:
            print(f"{coin:>3} * {counts[coin]:<2} | {MOBS[coin]:<38} | {counts[coin]*coin:>5} EXP |")
    print("-" * 64)

if __name__ == "__main__":
    main()
