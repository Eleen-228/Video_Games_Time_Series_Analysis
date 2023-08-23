SELECT *
FROM Video_Games_Analysis vga
LIMIT 5


SELECT count(Name)
FROM Video_Games_Analysis vga 
-- 16448

-- convert Year_of_Release to string and stored in a new column
CREATE VIEW games AS 
SELECT 
Name,
Platform,
CONVERT(Year_of_Release, char) Yr,
Genre,
Publisher ,
NA_Sales ,
EU_Sales ,
JP_Sales ,
Other_Sales ,
Global_Sales 
FROM Video_Games_Analysis vga 

-- different platforms
SELECT Platform, COUNT(Platform) 
FROM games g
GROUP BY Platform 
ORDER BY COUNT(Platform) DESC  

-- year range
SELECT DISTINCT Yr
FROM games g 
ORDER BY Yr 
-- from 1980 to 2020 (missing sales data for 2018 and 2019)
-- 39 counts

-- Genre types
SELECT DISTINCT Genre
FROM games g 
-- 12

-- different Publishers
SELECT DISTINCT Publisher
FROM games g 
ORDER BY Publisher 
-- 580

-- Simply Trend 
-- sales trend in North America over time
SELECT Yr, SUM(NA_Sales)
FROM games g 
GROUP BY 1
ORDER BY 1 
-- 0 sales in 2017 for North America

-- sales trend in Europe over time
SELECT Yr, SUM(EU_Sales)
FROM games g 
GROUP BY 1 
ORDER BY 1
-- 0 sales in 2017 and 2020 for Europe

-- sales trend in Japan over time
SELECT Yr, SUM(JP_Sales)
FROM games g 
GROUP BY 1 
ORDER BY 1
-- 0 sales in 1980, 1981, 1982, and 2020 in Japan

-- sales trend for the rest of the world over time
SELECT Yr, SUM(Other_Sales)
FROM games g 
GROUP BY 1 
ORDER BY 1
-- 0 sales in 2017

-- Global sales trend over time 
SELECT Yr, SUM(Global_Sales)
FROM games g 
GROUP BY 1 
ORDER BY 1

-- Components Comparing

-- Check for Genre(s) that showed up every year
SELECT Genre, COUNT(Genre)
FROM (
SELECT Yr, Genre, SUM(Global_Sales)  FROM games GROUP BY 1,2 ORDER BY 1
) tb1
GROUP BY Genre
ORDER BY COUNT(Genre) DESC  
-- since none of the genres showed up every single year, I will just compare those genres showed up most of the years
-- Those genres are Action, Sports, Shooter, and Platform

-- sales of each Genre over time
CREATE VIEW sales_per_genre AS 
SELECT 
Yr, 
Genre, 
SUM(NA_Sales),
SUM(EU_Sales),
SUM(JP_Sales),
SUM(Other_Sales),
SUM(Global_Sales) 
FROM games g
WHERE Genre IN ('Action', 'Sports', 'Shooter', 'Platform')
GROUP BY Yr, Genre
ORDER BY Yr 

SELECT * 
FROM sales_per_genre spg 

-- percentage of sales total for Action Sports Shooter and Platform each year
-- North America
WITH yearly_sales AS (
SELECT Yr, SUM(NA_Sales) NA_total_sales 
FROM games g 
GROUP BY Yr
ORDER BY Yr
)
SELECT 
spg.Yr, 
Genre,
spg.`SUM(NA_Sales)`,
ys.NA_total_sales,
IFNULL(ROUND((spg.`SUM(NA_Sales)` / ys.NA_total_sales)*100, 2), 0) perct_sales_total
FROM sales_per_genre spg 
JOIN yearly_sales ys ON spg.Yr = ys.Yr

-- Europe
WITH yearly_sales AS (
SELECT Yr, SUM(EU_Sales) EU_total_sales 
FROM games g 
GROUP BY Yr
ORDER BY Yr
)
SELECT 
spg.Yr, 
Genre,
spg.`SUM(EU_Sales)`,
ys.EU_total_sales,
IFNULL(ROUND((spg.`SUM(EU_Sales)` / ys.EU_total_sales)*100, 2), 0) perct_sales_total
FROM sales_per_genre spg 
JOIN yearly_sales ys ON spg.Yr = ys.Yr

-- Japan
WITH yearly_sales AS (
SELECT Yr, SUM(JP_Sales) JP_total_sales 
FROM games g 
GROUP BY Yr
ORDER BY Yr
)
SELECT 
spg.Yr, 
Genre,
spg.`SUM(JP_Sales)`,
ys.JP_total_sales,
IFNULL(ROUND((spg.`SUM(JP_Sales)` / ys.JP_total_sales)*100, 2), 0) perct_sales_total
FROM sales_per_genre spg 
JOIN yearly_sales ys ON spg.Yr = ys.Yr

