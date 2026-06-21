from pathlib import Path
import duckdb

PROJECT_DIR = Path(__file__).resolve().parents[1] / "spiris"
DB_PATH = PROJECT_DIR / "spiris.duckdb"
EXPORT_DIR = PROJECT_DIR / "exports"

EXPORT_DIR.mkdir(exist_ok=True)


# write the name of each table you want exported
models = [
    "orders_enriched",
    "daily_sales",
    "category_sales",
    "customer_sales_summary",
    "data_quality_issues",
]

with duckdb.connect(str(DB_PATH)) as con:
    for model in models:
        output_path = EXPORT_DIR / f"{model}.csv"
        con.execute(f"""
            COPY (
                SELECT *
                FROM {model}
            )
            TO '{output_path.as_posix()}'
            WITH (HEADER, DELIMITER ',')
        """)
        print(f"Exported {model} to {output_path}")