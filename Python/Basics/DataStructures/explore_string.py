print("""\n------------------------------------------------------------------------------
------------------------------------------------------------------------------
-------------------------------- STRING MODULE ---------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------""")

import string

print(string.ascii_letters)  # 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'
print(string.ascii_lowercase)  # 'abcdefghijklmnopqrstuvwxyz'
print(string.ascii_uppercase)  # 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
print(string.digits)  # '0123456789'
print(string.punctuation)  # '!"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~'
print(string.printable)  # '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!"#$%&\'
print(string.whitespace)  # ' \t\n\r\x0b\x0c'
print(string.hexdigits)  # '0123456789abcdefABCDEF'
print(string.octdigits)  # '01234567'
print(string.capwords("hello world"))  # 'Hello World'
print(string.Template("Hello, $name!").substitute(name="Alice"))  # 'Hello, Alice!'
print(string.Formatter().format("Hello, {}!", "Bob"))  # 'Hello, Bob!'
print(string.Formatter().parse("Hello, {}!"))  # [('Hello, ', None, None), ('!', None, None)]
print(string.Formatter().vformat("Hello, {}!", ("Charlie",), {})) # 'Hello, Charlie!'
print(string.Formatter().format("Hello, {name}!", name="Dave"))  # 'Hello, Dave!'

print("""\n------------------------------------------------------------------------------
------------------------------------------------------------------------------
-------------------------------- STRING ---------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------""")

# String Initialization
place = "India"
quote = 'Believe In Yourself'
bio = """I love
Python and AI."""  # Multiline string

# Display strings
print(place, quote, bio, sep='\n', end='\n------------\n')
bio  # Print directly in terminal (e.g. Jupyter)

# Accessing & Slicing
print("\n---- Accessing & Slicing ----")
print(place[0])      # 'I'
print(place[-1])     # 'a'
print(quote[1:7])    # 'elieve'
print(quote[::-1])    # 'flesruoY nI eveileB'

# Common Methods
print("\n---- String Methods ----")
print(place.upper())               # 'INDIA'
print(quote.lower())               # 'believe in yourself'
print("ai" in bio, "AI" in bio)     # False True
print(len(place))                  # 5

# Full demonstration string
s = "Hello, World!"

print("\nOriginal String:", s)
print(type(s))
print(len(s))

print("\n---- Case & Replace ----")
print(s.upper())
print(s.lower())
print(s.replace("World", "Python"))
print(s.title())
print(s.capitalize())
print(s.swapcase())

print("\n---- Splitting & Joining ----")
print(s.split(", "))        # ['Hello', 'World!']
print(s.splitlines())        # ['Hello, World!']
print(s.join(["Python", "is", "awesome"]))

print("\n---- Searching & Counting ----")
print(s.find("World"))      # 7
print(s.index("World"))     # 7
print(s.count("o"))         # 2
print(s.startswith("Hello"))
print(s.endswith("!"))

print("\n---- Boolean Checks ----")
print(s.isalpha())
print(s.isalnum())
print(s.isdigit())
print(s.islower())
print(s.isupper())

print("\n---- Trimming ----")
print(s.strip())
print(s.lstrip())
print(s.rstrip())

print("\n---- Alignment ----")
print(s.center(20, "-"))
print(s.ljust(20, "-"))
print(s.rjust(20, "-"))
print(s.zfill(20))

print("\n---- Prefix/Suffix ----")
print(s.removeprefix("Hello, "))
print(s.removesuffix(" World!"))

print("\n---- Advanced ----")
print(s.casefold())
print(s.translate(str.maketrans("Helo", "1234")))  # character mapping

print("\n---- Encoding ----")
encodings = ["utf-8", "ascii", "utf-16", "utf-32", "latin-1", "cp1252"]
errors = ["strict", "ignore", "replace", "backslashreplace", "xmlcharrefreplace"]

for encoding in encodings[:3]:
    for error in errors[:2]:
        try:
            print(f"{encoding}-{error}:", s.encode(encoding, error))
        except Exception as e:
            print(f"{encoding}-{error} failed:", e)


