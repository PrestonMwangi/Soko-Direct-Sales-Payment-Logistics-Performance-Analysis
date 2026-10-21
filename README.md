# Soko Direct: Sales, Payment & Logistics Performance Analysis

## 1. Executive Summary
Soko Direct's net revenue was flat between 2023 and 2024 (KES 98.9M to 99.4M, +0.4%), but the total hides a sharp split between regions. Rift Valley (+12.3%) and Nyanza (+10.7%) grew, while Western fell 45.8% and Eastern 16.8%. Delivery takes about 4 days in Nairobi and about 7 days in five other regions, and ratings are lower where delivery is slower. About 12.5% of orders are cancelled or returned, spread fairly evenly across regions and categories, with Card the clear outlier (16.2%). Electronics generates 74% of net revenue and M-Pesa carries 61% of it, so the business is concentrated in one category and one payment method.

## 2. Business Context and Objectives
Soko Direct is a three-year-old Kenyan e-commerce retailer selling Electronics, Fashion & Clothing, Beauty & Personal Care, Home & Living and Groceries across seven regions. Leadership has seen inconsistent regional growth and rising cancelled and returned orders, without a quantified view of why.

**Business questions**
1. What drives revenue and growth across region, category and payment method?
2. How does delivery performance relate to customer satisfaction?
3. Where do cancellations and returns occur, by region, category and payment method?

**Hypotheses tested:** (a) slower delivery outside Nairobi hurts satisfaction and repeat purchases, and (b) payment method relates to order outcome.

**Stakeholders:** Head of Operations (delivery), Head of Growth (regions and categories), Finance (revenue and discounts).

## 3. Data
| Item | Detail |
|---|---|
| Raw file | `kenya_ecommerce_sales_raw.csv`, 5,008 rows, 13 columns, never edited |
| Clean file | `kenya_ecommerce_sales_clean.csv`, 5,000 rows, 13 columns |
| Period | 2023 to 2024 |
| Grain | One row per order |
| Columns | order_id, order_date, customer_id, product_category, region, quantity, unit_price, discount, payment_method, delivery_days, customer_rating, revenue, order_status |

## 4. Tools
- Python (pandas, numpy, matplotlib) for cleaning, statistics and charts. 
- PostgreSQL for deeper analysis; growth by category and payment method, orders per region per year, repeat customers, and discount bands. .

## 5. Methodology

### 5.1 Data cleaning
Cleaning was done in code on a copy of the data. Every decision is recorded in the data quality log (`kenya_ecommerce_sales_data_quality_log.xlsx`).

| Area | Issue found | Action |
|---|---|---|
| Data types | order_date, unit_price and customer_rating stored as text | Converted to date and numeric types |
| order_date | 120 values unreadable after conversion | Sorted by order_id and filled from the order above. Dates were checked to rise with order ID. Filled dates are estimates |
| unit_price | 5 unreadable values and 2 prices of 0 | Recalculated as revenue ÷ (quantity × (1 − discount)) |
| customer_rating | 1,173 placeholder entries became blank on conversion, and X values fell outside the 1 to 5 scale | Left blank, not imputed |
| Text columns | Inconsistent spacing, capitals and variants | Standardised to 7 regions, 5 categories, 4 payment methods and 4 statuses |
| Duplicates | 8 order IDs appeared twice with slightly different details | Kept the first record: 5,008 to 5,000 rows |
| quantity | 5 negative values on Delivered or Pending orders with positive revenue | Converted to positive |
| discount | 3 values above 100% | Recalculated from revenue and price |
| revenue | Checked against quantity × price × (1 − discount) | 0 mismatches after the fixes |
| delivery_days | 625 blank (12.5%): 377 Cancelled, 164 Pending, 84 Delivered | Left blank. 541 were never delivered |

About 15 rows had a value recalculated or corrected.

<img width="1469" height="667" alt="image" src="https://github.com/user-attachments/assets/368c0b87-d176-4a6a-be4f-04743e06cf24" />


### 5.2 Feature engineering
`year`, `month` and `quarter` from order_date, and `is_cancelled_or_returned`, `is_cancelled` and `is_returned` from order_status. These exist only in the analysis notebook, not in the clean CSV.

### 5.3 Definitions
- **Net revenue:** revenue from all orders except Cancelled and Returned. Pending orders (3.3%) are included, since they have not failed.
- **Lost order:** Cancelled or Returned. Lost-order rates use all 5,000 orders.
- **Satisfaction:** average customer_rating over rated orders only.
- **Currency:** Kenyan shillings (KES).

## 6. Key Findings

### Headline numbers
| Metric | Value |
|---|---|
| Net revenue | KES 198.3M |
| Orders | 5,000 |
| Average net order value | KES 45,328 (median much lower, because a few large Electronics orders skew the average) |
| Average delivery time | 5.86 days |
| Average rating | 4.03, with 76.4% of orders rated |
| Lost-order rate | 12.5% (7.5% cancelled, 5.0% returned), about KES 29M of gross revenue |

