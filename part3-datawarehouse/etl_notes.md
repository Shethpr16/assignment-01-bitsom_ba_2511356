## ETL Decisions

### Decision 1 — Normalize mixed date formats to ISO
**Problem:** The source file contains multiple date formats (e.g., `2023-02-05`, `12-12-2023`, `29/08/2023`). This prevents reliable parsing/grouping by month and breaks keys like `date_key`. [1](https://danaher-my.sharepoint.com/personal/pooja_sheth_sciex_com/_layouts/15/Doc.aspx?sourcedoc=%7B6F066E84-F184-4F99-BAA1-08372AAB145C%7D&file=retail_transactions.csv&action=default&mobileredirect=true)  
**Resolution:** During ETL, we parsed all recognized patterns and converted them to a single canonical format (`YYYY-MM-DD`). We also derived a surrogate `date_key` as `YYYYMMDD` for the `dim_date` table, and populated `year`, `month`, and `day`. This ensures consistent joins and time‑series analysis in the warehouse.

### Decision 2 — Standardize product category casing
**Problem:** Category values appear with inconsistent casing and labels (e.g., `electronics`, `Electronics`, `Groceries`). If loaded as‑is, aggregations by category would splinter across multiple spellings. [1](https://danaher-my.sharepoint.com/personal/pooja_sheth_sciex_com/_layouts/15/Doc.aspx?sourcedoc=%7B6F066E84-F184-4F99-BAA1-08372AAB145C%7D&file=retail_transactions.csv&action=default&mobileredirect=true)  
**Resolution:** We conformed categories to a controlled vocabulary in `dim_product`: **Electronics**, **Clothing**, **Grocery**. A simple mapping (lowercase‑trim → title case) was applied in the transform step before loading the dimension and the fact table. This guarantees that reporting by category is accurate and stable over time.

### Decision 3 — Exclude/repair transactions with blank store_city
**Problem:** Some rows have an empty `store_city` (while `store_name` is present). This breaks the uniqueness and completeness of the `dim_store` grain and can lead to null foreign keys. [1](https://danaher-my.sharepoint.com/personal/pooja_sheth_sciex_com/_layouts/15/Doc.aspx?sourcedoc=%7B6F066E84-F184-4F99-BAA1-08372AAB145C%7D&file=retail_transactions.csv&action=default&mobileredirect=true)  
**Resolution:** For the sample load, we **excluded** lines where `store_city` was blank to maintain referential integrity. In a production pipeline, we would (a) attempt to repair using a store master lookup; or (b) route such rows to a quarantine table for data stewardship. Only rows with valid `store_name` + `store_city` pairs were conformed into `dim_store` and referenced by `fact_sales`.
``
