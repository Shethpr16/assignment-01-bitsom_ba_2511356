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

While keeping all information in a single table such as `orders_flat.csv` may appear simpler at first, the dataset clearly shows that this approach creates serious data quality and maintenance problems rather than reducing complexity.

One major issue is **update anomalies** caused by repeated data. For example, the sales representative **Deepak Joshi (SR01)** appears in many orders, but his office address is stored with inconsistent spellings such as “Mumbai HQ, Nariman Point, Mumbai - 400021” and “Mumbai HQ, Nariman Pt, Mumbai - 400021.” Because the same information is duplicated across multiple rows, correcting or updating the address requires changing many records, increasing the risk of inconsistencies.

The dataset also demonstrates **insert anomalies**. Product details like `product_name`, `category`, and `unit_price` exist only within order rows. As a result, a new product cannot be added to the system unless an order is created for it. For instance, the product **Webcam (P008)** appears only because it is associated with order **ORD1185**. This prevents the business from maintaining a clean product catalog independent of sales activity.

Additionally, **delete anomalies** pose a serious risk. If an order is deleted—such as cancelling **ORD1185**—the only record of product **P008 (Webcam)** would be lost entirely. This unintended data loss makes the system unreliable.

Normalizing the data into separate tables for customers, products, sales representatives, orders, and order items resolves these issues. Each fact is stored once and referenced through keys, improving data integrity, flexibility, and scalability. In this context, normalization is not over‑engineering; it is essential for accurate, maintainable, and trustworthy data management.