### Q1: Revenue and growth
- **Flat total, uneven regions.** Four regions grew(Rift Valley, Nyanza, Central and Nairobi) and three declined(Coast, Eastern and Western). Gains (KES 5.5M) were almost cancelled out by declines (KES 5.1M).

| Region | 2023 (KES M) | 2024 (KES M) | Change |
|---|---|---|---|
| Rift Valley | 15.8 | 17.7 | +12.3% |
| Nyanza | 9.6 | 10.6 | +10.7% |
| Central | 12.4 | 13.2 | +6.4% |
| Nairobi | 33.8 | 35.5 | +5.2% |
| Coast | 12.6 | 12.3 | -1.9% |
| Eastern | 6.6 | 5.5 | -16.8% |
| Western | 8.1 | 4.4 | -45.8% |

- **Western accounts for about 73% of all regional revenue lost** (KES 3.7M of 5.1M).
- **Nairobi** is the largest region, with 35% of net revenue, and its share rose from 34.1% to 35.8%.
- **Electronics** is 27% of orders but 74% of net revenue (KES 147.1M). Groceries is 12% of orders and 1.6% of revenue.
- **M-Pesa** is 61% of orders and 61% of net revenue, followed by Cash on Delivery (16%), Card (13%) and Airtel Money (10%).
- Monthly revenue stays between KES 6M and 10M. 2024 is above 2023 in 6 of 12 months, and no repeating seasonal pattern is visible in two years.
- 
![Net Revenue by Region (2023 vs 2024)](https://github.com/PrestonMwangi/Soko-Direct-Sales-Payment-Logistics-Performance-Analysis/blob/main/images/Net%20Revenue%20by%20Region%20(2023%20vs%202024).png)
![Net revenue by Category](https://github.com/PrestonMwangi/Soko-Direct-Sales-Payment-Logistics-Performance-Analysis/blob/main/images/Product%20Category%20vs%20Revenue.png)

### Q2: Delivery and satisfaction
- Average delivery is **4.0 days in Nairobi**, 6.0 in Coast, and **6.9 to 7.1 days in the other five regions**.
- Average rating is highest in Nairobi (4.25) and Coast (4.05), and 3.84 to 3.91 elsewhere.
- Across 3,748 rated, delivered orders, the average rating falls steadily from 4.53 at 1 day to 3.45 at 10 days (correlation -0.3, a moderate negative relationship).
- This supports leadership's hypothesis as an **association**. Delivery time explains only part of the variation in ratings.
- Repeat purchases by region: 31.0% of Nairobi customers ordered more than once, against Rift Valley 15.8%, Coast 14.9%, Central 10.7%, Nyanza 10.0%, Eastern 6.5% and Western 5.8%. Nairobi, with the fastest delivery, has by far the highest repeat rate. Among the five regions with about 7-day delivery, repeat rates still range from 5.8% to 15.8%, so delivery time alone doesn't explain repeat buying. Customers are counted within each region, so regional customer counts overlap.

![Average Rating by Delivery Days](https://github.com/PrestonMwangi/Soko-Direct-Sales-Payment-Logistics-Performance-Analysis/blob/main/images/Average%20Rating%20by%20Delivery%20Days.png)
![Average Delivery Days by Region](https://github.com/PrestonMwangi/Soko-Direct-Sales-Payment-Logistics-Performance-Analysis/blob/main/images/Average%20Delivery%20Days%20by%20Region.png)

### Q3: Cancellations and returns
- Cancellations outnumber returns for every payment method (about 60% of lost orders).
- Lost-order rates range from 10.4% (Rift Valley) to 13.3% (Nairobi, Coast) by region, and from 11.8% (Home & Living) to 13.8% (Groceries) by category. These gaps are small.
- Repeat purchases by region: 31.0% of Nairobi customers ordered more than once, against Rift Valley 15.8%, Coast 14.9%, Central 10.7%, Nyanza 10.0%, Eastern 6.5% and Western 5.8%. Nairobi, with the fastest delivery, has by far the highest repeat rate. Among the five regions with about 7-day delivery, repeat rates still range from 5.8% to 15.8%, so delivery time alone doesn't explain repeat buying. Customers are counted within each region, so regional customer counts overlap.
- **Payment method shows the clearest difference:** Card 16.2% (117 of 724 orders), Airtel Money 13.0%, M-Pesa 11.9%, Cash on Delivery 11.1%. Card is higher on both cancellations (9.9%) and returns (6.2%). 
- Western and Eastern have mid-range lost-order rates overall, so lost orders alone don't look like the explanation for their declines. Rates were not checked year by year.

![Cancelled and Returned Share by Payment Method](https://github.com/PrestonMwangi/Soko-Direct-Sales-Payment-Logistics-Performance-Analysis/blob/main/images/Cancelled%20%26%20Returned%20Orders%20by%20Payment%20Method.png)

### SQL findings
- Net revenue growth came from Home & Living (+15.7%) and from Card (+11.2%), while Electronics, Fashion, Cash on Delivery and Airtel Money declined.
- Western's fall comes from fewer declining orders (184 > 133). Eastern's comes from smaller orders only (135 > 139).
- Nairobi's repeat-customer rate (31.0%) is about twice that of the next region (Rift Valley, 15.8%) and five to six times that of Western and Eastern.
- **Discounts:** only 16 of 5,000 orders (0.3%) had no discount, so discounted vs. full-price orders can't be compared. Among discounted orders, average basket size is similar across bands (3.86 to 4.04 units), so deeper discounts are not associated with larger orders. Orders with discounts over 20% have a slightly lower lost-order rate (about 10% vs. 12%) on a small group (233 orders).

## 7. Recommendations for 2025

| # | Action | Owner | Evidence | Success measure |
|---|---|---|---|---|
| 1 | **Pilot faster delivery in Rift Valley and Central**, the other regions(Apart from Nairobi) by orders and the slowest | Operations | About 7 days vs. 4 in Nairobi, and ratings fall as delivery days rise | Delivery time, rating and lost-order rate in pilot vs. comparable regions | Nairobi also has the highest repeat rate (31.0% vs. 5.8% to 15.8% for other regions.
| 2 | **Review the Card payment flow** (checkout failures, authorisation, returns) | Operations, Finance | Card loses 16.2% of orders vs. 11.1% to 13.0% for other methods | Card revenue also grew 11.2%, so the problem is growing with it |
| 3 | **Focus regional marketing on Rift Valley and Nyanza**,| Growth | Western’s orders fell 27.7% and its average order fell 25.0%, and Eastern’s average order fell 19.2% | Revenue and order count by region
| 4 | **Reduce reliance on Electronics** by growing Home & Living, the next-highest average order value | Growth, Finance | Electronics is 74% of net revenue; Share of revenue from other categories | Electronics revenue  also fell 1.7% in 2024 while Home & Living grew 15.7% |


## 8. Next Steps (investigate before acting)
1. **Diagnose Western:** SQL shows both fewer orders (-27.7%) and smaller orders (-25.0%), and Western has the lowest repeat rate (5.8%). Check category mix and large-order losses next.
2. **Strengthen the delivery finding:** test whether ratings still fall with delivery days within the other regions only(apart from Nairobi), so Nairobi's own characteristics don't drive the result.
3. **Capture cancellation reasons** at checkout, and encourage ratings (24% are missing).
4. **Record delivery times** for all delivered orders (84 are missing).
5. **Review discount policy** Discounts over 20% are not associated with larger orders (3.86 vs. 4.02 to 4.04 units). Test against margin data, which this dataset lacks.
6. **Test repeat purchases by region** Nairobi has the highest repeat_pct at 31% which is explained by its larger share of customers. Eastern and Western are trailing with ~6% repeat customers.

## 9. Limitations and Assumptions

**Data limitations (what the data can't tell us)**
- Revenue only, with no cost or margin, so discount effectiveness can't be judged on profit.
- No cancellation or return reasons.
- Only 76.4% of orders are rated, and delivery times exist only for delivered orders.
- Two years of data, is a single year-on-year comparison so seasonality can't be judged.
- Repeat rates count customers within each region over two years, so customers appearing in more than one region are counted in each. Nairobi's larger market may also help its repeat rate.
- Almost every order carries a discount, so discount effectiveness can only be compared across bands.

**Assumptions (choices that could change the numbers)**
- Net revenue includes Pending orders.
- Recalculated prices, discounts and quantities assume revenue was correct.
- 120 order dates are estimated from neighbouring order IDs, so month-level trends carry small uncertainty (2.4% of rows).
- Repeated order IDs were treated as errors, keeping the first record.
- Ratings outside 1 to 5 were treated as invalid.

**Analytical caveats (how to read the results)**
- Results show association, not cause. Nairobi differs from other regions in ways beyond delivery speed.
- Small groups Card(payment_method), Western & Eastern(region), Groceries(product_category) give less stable rates.
- Lost-order rates combine both years.
- Revenue averages are skewed by a few large Electronics orders, so the median is the better "typical order" figure.

## 10. Project Structure
```
Soko Ecommerce Analysis/
├── kenya_ecommerce_sales_raw.csv                    (original)
├── kenya_ecommerce_sales_clean.csv                  (cleaned, 5,000 rows)
├── soko_ecommerce_analysis.ipynb
├── kenya_ecommerce_sales_data_quality_log.xlsx
├── Soko_analysis.sql                                
└── [In Progress].pbix                            
```

## 11. How to Reproduce
1. Run the notebook from top to bottom (Restart, then Run All). It reads the raw file and writes the clean file.
2. Create the `orders` table in PostgreSQL, load the clean CSV, and run `soko_analysis.sql`.

## 13. Author
**[Preston Mwangi]**

Data Analytics | Python | SQL | Business Intelligence | 
