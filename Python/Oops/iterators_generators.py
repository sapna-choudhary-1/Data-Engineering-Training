my_list = [1, 4, 9]

"""
| Feature                 | Iterable           | Iterator                 | Generator           |
| ----------------------- | ------------------ | ------------------------ | ------------------- |
| Loopable                | ✅                 | ✅                       | ✅                  |
| Has `__iter__()`        | ✅                 | ✅                       | ✅                  |
| Has `__next__()`        | ❌                 | ✅                       | ✅                  |
| Stores all values       | ✅                 | ❌                       | ❌                  |
| Lazy (memory-efficient) | ❌                 | ✅                       | ✅                  |
| Built using             | Class or container | `iter()` or custom class | `yield` or gen expr |
| Use case                | Collections        | Manual looping           | Streaming data      |
| Example                 | List, Set, Dict    | Custom iterator class    | Generator function  |
"""


print("""\n------------------------------------------------------------------------------
------------------------------------------------------------------------------
-------------------------------- ITERABLE ---------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------""")

for item in my_list:  # This works because list is iterable
    print(item)


# ---------------- To Make any Obj Iterable --> define __iter__() ----------------
class MyIterable:
    def __init__(self, data):
        self.data = data

    def __iter__(self):
        return iter(self.data)  # Returns iterator

print("Using MyIterable: ", MyIterable(my_list), type(MyIterable(my_list)))
# Usage:
for x in MyIterable(my_list):
    print(x)



print("""\n------------------------------------------------------------------------------
------------------------------------------------------------------------------
-------------------------------- ITERATORS ---------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------""")



# ---------------- To Make any Obj an Iterator --> define __iter__() & __next__() ----------------
class MyIterator:
    def __init__(self, data):
        self.data = data
        self.index = 0

    def __iter__(self):
        return self  # Returns itself as iterator

    def __next__(self):
        if self.index >= len(self.data):
            raise StopIteration
        value = self.data[self.index]
        self.index += 1
        return value

# Usage:
itr = MyIterator(my_list)
print("Using MyIterator: ", itr, type(itr))
for x in itr:
    print(x)


print("""\n------------------------------------------------------------------------------
------------------------------------------------------------------------------
-------------------------------- GENERATORS ---------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------""")

# ---------------- Using yield ----------------
def my_generator(data):
    for item in data:
        yield item


print("Using MyGenerator: ", my_generator(my_list), type(my_generator(my_list)))
# Usage:
for x in my_generator(my_list):
    print(x)



print("""\n------------------------------------------------------------------------------
------------------------------------------------------------------------------
-------------------------------- DECORATORS ---------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------""")

# ---------------- ----------------
def log_iteration(func):
    def wrapper(*args, **kwargs):
        print("Calling generator/iterator/iterable...")
        return func(*args, **kwargs)
    return wrapper


print("\n----------------------------------- Decorate generator:-------------------------------------------")
@log_iteration
def my_generator(data):
    for item in data:
        yield item

for x in my_generator(my_list):
    print(x)


print("\n----------------------------------- Decorate iterable class::-------------------------------------------")
class MyIterable:
    def __init__(self, data):
        self.data = data

    @log_iteration
    def __iter__(self):
        return iter(self.data)

for x in MyIterable(my_list):
    print(x)


print("\n----------------------------------- Decorate iterator class: -------------------------------------------")
class MyIterator:
    def __init__(self, data):
        self.data = data
        self.index = 0

    @log_iteration
    def __iter__(self):
        return self

    @log_iteration
    def __next__(self):
        if self.index >= len(self.data):
            raise StopIteration
        value = self.data[self.index]
        self.index += 1
        return value

itr = MyIterator(my_list)
for x in itr:
    print(x)

print("""\n------------------------------------------------------------------------------
---- Chaining Decorators ----
------------------------------------------------------------------------------""")
def star(func):
    def inner(*args, **kwargs):
        print("*" * 15)
        func(*args, **kwargs)
        print("*" * 15)
    return inner


def percent(func):
    def inner(*args, **kwargs):
        print("%" * 15)
        func(*args, **kwargs)
        print("%" * 15)
    return inner


@star
@percent
def printer(msg):
    print(msg)
printer("Hello")

# It's equivalent to :-
def printer(msg):
    print(msg)
p = star(percent(printer))
p("Hi")