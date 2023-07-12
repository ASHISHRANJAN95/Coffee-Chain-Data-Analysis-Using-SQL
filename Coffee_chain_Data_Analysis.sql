
############ create a database ############

DROP DATABASE IF EXISTS coffee_chain;
CREATE DATABASE coffee_chain;
USE coffee_chain; 

############ create tables ############
  
CREATE TABLE Product (
	Product_Id VARCHAR(255),
    Product VARCHAR(255),
    Product_Type VARCHAR(255),
    Product_Category VARCHAR(255),
	PRIMARY KEY (Product_Id));
    
CREATE TABLE Location (
	Area_Code CHAR(3),
    State VARCHAR(255),
    Market VARCHAR(255),
    Market_Size VARCHAR(255),
	PRIMARY KEY (Area_Code));

CREATE TABLE Date (
	Date DATE,
    Month CHAR(6),
    Quarter CHAR(6),
    Year CHAR(4),
	PRIMARY KEY (Date));

CREATE TABLE Fact (
	Product_Id VARCHAR(255),
    Area_Code CHAR(3),
    Date DATE,
    Sales INTEGER,
    COGS INTEGER,
    Margin INTEGER,
    Expenses INTEGER,
    Profit INTEGER,
    Marketing INTEGER,
    Inventory INTEGER,
    Budget_Sales INTEGER,
    Budget_COGS INTEGER,
    Budget_Margin INTEGER,
    Budget_Profit INTEGER,
    FOREIGN KEY (Product_Id) REFERENCES Product (Product_Id),
    FOREIGN KEY (Area_Code) REFERENCES Location (Area_Code),
    FOREIGN KEY (Date) REFERENCES Date (Date));


LOAD DATA LOCAL INFILE 'D:/Desktop/Coffee Chain/csv/Product.csv'
INTO TABLE Product
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'D:/Desktop/Coffee Chain/csv/Location.csv'
INTO TABLE Location
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'D:/Desktop/Coffee Chain/csv/Date.csv'
INTO TABLE Date
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA LOCAL INFILE 'D:/Desktop/Coffee Chain/csv/Fact.csv'
INTO TABLE Fact
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;



SELECT  Product_Category,
		Market_Size,
		Year,
		SUM(Sales) Sales
FROM    Product p,
		Location l,
		Date d,
		Fact f
WHERE	p.Product_id = f.Product_id
        AND l.Area_Code = f.Area_Code
        AND d.Date = f.Date
GROUP	BY Product_Category, Market_Size, Year
ORDER	BY Product_Category, Market_Size, Year;


SELECT COUNT(DISTINCT Product_Id) FROM Product;
SELECT  Product_Id, COUNT(*) FROM Product GROUP BY Product_Id HAVING COUNT(*)=1;
SELECT  Product_Id, COUNT(*) FROM Product GROUP BY Product_Id HAVING COUNT(*)>1;


#1. Which Area Code was 25th place in Sales for Espresso? 318

SELECT	Area_Code,
		SUM(Sales) Sales
FROM	Product p,
		Fact f
WHERE	p.Product_Id = f.Product_Id
		AND Product_Type = 'Espresso'
GROUP	BY Area_Code
ORDER	BY Sales DESC
LIMIT	1 OFFSET 24;

#2. Which State in the East Market has the lowest Profit for Espresso? New Hampshire

SELECT	State,
		SUM(Profit) Profit
FROM	Product p,
		Location l,
		Fact f
WHERE	p.Product_Id = f.Product_Id
		AND l.Area_Code = f.Area_Code
		AND Product_Type = 'Espresso'
		AND Market = 'East'
GROUP	BY State
ORDER	BY Profit
LIMIT	1;

#3. What is the difference in Budget Profit, in 2012Q3 from the previous quarter for Major Market? 630

SELECT	Quarter,
		Budget_Profit_Diff
FROM	(SELECT	Quarter,
				SUM(Budget_Profit) Budget_Profit_Curr,
                LAG(SUM(Budget_Profit),1) OVER (ORDER BY Quarter) Budget_Profit_Prev,
				SUM(Budget_Profit)-LAG (SUM(Budget_Profit),1) OVER (ORDER BY Quarter) Budget_Profit_Diff
		FROM	Location l,
				Date d,
				Fact f
		WHERE	l.Area_Code = f.Area_Code
				AND d.Date = f.Date
				AND Market_Size = 'Major Market'
		GROUP	BY Quarter
		ORDER	BY Quarter) x
WHERE	Quarter = '2012Q3';

#4. In which Month did the running Sales cross $30,000 for Decaf in Colorado and Florida? 201305

SELECT 	Month
FROM	(SELECT	*,
				ROW_NUMBER() OVER (ORDER BY Month) Row_Num
		FROM	(SELECT	Month,
						SUM(Sales) Sales,
						SUM(SUM(Sales)) OVER (ORDER BY Month) Sales_Cum
				FROM	Product p,
						Location l,
						Date d,
						Fact f
				WHERE	p.Product_Id = f.Product_Id
						AND l.Area_Code = f.Area_Code
						AND d.Date = f.Date
                        AND Product_Category = 'Decaf'
						AND State IN ('Colorado', 'Florida')
				GROUP	BY Month) x
		WHERE	Sales_Cum >= 30000) y
