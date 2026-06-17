--Rank tracks by length within each album.
SELECT
	a.AlbumId ,
	a.Title ,
	t.TrackId ,
	t.Milliseconds,
	ROW_NUMBER() OVER(PARTITION BY a.AlbumId ORDER BY t.Milliseconds DESC) AS Ranking
FROM
	Album a
INNER JOIN Track t ON
	a.AlbumId = t.AlbumId
	
	
--Find the second-longest track in each album.
WITH AlbumTracksRank AS (
SELECT
	a.AlbumId AS AlbumNum,
	t.TrackId AS TrackNum,
	t.Milliseconds AS Length,
	DENSE_RANK() OVER(PARTITION BY a.AlbumId ORDER BY t.Milliseconds DESC) AS Ranking
FROM
	Album a
INNER JOIN Track t ON
	a.AlbumId = t.AlbumId
)
SELECT
	AlbumNum,
	TrackNum,
	Length
FROM
	AlbumTracksRank
WHERE
	Ranking = 2
	
	
--Show the top 3 highest-spending customers per country.
WITH CountryCustomerSpent AS (
SELECT
	c.Country AS Country,
	c.CustomerId AS CustNum,
	c.FirstName || ' ' || c.LastName AS FullName,
	SUM(i.Total) AS Spent,
	DENSE_RANK() OVER(PARTITION BY c.Country ORDER BY SUM(i.Total) DESC ) AS Rankings
FROM
	Customer c
INNER JOIN Invoice i ON
	c.CustomerId = i.CustomerId
GROUP BY
	c.Country,
	c.CustomerId,
	c.FirstName,
    c.LastName
)
SELECT
	Country,
	CustNum,
	FullName,
	Spent,
	Rankings
FROM
	CountryCustomerSpent
WHERE
	Rankings <= 3;


--Display running yearly sales totals.
SELECT
	STRFTIME('%Y',i.InvoiceDate) AS Year,
	SUM(i.Total) AS SalesInAYear,
	SUM(SUM(i.Total)) OVER(ORDER BY STRFTIME('%Y',i.InvoiceDate)) AS RunningSales
FROM
	Invoice i
GROUP BY Year


--Find each customer’s previous purchase amount.
SELECT
	i.InvoiceDate ,
	i.CustomerId ,
	i.Total,
	COALESCE(LAG(i.Total , 1) OVER(PARTITION BY i.CustomerId ORDER BY i.InvoiceDate ), 0) AS PrevPurchaseAmt
FROM
	Invoice i
ORDER BY
	i.CustomerId ,
	i.InvoiceDate
	
	
--Show sales growth percentage year-over-year.
SELECT
	STRFTIME('%Y', i.InvoiceDate ) AS Year,
	SUM(i.Total) AS SalesInAYear,
	ROUND(((SUM(i.Total) - LAG(SUM(i.Total), 1) OVER(ORDER BY STRFTIME('%Y', i.InvoiceDate ) ASC))* 100) / LAG(SUM(i.Total), 1) OVER(ORDER BY STRFTIME('%Y', i.InvoiceDate ) ASC), 2) AS SalesPercentGrowth
FROM
	Invoice i
GROUP BY
	STRFTIME('%Y', i.InvoiceDate )


--Find the first invoice made by each customer.
WITH CustomerInvoiceRanking AS (
SELECT
	c.CustomerId AS CustNum,
	c.FirstName || ' ' || c.LastName AS FullName,
	i.InvoiceId AS InvoiceNum,
	i.InvoiceDate AS InvoiceDate,
	i.Total AS Amt,
	DENSE_RANK() OVER(PARTITION BY c.CustomerId ORDER BY i.InvoiceDate ASC) AS Ranking
FROM
	Invoice i
INNER JOIN Customer c ON
	i.CustomerId = c.CustomerId
)
SELECT
	CustNum,
	FullName,
	InvoiceNum,
	Amt
FROM
	CustomerInvoiceRanking
WHERE
	Ranking = 1
	
	
