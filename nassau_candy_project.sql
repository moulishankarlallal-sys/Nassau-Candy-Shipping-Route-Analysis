CREATE TABLE Raw_Shipments (
    `Row ID` INT,
    `Order ID` VARCHAR(100),
    `Order Date` VARCHAR(50),
    `Ship Date` VARCHAR(50),
    `Ship Mode` VARCHAR(50),
    `Customer ID` VARCHAR(50),
    `Country/Region` VARCHAR(100),
    `City` VARCHAR(100),
    `State/Province` VARCHAR(100),
    `Postal Code` VARCHAR(20),
    `Division` VARCHAR(100),
    `Region` VARCHAR(100),
    `Product ID` VARCHAR(100),
    `Product Name` VARCHAR(200),
    `Sales` DECIMAL(18,2),
    `Units` INT,
    `Gross Profit` DECIMAL(18,2),
    `Cost` DECIMAL(18,2),
    `factory` VARCHAR(100),
    `Shipping lead time` DECIMAL(18,2),
    `Data quality status` VARCHAR(100),
    `route` VARCHAR(200),
    `regional route` VARCHAR(200),
    `order month` VARCHAR(50),
    `gross margin` DECIMAL(18,6),
    `Delay flag` VARCHAR(50)
);


INSERT INTO Product_Factory (Product_Name, Factory)
VALUES
('Wonka Bar - Nutty Crunch Surprise', 'Lot''s O'' Nuts'),
('Wonka Bar - Fudge Mallows', 'Lot''s O'' Nuts'),
('Wonka Bar -Scrumdiddlyumptious', 'Lot''s O'' Nuts'),
('Wonka Bar - Milk Chocolate', 'Wicked Choccy''s'),
('Wonka Bar - Triple Dazzle Caramel', 'Wicked Choccy''s'),
('Laffy Taffy', 'Sugar Shack'),
('SweeTARTS', 'Sugar Shack'),
('Nerds', 'Sugar Shack'),
('Fun Dip', 'Sugar Shack'),
('Fizzy Lifting Drinks', 'Sugar Shack'),
('Everlasting Gobstopper', 'Secret Factory'),
('Lickable Wallpaper', 'Secret Factory'),
('Wonka Gum', 'Secret Factory'),
('Hair Toffee', 'The Other Factory'),
('Kazookles', 'The Other Factory');


SELECT
    pf.Factory,
    rs.`State/Province` AS State_Province,
    COUNT(*) AS Total_Shipments,
    SUM(rs.Sales) AS Total_Sales,
    SUM(rs.`Gross Profit`) AS Gross_Profit,
    SUM(rs.Units) AS Total_Units
FROM Raw_Shipments rs
JOIN Product_Factory pf
    ON rs.`Product Name` = pf.Product_Name
GROUP BY
    pf.Factory,
    rs.`State/Province`
ORDER BY Total_Shipments DESC;

USE nassau_candy;

SELECT
    COUNT(*) AS Total_Shipments,
    SUM(Sales) AS Total_Sales,
    SUM(Units) AS Total_Units,
    SUM(`Gross Profit`) AS Total_Gross_Profit,
    SUM(Cost) AS Total_Cost
FROM Raw_Shipments;

SELECT
    SUM(`Gross Profit`) AS Gross_Profit,
    SUM(Sales) AS Sales,
    ROUND(
        SUM(`Gross Profit`) / NULLIF(SUM(Sales),0) * 100,
        2
    ) AS Gross_Margin_Percent
FROM Raw_Shipments;

SELECT
    `Ship Mode`,
    COUNT(*) AS Shipments,
    SUM(Sales) AS Total_Sales,
    SUM(Units) AS Total_Units,
    SUM(`Gross Profit`) AS Gross_Profit,
    ROUND(AVG(`Shipping lead time`),2) AS Avg_Recorded_Lead_Time
FROM Raw_Shipments
GROUP BY `Ship Mode`
ORDER BY Shipments DESC;

SELECT
    Region,
    COUNT(*) AS Shipments,
    SUM(Sales) AS Total_Sales,
    SUM(Units) AS Total_Units,
    SUM(`Gross Profit`) AS Gross_Profit
FROM Raw_Shipments
GROUP BY Region
ORDER BY Shipments DESC;

SELECT
    `State/Province`,
    Region,
    COUNT(*) AS Shipments,
    SUM(Sales) AS Total_Sales,
    SUM(`Gross Profit`) AS Gross_Profit
FROM Raw_Shipments
GROUP BY
    `State/Province`,
    Region
ORDER BY Shipments DESC;

