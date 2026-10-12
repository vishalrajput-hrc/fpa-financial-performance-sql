# FP&A Financial Performance & Variance Analysis (SQL)

## 📌 Project Overview
Analyzed Q1 financial performance across product categories to evaluate revenue contributions and Month-over-Month (MoM) growth trends using advanced SQL techniques.

## 🛠️ Tech Stack & Skills
- **Database:** MySQL
- **Key Concepts:** Window Functions (`SUM() OVER`), `PARTITION BY`, `LAG()`, Common Table Expressions (CTEs), Chronological Sorting (`CASE WHEN`).

## 📊 Key Business Questions Solved
1. **Category Contribution Analysis:** Calculated percentage share of each category within monthly totals using window functions.
2. **Month-over-Month (MoM) Trend:** Evaluated revenue shifts between January and February using `LAG()` to track growth and decline.
3. **Budget Variance Tracking:** Compared actuals against baseline targets to identify underperforming segments.

## 📈 Key Insights
- **Apparel:** Showed strong MoM expansion (+25.00%).
- **Footwear & Accessories:** Experienced slight month-over-month contractions (-8.70% and -8.82% respectively).