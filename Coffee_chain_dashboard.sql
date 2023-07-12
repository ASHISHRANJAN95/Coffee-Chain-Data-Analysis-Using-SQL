USE coffee_chain;
#1 states wise profit to sales percentage

SELECT state,
       SUM(sales)sales,
       SUM(profit)profit,
       CONCAT(FORMAT(SUM(Profit)/SUM(Sales)*100,2),'%') profit_ovr_sales_pcr
FROM  location l,
	  fact f
WHERE l.area_code=f.area_code
GROUP BY state
ORDER BY sales desc

#2 product wise profit to sales percentage

SELECT product,
       SUM(sales) sales,
       SUM(profit)profit,
       CONCAT(FORMAT(SUM(Profit)/SUM(Sales)*100,2),'%') profit_ovr_sales_pcr
FROM   product p,
       fact f
WHERE  p.product_id=f.product_id
GROUP BY product
ORDER BY profit desc

#3 Actual P & L

SELECT SUM(sales) Sales,
       CONCAT( SUM(Margin)-SUM(sales)) COGS,
       SUM(Margin) Margin,
       CONCAT(SUM(Profit)- SUM(Margin))Expenses,
       SUM(Profit) Profit
FROM fact f

#4 Budget P & L

SELECT SUM(Budget_sales) sales,
       CONCAT(SUM(Budget_Margin)-SUM(Budget_sales) ) COGS,
       SUM(Budget_Margin) Margin,
       CONCAT(SUM(Budget_Profit)- SUM(Budget_Margin))Expenses,
       SUM(Budget_Profit) Profit
FROM fact f

#5 Slicers

SELECT Market,
	   Market_size,
       state,
       Product_category,
       Product_type,
       Product
FROM   Product p,
       Location l
GROUP BY Market,
	   Market_size,
       state,
       Product_category,
       Product_type,
       Product



	   

