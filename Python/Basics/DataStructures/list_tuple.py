
print("""\n------------------------------------------------------------------------------
------------------------------------------------------------------------------
-------------------------------- LISTS ---------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------""")
empty_list = []; print(empty_list)
empty_list = list(); print(empty_list)
empty_list = list([]); print(empty_list)
empty_list = list([""]); print(empty_list) # ❌ : Not an empty list

fruits = ["apple", "banana", "banana", ""]; print(fruits)


print("\n----------------------------------- Add -------------------------------------------")
fruits.insert(1, "grapes"); print(fruits)
fruits.append("kiwi"); print(fruits)
fruits.append(["a", "b"]); print(fruits)
fruits.extend(("orange", "guava", {'key': 'value'})); print(fruits)


print("\n----------------------------------- Pop -------------------------------------------")
fruits.remove("banana"); print(fruits)
print(fruits.pop()); print(fruits)
print(fruits.pop(0)); print(fruits)
# print(fruits.pop(10)); print(fruits) # ❌ "IndexError: pop index out of range
fruits.clear(); print(fruits)


print("\n----------------------------------- Index & Count -------------------------------------------")
fruits = ["apple", "banana", "banana", "", ["a", "b"]]; print(fruits)
print(fruits.index("banana")); 
print(fruits.index("")); 
print(fruits.index(["a", "b"]));
# fruits.index("litchi") # ❌ "ValueError: 'litchi' is not in list"
fruits.count("banana")


print("\n----------------------------------- Sort & Reverse -------------------------------------------")
# fruits.sort() # ❌ "TypeError: '<' not supported between instances of 'list' and 'str' "
fruits.remove(["a", "b"]); fruits.sort(); print(fruits)
fruits.sort(reverse=True); print(fruits)

fruits.reverse(); print(fruits)



'''
| Method         | Example                              | Description                         |
| -------------- | ------------------------------------ | ----------------------------------- |
| `append(x)`    | `fruits.append("kiwi")`              | Add item at end                     |
| `insert(i, x)` | `fruits.insert(1, "grapes")`         | Insert at index                     |
| `extend(list)` | `fruits.extend(["orange", "guava"])` | Add all items from another list     |
| `remove(x)`    | `fruits.remove("banana")`            | Remove first occurrence             |
| `pop(i)`       | `fruits.pop(1)`                      | Remove item at index (default last) |
| `clear()`      | `fruits.clear()`                     | Remove all items                    |
| `index(x)`     | `fruits.index("apple")`              | Return index of item                |
| `count(x)`     | `fruits.count("apple")`              | Count occurrences                   |
| `sort()`       | `fruits.sort()`                      | Sort ascending                      |
| `reverse()`    | `fruits.reverse()`                   | Reverse the list                    |
| `copy()`       | `new_list = fruits.copy()`           | Return a shallow copy               |
'''


print("""\n------------------------------------------------------------------------------
------------------------------------------------------------------------------
-------------------------------- TUPLE ---------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------""")
empty_tuple = (); print(empty_tuple)
oneVal_tuple = (1,); print(oneVal_tuple) # ❗

nums = (1, 2, 3, 2, 4, 2); print(nums)
print(nums.count(2))  # 3
print(nums.count(10))  # 0
print(nums.index(4))  # 4


print("\n----------------------------------- Sort & Reverse -------------------------------------------")
# print(nums.sort()) # ❌ "AttributeError: 'tuple' object has no attribute 'sort'
print(tuple(sorted(nums))) # ✅ 

# print(nums.reverse()) # ❌ "AttributeError: 'tuple' object has no attribute 'reverse'
print(tuple(reversed(nums))) # ✅ 