-- Others 
WITH yearly_sales AS (
SELECT Yr, SUM(Other_Sales) Other_total_sales 
FROM games g 
GROUP BY Yr
ORDER BY Yr
)
SELECT 
spg.Yr, 
Genre,
spg.`SUM(Other_Sales)`,
ys.Other_total_sales,
IFNULL(ROUND((spg.`SUM(Other_Sales)` / ys.Other_total_sales)*100, 2), 0) perct_sales_total
FROM sales_per_genre spg 
JOIN yearly_sales ys ON spg.Yr = ys.Yr

-- Global 
WITH yearly_sales AS (
SELECT Yr, SUM(Global_Sales) Global_total_sales 
FROM games g 
GROUP BY Yr
ORDER BY Yr
)
SELECT 
spg.Yr, 
Genre,
spg.`SUM(Global_Sales)`,
ys.Global_total_sales,
IFNULL(ROUND((spg.`SUM(Global_Sales)` / ys.Global_total_sales)*100, 2), 0) perct_sales_total
FROM sales_per_genre spg 
JOIN yearly_sales ys ON spg.Yr = ys.Yr


-- calculating accumulated sum (sales)/ running total over the years (1981 - 2016) for Action, Sports, Shooter, and Platform per geographic market
-- North America
SELECT 
Yr, 
Genre, 
`SUM(NA_Sales)` ,
SUM(`SUM(NA_Sales)`) OVER(PARTITION BY Genre ORDER BY Yr) AS acc_sales 
FROM sales_per_genre spg 
ORDER BY Genre 


-- Europe
SELECT 
Yr, 
Genre, 
`SUM(EU_Sales)` ,
SUM(`SUM(EU_Sales)`) OVER(PARTITION BY Genre ORDER BY Yr) AS acc_sales 
FROM sales_per_genre spg 
ORDER BY Genre

-- Japan
SELECT 
Yr, 
Genre, 
`SUM(JP_Sales)` ,
SUM(`SUM(JP_Sales)`) OVER(PARTITION BY Genre ORDER BY Yr) AS acc_sales 
FROM sales_per_genre spg 
ORDER BY Genre

-- Other
SELECT 
Yr, 
Genre, 
`SUM(Other_Sales)` ,
SUM(`SUM(Other_Sales)`) OVER(PARTITION BY Genre ORDER BY Yr) AS acc_sales 
FROM sales_per_genre spg 
ORDER BY Genre

-- Gloabl
SELECT 
Yr, 
Genre, 
`SUM(Global_Sales)` ,
SUM(`SUM(Global_Sales)`) OVER(PARTITION BY Genre ORDER BY Yr) AS acc_sales 
FROM sales_per_genre spg 
ORDER BY Genre

-- Calculating absolute sales diff over time (1981- 2016) 
SELECT 
Yr, 
Genre, 
`SUM(NA_Sales)` ,
LAG(`SUM(NA_Sales)`) OVER(PARTITION BY Genre ORDER BY Yr) AS NA_lag_val,
`SUM(NA_Sales)` - LAG(`SUM(NA_Sales)`) OVER(PARTITION BY Genre ORDER BY Yr) NA_abs_diff,
`SUM(EU_Sales)` ,
LAG(`SUM(EU_Sales)`) OVER(PARTITION BY Genre ORDER BY Yr) AS EU_lag_val,
`SUM(EU_Sales)` - LAG(`SUM(EU_Sales)`) OVER(PARTITION BY Genre ORDER BY Yr) EU_abs_diff,
`SUM(JP_Sales)` ,
LAG(`SUM(JP_Sales)`) OVER(PARTITION BY Genre ORDER BY Yr) AS JP_lag_val,
`SUM(JP_Sales)` - LAG(`SUM(JP_Sales)`) OVER(PARTITION BY Genre ORDER BY Yr) JP_abs_diff,
`SUM(Other_Sales)` ,
LAG(`SUM(Other_Sales)`) OVER(PARTITION BY Genre ORDER BY Yr) AS JP_lag_val,
`SUM(Other_Sales)` - LAG(`SUM(Other_Sales)`) OVER(PARTITION BY Genre ORDER BY Yr) Other_abs_diff,
`SUM(Global_Sales)` ,
LAG(`SUM(Global_Sales)`) OVER(PARTITION BY Genre ORDER BY Yr) AS JP_lag_val,
`SUM(Global_Sales)` - LAG(`SUM(Global_Sales)`) OVER(PARTITION BY Genre ORDER BY Yr) Global_abs_diff
FROM sales_per_genre spg 
WHERE Yr >= '1981' AND Yr <= '2016'
ORDER BY Genre 


