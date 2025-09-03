import polars as pl
import re

# --- 1. Title Case ---
def to_title_case(expr: pl.Expr) -> pl.Expr:
    """Capitalize first letter of each word."""
    # return expr.map_elements(
    #     lambda x: x.title() if isinstance(x, str) else x,
    #     return_dtype=pl.Utf8
    # )
    return expr.cast(pl.Utf8).str.to_titlecase()

# --- 2. Remove Special Characters ---
def remove_special_chars(expr: pl.Expr) -> pl.Expr:
    """Keep only letters, numbers, spaces, dash, underscore."""
    # return expr.map_elements(
    #     lambda x: re.sub(r"[^0-9A-Za-z _-]", "", x) if isinstance(x, str) else x,
    #     return_dtype=pl.Utf8
    # )
    return expr.cast(pl.Utf8).str.replace_all(r"[^0-9A-Za-z _-]", "")

# --- 3. Clean (trim + remove specials + title case) ---
def clean(expr: pl.Expr) -> pl.Expr:
    res = expr.cast(pl.Utf8) \
            .str.strip_chars() \
            .str.replace_all(r"[^0-9A-Za-z _-]", "") \
            .str.to_titlecase() \
            .str.strip_chars()
    return res

# --- 4. Translation (replace digits with letters) ---
def translate(expr: pl.Expr) -> pl.Expr:
    mapping = str.maketrans("34105", "eaios")
    return clean(expr).map_elements(
        lambda x: x.translate(mapping) if isinstance(x, str) else x,
        return_dtype=pl.Utf8
    )

# --- 5. Date → Int ---
def date_to_int(expr: pl.Expr, fmt: str = "%Y-%m-%d") -> pl.Expr:
    return expr.str.strptime(pl.Date, fmt, strict=False) \
               .dt.strftime("%d%m%Y") \
               .cast(pl.Int64)

# --- 6. Clean & Validate Email ---
# def clean_validate_email(expr: pl.Expr) -> pl.Expr:
#     def validate(email: str) -> str | None:
#         if not isinstance(email, str):
#             return None
#         email = re.sub(r"[^0-9A-Za-z_.@]", "", email).lower()
#         pattern = r"^[A-Za-z0-9._]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,3}$"  # only 2–3 chars
#         return email if re.match(pattern, email) else None

#     return expr.map_elements(validate, return_dtype=pl.Utf8)
def clean_validate_email(expr: pl.Expr) -> pl.Expr:
    """Clean and validate email - EXACTLY matching SQL function"""
    
    def clean_email_udf(email):
        if email is None:
            return None
            
        # Step 1: Character filtering (keep only allowed chars)
        result = ""
        for char in str(email):
            ascii_val = ord(char)
            if (48 <= ascii_val <= 57 or    # 0-9
                65 <= ascii_val <= 90 or    # A-Z  
                97 <= ascii_val <= 122 or   # a-z
                char in ('_', '.', '@')):
                result += char
        
        # Step 2: Convert to lowercase  
        result = result.lower()
        
        # Step 3: Domain extension fixes (add these BEFORE validation)
        result = re.sub(r'\.commm+$', '.com', result)  # Fix .commm, .commmm etc
        result = re.sub(r'\.com{2,}$', '.com', result)  # Fix .comm, .commm etc
        
        # Step 4: Validation checks (exactly matching SQL)
        
        # a. Must contain exactly one '@'
        if result.count('@') != 1:
            return None
        
        # b. Must not contain consecutive dots  
        if '..' in result:
            return None
            
        # c. Must not start or end with dot or @
        if result.startswith(('.', '@')) or result.endswith(('.', '@')):
            return None
            
        # d. Must contain at least one '.' after '@'
        at_pos = result.find('@')
        if at_pos == -1 or '.' not in result[at_pos:]:
            return None
            
        return result
    
    return expr.map_elements(clean_email_udf, return_dtype=pl.String)
