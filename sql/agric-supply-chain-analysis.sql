-- Part B - SQL  
-- Question 50. Create and populate an agric_supply_chain table

CREATE DATABASE IF NOT EXISTS agric_supply_chain_db;

USE agric_supply_chain_db;

CREATE TABLE IF NOT EXISTS agric_supply_chain(
record_id VARCHAR(20) PRIMARY KEY NOT NULL,
farmer_id VARCHAR(20),
crop VARCHAR(50),
state VARCHAR(50),
lga VARCHAR(50),
harvest_date DATE,
season VARCHAR(20),
quantity_harvested_kg DECIMAL(12, 2),
post_harvest_loss_pct DECIMAL(5, 2),
quantity_sold_kg DECIMAL(12, 2),
farm_gate_price_per_kg DECIMAL(10, 2),
market_price_per_kg DECIMAL(10, 2),
gross_revenue_ngn DECIMAL(15, 2),
transport_mode VARCHAR(30),
transport_cost_ngn DECIMAL(12, 2),
destination_market VARCHAR(100),
days_to_market TINYINT UNSIGNED,
storage_type VARCHAR(50),
fertilizer_used VARCHAR(5),
irrigation_used VARCHAR(5),
cooperative_member VARCHAR(5)
);

-- load dataset csv file into mysql workbench
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/agric_supply_chain.csv'
INTO TABLE agric_supply_chain
FIELDS TERMINATED BY ","
IGNORE 1 LINES;


-- Confirm dataset was loaded successfully
SELECT * FROM agric_supply_chain LIMIT 5;

-- Question 51. Total revenue and avg post-harvest loss by crop (sorted by loss DESC)
SELECT 
    crop,
    SUM(gross_revenue_ngn) AS total_revenue,
    AVG(post_harvest_loss_pct) AS avg_post_harvest_loss
FROM agric_supply_chain
GROUP BY crop
ORDER BY avg_post_harvest_loss DESC;

-- Question 52. State performance: total revenue, avg margin, avg loss per state
SELECT 
    state,
    SUM(gross_revenue_ngn) AS total_revenue,
    AVG(market_price_per_kg - farm_gate_price_per_kg) AS avg_price_margin_per_kg,
    AVG(post_harvest_loss_pct) AS avg_loss_percentage
FROM agric_supply_chain
GROUP BY state;

-- Question 53. Effect of cooperative membership on avg price and loss rate
SELECT 
    cooperative_member,
    AVG(farm_gate_price_per_kg) AS avg_farm_gate_price,
    AVG(post_harvest_loss_pct) AS avg_loss_rate
FROM agric_supply_chain
GROUP BY cooperative_member;

-- Question 54. Top 5 most profitable crop-state combinations
SELECT 
    crop,
    state,
    SUM(gross_revenue_ngn - COALESCE(transport_cost_ngn, 0)) AS net_profit_ngn
FROM agric_supply_chain
GROUP BY crop, state
ORDER BY net_profit_ngn DESC
LIMIT 5;

-- Question 55. Transport cost as % of gross revenue by transport mode
SELECT 
    transport_mode,
    SUM(transport_cost_ngn) AS total_transport_cost,
    SUM(gross_revenue_ngn) AS total_gross_revenue,
    (SUM(transport_cost_ngn) * 100.0 / SUM(gross_revenue_ngn)) AS transport_cost_percentage
FROM agric_supply_chain
WHERE gross_revenue_ngn > 0
GROUP BY transport_mode;


-- Question 56. Monthly price trend: avg farm gate price vs market price per crop
SELECT 
    crop,
    DATE_FORMAT(harvest_date, '%Y-%m') AS harvest_month,
    AVG(farm_gate_price_per_kg) AS avg_farm_gate_price,
    AVG(market_price_per_kg) AS avg_market_price
FROM agric_supply_chain
GROUP BY crop, DATE_FORMAT(harvest_date, '%Y-%m')
ORDER BY crop, harvest_month;


-- Question 57. Farmers with post-harvest loss > 20% — count and avg revenue impact
SELECT 
    COUNT(DISTINCT farmer_id) AS high_loss_farmer_count,
    AVG(quantity_harvested_kg * (post_harvest_loss_pct / 100.0) * farm_gate_price_per_kg) AS avg_estimated_revenue_loss_ngn
FROM agric_supply_chain
WHERE post_harvest_loss_pct > 20.00;


-- Question 58. Storage type impact: avg loss % and avg revenue by storage type
SELECT 
    storage_type,
    AVG(post_harvest_loss_pct) AS avg_loss_percentage,
    AVG(gross_revenue_ngn) AS avg_gross_revenue
FROM agric_supply_chain
GROUP BY storage_type;


-- Question 59. Market destination performance: revenue and volume per market
SELECT 
    destination_market,
    SUM(gross_revenue_ngn) AS total_revenue_ngn,
    SUM(quantity_sold_kg) AS total_volume_sold_kg
FROM agric_supply_chain
WHERE destination_market IS NOT NULL
GROUP BY destination_market
ORDER BY total_revenue_ngn DESC;


-- Question 60. Rank crops by net profit margin using RANK() window function
WITH CropMargins AS (
    SELECT 
        crop,
        -- Net Profit Margin = (Gross Revenue - Transport Cost) / Gross Revenue
        SUM(gross_revenue_ngn - COALESCE(transport_cost_ngn, 0)) * 100.0 / SUM(gross_revenue_ngn) AS net_profit_margin_pct
    FROM agric_supply_chain
    GROUP BY crop
)
SELECT 
    crop,
    net_profit_margin_pct,
    RANK() OVER (ORDER BY net_profit_margin_pct DESC) AS margin_rank
FROM CropMargins;












