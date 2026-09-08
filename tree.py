#!/usr/bin/env python3
'''
    Author	: Nishikant Kanunje
    Date	: 09/09/2026
    Purpose	: Print repository tree using ASCII characters, Uses: git ls-files | tree.py or find . | tree.py
'''

import sys
tree = {}
for line in sys.stdin:
    parts = line.strip().split('/')
    curr = tree
    for p in parts:
        curr = curr.setdefault(p, {})
def print_tree(d, indent=''):
    items = sorted(d.keys())
    for i, k in enumerate(items):
        is_last = (i == len(items) - 1)
        print(f'{indent}{"└── " if is_last else "├── "}{k}')
        print_tree(d[k], indent + ('    ' if is_last else '│   '))
print_tree(tree)
