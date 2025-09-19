from datetime import date

import polars as pl

import transformations


TABLE_GROUPS = {
    "initial": {
        "customer": ["gender", "marital_status", "customer_type", "account_status", 
                     "region", "country", "state", "city", "postal_code", "location"],
        "product": ["brand_tier", "brand_name", "brand_country", "brand", 
                    "main_category", "sub_category"],
        "orders": ["payment_source", "lead_type", "order_status"],
        "shipping_type": ["delivery_estimate", "shipping_type"]
    },
    "final": ["customer", "product", "orders", "sales"]
}

TABLE_CONFIG = {
    "customer": {
        "staging_file": "staging_customer.parquet",
        "key_col": "customer_id",
        "joins": [
            ("gold_dim_gender.parquet", ["gender", "gender_skey"], "gender", "left"),
            ("gold_dim_marital_status.parquet", ["marital_status", "marital_status_skey"], "marital_status", "left"),
            ("gold_dim_customer_type.parquet", ["customer_type", "customer_type_skey"], "customer_type", "left"),
            ("gold_dim_account_status.parquet", ["account_status", "account_status_skey"], "account_status", "left"),
            ("gold_dim_postal_code.parquet", ["postal_code", "postal_code_skey"], "postal_code", "left"),
            ("gold_dim_location.parquet", ["postal_code_skey", "location_skey"], "postal_code_skey", "left"),
        ],
        "select_cols": [
            "customer_id",
            pl.col("signup_date").fill_null(pl.lit(date(1900,1,1))).alias("signup_date"),
            "gender_skey",
            pl.when(pl.col("customer_dob").is_not_null())
              .then(pl.col("customer_dob"))
              .otherwise(pl.lit(date(1900,1,1))).alias("customer_dob"),
            pl.when((pl.col("calculated_customer_age") >= 0) & (pl.col("calculated_customer_age") <= 120))
              .then(pl.col("calculated_customer_age"))
              .when(pl.col("calculated_customer_age") < 0).then(0)
              .when(pl.col("calculated_customer_age") > 120).then(120)
              .otherwise(None).alias("customer_age"),
            "first_name", "middle_name", "last_name",
            "marital_status_skey", "customer_type_skey", "account_status_skey", "location_skey",
            pl.col("email").fill_null("").alias("email"),
            pl.col("phone").cast(pl.Int64).alias("phone"),
        ],
        "transform_fn": "transform_customer",
    },

    "product": {
        "staging_file": "staging_product.parquet",
        "key_col": "product_id",
        "joins": [
            ("gold_dim_brand_name.parquet", ["brand_name", "brand_name_skey"], "brand_name", "left"),
            ("gold_dim_brand_tier.parquet", ["brand_tier", "brand_tier_skey"], "brand_tier", "left"),
            ("gold_dim_brand_country.parquet", ["brand_country", "brand_country_skey"], "brand_country", "left"),
            ("gold_dim_brand.parquet", ["brand_skey", "brand_name_skey", "brand_tier_skey", "brand_country_skey"], 
             ["brand_name_skey", "brand_tier_skey", "brand_country_skey"], "left"),
            ("gold_dim_sub_category.parquet", ["sub_category", "sub_category_skey"], "sub_category", "left"),
        ],
        "select_cols": ["product_id", "brand_skey", "product_name", "product_description",
                        "rating", "no_of_ratings", "sub_category_skey", "discount_percent", "actual_price"],
        "transform_fn": "transform_product",
    },

    "orders": {
        "staging_file": "staging_orders.parquet",
        "key_col": "orders_id",
        "joins": [
            ("gold_dim_customer.parquet", ["customer_id", "customer_skey"], "customer_id", "inner"),
            ("gold_dim_shipping_type.parquet", ["shipping_type", "shipping_type_skey"], "shipping_type", "left"),
            ("gold_dim_payment_source.parquet", ["payment_source", "payment_source_skey"], "payment_source", "left"),
            ("gold_dim_lead_type.parquet", ["lead_type", "lead_type_skey"], "lead_type", "left"),
        ],
        "select_cols": ["orders_id", "customer_skey", "shipping_type_skey",
                        "payment_source_skey", "lead_type_skey",
                        "has_coupon", "coupon_code", "is_gift", "gift_message"],
    },

    "sales": {
        "staging_file": "staging_orders.parquet",
        "key_col": "orders_id",
        "joins": [
            ("gold_dim_orders.parquet", ["orders_id", "orders_skey"], "orders_id", "inner"),
            ("gold_dim_product.parquet", ["product_id", "product_skey", "discount_percent", "actual_price"], "product_id", "inner"),
            ("gold_dim_order_status.parquet", ["order_status", "order_status_skey"], "order_status", "inner"),
        ],
        "select_cols": ["orders_id", "customer_id", "product_id", "orders_skey",
                        "product_skey", "order_status_skey", "quantity", "unit_price", "actual_price",
                        "discount_percent", "discount_amount", "order_date", "expected_delivery_date",
                        "shipping_date", "delivery_date", "return_date", "refund_date", "is_returned"],
        "transform_fn": "transform_sales",
    },
}

TABLE_PROPS = {
    "customer": {"is_scd2": True},
    "sales":    {"is_dim": False},
}


parent_map = {
    "country": ["region"],
    "state": ["country"],
    "city": ["state"],
    "postal_code": ["city"],
    "location": ["postal_code"],
    "shipping_type": ["delivery_estimate"],
    "sub_category": ["main_category"],
    "brand": ["brand_tier", "brand_name", "brand_country"],

    "customer": ["gender", "marital_status", "customer_type", "account_status", "location"],
    "product": ["brand", "sub_category"],
    "orders": ["customer", "shipping_type", "payment_source", "lead_type"],
    "sales": ["orders", "product", "order_status"],
}

extra_col_map = {
    "customer": ["signup_date", "customer_dob", "customer_age", "email", "phone"],
    "product": ["product_name", "product_description", 
                "rating", "no_of_ratings", 
                "discount_percent", "actual_price"],
    "orders": ["has_coupon", "coupon_code", "is_gift", 
              "gift_message"],
    "sales": ["quantity", "unit_price", "actual_price",
            "discount_percent", "discount_amount", 
            "order_date", "expected_delivery_date", "shipping_date", "delivery_date", 
            "return_date", "refund_date","is_returned"],
}

key_col_map = {
    'customer': "customer_id",
    'product': "product_id",
    'orders': "orders_id"
}

transform_fn_map = {
    "transform_customer": transformations.transform_customer,
    "transform_product": transformations.transform_product,
    "transform_sales": transformations.transform_sales,
}