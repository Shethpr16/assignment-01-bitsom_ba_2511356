## Architecture Recommendation

I recommend a **Data Lakehouse** for the food‑delivery startup.

**First**, the data is natively **multi‑modal**: GPS location logs (high‑volume time series), customer text reviews (unstructured NLP), payment transactions (structured, ACID‑sensitive), and restaurant menu images (binary blobs). A lakehouse on low‑cost object storage can hold all of these formats in one place, while table formats like **Delta/Iceberg/Hudi** provide transactional guarantees for analytical tables built on top. This gives the flexibility of a data lake with the reliability of a warehouse.

**Second**, the business will need both **BI and ML**. Executives and ops teams need dashboards (warehouse‑style star schemas), while data scientists need raw and curated layers for feature engineering (geospatial features from GPS, embeddings from reviews/images). A lakehouse supports **governed bronze/silver/gold layers**, so the same data powers batch BI, near‑real‑time ops metrics, and model training without copying data into multiple systems.

**Third**, a lakehouse offers **schema evolution + governance** at scale. As the product evolves (new payment providers, new review languages, new image metadata), schemas can change without brittle ETL breaks. With ACID tables, you can safely **upsert**, **delete** (for GDPR), and maintain slowly changing dimensions while keeping data quality rules and lineage in one platform.

In short: a **Data Warehouse** alone is too rigid for unstructured data; a pure **Data Lake** lacks ACID/semantic layers for trustworthy analytics. A **Lakehouse** combines both: low‑cost storage for all data types, strong governance/transactions for analytics, and a single platform for BI + ML.