SELECT
    `State/Province`,
    COUNT(*) AS Shipments,
    SUM(Sales) AS Total_Sales,
    SUM(`Gross Profit`) AS Gross_Profit
FROM Raw_Shipments
GROUP BY `State/Province`
ORDER BY Shipments DESC
LIMIT 10;

SELECT
    `State/Province`,
    COUNT(*) AS Shipments,
    SUM(Sales) AS Total_Sales,
    SUM(`Gross Profit`) AS Gross_Profit
FROM Raw_Shipments
GROUP BY `State/Province`
ORDER BY Shipments DESC
LIMIT 10;

SELECT
    `Product Name`,
    COUNT(*) AS Shipments,
    SUM(Units) AS Total_Units,
    SUM(Sales) AS Total_Sales,
    SUM(`Gross Profit`) AS Gross_Profit
FROM Raw_Shipments
GROUP BY `Product Name`
ORDER BY Total_Sales DESC;

SELECT
    pf.Factory,
    COUNT(*) AS Shipments,
    SUM(rs.Units) AS Total_Units,
    SUM(rs.Sales) AS Total_Sales,
    SUM(rs.`Gross Profit`) AS Gross_Profit,
    ROUND(AVG(rs.`Shipping lead time`),2) AS Avg_Recorded_Lead_Time
FROM Raw_Shipments rs
JOIN Product_Factory pf
    ON rs.`Product Name` = pf.Product_Name
GROUP BY pf.Factory
ORDER BY Shipments DESC;

SELECT
    pf.Factory,
    rs.`State/Province` AS Customer_State,
    COUNT(*) AS Total_Shipments,
    ROUND(AVG(rs.`Shipping lead time`),2) AS Avg_Recorded_Lead_Time,
    SUM(rs.Sales) AS Total_Sales,
    SUM(rs.`Gross Profit`) AS Gross_Profit
FROM Raw_Shipments rs
JOIN Product_Factory pf
    ON rs.`Product Name` = pf.Product_Name
GROUP BY
    pf.Factory,
    rs.`State/Province`
ORDER BY Total_Shipments DESC;

SELECT
    pf.Factory,
    rs.`State/Province` AS Customer_State,
    COUNT(*) AS Total_Shipments,
    ROUND(AVG(rs.`Shipping lead time`),2) AS Avg_Recorded_Lead_Time
FROM Raw_Shipments rs
JOIN Product_Factory pf
    ON rs.`Product Name` = pf.Product_Name
GROUP BY
    pf.Factory,
    rs.`State/Province`
ORDER BY Total_Shipments DESC
LIMIT 10;

SELECT
    `Order ID`,
    `Order Date`,
    `Ship Date`,
    `Shipping lead time` AS Recorded_Lead_Time
FROM Raw_Shipments
LIMIT 20;

SELECT
    ROUND(AVG(`Shipping lead time`), 2) AS Average_Recorded_Lead_Time,
    MIN(`Shipping lead time`) AS Minimum_Lead_Time,
    MAX(`Shipping lead time`) AS Maximum_Lead_Time
FROM Raw_Shipments
WHERE `Shipping lead time` IS NOT NULL;

SELECT
    `Ship Mode`,
    COUNT(*) AS Shipments,
    ROUND(AVG(`Shipping lead time`), 2) AS Avg_Recorded_Lead_Time,
    MIN(`Shipping lead time`) AS Min_Lead_Time,
    MAX(`Shipping lead time`) AS Max_Lead_Time
FROM Raw_Shipments
GROUP BY `Ship Mode`
ORDER BY Avg_Recorded_Lead_Time;

SELECT
    `Data quality status`,
    COUNT(*) AS Records
FROM Raw_Shipments
GROUP BY `Data quality status`
ORDER BY Records DESC;

SELECT
    `Delay flag`,
    COUNT(*) AS Shipments
FROM Raw_Shipments
GROUP BY `Delay flag`
ORDER BY Shipments DESC;


SELECT
    ROUND(
        SUM(CASE WHEN `Delay flag` = 'Delayed' THEN 1 ELSE 0 END)
        / COUNT(*) * 100,
        2
    ) AS Delay_Percentage
FROM Raw_Shipments;

