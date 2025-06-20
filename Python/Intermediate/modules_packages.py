
print("""\n------------------------------------------------------------------------------
------------------------------------------------------------------------------
-------------------------------- Function Scope (LEGB Rule) ---------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------""")
x = "global scope variable"
def outer():
    x = "enclosing scope variable"
    def inner():
        x = "local scope variable"
        print("Inner:", x)
    inner()
    print("Enclosing:", x)
outer()
print("Global:", x)


print("\n----------------------------------- GLOBAL Keyword -------------------------------------------")
x = 10
print(x)  # 10
def change():
    # print(x) # ❌ SyntaxError: name 'x' is used prior to global declaration
    global x
    x = 20
    print(x) 
change()
print(x)  # 20


print("\n----------------------------------- NONLOCAL Keyword -------------------------------------------")
def outer():
    x = "outer"
    print(x)
    def inner():
        nonlocal x
        x = "changed in inner"
        print(x)
    inner()
    print(x)
outer()


print("""\n------------------------------------------------------------------------------
------------------------------------------------------------------------------
-------------------------------- MODULES ---------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------""")
import sys
print(sys.path)
import importlib

import math
importlib.reload(math)


print("""\n------------------------------------------------------------------------------
------------------------------------------------------------------------------
-------------------------------- Build Your Own Installable Python Package (Like PyPI Libraries) ---------------------------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------""")
# You'll create a Python project → turn it into a reusable, installable package → and can even upload it to PyPI later.

# STEP 1: Create Your Project Folder
'''
awesome_tools/
│
├── awesome_tools/         ← Your actual package folder
│   ├── __init__.py
│   └── math_utils.py
│
├── tests/                 ← (Optional) Unit tests
│   └── test_math_utils.py
│
├── README.md              ← Description (for GitHub & PyPI)
├── LICENSE                ← License info
├── setup.py               ← Important for packaging
├── pyproject.toml         ← Modern build info
└── MANIFEST.in            ← Extra files to include
'''

# STEP 2: Write Your Package Code
''' # awesome_tools/math_utils.py
def add(a, b):
    return a + b

def multiply(a, b):
    return a * b
'''

''' # awesome_tools/init.py
from .math_utils import add, multiply
'''

# STEP 3: Add setup.py
# This file tells Python how to install your package.
''' # setup.py
from setuptools import setup, find_packages

setup(
    name='awesome-tools',  # This is what gets used in pip install
    version='0.1.0',
    description='A simple math utilities package',
    long_description=open('README.md').read(),
    long_description_content_type='text/markdown',
    author='Your Name',
    author_email='your.email@example.com',
    packages=find_packages(),  # Automatically finds your package folders
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
    ],
    python_requires='>=3.6',
)
'''

# STEP 4: Add pyproject.toml (Modern packaging)

''' # pyproject.toml
[build-system]
requires = ["setuptools", "wheel"]
build-backend = "setuptools.build_meta"
'''

# STEP 5: Optional Files
# LICENSE
# Pick a license like MIT (you can copy-paste from choosealicense.com).

# MANIFEST.in
# To include files like README in the package:
'''
include README.md
include LICENSE
'''

# STEP 6: Build the Package Locally
''' # In terminal (from the outer awesome_tools/ directory):
pip install --upgrade build  # only once
python -m build
'''
"""
This creates:
- dist/awesome-tools-0.1.0.tar.gz
- dist/awesome-tools-0.1.0-py3-none-any.whl
"""



# STEP 7: Install It Locally
# To test it before publishing:
'''pip install dist/awesome_tools-0.1.0-py3-none-any.whl'''

# Then try in Python:
'''from awesome_tools import add
print(add(3, 4))  # Should output: 7'''



# STEP 8: Upload to PyPI (optional)
# 1. Create an account at https://pypi.org/account/register/

# 2. Install tools:
'''pip install twine'''

# 3. Upload:
'''twine upload dist/*'''

# You’ll be prompted to enter your PyPI username & password.
# Now your package is live! 

#  ➡️ ➡️ publish your first test package on Test PyPI (a safe playground) ➡️ ➡️