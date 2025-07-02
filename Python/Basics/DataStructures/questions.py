

print("""\n------------------------------------------------------------------------------
------------------------------------------------------------------------------
-------------------------------- FLASHCARDS ---------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------""")
print('''| Question                                               | Answer                                                      |
| ------------------------------------------------------ | ----------------------------------------------------------- |
| Which data structures do not allow duplicates?	     | Set and dictionary keys.                                    |
| How do you access a dictionary value?                  | dict[key] or dict.get(key)                                  |
| How to create an empty list/tuple/set/dict?	         | [], (), set(), {} respectively                              |

| How to sort a list in descending order?                | `list.sort(reverse=True)`                                   |
| How to remove an item safely from a set?               | `set.discard(item)`                                         |
| How to combine two dictionaries?                       | `dict1.update(dict2)` or `{**dict1, **dict2}`               |
| Difference between `remove()` and `discard()` in sets? | `remove` raises error if item not found; `discard` doesn’t. |
| What does `list.copy()` do?                            | Returns a shallow copy of the list.                         |
| How to get keys of a dictionary?                       | `dict.keys()`                                               |
| How to iterate both key and value of a dictionary?     | `for k, v in dict.items():`                                 |

| Can a set contain another set?	                     | No, sets must contain hashable (immutable) types.           |
| What is the time complexity of dict[key] lookup?	     | Average O(1)                                                |

| Can you modify a value inside a list that is inside a tuple?| YES!! Only the tuple is immutable—not the objects inside it |
      
| Can sets be used as dictionary keys?| NO!! Sets are mutable and unhashable. Use frozenset() if needed |
''')


print("""\n------------------------------------------------------------------------------
------------------------------------------------------------------------------
-------------------------------- QUESTIONS ---------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------""")

print("\n---- Q1: Merge 2 dictionaries ----")
a = {"name": "Sana"}; b = {"age": 25}
a.update(b); print(a)


print("\n------------------------------------------------------------------------------")
print("---- Q2: Remove duplicates from list ----")
print("------------------------------------------------------------------------------")
nums = [1, 2, 2, 3, 4, 4]
unique = list(set(nums)); print(unique)

#  ❓using fromkeys?❓

print("\n------------------------------------------------------------------------------")
print("---- Q3: Check if all elements in a list are unique ----")
print("------------------------------------------------------------------------------")
print(len(nums) == len(set(nums)))

print("\n------------------------------------------------------------------------------")
print("---- Q4: Check key exists in dictionary ----")
print("------------------------------------------------------------------------------")
a = {"name": "Sana"}; print("chk_key" in a)

print("\n------------------------------------------------------------------------------")
print("---- Q5: Flip the keys and values ----")
print("------------------------------------------------------------------------------")
a = {"a": 1, "b": 2}
print({v: k for k, v in a.items()})


print("\n------------------------------------------------------------------------------")
print("---- Q6: Convert this list into a dict of element -> count ----")
print("------------------------------------------------------------------------------")
lst = ['a', 'b', 'a', 'c', 'b']

count_dict = {}
for item in lst:
    count_dict[item] = count_dict.get(item, 0) + 1
print(count_dict)
# OR
print({k: lst.count(k) for k in lst})


print("\n------------------------------------------------------------------------------")
print("---- Q7: Merge two dicts and keep only items with even values. ----")
print("------------------------------------------------------------------------------")
dt = {"x": 1, "y": 2}; b = {"z": 4, "y": 3}

dt.update(b)
filtered_a = {k: v for k, v in dt.items() if v%2==0}
print(a, filtered_a, sep="\n")


print("\n------------------------------------------------------------------------------")
print("---- Q7: Merge two dicts and keep only items with even values. ----")
print("------------------------------------------------------------------------------")
dt = {"x": 1, "y": 2}; b = {"z": 4, "y": 3}

dt.update(b)
filtered_a = {k: v for k, v in dt.items() if v%2==0}
print(a, filtered_a, sep="\n")


print("\n------------------------------------------------------------------------------")
print("---- Q8: Reverse a list without using reverse() or slicing. ----")
print("------------------------------------------------------------------------------")
lst = [1, 2, 3, 3, 4]

lst1 = []
for i in lst:
    lst1 = [i] + lst1
print(lst1)

# Alternates
lst2 = lst.reverse(); print(lst2)
lst3 = lst[:-1]; print(lst3)
lst4 = list(reversed(lst)); print(lst4)


print("\n------------------------------------------------------------------------------")
print("---- Q9: Flatten a nested list ----") # ❓without recursion ❓
print("------------------------------------------------------------------------------")
nested = [1, [2, [3, 4]], 5]

def flatten(lst):
    result = []
    for i in lst:
        if isinstance(i, list):
            result.extend(flatten(i))
        else:
            result.append(i)
    return result
flatten(nested)


print("\n------------------------------------------------------------------------------")
print("---- Q10: What will be the result? ----")
print("------------------------------------------------------------------------------")
d = {}
d[1] = 'a'
d[True] = 'b'
d[False] = 'c'
d[0] = 'd'
print(d)

# ❗❗➤ Because 1 & True and 0 & False are considered the same key (1 == True, 0 == False), second assignment overrides the first.
# {1: 'b', False: 'd'} # ❗❗



print("\n------------------------------------------------------------------------------")
print("---- Q11: How to merge dicts but keep both values if key overlaps? ----")
print("------------------------------------------------------------------------------")
a = {'x': 1, 'y': 2}; b = {'y': 3, 'z': 4}
res = {}
for k in a.keys() | b.keys():
    res[k] = ( [a[k], b[k]] 
              if k in a and k in b 
              else a.get(k) or b.get(k) )
print(res)


