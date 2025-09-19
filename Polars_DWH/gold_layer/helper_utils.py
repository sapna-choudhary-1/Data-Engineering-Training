import os
import logging
from pathlib import Path
from typing import Optional

import polars as pl


logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


# ------------------ Utility: logging ------------------
def log_step(msg, df: Optional[pl.DataFrame] = None) -> None:
    """
    Utility for logging steps during execution.

    Operations:
    - Print the given message with a prefix.
    - If a DataFrame is provided, log its columns and schema.
    """
    logger.info(f"# --- {msg} ---")
    if df is not None:
        logger.info(f"Columns: {df.columns}")
        logger.info(f"Schema: {df.schema}")

# ------------------ Utility: get batch_id ------------------
def get_batch_id(df_tgt: Optional[pl.DataFrame]) -> int:
    """
    Utility for determining the next batch ID.

    Operations:
    - If target DataFrame is empty or None, return 1.
    - Otherwise, return max(batch_id) + 1.
    """
    if df_tgt is None or df_tgt.is_empty():
        return 1
    return int(df_tgt["batch_id"].max()) + 1

# ------------------ Utility: load parquet ------------------
_parquet_cache: dict[str, pl.DataFrame] = {}

def load_cached_parquet(
    parquet_dir: Path, 
    file_path: Path, 
    cols: Optional[list[str]] = None
) -> pl.DataFrame:
    """
    Utility for loading parquet files with caching.

    Operations:
    - Check if parquet file is already cached; if not, load it from disk.
    - If file is missing, log a message and set cache to None.
    - On each call, optionally return only the requested columns without altering cached data.
    """
    file_loc = Path(parquet_dir / file_path)

    if file_loc not in _parquet_cache or _parquet_cache[file_loc] is None:
        if os.path.exists(file_loc):
            _parquet_cache[file_loc] = pl.read_parquet(file_loc)
        else:
            logger.info(f"Parquet file not found: {file_loc}")
            _parquet_cache[file_loc] = None

    df = _parquet_cache[file_loc]

    # per-call selection (never alters cached copy)
    if df is not None and cols:
        return df.select(cols)
    return df
