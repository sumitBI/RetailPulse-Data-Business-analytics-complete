# Build the Power BI report

This guide takes the CSV files to a working report. Follow it in order and save your work as you go.

## 1. Load the data

In Power BI Desktop, choose **Home → Get data → Text/CSV** and load the five files from `Dataset`.

In Power Query, rename the queries to:

- `FactSales`
- `DimDate`
- `DimProduct`
- `DimCustomer`
- `DimStore`

Check the types before selecting **Close & Apply**:

- Date fields: Date
- DateKey, Units, ShippingDays and flags: Whole Number
- Price, sales, discount amount, cost and profit: Decimal Number
- Keys and category/name fields: Text
- IsWeekend: True/False

## 2. Create the relationships

Open Model view and create these active relationships. Keep the filter direction single, from the dimension table to the sales table.

- `DimDate[DateKey]` → `FactSales[DateKey]`
- `DimProduct[ProductKey]` → `FactSales[ProductKey]`
- `DimCustomer[CustomerKey]` → `FactSales[CustomerKey]`
- `DimStore[StoreKey]` → `FactSales[StoreKey]`

Each dimension key should be on the **1** side and `FactSales` should be on the **many** side. Do not connect the dimensions to each other. Mark `DimDate` as the date table using `DimDate[Date]`.

## 3. Tidy the fields

Sort `DimDate[MonthName]` by `DimDate[MonthNumber]`. Use `YearMonth` for monthly chart axes. Hide technical key fields from Report view so the field list is easier to use.

Set revenue, profit, cost and discount amounts to currency (INR). Set margin, discount rate, YoY and MoM measures to Percentage.

## 4. Add the measures

Create a blank table named `_Measures` using **Home → Enter data**. Hide its dummy column. Open `DAX_Measures.dax` and create each measure separately with **Modeling → New measure**. If Power BI shows an error, check the table and column names first; they must match the model above.

## 5. Apply the theme

Go to **View → Themes → Browse for themes** and select `Dark_Navy_Theme.json`. Set the report page to 16:9. Use a consistent layout, align visuals, and leave enough space around KPI cards.

## 6. Page 1 — Executive Overview

Start with the big picture:

- KPI cards: Total Revenue, Total Profit, Profit Margin %, Total Orders, Average Order Value and Revenue YoY %.
- Line chart: `DimDate[YearMonth]` with Total Revenue.
- Bar chart: `DimProduct[Category]` with Total Revenue.
- Donut chart: `DimCustomer[Segment]` with Total Revenue.
- Slicers: Date, Store Region and Customer Segment.

Add a small note on the page: **Synthetic sample data | 2023–2025**.

## 7. Page 2 — Product & Discount Analysis

Add a Top 10 product bar chart using Product Sales Rank as a visual filter (less than or equal to 10). Add a category treemap, a product revenue/profit scatter chart, a discount-rate chart and a product table with revenue, profit, margin and units sold.

Useful slicers: Year, Category and Product Tier.

## 8. Page 3 — Regional & Customer Analysis

Show revenue by Region, profit by Store, customer count by Segment, and a Region → City matrix with revenue, profit, margin and orders. Add a Top 10 customer chart. Use Date, Region, Segment and Store slicers where they help answer the questions.

## 9. Page 4 — Product Detail drill-through

Create a page called `Product Detail`. Add `DimProduct[ProductName]` to the Drill-through filters. Add cards for revenue, profit, units sold and margin, plus a monthly trend and a detail table with OrderID, Units, NetSales and Profit. Add a Back button. From a product visual, right-click a product and choose **Drill through → Product Detail**.

## 10. Bookmarks and navigation

On the Executive Overview page, create three bookmarks: `Overview`, `Revenue Focus` and `Profit Focus`. Use the Selection pane to show the right visual groups for each view. In the Bookmarks pane, add or update each bookmark.

If bookmarks should only change which visuals are visible, turn **Data** off in the bookmark options so slicer selections are not reset. Add buttons and set Action to the matching bookmark. A Page navigator button can handle page navigation. In edit mode, use Ctrl+click to test buttons.

## 11. Sync slicers and tooltips

Use **View → Sync slicers** to share Date, Region and Segment filters across pages where it makes sense.

Optional: create a `Product Tooltip` page, turn Tooltip on in Page information, set the page size to Tooltip, and add product name, revenue, profit and margin. Assign it under the visual's Format → General → Tooltips settings.

## 12. Check and save

Work through `Documentation/QA_Checklist.md`. Save the finished report as `PowerBI/RetailPulse.pbix`. The PBIX is created in Power BI Desktop; it is not included in this source ZIP.

## 13. Put it on GitHub

Upload the extracted `RetailPulse` project folder, not a ZIP file inside another folder. Add report screenshots to `Screenshots/`. If your PBIX is too large for a normal GitHub upload, use Git LFS or attach it to a GitHub Release.
