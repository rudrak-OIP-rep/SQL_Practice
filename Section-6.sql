--Find customers who purchased tracks in consecutive years.
WITH CustAndYears AS (
SELECT
	c.CustomerId AS CustNum,
	CAST(STRFTIME('%Y', i.InvoiceDate ) AS INTEGER) AS CurrPurchaseYear,
	LAG(CAST(STRFTIME('%Y', i.InvoiceDate ) AS INTEGER)) OVER(PARTITION BY c.CustomerId ORDER BY CAST(STRFTIME('%Y', i.InvoiceDate ) AS INTEGER)) AS PrevPurchaseYear
FROM
	Customer c
INNER JOIN Invoice i ON
	c.CustomerId = i.CustomerId
GROUP BY
	c.CustomerId,
	STRFTIME('%Y', i.InvoiceDate )
)
SELECT DISTINCT
	CustNum
FROM
	CustAndYears
WHERE
	 CurrPurchaseYear = PrevPurchaseYear + 1


--Identify the longest gap between purchases for each customer.
WITH CustAndYears AS (
SELECT
	c.CustomerId AS CustNum,
	CAST(STRFTIME('%Y', i.InvoiceDate ) AS INTEGER) AS CurrPurchaseYear,
	LAG(CAST(STRFTIME('%Y', i.InvoiceDate ) AS INTEGER)) OVER(PARTITION BY c.CustomerId ORDER BY CAST(STRFTIME('%Y', i.InvoiceDate ) AS INTEGER)) AS PrevPurchaseYear
FROM
	Customer c
INNER JOIN Invoice i ON
	c.CustomerId = i.CustomerId
GROUP BY
	c.CustomerId,
	STRFTIME('%Y', i.InvoiceDate )
)
SELECT
	CustNum, CurrPurchaseYear, PrevPurchaseYear, MAX(CurrPurchaseYear - PrevPurchaseYear) AS LongestGap
FROM
	CustAndYears
WHERE PrevPurchaseYear IS NOT NULL
GROUP BY CustNum

--Gemini longest gap in days
WITH CustomerGaps AS (
	SELECT
		c.CustomerId AS CustNum,
		i.InvoiceDate AS CurrPurchaseDate,
		LAG(i.InvoiceDate) OVER(PARTITION BY c.CustomerId ORDER BY i.InvoiceDate) AS PrevPurchaseDate
	FROM
		Customer c
	INNER JOIN Invoice i ON
		c.CustomerId = i.CustomerId
)
SELECT
	CustNum,
	-- JULIANDAY converts the date to pure days so we can do strict math!
	MAX(CAST(JULIANDAY(CurrPurchaseDate) - JULIANDAY(PrevPurchaseDate) AS INTEGER)) AS LongestGapInDays
FROM
	CustomerGaps
WHERE 
	-- We filter out the first purchase because you can't have a gap before your first receipt!
	PrevPurchaseDate IS NOT NULL
GROUP BY
	CustNum
ORDER BY
	CustNum;


--Find customers who bought all tracks from a particular artist.
SELECT
	c.CustomerId AS CustNum,
	c.FirstName || ' ' || c.LastName AS FullName,
	a.ArtistId AS ArtistNum,
	a2.Name AS ArtistName,
	COUNT(DISTINCT t.TrackId) AS NumOfTracksPurchased
FROM
	Customer c
INNER JOIN Invoice i ON
	c.CustomerId = i.CustomerId
INNER JOIN InvoiceLine il ON
	i.InvoiceId = il.InvoiceId
INNER JOIN Track t ON
	il.TrackId = t.TrackId
INNER JOIN Album a ON
	t.AlbumId = a.AlbumId
INNER JOIN Artist a2 ON
	a.ArtistId = a2.ArtistId
GROUP BY
	c.CustomerId,
	c.FirstName,
	c.LastName,
	a.ArtistId,
	a2.Name
HAVING
	COUNT(DISTINCT t.TrackId) = (
	SELECT COUNT(t2.TrackId )
	FROM
		Album a3
	INNER JOIN Track t2 ON
		a3.AlbumId = t2.AlbumId
	WHERE a3.ArtistId = a.ArtistId)
	--distinct in count should be added as some customers can buy a same track multiple times


--Show genres whose sales are consistently increasing year-over-year.
WITH GenreYearSales AS (
SELECT
	g.GenreId AS GenreNum,
	g.Name AS GenreName,
	STRFTIME('%Y', i.InvoiceDate) AS SaleYear,
	SUM(il.Quantity * il.UnitPrice ) AS CurrYearSales,
	LAG(SUM(il.Quantity * il.UnitPrice )) OVER(PARTITION BY g.GenreId ORDER BY STRFTIME('%Y', i.InvoiceDate)) AS PrevYearSales
FROM
	Genre g
INNER JOIN Track t ON
	g.GenreId = t.GenreId
INNER JOIN InvoiceLine il ON
	t.TrackId = il.TrackId
INNER JOIN Invoice i ON
	il.InvoiceId = i.InvoiceId
GROUP BY
	g.GenreId ,
	g.Name ,
	STRFTIME('%Y', i.InvoiceDate)
)
SELECT
	GenreNum,
	GenreName
FROM
	GenreYearSales
GROUP BY
	GenreNum,
	GenreName
HAVING
	SUM( 
	CASE WHEN PrevYearSales IS NOT NULL AND CurrYearSales <= PrevYearSales THEN 1
	ELSE 0
	END ) = 0