SELECT
    pf.Factory,
    rs.`State/Province` AS Customer_State,
    COUNT(*) AS Total_Shipments,
    ROUND(AVG(rs.`Shipping lead time`), 2) AS Avg_Lead_Time,
    ROUND(STDDEV(rs.`Shipping lead time`), 2) AS Lead_Time_StdDev,
    SUM(
        CASE
            WHEN rs.`Delay flag` = 'Delayed' THEN 1
            ELSE 0
        END
    ) AS Delayed_Shipments,
    ROUND(
        SUM(
            CASE
                WHEN rs.`Delay flag` = 'Delayed' THEN 1
                ELSE 0
            END
        ) / COUNT(*) * 100,
        2
    ) AS Delay_Percentage,
    SUM(rs.Sales) AS Total_Sales,
    SUM(rs.`Gross Profit`) AS Gross_Profit
FROM Raw_Shipments rs
JOIN Product_Factory pf
    ON rs.`Product Name` = pf.Product_Name
GROUP BY
    pf.Factory,
    rs.`State/Province`
ORDER BY Total_Shipments DESC;

SELECT
    pf.Factory,
    rs.`State/Province` AS Customer_State,
    COUNT(*) AS Total_Shipments,
    ROUND(AVG(rs.`Shipping lead time`), 2) AS Avg_Lead_Time
FROM Raw_Shipments rs
JOIN Product_Factory pf
    ON rs.`Product Name` = pf.Product_Name
GROUP BY
    pf.Factory,
    rs.`State/Province`
ORDER BY Total_Shipments DESC
LIMIT 10;

USE nassau_candy;

CREATE OR REPLACE VIEW vw_route_analysis AS
SELECT
    pf.Factory,
    rs.`State/Province` AS Customer_State,
    COUNT(*) AS Total_Shipments,
    ROUND(AVG(rs.`Shipping lead time`), 2) AS Avg_Lead_Time,
    ROUND(STDDEV(rs.`Shipping lead time`), 2) AS Lead_Time_StdDev,
    SUM(
        CASE
            WHEN rs.`Delay flag` = 'Delayed' THEN 1
            ELSE 0
        END
    ) AS Delayed_Shipments,
    ROUND(
        SUM(
            CASE
                WHEN rs.`Delay flag` = 'Delayed' THEN 1
                ELSE 0
            END
        ) / COUNT(*) * 100,
        2
    ) AS Delay_Percentage,
    ROUND(SUM(rs.Sales), 2) AS Total_Sales,
    ROUND(SUM(rs.`Gross Profit`), 2) AS Gross_Profit
FROM Raw_Shipments rs
JOIN Product_Factory pf
    ON rs.`Product Name` = pf.Product_Name
GROUP BY
    pf.Factory,
    rs.`State/Province`;
    
    
    
    SELECT *
FROM vw_route_analysis
ORDER BY Total_Shipments DESC
LIMIT 20;

CREATE OR REPLACE VIEW vw_ship_mode_analysis AS
SELECT
    `Ship Mode`,
    COUNT(*) AS Shipments,
    ROUND(AVG(`Shipping lead time`), 2) AS Avg_Lead_Time,
    ROUND(STDDEV(`Shipping lead time`), 2) AS Lead_Time_StdDev,
    SUM(
        CASE
            WHEN `Delay flag` = 'Delayed' THEN 1
            ELSE 0
        END
    ) AS Delayed_Shipments,
    ROUND(
        SUM(
            CASE
                WHEN `Delay flag` = 'Delayed' THEN 1
                ELSE 0
            END
        ) / COUNT(*) * 100,
        2
    ) AS Delay_Percentage,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(`Gross Profit`), 2) AS Gross_Profit
FROM Raw_Shipments
GROUP BY `Ship Mode`;


SELECT *
FROM vw_ship_mode_analysis
ORDER BY Shipments DESC;

USE nassau_candy;

CREATE OR REPLACE VIEW vw_route_analysis AS
SELECT
    pf.Factory,
    rs.`State/Province` AS Customer_State,
    COUNT(*) AS Total_Shipments,
    ROUND(AVG(rs.`Shipping lead time`), 2) AS Avg_Lead_Time,
    ROUND(STDDEV(rs.`Shipping lead time`), 2) AS Lead_Time_StdDev,
    SUM(
        CASE
            WHEN rs.`Delay flag` = 'Delayed' THEN 1
            ELSE 0
        END
    ) AS Delayed_Shipments,
    ROUND(
        SUM(
            CASE
                WHEN rs.`Delay flag` = 'Delayed' THEN 1
                ELSE 0
            END
        ) / COUNT(*) * 100,
        2
    ) AS Delay_Percentage,
    ROUND(SUM(rs.Sales), 2) AS Total_Sales,
    ROUND(SUM(rs.`Gross Profit`), 2) AS Gross_Profit
FROM Raw_Shipments rs
JOIN Product_Factory pf
    ON rs.`Product Name` = pf.Product_Name
