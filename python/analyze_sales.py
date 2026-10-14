
from pathlib import Path
import pandas as pd

# Locate the dataset relative to this script
PROJECT_ROOT = Path(__file__).resolve().parent.parent
DATA_FILE = PROJECT_ROOT / "data" / "raw" / "Sample - Superstore.csv"
OUTPUT_DIR = PROJECT_ROOT / "data" / "processed"
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

# Load the dataset
df = pd.read_csv(DATA_FILE, encoding="latin1")

# Standardize column names
df.columns = (
    df.columns.str.strip()
    .str.replace(" ", "_", regex=False)
    .str.replace("-", "_", regex=False)
)

# Convert dates and numeric fields
for column in ["Order_Date", "Ship_Date"]:
    if column in df.columns:
        df[column] = pd.to_datetime(df[column], errors="coerce")

for column in ["Sales", "Profit", "Discount", "Quantity"]:
    if column in df.columns:
        df[column] = pd.to_numeric(df[column], errors="coerce")

# Basic data-quality report
report = pd.DataFrame({
    "metric": [
        "row_count",
        "column_count",
        "duplicate_rows",
        "missing_cells",
        "negative_profit_rows",
        "zero_discount_rows",
    ],
    "value": [
        len(df),
        len(df.columns),
        int(df.duplicated().sum()),
        int(df.isna().sum().sum()),
        int((df["Profit"] < 0).sum()) if "Profit" in df.columns else 0,
        int((df["Discount"] == 0).sum()) if "Discount" in df.columns else 0,
    ],
})

report.to_csv(OUTPUT_DIR / "data_quality_report.csv", index=False)

# Summarize performance by category
if {"Category", "Sales", "Profit", "Discount"}.issubset(df.columns):
    category_summary = (
        df.groupby("Category", dropna=False)
        .agg(
            total_sales=("Sales", "sum"),
            total_profit=("Profit", "sum"),
            average_discount=("Discount", "mean"),
            order_lines=("Sales", "size"),
        )
        .reset_index()
    )

    category_summary["profit_margin_pct"] = (
        category_summary["total_profit"]
        / category_summary["total_sales"].replace(0, pd.NA)
        * 100
    )

    category_summary.to_csv(
        OUTPUT_DIR / "category_profitability.csv", index=False
    )

print("Analysis complete.")
print(report.to_string(index=False))
print(f"\nProcessed files saved to: {OUTPUT_DIR}")
