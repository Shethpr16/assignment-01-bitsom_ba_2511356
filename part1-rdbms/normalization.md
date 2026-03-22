## Anomaly Analysis

### Insert Anomaly
- **Description:** It is not possible to insert a new product into the system unless an order exists for that product.
- **Explanation:** Product details such as `product_id`, `product_name`, `category`, and `unit_price` only appear as part of order records.
- **Example:** Product **P008 (Webcam)** appears only in order **ORD1185**. If the company wants to add Webcam to the catalog before selling it, there is no place to store it without creating a fake order.
- **Columns involved:** product_id, product_name, category, unit_price, order_id

---

### Update Anomaly
- **Description:** Updating a single real‑world fact requires updating multiple rows, which can lead to inconsistencies.
- **Explanation:** Sales representative office addresses are duplicated across many orders.
- **Example:** Sales rep **SR01 (Deepak Joshi)** has office address written as:
  - “Mumbai HQ, Nariman Point, Mumbai - 400021”
  - “Mumbai HQ, Nariman Pt, Mumbai - 400021”
  These represent the same office but are stored inconsistently across orders such as **ORD1180, ORD1170, ORD1183**.
- **Columns involved:** sales_rep_id, sales_rep_name, office_address

---

### Delete Anomaly
- **Description:** Deleting an order can remove important information about customers or products.
- **Explanation:** If a product or customer appears in only one order, deleting that order removes all information about them.
- **Example:** If order **ORD1185** is deleted, product **P008 (Webcam)** is completely lost from the dataset.
- **Columns involved:** order_id, product_id, product_name



## Normalization Justification

At first glance, storing all information in a single table such as orders_flat.csv appears simpler. However, this design introduces significant data quality and maintenance problems.

The dataset clearly demonstrates update anomalies. Sales representative office addresses and customer details are repeated across multiple rows. For example, the office address of Deepak Joshi appears with different spellings in different orders. If the office address changes, every related row must be updated, increasing the risk of inconsistency.

Insert anomalies also exist. Product information such as product name, category, and price is only available when an order is placed. This makes it impossible to add new products to the system unless a dummy order is created, which is not a valid business process.

Delete anomalies are equally problematic. If an order is removed, important information about customers or products may be lost entirely. For instance, deleting the only order containing a specific product would erase all records of that product.

Normalizing the data to Third Normal Form resolves these issues by separating customers, products, sales representatives, and orders into independent tables. Each fact is stored once and referenced using foreign keys. This approach improves data integrity, supports safe updates and deletions, and allows the business to scale operations without introducing inconsistencies.

Therefore, normalization is not over‑engineering in this case; it is essential for maintaining accurate, reliable, and scalable data systems.
