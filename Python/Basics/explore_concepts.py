# ✅ ❌ ➡️ ❓❗➤ 

print("""\n------------------------------------------------------------------------------
---- BASICS ----
------------------------------------------------------------------------------""")
# This is a comment
print("Hello, Python!")  # Print statement

print("---- Multiple assignments ----")
x, y = 5, 10
a = b = c = 7
print(x, y, a, b, c)

print("---- Methods to fetch: data type & memory location ----")
a =[1, 2, 3]
b = a
c = [1, 2, 3]
print(type(a), type("a"), type(1+5j))
print(id(a), id(b), id(c))


print("""\n------------------------------------------------------------------------------
---- OPERATORS ----
------------------------------------------------------------------------------""")
a =[1, 2, 3]
b = a
c = [1, 2, 3]

print("---- Identity ----")
print(a is b)      # True (same object)
print(a is c)      # False (same content, diff object)
print(a == c)      # True (same content)

print("---- Membership ----")
print(2 in a)      # True
print(2 not in a)  # True

print("---- Arithmetic ----")
print(10/3, 
    10//3, 
    10%3, sep="\n")

print("---- Comparision ----")
print(10<3, 
    10!=3, 
    3>=3, sep="\n")

print("---- Logical ----")
print(10>3 and 10==3, 
      10>3 or 10==3, 
      not(10>3), 
      not(10==3),  sep="\n")


print("""\n------------------------------------------------------------------------------
---- TYPE CONVERSION ----
------------------------------------------------------------------------------""")
print(int("123") + 1)       # 124
print(float("3.5") * 2)       # 7.0
print(str(100) + "0")     # '1000'
print(bool(0), bool(None), bool(''), bool([]))
print(bool("hello"), bool(1))



print("""\n------------------------------------------------------------------------------
---- CONTROL FLOW ----
------------------------------------------------------------------------------""")
print("---- If/ Elif/ Else ----")
age = 20
if age > 18:
    if age < 25:
        print("You are in your early 20s.")
    else:
        print("Adult")
else:
    print("Minor")

print("---- Case ----")


print("""\n------------------------------------------------------------------------------
---- LOOPS ----
------------------------------------------------------------------------------""")
print("---- For ----")
for i in range(2, 10, 2):
    print(i)

print("---- ----")
for char in "Sapna":
    print(char)

print("---- ----")
fruits = ["apple", "banana", "mango"]
for fruit in fruits:
    print(fruit)

print("---- While ----")
count = 1
while count <= 5:
    print("Count is:", count)
    count += 1

print("---- ----")
# break example
for i in range(10):
    if i == 5:
        break
    print(i)

print("---- ----")
# continue example
for i in range(5):
    if i == 2:
        continue
    print(i)


print("""\n------------------------------------------------------------------------------
---- COMPREHENSIONS ----
------------------------------------------------------------------------------""")
print("---- List ----")
squares = [x**2 for x in range(1, 6)]
print(squares)  # [1, 4, 9, 16, 25]

print("---- ----")
even_numbers = [x for x in range(10) if x % 2 == 0]
print(even_numbers)  # [0, 2, 4, 6, 8]

print("---- ----")
pairs = [(x, y) for x in [1, 2] for y in [3, 4]]
print(pairs)  # [(1, 3), (1, 4), (2, 3), (2, 4)]