print("\n------------------------------------------------------------------------------")
print("---- Q12: Convert a list of tuples to a dictionary with list values: ----")
print("------------------------------------------------------------------------------")
lst = [("a", 1), ("b", 2), ("a", 3)]
# Output: {'a': [1, 3], 'b': [2]}

print("---- Using regular dict + .setdefault() ----")
dct = {}
for key, value in lst:
    dct.setdefault(key, []).append(value)
print(dct)

# OR 
print("---- Using defaultdict ----")
from collections import defaultdict
dct = defaultdict(list)
for key, value in lst:
    dct[key].append(value)
print(dct, dict(dct), sep="\n")

# OR 
print("---- Using groupby from itertools (if data is sorted) ----")
from itertools import groupby
grouped = {k: [v for _, v in g] for k, g in groupby(lst, key=lambda x: x[0])}
print(grouped)




print("\n------------------------------------------------------------------------------")
print("---- Q13: You’re given a list of numbers. Find duplicates. ----")
print("------------------------------------------------------------------------------")
lst = [1, 2, 3, 2, 4, 5, 1]

print("---- Using a set to track seen values (Optimal) ----")
seen, duplicates = set(), set()
for num in lst:
    if num in seen:
        duplicates.add(num)
    else:
        seen.add(num)
print(duplicates)

# OR 
print("---- Using a dictionary manually ----")
count_dict = {}
for num in lst:
    count_dict[num] = count_dict.get(num, 0) + 1
duplicates = {k for k, v in count_dict.items() if v > 1}
print(duplicates)

# OR 
print("---- Using Counter from collections ----")
from collections import Counter
counts = Counter(lst)
duplicates = {num for num, count in counts.items() if count > 1}
print(duplicates)

# OR 
print("---- Find all duplicates (including repeated ones) ----")
from collections import Counter
counts = Counter(lst)
duplicates = []
for num in lst:
    if counts[num] > 1:
        duplicates.append(num)
print(duplicates)

# OR 
print("---- First duplicate only ----")
seen = set()
for num in lst:
    if num in seen:
        print(f"First duplicate: {num}")
        break
    seen.add(num)





print("\n------------------------------------------------------------------------------")
print("---- Q14: Group anagrams from a list: ----")
print("------------------------------------------------------------------------------")
words = ["eat", "tea", "tan", "ate", "nat", "bat"]
# Output: [["eat", "tea", "ate"], ["tan", "nat"], ["bat"]]

from collections import defaultdict
anagrams = defaultdict(list)
for word in words:
    key = ''.join(sorted(word))
    anagrams[key].append(word)

res = list(anagrams.values()); print(res)



print("\n------------------------------------------------------------------------------")
print("---- Q15: Rotate the list by n values ----")
print("------------------------------------------------------------------------------")
my_list = [1, 2, 3, 4, 5] # Output: [4, 5, 1, 2, 3] if n=2
n = 2
l = len(my_list)
lst = my_list[l-n : ] + my_list[ : l-n]
print(lst)



print("\n------------------------------------------------------------------------------")
print("---- Q16: Return the second largest element from the given list of values ----")
print("------------------------------------------------------------------------------")
# Way-1: Using set to remove duplicates & indexing
# Way-2: Using loop and checking with the maximum value
# QUES LINK: https://www.hackerrank.com/challenges/find-second-maximum-number-in-a-list




print("\n------------------------------------------------------------------------------")
print("---- Q17: Return ordered names of students getting second-lowest-scores ----")
print("------------------------------------------------------------------------------")
# QUES LINK: https://www.hackerrank.com/challenges/nested-list

# ➡️  ➡️ To sort a nested list first:  wrt the second ele in each sublist, then: wrt the first ele in each sublist
students = [["Harry", 37.21], ["Berry", 37.21], ["Tina", 37.2], ["Akriti", 41], ["Harsh", 39]]
students.sort(key=lambda x: (x[1], x[0]))




print("\n------------------------------------------------------------------------------")
print("---- Q18: Perform list operations based on given inputs of (function arg1 arg2) ----")
print("------------------------------------------------------------------------------")
# QUES LINK: https://www.hackerrank.com/challenges/python-lists
"""
# ➡️  ➡️ To take input of each operation as the function name followed by its arguments
cmd, *args = input().split(" ")

# ➡️  ➡️ To take args as integers
int_args = ', '.join(str(int(a)) for a in args)

# ➡️  ➡️ To evaluate the command with arguments
lst = []; eval(f"lst.{cmd}({int_args})")
"""





print("\n------------------------------------------------------------------------------")
print("---- Q19: Find number of occurances of substring in the given string (consider overlaps too)----")
print("------------------------------------------------------------------------------")
# QUES LINK: https://www.hackerrank.com/challenges/find-a-string
# Way-1: Using loop
# Way-2: Using regex




print("\n------------------------------------------------------------------------------")
print("---- Q20: Wrap the string into a paragraph of width 'w' ----")
print("------------------------------------------------------------------------------")
# QUES LINK: https://www.hackerrank.com/challenges/text-wrap
# :- Using textwrap module




print("\n------------------------------------------------------------------------------")
print("---- Q21: Print the capitalized string (12abc when capitalized remains 12abc & not become 12Abc) ----")
print("------------------------------------------------------------------------------")
# QUES LINK: https://www.hackerrank.com/challenges/capitalize
# --------> There can be multiple spaces between 2 words
# :- Using for loop and str.capitalize()
# :- Can't use str.title() ---> it capitalizes the first letter of each word




print("\n------------------------------------------------------------------------------")
print("---- Q22: 'The Minion Game' ----")
print("------------------------------------------------------------------------------")
# QUES LINK: https://www.hackerrank.com/challenges/the-minion-game