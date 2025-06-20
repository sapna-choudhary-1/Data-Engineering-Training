
print("""\n------------------------------------------------------------------------------
------------------------------------------------------------------------------
-------------------------------- TYPES OF COPY ---------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------""")

print("\n----------------------------------- Referential Copy -------------------------------------------")
# Both a and b point to the same object in memory (only for mutable). Changes in one affect the other.
# just another name for the same list (Alias)
# ❗❗modifies the list in place
original_lst = [1, 2, 3]
original_str = "Hello"
original_tpl =  (1, 2, 3)

referential_lst = original_lst; print(original_lst, referential_lst, sep="\n")
print(id(original_lst), id(referential_lst), sep="\n")  # same IDs
referential_lst.append(4); print(original_lst, referential_lst, sep="\n")

referential_str = original_str; print(original_str, referential_str, sep="\n")
referential_str += " World"
print(id(original_str), id(referential_str), sep="\n")  # different IDs
print(original_str, referential_str, sep="\n")

referential_tpl = original_tpl; print(original_tpl, referential_tpl, sep="\n")
print(id(original_tpl), id(referential_tpl), sep="\n")  # same IDs
# referential_tpl += (4,)  # ❌ "TypeError: 'tuple' object does not support item assignment"
# referential_tpl.append(4)  # ❌ "AttributeError: 'tuple' object has no attribute 'append'"
tmp = list(referential_tpl)
tmp.append(5)
referential_tpl = tuple(tmp)  # creates a new tuple
print(id(original_tpl), id(referential_tpl), sep="\n")  # different IDs
print(original_tpl, referential_tpl, sep="\n")


print("\n----------------------------------- Shallow Copy -------------------------------------------")
# You create a new outer object, but inner objects are shared.
# Copies references only
import copy

original = [[1, 2], [3, 4]]
shallow = copy.copy(original)
shallow = original.copy()
print(id(original), id(shallow),sep="\n")
print(id(original[0]), id(shallow[0]), sep="\n") # ❗

shallow[0].append(5); print(original, shallow, sep="\n")
shallow.append([5, 6]); print(original, shallow, sep="\n") # ❗


print("\n----------------------------------- Deep Copy -------------------------------------------")
# You create a new outer object, and nested/inner objects are not shared.
# Everything is fully cloned recursively, including nested items.
original = [[1, 2], [3, 4]]
deepc = copy.deepcopy(original)
print(id(original), id(deepc), sep="\n")
print(id(original[0]), id(deepc[0]), sep="\n") # ❗

deepc[0].append(5); print(original, deepc, sep="\n")
deepc.append([5, 6]); print(original, deepc, sep="\n") # ❗




'''
| Type of Copy     | What gets copied       | When to use                                          |
| ---------------- | ---------------------- | ---------------------------------------------------- |
| Referential Copy | Nothing (just alias)   | Never! (unless intentional)                          |
| Shallow Copy     | Outer object           | When inner items are not mutable or won’t be changed |
| Deep Copy        | Everything (recursive) | Always safe for complex objects                      |
'''