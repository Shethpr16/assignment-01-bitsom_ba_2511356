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
