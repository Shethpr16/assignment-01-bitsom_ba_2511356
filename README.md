# assignment-01-bitsom_ba_2511356
mkdir -p assignment-01-bitsom_ba_2511356/{datasets,part1-rdbms,part2-nosql,part3-datawarehouse,part4-vector-db,part5-datalake,part6-capstone} && \
cd assignment-01-bitsom_ba_2511356 && \
touch README.md && \
touch datasets/{orders_flat.csv,retail_transactions.csv,customers.csv,orders.json,products.parquet} && \
touch part1-rdbms/{schema_design.sql,queries.sql,normalization.md} && \
touch part2-nosql/{mongo_queries.js,sample_documents.json,rdbms_vs_nosql.md} && \
touch part3-datawarehouse/{star_schema.sql,dw_queries.sql,etl_notes.md} && \
touch part4-vector-db/{embeddings_demo.ipynb,vector_db_reflection.md} && \
touch part5-datalake/{duckdb_queries.sql,architecture_choice.md} && \
touch part6-capstone/{architecture_diagram.png,design_justification.md} && \
git init && \
git branch -M main && \
git remote add origin https://github.com/your-username/assignment-01-bitsom_ba_2511356.git && \
git add . && \
git commit -m "Initial assignment structure" && \
git push -u origin main
