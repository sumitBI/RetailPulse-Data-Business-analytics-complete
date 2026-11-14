# RetailPulse — Retail Business Intelligence Dashboard

A hands-on retail analytics project built with **Power BI, PostgreSQL and CSV data**. The aim is to answer the sort of questions a sales or operations team would ask: what is selling, where profit is coming from, which customers matter most, and whether discounts or returns are hurting performance.

> **Data note:** This is a synthetic practice dataset. The customer names, stores and transactions are fictional.

## What is in the project?

- 7,200 sales-line records covering 2023–2025.
- Four lookup tables: date, product, customer and store.
- A star-schema model for Power BI.
- PostgreSQL table creation, import steps and ten business questions.
- DAX measures for sales, profit, order value, time comparisons, returns and rankings.
- A dark navy report theme and a build guide for the Power BI report.

## Folder guide

```text
Dataset/          Source CSV files
SQL/              PostgreSQL table setup and analysis queries
PowerBI/          DAX measures, report theme and build guide
Documentation/    Data notes, model notes, insights and QA checklist
Screenshots/      Add screenshots of your finished report here
```

## How I would build it

1. Load the five CSV files into Power BI.
2. Check the data types and create the four relationships shown in `Documentation/Data_Model.md`.
3. Add the measures from `PowerBI/DAX_Measures.dax`, one at a time.
4. Apply `PowerBI/Dark_Navy_Theme.json`.
5. Build the report pages by following `PowerBI/PBIX_Assembly_Guide.md`.
6. Run the SQL queries to compare the same business questions outside Power BI.
7. Test the filters, totals, bookmarks and drill-through before publishing screenshots.

## Report pages

| Page | Main purpose |
|---|---|
| Executive Overview | Overall revenue, profit, orders and monthly trend |
| Product & Discount Analysis | Product/category performance and discount impact |
| Regional & Customer Analysis | Store, region and customer segment performance |
| Product Detail | Drill-through view for an individual product |


--BUSINESS RECOMMENDATION --
◑ Focus on top churn drivers 
◑ Offers retention plans for  high risk customers
◑ Track Retention Monthly 

The ZIP contains the source data and build instructions, **not a finished `.pbix` file**. Open Power BI Desktop and save the report yourself as `PowerBI/RetailPulse.pbix` after completing the guide.

## Tools

- Power BI Desktop
- PostgreSQL
- Excel or another CSV viewer (optional)

