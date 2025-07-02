
# ================================================================================
# Python Practice Code for: namedtuple, dataclass, SimpleNamespace, TypedDict
# Purpose: Understand each concept individually with simple use cases.
# ================================================================================

# -----------------------
# 1. namedtuple
# -----------------------
from collections import namedtuple

print("\n========== namedtuple ==========")

# Define a simple namedtuple
Point = namedtuple("Point", ["x", "y"])
p = Point(10, 20)

print("x:", p.x)
print("y:", p[1])
# p.x = 30  # ❌ AttributeError: can't set attribute
# -----------------------

print("As tuple:", p)
print("As dict:", p._asdict())
# -----------------------

print("Fields:", p._fields)
print("Replace:", p._replace(y=25))
# -----------------------

a, b = p  # Unpacking
print("Unpacked:", a, b)
# -----------------------

for field in p._fields:
    print(f"{field}: {getattr(p, field)}")
for val in p:
    print(val)
# -----------------------

class Person(namedtuple("PersonBase", ["name", "age"])):
    def is_senior(self):
        return self.age >= 60

p = Person("AA", 70)
print(p.is_senior())  



# -----------------------
# 2. dataclass
# -----------------------
from dataclasses import dataclass, field, asdict, astuple
from uuid import uuid4
from datetime import datetime

print("\n========== dataclass ==========")
class Counter:
    def __init__(self):
        self.count = 0

    def __call__(self):
        self.count += 1
        return self.count

    def __repr__(self):
        return f"Counter({self.count})"
    

@dataclass(init=True, repr=True, eq=True, order=True, unsafe_hash=True, frozen=False)
class Person:
    name: str
    age: int = field(default=18, init=True, repr=True, compare=True, hash=True, metadata={'format': 'years'})
    hobbies: list = field(default_factory=list)
    cnt: int = field(init=False, default_factory=Counter())
    is_senior: bool = field(init=False)
    id: str = field(default_factory=lambda: str(uuid4()))
    timestamp: str = field(default_factory=lambda: datetime.now().isoformat())

    def __post_init__(self):
        if self.age < 0:
            raise ValueError("Age cannot be negative")
        if self.age >= 60:
            self.is_senior = True
        else:
            self.is_senior = False

    def greet(self):
        print(f"Hi, I'm {self.name} and I'm {self.age} years old.")

p = Person("AA", 24)
p2 = Person("AA", 60, hobbies=["Reading", "Traveling"])
p.greet()
p.hobbies.append("Chess")
print("\n-----------------------\n")
print("p1: ", p)
print("p2: ", p2)
print(p.__dict__.get('name'))  
print("\n-----------------------\n")

print("p1 == p2:", p == p2)
print("p1 != p2:", p != p2)
print("p1.age < p2.age:", p.age < p2.age)
print("p1.name == p2.name:", p.name in p2.__dict__.values())
print("\n-----------------------\n")

print("Hobbies:", p.hobbies)
print("As dict:", asdict(p))
print("As tuple:", astuple(p))

# -----------------------
print("\n-----------------------\n")
@dataclass
class Employee(Person):
    # employee_id: int  # ❌ TypeError: non-default argument 'employee_id' follows default args in Person
    employee_id: int = field(default=0, init=True, repr=True, compare=True, hash=True)
    department: str = "General"

    def work(self):
        print(f"{self.name} is working in {self.department} department.")

e = Employee("Ankit", 30, employee_id=101, department="Engineering")
e.greet()
e.work()
print("Employee ID:", e.employee_id)
print(e.is_senior)  # Inherited method from Person
print("Counter:", e.cnt)

print("\n-----------------------\n")
print("As dict:", asdict(e))
print("-----------------------\n")
print("Fields:", e.__dataclass_fields__)
print("-----------------------\n")
print("Metadata for age:", e.__dataclass_fields__['age'].metadata)
print("\n-----------------------\n")


# -----------------------

# -----------------------
# 3. SimpleNamespace
# -----------------------
from types import SimpleNamespace

print("\n========== SimpleNamespace ==========")

config = SimpleNamespace(debug=True, version="1.0.0")
print("Debug mode:", config.debug)
print("Version:", config.version)

# Mutate values easily
config.debug = False
config.new_field = "extra"
print("Updated:", vars(config))


# -----------------------
# 4. TypedDict
# -----------------------
from typing import TypedDict

print("\n========== TypedDict ==========")

class StudentDict(TypedDict):
    name: str
    marks: int

student: StudentDict = {"name": "Ankit", "marks": 87}

print("Student name:", student["name"])
print("Marks:", student["marks"])

# TypedDict behaves like a normal dict at runtime
student["marks"] = 90
print("Marks:", student["marks"])

