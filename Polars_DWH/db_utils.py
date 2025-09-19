import os
import urllib

from sqlalchemy import create_engine
from dotenv import load_dotenv


load_dotenv()

def get_engine():
    driver = os.getenv("DB_DRIVER")
    server = os.getenv("DB_SERVER")
    database = os.getenv("DB_NAME")
    user = os.getenv("DB_USER")
    password = os.getenv("DB_PASSWORD")

    params = urllib.parse.quote_plus(
        f"DRIVER={{{driver}}};"
        f"SERVER={server};"
        f"DATABASE={database};"
        f"UID={user};"
        f"PWD={password};"
    )
    return create_engine(f"mssql+pyodbc:///?odbc_connect={params}")

# Expose a shared engine
engine = get_engine()
