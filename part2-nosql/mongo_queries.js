/**********************
 * OP1: insertMany()
 * Insert all 3 documents from sample_documents.json
 * (Run this once. If you already imported them, you can skip.)
 **********************/
db.products.insertMany([
  {
    _id: "ELEC-SMARTPHONE-001",
    category: "Electronics",
    name: "Smartphone X Pro",
    brand: "TechOne",
    price: 29999,
    currency: "INR",
    specs: {
      warranty_years: 2,
      voltage: "100-240V",
      battery: { capacity_mAh: 4500, fast_charge_watts: 65 },
      display: { size_inches: 6.5, panel: "AMOLED", refresh_rate_hz: 120, resolution: "2400x1080" },
      storage: [{ ram_gb: 8, rom_gb: 128 }, { ram_gb: 12, rom_gb: 256 }],
      connectivity: ["5G", "Wi‑Fi 6", "Bluetooth 5.3", "Dual SIM"]
    },
    colors: [{ name: "Midnight Black", hex: "#0B0B0B" }, { name: "Aurora Blue", hex: "#3A7BD5" }],
    images: [
      "https://cdn.example.com/products/smartphone-x-pro/front.png",
      "https://cdn.example.com/products/smartphone-x-pro/back.png"
    ],
    available: true,
    ratings: { average: 4.5, count: 1283 },
    created_at: ISODate("2026-03-01T10:00:00Z")
  },
  {
    _id: "CLOTH-JEANS-001",
    category: "Clothing",
    name: "Men's Slim Denim Jeans",
    brand: "UrbanWear",
    price: 1999,
    currency: "INR",
    attributes: { gender: "Male", fit: "Slim", material: "Denim", wash: "Mid‑blue", stretch: true },
    sizes: [
      { size: "30", waist_in: 30, length_in: 32, stock: 25 },
      { size: "32", waist_in: 32, length_in: 32, stock: 18 },
      { size: "34", waist_in: 34, length_in: 34, stock: 10 }
    ],
    care: {
      instructions: ["Machine wash cold", "Do not bleach", "Warm iron if needed"],
      wash_symbol_codes: ["P", "30°C", "DoNotBleach"]
    },
    variants: [{ color: "Indigo", sku: "UW-JEANS-INDIGO-001" }, { color: "Black", sku: "UW-JEANS-BLACK-001" }],
    available: true,
    ratings: { average: 4.2, count: 642 },
    created_at: ISODate("2026-02-24T09:30:00Z")
  },
  {
    _id: "GROC-ATTA-5KG-001",
    category: "Groceries",
    name: "Organic Whole Wheat Atta 5kg",
    brand: "HealthyFarm",
    price: 499,
    currency: "INR",
    nutrition: {
      serving_size_g: 100,
      calories: 340,
      macros: { protein_g: 12, carbs_g: 72, fat_g: 2 },
      fiber_g: 11,
      sodium_mg: 5
    },
    certifications: ["FSSAI", "USDA Organic"],
    origin: { country: "India", state: "Punjab", farm_cluster: "Ludhiana‑North" },
    batches: [
      {
        batch_no: "HF-A5-2602",
        mfg_date: ISODate("2025-12-15T00:00:00Z"),
        expiry_date: ISODate("2026-12-14T00:00:00Z"),
        mrp: 525,
        barcode_ean13: "8901234567890",
        stock_kg: 250
      }
    ],
    allergens: ["Gluten"],
    storage: { instructions: ["Store in a cool, dry place", "Keep airtight after opening"] },
    available: false,
    created_at: ISODate("2026-03-05T06:45:00Z")
  }
]);

/**********************
 * OP2: find()
 * Retrieve all Electronics products with price > 20000
 **********************/
db.products.find(
  { category: "Electronics", price: { $gt: 20000 } },
  { _id: 0, name: 1, brand: 1, price: 1, category: 1 }
);

/**********************
 * OP3: find()
 * Retrieve all Groceries expiring before 2025-01-01
 * NOTE: This works if you store expiry_date as a BSON Date (ISODate).
 **********************/
db.products.find(
  {
    category: "Groceries",
    "batches.expiry_date": { $lt: ISODate("2025-01-01T00:00:00Z") }
  },
  { _id: 0, name: 1, "batches.$": 1 }
);

// If you had stored expiry_date as a string, use $expr + $toDate (MongoDB 4.0+):
// db.products.find({
//   category: "Groceries",
//   $expr: { $lt: [ { $toDate: { $first: "$batches.expiry_date" } }, ISODate("2025-01-01T00:00:00Z") ] }
// });

/**********************
 * OP4: updateOne()
 * Add a "discount_percent" field to a specific product
 **********************/
db.products.updateOne(
  { _id: "ELEC-SMARTPHONE-001" },   // target product
  { $set: { discount_percent: 10 } } // add or update discount_percent
);

/**********************
 * OP5: createIndex()
 * Create an index on category and explain why
 **********************/
// This index speeds up category filters (e.g., catalog pages like /electronics)
// and common aggregations grouped by category; it reduces collection scans.
db.products.createIndex({ category: 1 });