"""
| Method                  | Example                                    | Description                                      |
|------------------------ |--------------------------------------------|--------------------------------------------------|
| `capitalize()`          | `"hello".capitalize()`                     | Capitalizes first character                      |
| `casefold()`            | `"HELLO".casefold()`                       | Lowercase with aggressive Unicode support        |
| `center(width, fill)`   | `"hi".center(10, "*")`                     | Centers string in given width with fill character|
| `count(sub)`            | `"hello".count("l")`                       | Counts occurrences of substring                  |
| `encode()`              | `"hi".encode("utf-8")`                     | Converts string to bytes                         |
| `endswith(suffix)`      | `"file.txt".endswith(".txt")`              | Returns True if ends with suffix                 |
| `expandtabs(tabsize)`   | `"a\\tb".expandtabs(4)`                    | Replaces tabs with spaces                        |
| `find(sub)`             | `"hello".find("l")`                        | Returns first index or -1 if not found           |
| `format(...)`           | `"Hello {}".format("World")`               | String formatting using `{}`                     |
| `format_map(dict)`      | `"Hello {name}".format_map({'name': 'A'})` | Formatting using a dictionary                    |
| `index(sub)`            | `"hello".index("e")`                       | Returns index or raises ValueError               |
| `isalnum()`             | `"abc123".isalnum()`                       | Checks if all characters are alphanumeric        |
| `isalpha()`             | `"abc".isalpha()`                          | Checks if all characters are alphabetic          |
| `isascii()`             | `"abc".isascii()`                          | Checks if all characters are ASCII               |
| `isdecimal()`           | `"123".isdecimal()`                        | Checks if all characters are decimals            |
| `isdigit()`             | `"123".isdigit()`                          | Checks if all characters are digits              |
| `isidentifier()`        | `"var1".isidentifier()`                    | Checks if valid Python identifier                |
| `islower()`             | `"abc".islower()`                          | Checks if all letters are lowercase              |
| `isnumeric()`           | `"123".isnumeric()`                        | Checks if all characters are numeric             |
| `isprintable()`         | `"abc".isprintable()`                      | Checks if all characters are printable           |
| `isspace()`             | `"   ".isspace()`                          | Checks if only whitespace characters             |
| `istitle()`             | `"Hello World".istitle()`                  | Checks if string is titlecased                   |
| `isupper()`             | `"ABC".isupper()`                          | Checks if all letters are uppercase              |
| `join(iterable)`        | `" ".join(["A", "B"])`                     | Joins iterable with string separator             |
| `ljust(width, fill)`    | `"hi".ljust(5, "-")`                       | Left-justifies string and fills padding          |
| `lower()`               | `"HELLO".lower()`                          | Converts all characters to lowercase             |
| `lstrip()`              | `"  hi ".lstrip()`                         | Removes leading whitespace                       |
| `maketrans()`  +        | `s.translate(str.maketrans("ae", "12"))`   | Character mapping using translation table        |
       `translate()` 
| `partition(sep)`        | `"a:b".partition(":")`                     | Splits into (before, sep, after)                 |
| `removeprefix(prefix)`  | `"unhappy".removeprefix("un")`             | Removes prefix if it exists                      |
| `removesuffix(suffix)`  | `"temp.txt".removesuffix(".txt")`          | Removes suffix if it exists                      |
| `replace(old, new)`     | `"yes yes".replace("yes", "no")`           | Replaces all occurrences of substring            |
| `rfind(sub)`            | `"hello".rfind("l")`                       | Finds last occurrence of substring               |
| `rindex(sub)`           | `"hello".rindex("l")`                      | Finds last index or raises error                 |
| `rjust(width, fill)`    | `"hi".rjust(5, "-")`                       | Right-justifies with padding                     |
| `rpartition(sep)`       | `"a:b:c".rpartition(":")`                  | Splits at last occurrence into 3 parts           |
| `rsplit(sep, maxsplit)` | `"a,b,c".rsplit(",", 1)`                   | Splits from right side                           |
| `rstrip()`              | `" hi ".rstrip()`                          | Removes trailing whitespace                      |
| `split(sep)`            | `"a,b,c".split(",")`                       | Splits into a list                               |
| `splitlines()`          | `"a\\nb".splitlines()`                     | Splits string at line boundaries                 |
| `startswith(prefix)`    | `"file.py".startswith("file")`             | Checks if string starts with prefix              |
| `strip()`               | `"  hi  ".strip()`                         | Removes leading and trailing whitespace          |
| `swapcase()`            | `"Hi".swapcase()`                          | Swaps case of each character                     |
| `title()`               | `"hello world".title()`                    | Capitalizes first letter of each word            |
| `upper()`               | `"hi".upper()`                             | Converts string to uppercase                     |
| `zfill(width)`          | `"42".zfill(5)`                      | Pads string on the left with zeros to reach given width|
"""