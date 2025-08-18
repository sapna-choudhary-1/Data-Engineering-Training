
print("""\n------------------------------------------------------------------------------
------------------------------------------------------------------------------
-------------------------------- DICTIONARIES ---------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------""")
empty_dict = {}; print(empty_dict)
empty_dict = dict(); print(empty_dict)


stud = {
    "name": "Sana",
    "age": 25,
    "s_keyills": ["Python", "AI"]
}
print(stud)

for key, value in stud.items():
    print(key, "->", value)


print("\n------------------------------------------------------------------------------")
print(stud["name"]); 
# print(stud["n"]) # ❌ "KeyError: 'n' "
print(stud.get("name", None)); 
print(stud.get("n", None)) # ✅ 


print("\n------------------------------------------------------------------------------")
print(stud.keys())
print(stud.values())
print(stud.items())
# print(fruits.keys()) # ❌ "AttributeError: 'list' object has no attribute 'keys' "


print("\n----------------------------------- Add -------------------------------------------")
stud.update({"city": "Delhi"}); print(stud)
stud.update({"name": "Sarah"}); print(stud) #❗❗


print("\n----------------------------------- Pop -------------------------------------------")
stud.pop("age"); print(stud)
# stud.pop("n"); print(stud) # ❌ "KeyError: 'n'
# stud.pop(1); print(stud) # ❌ "KeyError: 1"
# stud.pop(); print(stud) # ❌ "TypeError: pop expected at least 1 argument, got 0
stud.clear(); print(stud)



print("\n----------------------------------- fromkeys() -------------------------------------------")
keys = ['name', 'age', 'city']
new_dict = dict.fromkeys(keys, 'unknown')
print(new_dict) # {'name': 'unknown', 'age': 'unknown', 'city': 'unknown'}

print("------------------------------------------------------------------------------")
defaults = dict.fromkeys(['a', 'b'], []); print(defaults)
defaults['a'].append(1)
print(defaults)  # ❗❗both 'a' and 'b' get updated --> Since both share the same list reference

print("\n----------------------------------- Alternative -------------------------------------------")
{key: [] for key in ['a', 'b']}




print("\n----------------------------------- Shallow Copy -------------------------------------------")
stud = {
    "name": "Sana",
    "age": 25,
    "s_keyills": ["Python", "AI"]
}; print(stud)
shallow_stud = stud.copy(); print(shallow_stud) # Return a shallow copy
shallow_stud.pop("s_keyills"); print(shallow_stud, stud)


print("\n----------------------------------- Deep Copy -------------------------------------------")
stud = {
    "name": "Sana",
    "age": 25,
    "s_keyills": ["Python", "AI"]
}; print(stud)
deep_stud = stud; print(deep_stud) # Return a deep copy
deep_stud.pop("s_keyills"); print(deep_stud, stud)


'''
| Method                | Example                             | Description                          |
| --------------------- | ----------------------------------- | ------------------------------------ |
| `get(key, default)`   | `student.get("age", 0)`             | Returns value or default             |
| `keys()`              | `student.keys()`                    | Returns list of keys                 |
| `values()`            | `student.values()`                  | Returns list of values               |
| `items()`             | `student.items()`                   | Returns (key, value) pairs           |
| `update(dict)`        | `student.update({"city": "Delhi"})` | Add or update key-value              |
| `pop(key)`            | `student.pop("age")`                | Remove key and return value          |
| `clear()`             | `student.clear()`                   | Remove all items                     |
| `copy()`              | `new_dict = student.copy()`         | Copy dictionary                      |
| `fromkeys(keys, val)` | `dict.fromkeys(['a', 'b'], 0)`      | Create dict with given keys & values |
'''


# UNPACKING
v = (1,2,3)
print(v, *v, sep="\n")

v = {"a":"a", "d":"b"}
print(v, *v, sep="\n")
def fn(**kwargs):
    print(kwargs)
fn(**v)
print(*[f"{k}={v}" for k, v in v.items()], sep="\n")