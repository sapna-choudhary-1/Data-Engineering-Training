
print("""\n------------------------------------------------------------------------------
------------------------------------------------------------------------------
-------------------------------- SETS ---------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------""")
empty_set = set(); print(empty_set)


colors = {"red", "blue"}
print(colors)


print("\n----------------------------------- Add -------------------------------------------")
colors.add("yellow"); print(colors)
colors.add(None); print(colors)
colors.add(5); print(colors)
colors.add(("black", "brown")); print(colors)
# colors.add(["pink", "purple"]); print(colors) # ❌ TypeError: unhashable type: 'list'

colors.update(["pink", "purple"]); print(colors)
colors.update("cyan"); print(colors)

print("\n----------------------------------- Pop -------------------------------------------")
colors.remove("red"); print(colors)
# colors.remove("brown"); print(colors) # ❌ KeyError: 'brown'

colors.discard("cyan"); print(colors) # ✅ 

print(colors.pop()); print(colors)
# print(colors.pop(1)); print(colors) # ❌ TypeError: set.pop() takes no arguments (1 given)

colors.clear(); print(colors)


print("\n----------------------------------- Set Operations -------------------------------------------")
x = {1, 2, 3}; print(x)
y = {3, 4, 5}; print(y)
z = x.union(y, ("yellow",), "blue")
print(z)
print(x | y)

print(x.intersection(y))
print(x & y)
print(x.intersection(y, ("yellow",), "blue"))

print(x.difference(y))
print(x - y)

print(x.symmetric_difference(y))
print(x ^ y)

print(x.issubset(z))
print(z.issuperset(x))





'''
| Method               | Example                             | Description                                         |
| -------------------- | ----------------------------------- | --------------------------------------------------- |
| `add(x)`             | `colors.add("yellow")`              | Add item; Returns None if addition is successful    |
| `update(iterable)`   | `colors.update(["pink", "purple"])` | Add multiple items                                  |
| `remove(x)`          | `colors.remove("red")`              | Remove item (Key Error if not found); Returns None  |
| `discard(x)`         | `colors.discard("red")`             | Remove item (no error if not found; Returns None    |
| `pop()`              | `colors.pop()`                      | Remove random item (Key Error if no ele found)      |
| `clear()`            | `colors.clear()`                    | Empty the set                                       |
| `union(set2)`        | `a.union(b)`                        | Combine sets (no duplicates)                        |
| `intersection(set2)` | `a.intersection(b)`                 | Common items                                        |
| `difference(set2)`   | `a.difference(b)`                   | Items in a not in b                                 |
| `issubset(set2)`     | `a.issubset(b)`                     | True if a is subset of b                            |
| `issuperset(set2)`   | `a.issuperset(b)`                   | True if a contains b                                |
'''