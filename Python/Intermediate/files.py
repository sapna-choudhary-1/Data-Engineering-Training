

print("""\n------------------------------------------------------------------------------
------------------------------------------------------------------------------
-------------------------------- FILE HANDLING ---------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------""")

"""
| Mode  | Meaning          | Used For                  | Destroys Data? | Notes                      |
| ----- | ---------------- | ------------------------- | -------------- | -------------------------- |
| `'r'` | Read only        | Reading files             | ❌             | Default mode               |
| `'w'` | Write only       | Create/overwrite          | ✅             | Creates file if not exists |
| `'a'` | Append           | Add to file               | ❌             | Creates file if not exists |
| `'x'` | Exclusive create | Avoid overwrite           | ❌             | Fails if file exists       |
| `'b'` | Binary mode      | Non-text (images, pickle) | N/A            | Use with `r`, `w`, etc.    |
| `'t'` | Text mode        | Readable text             | N/A            | Default, can omit          |
🔸 Combine modes like 'rb', 'wt', 'ab'.
"""

print("\n----------------------------------- WRITING -------------------------------------------")
f = open("Python/Intermediate/data.txt", "w")
f.write("Hi!\n")
f.close()  # You must remember to close it

print("\n----------------------------------- USING 'WITH' -------------------------------------------")
with open("Python/Intermediate/data.txt", "a") as f:
    f.write("Hello!\n")
    f.write("Welcome to file handling.")
with open("Python/Intermediate/data.txt", "r") as f:
    content = f.read()
    print("\n----\n", content)

lines = ["Hello\n", "Welcome\n", "Bye\n"]
with open("Python/Intermediate/data.txt", "w") as f:
    f.writelines(lines)
with open("Python/Intermediate/data.txt", "r") as f:
    content = f.read()
    print("\n----\n", content)

print("\n----------------------------------- APPENDING -------------------------------------------")
with open("Python/Intermediate/data.txt", "a") as f:
    f.write("\nThis is an added line.")

print("\n----------------------------------- READING -------------------------------------------")
with open("Python/Intermediate/data.txt", "r") as f:
    content2 = f.readline()
    content3 = f.readlines()
    content = f.read() # ❗Empty❗
    print(content2, content3, content, sep="\n----\n")

with open("Python/Intermediate/data.txt", "r") as f:
    content = f.read()
    print("\n----\n", content)

print("\n----------------------------------- READING LINE BY LINE -------------------------------------------")
with open("Python/Intermediate/data.txt", "r") as f:
    for line in f:
        print(line.strip())

print("\n----------------------------------- READING SPECIFIC BYTES -------------------------------------------")
with open("Python/Intermediate/data.txt", "r") as f:
    partial = f.read(10)  
    print(partial.strip())


print("\n----------------------------------- CHECKING IF FILE EXISTS -------------------------------------------")
import os

if os.path.exists("Python/Intermediate/data.txt"):
    print("File exists!")
else:
    print("File not found.")


print("\n----------------------------------- FILE ATTRIBUTES -------------------------------------------")
f = open("Python/Intermediate/data.txt", "r")
print(f.name)       # File name
print(f.mode)       # Mode used to open
print(f.encoding)   # Encoding used
f.close()


print("""\n------------------------------------------------------------------------------
------------------------------------------------------------------------------
-------------------------------- CSV ---------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------""")
import csv

data = [
    ["Name", "Age"],
    ["Alice", 30],
    ["Bob", 25]
]

with open("Python/Intermediate/people.csv", "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerows(data)

with open("Python/Intermediate/people.csv", "r") as f:
    reader = csv.reader(f)
    for row in reader:
        print(row)

print("\n----------------------------------- USING DictWriter & DictReader -------------------------------------------")
data = [
    {"name": "Alice", "age": 35},
    {"name": "Bob", "age": 28}
]

# Writing as dict
with open("Python/Intermediate/people.csv", "a", newline="") as f:
    fieldnames = ["name", "age"]
    writer = csv.DictWriter(f, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(data)

# Reading as dict
with open("Python/Intermediate/people.csv", "r") as f:
    reader = csv.DictReader(f)
    for row in reader:
        print(row)  # {'name': 'Alice', 'age': '30'}



print("""\n------------------------------------------------------------------------------
------------------------------------------------------------------------------
-------------------------------- JSON ---------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------""")
import json

person = {
    "name": "Alice",
    "age": 30,
    "languages": ["English", "Spanish"]
}

with open("Python/Intermediate/person.json", "w") as f:
    json.dump(person, f, indent=4)

with open("Python/Intermediate/person.json", "r") as f:
    data = json.load(f)
print(data["name"])  # Alice


print("\n-----------------------------------  -------------------------------------------")

class Person:
    def __init__(self, name, age):
        self.name = name
        self.age = age

def encode_person(obj):
    if isinstance(obj, Person):
        return {"name": obj.name, "age": obj.age}
    raise TypeError("Object is not JSON serializable")

p = Person("Alice", 30) 

json_str = json.dumps(p, default=encode_person)
print(json_str)
