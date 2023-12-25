-- Finding Total Sales Revenue
SELECT
    YEAR(s.date) AS sale_year,
    MONTH(s.date) AS sale_month,
    SUM(s.quantity * p.productcost) AS total_monthly_revenue,
    (SELECT SUM(s2.quantity * p2.productcost)
     FROM sales s2
     INNER JOIN inventory i2 ON s2.productid = i2.productid
     INNER JOIN products p2 ON i2.productid = p2.productid
     WHERE YEAR(s2.date) = YEAR(s.date)
     GROUP BY YEAR(s2.date)) AS total_yearly_revenue
FROM
    sales s
INNER JOIN
    inventory i ON s.productid = i.productid
INNER JOIN
    products p ON i.productid = p.productid
WHERE
    YEAR(s.date) IN (2019, 2020)
GROUP BY
    YEAR(s.date),
    MONTH(s.date)
ORDER BY
    sale_year, sale_month;

-- Query returns top 5 stores and their inventory sell-through
WITH StoreRevenue AS (
    SELECT
        i.storeid,
        MAX(i.storename) AS store,
        YEAR(s.date) AS sale_year,
        SUM(s.quantity * p.productcost) AS yearly_revenue
    FROM
        sales s
    INNER JOIN
        inventory i ON s.productid = i.productid
    INNER JOIN
        products p ON s.productid = p.productid
    WHERE
        YEAR(s.date) = 2018
    GROUP BY
        i.storeid, YEAR(s.date)
),
StoreInventory AS (
    SELECT
        i.storeid,
        SUM(i.QuantityAvailable) AS total_inventory
    FROM
        inventory i
    GROUP BY
        i.storeid
)
SELECT TOP 5
    sr.storeid,
    sr.store,
    sr.yearly_revenue AS revenue,
    SUM(s.quantity) AS unit_sales,
    si.total_inventory AS inventory,
    (SUM(s.quantity) * 100.0) / NULLIF(si.total_inventory, 0) AS sell_through_percentage
FROM
    StoreRevenue sr
INNER JOIN
    sales s ON sr.storeid = s.storeid
INNER JOIN
    StoreInventory si ON sr.storeid = si.storeid
WHERE
    sr.sale_year = 2018
GROUP BY
    sr.storeid, sr.store, sr.yearly_revenue, si.total_inventory
ORDER BY
    revenue DESC;

-- Query seeks top 5 suppliers and their top 5 selling products.
WITH ProductProfit AS (
    SELECT
        p.supplier,
        p.productname,
        SUM(s.quantity * (p.productcost - s.unitprice)) AS product_profit
    FROM
        sales s
    INNER JOIN
        inventory i ON s.productid = i.productid
    INNER JOIN
        products p ON s.productid = p.productid
    WHERE
        YEAR(s.date) = 2019
    GROUP BY
        p.supplier, p.productname
),
RankedProducts AS (
    SELECT
        supplier,
        productname,
        product_profit,
        ROW_NUMBER() OVER (PARTITION BY supplier ORDER BY product_profit DESC) AS product_rank
    FROM
        ProductProfit
),
RankedSuppliers AS (
    SELECT
        supplier,
        SUM(product_profit) AS supplier_total_profit
    FROM
        RankedProducts
    GROUP BY
        supplier
),
TopSuppliers AS (
    SELECT
        supplier,
        supplier_total_profit,
        ROW_NUMBER() OVER (ORDER BY supplier_total_profit DESC) AS supplier_rank
    FROM
        RankedSuppliers
)
-- Finds the top 5 Suppliers and their top 5 Products
SELECT
    ts.supplier AS supplier,
    rp.productname,
    rp.product_profit
FROM
    TopSuppliers ts
INNER JOIN RankedProducts rp ON ts.supplier = rp.supplier
WHERE
    rp.product_rank <= 5
    AND ts.supplier_rank <= 5 
ORDER BY
    ts.supplier_rank, rp.product_rank;
