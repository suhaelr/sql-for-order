/*All the data is an example */

/* query to get best seller product for male and female */

select CatagoryID, UnitsOnOrder
    from Products
    where (CatagoryID between 1 and 5 -- inclusive
		or CatagoryID = 8
        or FullName like '%Maximo%') --contoh nama produk
		and UnitsOnOrder NOT in (1000, 1400)
	order by FullName DESC;

/* query to get customer that spends the most money */

SELECT Order Details.OrderID, Customers.ContactName, Order Details.Quantity
FROM Orders
INNER JOIN Customers ON Orders.CustomerID=Customers.CustomerID;

/* query to show number of transactions for every 2 hours. */

DECLARE @users TABLE(UserID INT, creationDate DATETIME)
INSERT @users
        ( UserID, creationDate )
VALUES  ( 1, '2014-10-08 14:33:20.763'),
        (  2, '2014-10-09 04:24:14.283'),
         ( 3, '2014-10-10 18:34:26.260')


;WITH u1st AS (  -- determine the FIRST time the user appears
    SELECT UserID, MIN(creationDate) AS creationDate
    FROM @users
    GROUP BY UserID
),  hrs AS ( -- recursive CTE of start hours
    SELECT DISTINCT CAST(CAST(creationDate AS DATE) AS DATETIME) AS [StartHour] 
    FROM @users AS u
    UNION ALL
    SELECT DATEADD(HOUR, 2, [StartHour]) AS [StartHour] FROM hrs 
    WHERE DATEPART(HOUR,[StartHour]) < 23
), uGrp AS ( -- your data grouped by start hour
    SELECT -- note that DATETIMEFROMPARTS is only in SQL Server 2012 and later
        DATETIMEFROMPARTS(YEAR(CreationDate),MONTH(CreationDate), 
                     DAY(creationDate),DATEPART(HOUR, creationDate),0,0,0) 
                     AS StartHour, 
        COUNT(2) AS UserCount  FROM u1st AS u
    GROUP BY YEAR(creationDate), MONTH(creationDate), DAY(creationDate), 
             DATEPART(HOUR, creationDate)
)
SELECT hrs.StartHour, ISNULL(uGrp.UserCount, 0) AS UserCount 
FROM hrs LEFT JOIN uGrp ON hrs.StartHour = uGrp.StartHour
ORDER BY hrs.StartHour

/* NB - DATETIMEFROMPARTS is only in SQL SERVER 2012 and greater. If you are using an earlier version of SQL SERVER you could have */

WITH u1st AS ( -- determine the FIRST time the user appears
    SELECT UserID, MIN(creationDate) AS creationDate
    FROM @users
    GROUP BY UserID
),  hrs AS ( -- recursive CTE of start hours
    SELECT DISTINCT CAST(CAST(creationDate AS DATE) AS DATETIME) AS [StartHour] 
    FROM @users AS u
    UNION ALL
    SELECT DATEADD(HOUR, 2, [StartHour]) AS [StartHour] FROM hrs 
    WHERE DATEPART(HOUR,[StartHour]) < 23
), uGrp AS ( -- your data grouped by start hour
    SELECT -- note that DATETIMEFROMPARTS is only in SQL Server 2012 and later
        CAST(CAST(YEAR(creationDate) AS CHAR(4)) + '-'
             + RIGHT('0' + CAST(MONTH(creationDate) AS CHAR(2)), 2) + '-'
             + RIGHT('0' + CAST(DAY(creationDate) AS CHAR(2)), 2) + ' '
             + RIGHT('0' + CAST(DATEPART(HOUR, creationDate) AS CHAR(2)), 2) 
             + ':00:00.000'
             AS DATETIME) AS StartHour,
        COUNT(2) AS UserCount  FROM u1st AS u
    GROUP BY YEAR(creationDate), MONTH(creationDate), DAY(creationDate), 
             DATEPART(HOUR,creationDate)
)
SELECT hrs.StartHour, ISNULL(uGrp.UserCount, 0) AS UserCount 
FROM hrs LEFT JOIN uGrp ON hrs.StartHour = uGrp.StartHour
ORDER BY hrs.StartHour