GROUP BY
    pf.Factory,
    rs.`State/Province`;
    
    
    SELECT *
FROM vw_route_analysis
ORDER BY Total_Shipments DESC
LIMIT 20;

CREATE OR REPLACE VIEW vw_ship_mode_analysis AS
SELECT
    `Ship Mode`,
    COUNT(*) AS Shipments,
    ROUND(AVG(`Shipping lead time`), 2) AS Avg_Lead_Time,
    ROUND(STDDEV(`Shipping lead time`), 2) AS Lead_Time_StdDev,
    SUM(
        CASE
            WHEN `Delay flag` = 'Delayed' THEN 1
            ELSE 0
        END
    ) AS Delayed_Shipments,
    ROUND(
        SUM(
            CASE
                WHEN `Delay flag` = 'Delayed' THEN 1
                ELSE 0
            END
        ) / COUNT(*) * 100,
        2
    ) AS Delay_Percentage,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(`Gross Profit`), 2) AS Gross_Profit
FROM Raw_Shipments
GROUP BY `Ship Mode`;

SELECT *
FROM vw_ship_mode_analysis
ORDER BY Shipments DESC;

CREATE OR REPLACE VIEW vw_geographic_analysis AS
SELECT
    `State/Province` AS State_Province,
    Region,
    COUNT(*) AS Shipments,
    ROUND(AVG(`Shipping lead time`), 2) AS Avg_Lead_Time,
    ROUND(
        SUM(
            CASE
                WHEN `Delay flag` = 'Delayed' THEN 1
                ELSE 0
            END
        ) / COUNT(*) * 100,
        2
    ) AS Delay_Percentage,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    ROUND(SUM(`Gross Profit`), 2) AS Gross_Profit
FROM Raw_Shipments
GROUP BY
    `State/Province`,
    Region;
    
    
    
    SELECT *
FROM vw_geographic_analysis
ORDER BY Shipments DESC
LIMIT 20;

CREATE OR REPLACE VIEW vw_factory_analysis AS
SELECT
    pf.Factory,
    COUNT(*) AS Shipments,
    SUM(rs.Units) AS Total_Units,
    ROUND(SUM(rs.Sales), 2) AS Total_Sales,
    ROUND(SUM(rs.`Gross Profit`), 2) AS Gross_Profit,
    ROUND(AVG(rs.`Shipping lead time`), 2) AS Avg_Lead_Time,
    ROUND(
        SUM(
            CASE
                WHEN rs.`Delay flag` = 'Delayed' THEN 1
                ELSE 0
            END
        ) / COUNT(*) * 100,
        2
    ) AS Delay_Percentage
FROM Raw_Shipments rs
JOIN Product_Factory pf
    ON rs.`Product Name` = pf.Product_Name
GROUP BY pf.Factory;


SELECT *
FROM vw_factory_analysis
ORDER BY Shipments DESC;

CREATE OR REPLACE VIEW vw_kpi_summary AS
SELECT
    COUNT(*) AS Total_Shipments,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    SUM(Units) AS Total_Units,
    ROUND(SUM(`Gross Profit`), 2) AS Total_Gross_Profit,
    ROUND(SUM(`Gross Profit`) / NULLIF(SUM(Sales), 0) * 100, 2) AS Gross_Margin_Percentage,
    ROUND(AVG(`Shipping lead time`), 2) AS Avg_Recorded_Lead_Time,
    COUNT(DISTINCT `State/Province`) AS Total_States,
    COUNT(DISTINCT `Ship Mode`) AS Total_Ship_Modes
FROM Raw_Shipments;


SELECT *
FROM vw_kpi_summary;

CREATE OR REPLACE VIEW vw_kpi_summary AS
SELECT
    COUNT(*) AS Total_Shipments,
    ROUND(SUM(Sales), 2) AS Total_Sales,
    SUM(Units) AS Total_Units,
    ROUND(SUM(`Gross Profit`), 2) AS Total_Gross_Profit,
    ROUND(SUM(`Gross Profit`) / NULLIF(SUM(Sales), 0) * 100, 2) AS Gross_Margin_Percentage,
    ROUND(AVG(`Shipping lead time`), 2) AS Avg_Recorded_Lead_Time,
    COUNT(DISTINCT `State/Province`) AS Total_States,
    COUNT(DISTINCT `Ship Mode`) AS Total_Ship_Modes
FROM Raw_Shipments;


SELECT *
FROM vw_kpi_summary;

SHOW FULL TABLES
WHERE Table_type = 'VIEW';