--Find the month contributing the highest percentage to yearly sales.
WITH YearMonthTotals AS (
SELECT
	STRFTIME('%Y', i.InvoiceDate ) AS SaleYear,
	STRFTIME('%m', i.InvoiceDate ) AS SaleMonth,
	SUM(i.Total) AS ContibutionPerMonth,
	SUM(SUM(i.Total)) OVER(PARTITION BY STRFTIME('%Y', i.InvoiceDate )) AS TotalSalesInAYear
	--ROUND((SUM(i.Total ) / SUM(SUM(i.Total )) OVER())* 100.0, 2) AS PercentContibutionPerMonth
FROM
	Invoice i
GROUP BY
	STRFTIME('%Y', i.InvoiceDate ),
	STRFTIME('%m', i.InvoiceDate )
),
YearMonthTotalsRank AS (
SELECT
	SaleYear,
	SaleMonth,
	ROUND((ContibutionPerMonth / TotalSalesInAYear)* 100.0, 2) AS PercentPerMonthPerYear,
	DENSE_RANK() OVER (PARTITION BY SaleYear ORDER BY (ContibutionPerMonth / TotalSalesInAYear)* 100.0 DESC) AS Ranking
FROM
	YearMonthTotals
)
SELECT SaleYear, SaleMonth, PercentPerMonthPerYear
FROM YearMonthTotalsRank
WHERE Ranking = 1


--Find the top-selling artist for each year.
WITH YearArtistSales AS (
SELECT
	STRFTIME('%Y', i.InvoiceDate ) AS SaleYear,
	a2.ArtistId AS ArtistNum,
	a2.Name AS ArtistName,
	SUM(il.Quantity * il.UnitPrice ) AS SalesTotal,
	DENSE_RANK() OVER(PARTITION BY STRFTIME('%Y', i.InvoiceDate ) ORDER BY SUM(il.Quantity * il.UnitPrice ) DESC) AS Ranking
FROM
	Invoice i
INNER JOIN InvoiceLine il ON
	i.InvoiceId = il.InvoiceId
INNER JOIN Track t ON
	il.TrackId = t.TrackId
INNER JOIN Album a ON
	t.AlbumId = a.AlbumId
INNER JOIN Artist a2 ON
	a.ArtistId = a2.ArtistId
GROUP BY
	STRFTIME('%Y', i.InvoiceDate ),
	a2.ArtistId,
	a2.Name
)
SELECT
	SaleYear,
	ArtistNum,
	ArtistName,
	SalesTotal
FROM
	YearArtistSales
WHERE
	Ranking = 1


--Show customers whose latest purchase exceeded their average purchase amount.
WITH CustomersLatestInvoice AS (
SELECT
	i.CustomerId AS CustNum,
	i.InvoiceDate AS InvoiceDate,
	i.Total AS Amount,
	ROUND(AVG(i.Total) OVER(PARTITION BY i.CustomerId), 2) AS AvgPerCust,
	ROW_NUMBER() OVER(PARTITION BY i.CustomerId ORDER BY i.InvoiceDate DESC, i.InvoiceId DESC ) AS Ranking
FROM
	Invoice i
)
SELECT
	CustNum,
	c.FirstName || ' ' || c.LastName AS FullName
FROM
	CustomersLatestInvoice
INNER JOIN Customer c ON
	CustomersLatestInvoice.CustNum = c.CustomerId
WHERE
	Amount > AvgPerCust
	AND Ranking = 1


--Find tracks purchased by exactly one customer.
SELECT
	il.TrackId AS TrackNum,
	t.Name AS TrackName,
	COUNT( DISTINCT i.CustomerId) AS NumOfCustomes
FROM
	Invoice i
INNER JOIN InvoiceLine il ON
	i.InvoiceId = il.InvoiceId
INNER JOIN Track t ON
	il.TrackId = t.TrackId
GROUP BY
	il.TrackId,
	t.Name
HAVING
	NumOfCustomes = 1


--Show the most common genre purchased in each country.
WITH CountryGenreCount AS (
SELECT
	i.BillingCountry AS Country,
	g.GenreId AS GenreNum,
	g.Name AS GenreName,
	SUM(il.Quantity) AS NumOfGenres,
	DENSE_RANK() OVER(PARTITION BY i.BillingCountry ORDER BY SUM(il.Quantity) DESC) AS Ranking
FROM
	Invoice i
INNER JOIN InvoiceLine il ON
	i.InvoiceId = il.InvoiceId
INNER JOIN Track t ON
	il.TrackId = t.TrackId
INNER JOIN Genre g ON
	t.GenreId = g.GenreId
GROUP BY
	i.BillingCountry ,
	g.GenreId ,
	g.Name
)
SELECT
	Country,
	GenreNum,
	GenreName,
	NumOfGenres
FROM
	CountryGenreCount
WHERE
	Ranking = 1;


--Find customers who have purchased from every media type and every genre.
SELECT
	c.CustomerId ,
	c.FirstName || ' ' || c.LastName AS CustomerFullName,
	COUNT(DISTINCT t.MediaTypeId) AS NumOfMediaType ,
	COUNT(DISTINCT t.GenreId) AS NumOfGenre
FROM
	Customer c
INNER JOIN Invoice i ON
	c.CustomerId = i.CustomerId
INNER JOIN InvoiceLine il ON
	i.InvoiceId = il.InvoiceId
INNER JOIN Track t ON
	il.TrackId = t.TrackId
GROUP BY
	c.CustomerId,
	c.FirstName,
	c.LastName
HAVING
	COUNT(DISTINCT t.MediaTypeId) = (
	SELECT
		COUNT(*)
	FROM
		MediaType mt )
	AND
	COUNT(DISTINCT t.GenreId) = (
	SELECT
		COUNT(*)
	FROM
		Genre g )