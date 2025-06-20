try:
    x = 5
    # x = int(input("Enter a number: "))
    y = 10 / x #  ➡️ ZeroDivisionError: division by zero
    # file = open("example.txt", "r")
    # file = open(input("Enter file name: "), "r")
except ValueError:
    print("Not a number!")
except ZeroDivisionError as e:
    print("Exception:", e)  # prints the exception message
except FileNotFoundError:
    print("File not found.")
else:
    print("Everything went fine!")
finally:
    print("This runs no matter what.")



print("\n----------------------------------- CUSTOM EXCEPTION -------------------------------------------")
class AgeTooSmallError(Exception):
    def __init__(self, age, message="Age is too small. Must be at least 18."):
        self.age = age
        self.message = message
        super().__init__(self.message)

    def __str__(self):
        return f"{self.message} (Provided: {self.age})"

try:
    age = 16
    if age < 18:
        raise AgeTooSmallError(age)
except AgeTooSmallError as e:
    print(e)



print("\n----------------------------------- LOGGING -------------------------------------------")
import logging

# This will create an app.log file with:
logging.basicConfig(
    filename="Python/Intermediate/app.log",
    filemode="a",  # append mode
    format="%(asctime)s - %(levelname)s - %(message)s",
    level=logging.DEBUG
)
# logging.debug("This is an debug message.") # To see all levels
# logging.info("This is an info message.") # Allows info, warning, error, Critical
# logging.warning("This is an warning message.") # Allows warning, error, Critical
# logging.error("This is an error message.") # Allows error, Critical
# logging.critical("This is an critical message.") # Allows only Critical
# logging.exception("This is an critical message.") # NoneType: None

'''
| Level    | Description                         |
| -------- | ----------------------------------- |
| DEBUG    | Detailed info for debugging         |
| INFO     | General information                 |
| WARNING  | Something unexpected, but not error |
| ERROR    | A serious problem occurred          |
| CRITICAL | Critical error — program may crash  |
'''

print("\n-----------------------------------  -------------------------------------------")
try:
    1 / 0
except ZeroDivisionError:
    logging.exception("Something went wrong!")


print("\n-----------------------------------  -------------------------------------------")
logger = logging.getLogger("custom_logger")
logger.setLevel(logging.WARNING)

handler = logging.StreamHandler()
formatter = logging.Formatter("%(levelname)s: %(message)s")
handler.setFormatter(formatter)

logger.addHandler(handler)

logger.info("This won't show")
logger.warning("This will show")
logger.error("This will also show")

print("\n------------------------------------------------------------------------------")
print("---- Q1: Catch any unexpected error and log it as CRITICAL ----")
print("------------------------------------------------------------------------------")
import logging

logging.basicConfig(level=logging.CRITICAL)

try:
    1 / 0
except Exception as e:
    logging.critical(f"Something went wrong!: {e}")

print("\n------------------------------------------------------------------------------")
print("---- Q2: Log a custom exception when a user enters a negative number ----")
print("------------------------------------------------------------------------------")
import logging

# Clear existing handlers
for handler in logging.root.handlers[:]:
    logging.root.removeHandler(handler)

# ❗❗Now you can safely reconfigure; else this second basicConfig() call is ignored❗❗
logging.basicConfig(
    filename="Python/Intermediate/errors.log",
    level=logging.WARNING,
    format="%(asctime)s - %(levelname)s - %(message)s"
)

class NegativeNumberError(Exception):
    pass

def check_number(n):
    if n < 0:
        raise NegativeNumberError("Number is negative.")

try:
    check_number(-3)
except NegativeNumberError as e:
    logging.warning(f"Caught an error: {e}")

