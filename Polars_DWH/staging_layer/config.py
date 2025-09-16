STAGING_CONFIG = {
    "customer": {
        "src_file": "bronze_customer.parquet",
        "dest_file": "staging_customer.parquet",
        "transform_fn": "load_customer_table",
    },
    "shipping_type": {
        "src_file": "bronze_shipping_type.parquet",
        "dest_file": "staging_shipping_type.parquet",
        "transform_fn": "load_shipping_type_table",
    },
    "product": {
        "src_file": "bronze_product.parquet",
        "dest_file": "staging_product.parquet",
        "transform_fn": "load_product_table",
    },
    "orders": {
        "src_file": "bronze_orders.parquet",
        "dest_file": "staging_orders.parquet",
        "transform_fn": "load_orders_table",
    },
}
