BRONZE_CONFIG = {
    "customer": {
        "src_file": "raw_customer.parquet",
        "dest_file": "bronze_customer.parquet",
    },
    "shipping_type": {
        "src_file": "raw_shipping_type.parquet",
        "dest_file": "bronze_shipping_type.parquet",
    },
    "product": {
        "src_file": "raw_product.parquet",
        "dest_file": "bronze_product.parquet",
    },
    "orders": {
        "src_file": "raw_orders.parquet",
        "dest_file": "bronze_orders.parquet",
    },
}
