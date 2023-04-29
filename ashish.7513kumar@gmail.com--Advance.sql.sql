--SQL Advance Case Study


--Q1--BEGIN 
	SELECT State FROM DIM_LOCATION L
	INNER JOIN FACT_TRANSACTIONS F ON L.IDLocation=F.IDLocation
	WHERE YEAR(DATE)>=2005
	GROUP BY State




--Q1--END

--Q2--BEGIN
	SELECT STATE FROM (SELECT TOP 1 STATE, SUM(Quantity) as TOTAL_QTY FROM FACT_TRANSACTIONS AS F
	INNER JOIN DIM_LOCATION AS L ON F.IDLocation= L.IDLocation
	INNER JOIN DIM_MODEL AS M ON F.IDModel= M.IDModel
	INNER JOIN DIM_MANUFACTURER AS MA ON M.IDManufacturer= MA.IDManufacturer
	WHERE Manufacturer_Name= 'Samsung' and country= 'US'
	GROUP BY STATE
	ORDER BY TOTAL_QTY DESC) AS A1









--Q2--END

--Q3--BEGIN      
SELECT ZipCode, STATE, M.IDModel, COUNT(IDCUSTOMER) as TOTAL_TRANSACTION FROM FACT_TRANSACTIONS F 
INNER JOIN DIM_MODEL M ON F.IDModel= M.IDModel
INNER JOIN DIM_LOCATION L ON F.IDLocation= L.IDLocation
GROUP BY ZIPCODE, STATE, M.IDModel










--Q3--END

--Q4--BEGIN
SELECT IDModel,Model_Name,Unit_price,M.IDManufacturer,Manufacturer_Name  FROM DIM_MODEL AS M
INNER JOIN DIM_MANUFACTURER AS MA ON M.IDManufacturer= MA.IDManufacturer
WHERE Unit_price= (SELECT MIN(Unit_price) from DIM_MODEL)






--Q4--END

--Q5--BEGIN
SELECT TOP 5 MA.MANUFACTURER_NAME,MA.IDMANUFACTURER, SUM(F.QUANTITY) AS TOT_QTY, AVG(F.TOTALPRICE) AS AVG_PRICE  FROM FACT_TRANSACTIONS F 
INNER JOIN DIM_MODEL M ON F.IDMODEL= M.IDMODEL
INNER JOIN DIM_MANUFACTURER MA ON M.IDMANUFACTURER= MA.IDMANUFACTURER
GROUP BY MA.MANUFACTURER_NAME, MA.IDMANUFACTURER
ORDER BY TOT_QTY DESC, AVG_PRICE DESC













--Q5--END

--Q6--BEGIN
SELECT C.IDCustomer, Customer_Name, AVG(TOTALPRICE) AS AVG_AMOUNT FROM DIM_CUSTOMER C 
INNER JOIN FACT_TRANSACTIONS F ON C.IDCustomer= F.IDCustomer
WHERE YEAR(DATE)=2009
GROUP BY C.IDCustomer, Customer_Name
HAVING AVG(TOTALPRICE)>500











--Q6--END
	
--Q7--BEGIN  
SELECT T1.MODEL_NAME FROM (SELECT TOP 5 M.IDModel,M.Model_Name, SUM(F.Quantity) AS TOTAL_QTY FROM DIM_MODEL M
INNER JOIN FACT_TRANSACTIONS F ON M.IDModel= F.IDModel 
WHERE YEAR(DATE) = 2008
GROUP BY M.IDModel, M.Model_Name
ORDER BY TOTAL_QTY DESC) AS T1 INNER JOIN
(SELECT TOP 5 M.IDModel,M.Model_Name, SUM(F.Quantity) AS TOTAL_QTY FROM DIM_MODEL M
INNER JOIN FACT_TRANSACTIONS F ON M.IDModel= F.IDModel 
WHERE YEAR(DATE) = 2009
GROUP BY M.IDModel, M.Model_Name
ORDER BY TOTAL_QTY DESC) AS T2 ON T1.MODEL_NAME= T2.MODEL_NAME INNER JOIN
(SELECT TOP 5 M.IDModel,M.Model_Name, SUM(F.Quantity) AS TOTAL_QTY FROM DIM_MODEL M
INNER JOIN FACT_TRANSACTIONS F ON M.IDModel= F.IDModel 
WHERE YEAR(DATE) = 2010
GROUP BY M.IDModel, M.Model_Name
ORDER BY TOTAL_QTY DESC) AS T3 ON T2.MODEL_NAME= T3.MODEL_NAME
	
