--Find customers whose purchases continuously increased over time.
--GPT
WITH CustomerYearAmount AS (
SELECT
	c.CustomerId as CustNum,
	STRFTIME('%Y', i.InvoiceDate) AS Year,
	SUM(i.Total) AS TotalSales,
	LAG(SUM(i.Total) , 1) OVER(PARTITION BY c.CustomerId ORDER BY STRFTIME('%Y', i.InvoiceDate) ) AS PrevPurchaseAmt
FROM
	Customer c
INNER JOIN Invoice i ON
	c.CustomerId = i.CustomerId
GROUP BY
	c.CustomerId ,
	STRFTIME('%Y', i.InvoiceDate)
	)
SELECT
    CustNum
FROM CustomerYearAmount
GROUP BY CustNum
HAVING SUM(
    CASE
        WHEN PrevPurchaseAmt IS NOT NULL
             AND TotalSales <= PrevPurchaseAmt
        THEN 1
        ELSE 0
    END
) = 0;


--Gemini
WITH CustomerYearAmount AS (
	SELECT
		c.CustomerId AS CustNum,
		STRFTIME('%Y', i.InvoiceDate) AS Year,
		SUM(i.Total) AS TotalSales,
		LAG(SUM(i.Total), 1) OVER(PARTITION BY c.CustomerId ORDER BY STRFTIME('%Y', i.InvoiceDate)) AS PrevPurchaseAmt
	FROM
		Customer c
	INNER JOIN Invoice i ON
		c.CustomerId = i.CustomerId
	GROUP BY
		c.CustomerId,
		STRFTIME('%Y', i.InvoiceDate)
	-- Removed the trailing ORDER BY here!
)
SELECT
	CustNum
FROM
	CustomerYearAmount
GROUP BY
	CustNum
HAVING 
	-- Check 1: Did they ever drop or stay flat? (Must be 0 rule-breakers)
	SUM(CASE WHEN TotalSales <= PrevPurchaseAmt THEN 1 ELSE 0 END) = 0
	-- Check 2: Make sure they actually have a history (More than 1 year of data)
	AND COUNT(Year) > 1;


--Display the difference between each invoice and the previous invoice for the same customer.
SELECT
	c.CustomerId ,
	c.FirstName || ' ' || c.LastName AS FullName,
	i.InvoiceDate,
	i.Total,
	i.Total - LAG(i.Total) OVER(PARTITION BY c.CustomerId ORDER BY i.InvoiceDate, i.InvoiceId) AS Difference
FROM
	Invoice i
INNER JOIN Customer c ON
	i.CustomerId = c.CustomerId
ORDER BY
    c.CustomerId,
    i.InvoiceDate;


--Show the most expensive track in each genre.
WITH GenreTrackRank AS (
SELECT
	g.GenreId AS GenreNum,
	g.Name AS GenreName,
	t.TrackId AS TracNum,
	t.Name AS TrackName,
	t.UnitPrice AS Price,
	DENSE_RANK() OVER(PARTITION BY g.GenreId ORDER BY t.UnitPrice DESC) AS Ranking
FROM
	Track t
INNER JOIN Genre g ON
	t.GenreId = g.GenreId
)
SELECT
	GenreNum,
	GenreName,
	TracNum,
	TrackName,
	Price
FROM
	GenreTrackRank
WHERE
	Ranking = 1
	
	
--Find the top-selling track within each country. No CTE
SELECT
	Country,
	TrackNum,
	QtySold
FROM
	(
	SELECT
		i.BillingCountry AS Country,
		il.TrackId AS TrackNum,
		SUM(il.Quantity) AS QtySold,
		DENSE_RANK() OVER(PARTITION BY i.BillingCountry ORDER BY SUM(il.Quantity) DESC) AS Ranking
	FROM
		InvoiceLine il
	INNER JOIN Invoice i ON
		il.InvoiceId = i.InvoiceId
	GROUP BY
		i.BillingCountry ,
		il.TrackId) AS RankedTracks
WHERE
	Ranking = 1


