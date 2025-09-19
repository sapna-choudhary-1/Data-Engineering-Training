from datetime import datetime
import polars as pl

#### TRANSFORMATION FUNCTIONS ##
# - Provides transformations specific to the final tables

# ------------------ Transform Customer Table ------------------
def transform_customer(df: pl.DataFrame) -> pl.DataFrame:
    """
    Transform customer data by calculating derived attributes.

    Operations:
    - Calculate `calculated_customer_age` based on `customer_dob`.
    - Split `customer_name` into `first_name`, `middle_name`, and `last_name`.
    - Join the new columns back into the original DataFrame.
    """
    today = datetime.now().date()

    # Age calculation
    df_age = (
        df.filter(pl.col("customer_dob").is_not_null())
        .with_columns([
            (
                (pl.lit(today.year) - pl.col("customer_dob").dt.year()) -
                (
                    (pl.col("customer_dob").dt.month() > today.month) |
                    ((pl.col("customer_dob").dt.month() == today.month) &
                     (pl.col("customer_dob").dt.day() > today.day))
                ).cast(pl.Int32)
            ).alias("calculated_customer_age")
        ])
        .select(["customer_id", "calculated_customer_age"])
    )
    
    # Split names
    df_name_parts = (
        df.select(["customer_id", "customer_name"])
        .with_columns([
            pl.col("customer_name").str.strip_chars().str.split(" ").alias("name_parts")
        ])
        .with_columns([
            pl.col("name_parts").list.get(0, null_on_oob=True).fill_null("").alias("first_name"),
            pl.when(pl.col("name_parts").list.len() >= 3)
              .then(pl.col("name_parts").list.get(1, null_on_oob=True))
              .otherwise(None)
              .fill_null("").alias("middle_name"),
            pl.when(pl.col("name_parts").list.len() == 2)
              .then(pl.col("name_parts").list.get(1, null_on_oob=True))
              .when(pl.col("name_parts").list.len() >= 3)
              .then(pl.col("name_parts").list.get(-1, null_on_oob=True))
              .otherwise(None)
              .fill_null("").alias("last_name"),
        ])
        .select(["customer_id", "first_name", "middle_name", "last_name"])
    )
    
    return (
        df.join(df_age, on="customer_id", how="left")
          .join(df_name_parts, on="customer_id", how="left")
    )

# ------------------ Transform Product Table ------------------
def transform_product(df: pl.DataFrame) -> pl.DataFrame:
    """
    Transform product data by splitting the product name into clean attributes.

    Operations:
    - Extract `product_name` as the text before parentheses.
    - Extract `product_description` as the text inside parentheses.
    """
    return df.with_columns([
        pl.col("product_name").str.extract(r"^([^(]+)", 1).str.strip_chars().alias("product_name"),
        pl.col("product_name").str.extract(r"\(([^)]+)\)", 1).alias("product_description"),
    ])

# ------------------ Transform Sales Table ------------------
def transform_sales(df: pl.DataFrame) -> pl.DataFrame:
    """
    Transform sales data by adding derived financial and status-related attributes.

    Operations:
    - Compute `discount_amount` as (quantity × unit_price × discount_percent / 100).
    - Compute `total_amount` as (quantity × unit_price - discount_amount).
    - Flag `is_returned` as 1 if `order_status` is Returned/Refunded, else 0.
    """
    return df.with_columns([
        (pl.col("quantity") * pl.col("unit_price") * pl.col("discount_percent") / 100)
            .round(2).alias("discount_amount"),

        ((pl.col("quantity") * pl.col("unit_price")) -
         (pl.col("quantity") * pl.col("unit_price") * pl.col("discount_percent") / 100))
            .round(2).alias("total_amount"),

        # is_returned = 1 if status == Returned/Refunded else 0
        pl.when(pl.col("order_status").is_in(["Returned", "Refunded"]))
          .then(pl.lit(1)).otherwise(pl.lit(0))
          .cast(pl.Int8).alias("is_returned"),
    ])