--Q7--END	
--Q8--BEGIN

SELECT * FROM (SELECT ROW_NUMBER () OVER (ORDER BY SUM (TOTALPRICE) DESC ) AS R,MA.Manufacturer_Name, SUM(TOTALPRICE) AS TOT_AMT,
YEAR(DATE) AS [YEAR] FROM FACT_TRANSACTIONS F
INNER JOIN DIM_MODEL M ON F.IDModel= M.IDModel
INNER JOIN DIM_MANUFACTURER MA ON M.IDManufacturer= MA.IDManufacturer
WHERE YEAR(DATE)= 2009
GROUP BY MA.Manufacturer_Name,YEAR(DATE)) AS T1
WHERE R = 2
UNION ALL
SELECT * FROM (SELECT ROW_NUMBER () OVER (ORDER BY SUM (TOTALPRICE) DESC ) AS R,MA.Manufacturer_Name, SUM(TOTALPRICE) AS TOT_AMT,
YEAR(DATE) AS [YEAR] FROM FACT_TRANSACTIONS F
INNER JOIN DIM_MODEL M ON F.IDModel= M.IDModel
INNER JOIN DIM_MANUFACTURER MA ON M.IDManufacturer= MA.IDManufacturer
WHERE YEAR(DATE)= 2010
GROUP BY MA.Manufacturer_Name,YEAR(DATE)) AS T2
WHERE R = 2



















--Q8--END
--Q9--BEGIN

SELECT Manufacturer_Name FROM (SELECT MA.Manufacturer_Name, sum(F.TotalPrice) as TOT_AMT FROM FACT_TRANSACTIONS AS F 
INNER JOIN DIM_MODEL AS M ON F.IDModel = M.IDModel
INNER JOIN DIM_MANUFACTURER AS MA ON M.IDManufacturer = MA.IDManufacturer
WHERE YEAR(F.DATE)= 2010
GROUP BY MA.Manufacturer_Name, YEAR(F.Date)) AS T1
EXCEPT
SELECT Manufacturer_Name FROM (SELECT MA.Manufacturer_Name, sum(F.TotalPrice) as TOT_AMT FROM FACT_TRANSACTIONS AS F 
INNER JOIN DIM_MODEL AS M ON F.IDModel = M.IDModel
INNER JOIN DIM_MANUFACTURER AS MA ON M.IDManufacturer = MA.IDManufacturer
WHERE YEAR(F.DATE)= 2009
GROUP BY MA.Manufacturer_Name, YEAR(F.Date)) AS T2



















--Q9--END

--Q10--BEGIN

	SELECT Tabl1.IDCustomer,Tabl1.Customer_Name , Tabl1.[Year],Tabl1.Avg_amt,Tabl1.Avg_Qty,case when Tabl2.[Year] is not null then
((Tabl1.Avg_amt-Tabl2.Avg_amt)/Tabl2.Avg_amt )* 100 
else NULL
end as 'YOY in Average Spend' from
(select C.IDcustomer,C.Customer_Name,AVG(F.TotalPrice) as Avg_amt ,AVG(F.Quantity) as Avg_Qty ,
YEAR(F.Date) as [Year] from DIM_CUSTOMER as c 
left join FACT_TRANSACTIONS as F on F.IDCustomer=C.IDCustomer 
where C.IDCustomer in (Select top 10 C.IDCustomer from DIM_CUSTOMER as c 
left join FACT_TRANSACTIONS as F on F.IDCustomer=C.IDCustomer 
group by C.IDCustomer 
order by Sum(F.TotalPrice) desc)
group by C.IDcustomer,C.Customer_Name,YEAR(F.Date)) as Tabl1 
left join 
(select C.IDcustomer,C.Customer_Name,AVG(F.TotalPrice) as Avg_amt ,AVG(F.Quantity) as Avg_Qty ,
YEAR(F.Date) as [Year] from DIM_CUSTOMER as c 
left join FACT_TRANSACTIONS as F on F.IDCustomer=C.IDCustomer 
where C.IDCustomer in (Select top 10 C.IDCustomer from DIM_CUSTOMER as c 
left join FACT_TRANSACTIONS as F on F.IDCustomer=C.IDCustomer 
group by C.IDCustomer 
order by Sum(F.TotalPrice) desc)
group by C.IDcustomer,C.Customer_Name,YEAR(F.Date)) as Tabl2 
on Tabl1.IDCustomer=Tabl2.IDCustomer and Tabl2.[Year]=Tabl1.[Year]-1;


















--Q10--END
	