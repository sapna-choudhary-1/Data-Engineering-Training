# Data Warehouse Layers using Polars

**Dummy Data:** 4 tables (customer, orders, product, shipping_type) from SQL-Server db

**config.py:** holds the information, about tables and their respective properties, for code-flexibility

---

## 🚀 Project Overview

The pipeline moves data across the following layers:

1. **Raw Layer (`raw_layer/`)**
   - Fetches raw dummy data directly from the source database.  
   - No transformations applied.  

2. **Bronze Layer (`bronze_layer/`)**
   - Ingests raw data as-is, but:
     - Converts all column values to **string** type.  
     - Adds a new column: `load_timestamp`.  

3. **Staging Layer (`staging_layer/`)**
   - Performs **data cleaning** (udfs.py) and **transformations** (transformations.py).  
   - Converts columns into correct data types (int, float, datetime, etc).  
   - Prepares data for business logic consumption.  

4. **Gold Layer (`gold_layer/`)**
   - Implements **Snowflake Schema** (fact and dimension tables).  
   - Applies **denormalisation** for reporting.  
   - Supports:
     - **Initial Load**: First-time full data ingestion.  
     - **Incremental Load**: Load only new/changed records.  

5. **Historical Layers**
   - After successful load to Gold:
     - Bronze tables are concatenated into **`bronze_hist_layer`**.
     - Staging tables are concatenated into **`staging_hist_layer`**.
     
     with `batch_id` designated at each new load
   - Helps preserve change history for auditing and rollback.  

---

## 📂 Project Structure

```
├── raw_layer/
├── bronze_layer/
├── staging_layer/
├── gold_layer/
├── load_hist_tables.ipynb
├── parquet_files/
├── .env 
└── README.md
```

---

## ▶️ Running the Pipeline

1. **Load Raw Data**
    : Run
   ```bash
   raw_layer/load_tables.ipynb
   ```

2. **Build Bronze Layer**
    : Run
   ```bash
   bronze_layer/load_tables.ipynb
   ```

3. **Build Staging Layer**
    : Run
   ```bash
   staging_layer/load_tables.ipynb
   ```

4. **Build Gold Layer**
    : Run
   ```bash
   gold_layer/load_tables.ipynb
   ```

5. **Update Historical Layers**
    : Run
   ```bash
   load_hist_tables.ipynb
   ```

---

## 📊 Example Flow

```text
raw_layer  →  bronze_layer  →  staging_layer  →  gold_layer
                                                      ↘︎
                           bronze_hist_layer + staging_hist_layer
```

---