WHERE	Row_Num = 1;

#5. Create a bar chart with Product Type, Product, and Profit. Identify which product falls below the overall 99.9% Confidence Interval Distribution (Table across)? Green Tea

#6. Using quartiles, identify which of the following Espresso product has the highest distribution of sales? Regular Espresso

#7. In 2013, identify the State with the highest Profit in the West Market? California

SELECT	State,
		SUM(Profit) Profit
FROM	Location l,
		Date d,
        Fact f
WHERE	l.Area_Code = f.Area_Code
		AND d.Date = f.Date
        AND Market = 'West'
		AND Year = '2013'
GROUP	BY State
ORDER	BY Profit DESC
limit	1;

#8. Create a scatter plot with State, Sales, and Profit. Identify the Trend Line with ‘R-Squared’ value between 0.7 to 0.8? Polynomial Trend Line with Degree 2

#9. Identify the % Expenses / Sales of the State with the lowest Profit. 45.58%

SELECT	State,
		SUM(Profit) Profit,
        CONCAT(FORMAT(SUM(Expenses)/SUM(Sales)*100,2),'%') Expenses_To_Sales_Ratio
FROM	Location l,
		Fact f
WHERE	l.Area_Code = f.Area_Code
GROUP	BY State
order	by Profit
LIMIT	1;

#10. Create a Combined Field with Product and State. Identify the highest selling Product and State. (Colombian, California), (Colombian, New York)

SELECT	Product_State
FROM	(SELECT	CONCAT('(',Product,', ',State,')') Product_State,
				SUM(Sales) Sales,
				RANK() OVER (ORDER BY SUM(Sales) DESC) Rank_Num
		FROM	Product p,
				Location l,
				Fact f
		WHERE	p.Product_Id = f.Product_Id
				AND l.Area_Code = f.Area_Code
		GROUP	BY Product_State) x
WHERE	Rank_Num = 1;

#11. What is the contribution of Tea to the overall Profit in 2012? 20.42%

SELECT	Profit_Pct_Total
FROM	(SELECT	Product_Type,
				SUM(Profit) Profit,
                SUM(SUM(Profit)) OVER () Profit_Total,
				CONCAT(FORMAT(SUM(Profit)/SUM(SUM(Profit)) OVER ()*100,2),'%') Profit_Pct_Total
		FROM	Product p,
				Date d,
				Fact f
		WHERE	p.Product_Id = f.Product_Id
				AND d.Date = f.Date
				AND Year = '2012'
		GROUP	BY Product_Type
		ORDER 	BY Product_Type) x
WHERE	Product_Type = 'Tea';

#12. What is the average % Profit / Sales for all the Products starting with C? 34.52%


SELECT	CONCAT(FORMAT(SUM(Profit)/SUM(Sales)*100,2),'%') Profit_To_Sales_Ratio
FROM	Product p,
		Fact f
WHERE	p.Product_Id = f.Product_Id
		AND Product LIKE "C%";

#13. What is the distinct count of Area Codes for the State with the lowest Budget Margin in Small Market? 1

SELECT	State,
		SUM(Budget_Margin) Budget_Margin,
		COUNT(DISTINCT f.Area_Code) Area_Code_Distinct_Count
FROM	Location l,
		Fact f
WHERE	l.Area_Code = f.Area_Code
		AND Market_Size = 'Small Market'
GROUP	BY State
ORDER	BY Budget_Margin
LIMIT	1;

#14. Which Product Type does not have any of its Product within the Top 5 Products by Sales? Tea 

SELECT	DISTINCT Product_Type
FROM	Product
WHERE	Product_Type NOT IN (SELECT	DISTINCT Product_Type
							FROM 	(SELECT	Product_Type,
											Product,
											SUM(Sales) Sales
									FROM	Product p,
											Fact f
									WHERE	p.Product_Id = f.Product_Id
									GROUP	BY Product_Type, Product
									ORDER	BY Sales DESC
									LIMIT	5) x);

#15. In the Central Market, the Top 5 Products by Sales contributed _% of the Expenses. 60.92% 

SELECT	Expenses_Cum_Pct_Total
FROM	(SELECT	*,
				SUM(Expenses) OVER (ORDER BY Sales DESC) Expenses_Cum,
                SUM(Expenses) OVER () Expenses_Total,
				CONCAT(FORMAT(SUM(Expenses) OVER (ORDER BY Sales DESC)/SUM(Expenses) OVER ()*100,2),'%') Expenses_Cum_Pct_Total,
				ROW_NUMBER() OVER (ORDER BY Sales DESC) Row_Num
		FROM	(SELECT	Product,
						SUM(Sales) Sales,
						SUM(expenses) Expenses
				FROM	Product p,
						Location l,
                        Fact f
				WHERE	p.Product_Id = f.Product_Id
						AND l.Area_Code = f.Area_Code
						AND Market = 'Central'
				GROUP	BY Product
				ORDER	BY Sales DESC) x) y
WHERE	Row_Num = 5;