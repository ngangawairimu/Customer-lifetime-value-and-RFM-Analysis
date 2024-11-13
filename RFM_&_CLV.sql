-- RFM_&_Customer_Segments Query

-- Step 1: Calculate RFM scores and quartiles for each customer
WITH rfm_quartiles AS ( 
    SELECT 
        CustomerID,
        -- Calculate 'recency' as days since last purchase
        TIMESTAMP_DIFF(TIMESTAMP('2011-12-01'), MAX(InvoiceDate), DAY) AS recency,
        -- Calculate 'frequency' as the count of unique invoices
        COUNT(DISTINCT InvoiceNo) AS frequency,
        -- Calculate 'monetary' as total spend (quantity * unit price)
        SUM(Quantity * UnitPrice) AS monetary,
        -- Assign quartiles for Recency, Frequency, and Monetary values
        NTILE(4) OVER (ORDER BY TIMESTAMP_DIFF(TIMESTAMP('2011-12-01'), MAX(InvoiceDate), DAY)) AS R_score,
        NTILE(4) OVER (ORDER BY COUNT(DISTINCT InvoiceNo) DESC) AS F_score,
        NTILE(4) OVER (ORDER BY SUM(Quantity * UnitPrice) DESC) AS M_score
    FROM `tc-da-1.turing_data_analytics.rfm`
    WHERE InvoiceDate BETWEEN '2010-12-01' AND '2011-12-01'
    GROUP BY CustomerID
)

-- Step 2: Assign customer segments based on RFM score combinations
SELECT 
    CustomerID,
    R_score,
    F_score,
    M_score,
    -- Concatenate RFM scores to create an RFM score identifier
    CONCAT(CAST(R_score AS STRING), CAST(F_score AS STRING), CAST(M_score AS STRING)) AS rfm_score,
    COUNT(CustomerID) AS n,
    -- Use CASE statements to assign customer segments based on RFM combinations
    CASE
        -- Dormant, Hibernating, At Risk, and High-Value Dormant customers (low Recency)
        WHEN R_score = 1 AND F_score = 1 AND M_score IN (1, 2, 3) THEN 'Dormant Customers'
        WHEN R_score = 1 AND F_score = 1 AND M_score = 4 THEN 'High-Value Dormant'
        WHEN R_score = 1 AND F_score = 2 AND M_score = 1 THEN 'Hibernating Customers'
        WHEN R_score = 1 AND F_score = 2 AND M_score = 2 THEN 'Hibernating Customers'
        WHEN R_score = 1 AND F_score = 2 AND M_score IN (3, 4) THEN 'At Risk'

        ELSE 'Other'
    END AS customer_segment
FROM rfm_quartiles
GROUP BY CustomerID, R_score, F_score, M_score
ORDER BY n DESC;




-- CLV Query
WITH purchases AS (
    SELECT 
        user_pseudo_id,
        SUM(purchase_revenue_in_usd) AS total_spent,
        COUNT(*) AS purchase_count
    FROM 
        turing_data_analytics.raw_events
    WHERE 
        event_name = 'purchase'
    GROUP BY 
        user_pseudo_id
),
-- Average Order Value
aov_pf AS (
    SELECT 
        AVG(total_spent / purchase_count) AS AOV,--  average amount of money that a customer spends every time they place an order.
        SUM(purchase_count) / COUNT(DISTINCT user_pseudo_id) AS PF -- Purchase Frequency
    FROM 
        purchases
)
-- CLV is a metric that indicates the total revenue a business can reasonably expect from a single customer account throughout the business relationship.
SELECT 
    ROUND(AOV) AS Average_Order_Value,
    ROUND(PF) AS purchase_frequency,
    ROUND(AOV * PF) AS Customer_value,-- Customer Value (CV)=Average Order Value (AOV)×Purchase Frequency (PF)
    ROUND(AOV* PF * 3 )AS CLV -- assuming a 3-year lifespan
--AOV is the average amount spent per order.
--PF is the average number of purchases each customer makes within that timeframe.
FROM 
    aov_pf;
