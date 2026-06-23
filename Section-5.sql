--Find the highest revenue-generating album.
SELECT
	a.AlbumId ,
	a.Title ,
	SUM(il.UnitPrice * il.Quantity) AS RevenueByAlbum
FROM
	InvoiceLine il
INNER JOIN Track t ON
	il.TrackId = t.TrackId
INNER JOIN Album a ON
	t.AlbumId = a.AlbumId
GROUP BY
	a.AlbumId ,
	a.Title
ORDER BY
	RevenueByAlbum DESC
LIMIT 1


--Show total revenue generated per genre per year.
SELECT
	STRFTIME('%Y', i.InvoiceDate ) AS Year,
	g.GenreId ,
	g.Name ,
	SUM(il.Quantity * il.UnitPrice ) AS RevenuePerGenre
FROM
	Genre g
INNER JOIN Track t ON
	g.GenreId = t.GenreId
INNER JOIN InvoiceLine il ON
	t.TrackId = il.TrackId
INNER JOIN Invoice i ON
	il.InvoiceId = i.InvoiceId
GROUP BY
	STRFTIME('%Y', i.InvoiceDate ),
	g.GenreId ,
	g.Name
--Gemini addition
ORDER BY
	Year ASC,
	RevenuePerGenre DESC;


--Find the employee responsible for the highest revenue in each country.
WITH CountryCustEmployRevenue AS (
SELECT
	i.BillingCountry AS Country,
	e.EmployeeId AS EmployeeNum,
	e.FirstName || ' ' || e.LastName AS EmployeeName,
	c.CustomerId AS CustNum,
	SUM(i.Total) AS Sales,
	DENSE_RANK() OVER(PARTITION BY i.BillingCountry ORDER BY SUM(i.Total) DESC) AS Ranking
FROM
	Invoice i
INNER JOIN Customer c ON
	I.CustomerId = C.CustomerId
INNER JOIN Employee e ON
	C.SupportRepId = e.EmployeeId
GROUP BY
	i.BillingCountry,
    e.EmployeeId,
    e.FirstName,
    e.LastName)
SELECT
	Country,
--Logic trap use below
	EmployeeNum,
	EmployeeName,
	Sales
FROM
	CountryCustEmployRevenue
WHERE
	Ranking = 1
	
	
--Show each customer’s favorite genre.(Hint: genre purchased most frequently)
WITH CustomerAndGenre AS (
SELECT
	c.CustomerId AS CustNum,
	g.GenreId AS GenreNum,
	g.Name AS GenreName,
	SUM(il.Quantity) AS QuantityBought,
	DENSE_RANK() OVER(PARTITION BY c.CustomerId ORDER BY SUM(il.Quantity) DESC ) AS Rank
FROM
	Customer c
INNER JOIN Invoice i ON
	c.CustomerId = i.CustomerId
INNER JOIN InvoiceLine il ON
	i.InvoiceId = il.InvoiceId
INNER JOIN Track t ON
	il.TrackId = t.TrackId
INNER JOIN Genre g ON
	t.GenreId = g.GenreId
GROUP BY
	c.CustomerId ,
	g.GenreId ,
	g.Name)
SELECT
	CustNum,
	GenreNum,
	GenreName
FROM
	CustomerAndGenre
WHERE
	Rank = 1;


--Find artists whose tracks were purchased by customers from more than 10 countries.
SELECT
	a.ArtistId ,
	a.Name ,
	COUNT(DISTINCT i.BillingCountry ) AS SaleCountry
FROM
	Artist a
INNER JOIN Album a2 
ON
	a.ArtistId = a2.ArtistId
INNER JOIN Track t ON
	a2.AlbumId = t.AlbumId
INNER JOIN InvoiceLine il ON
	t.TrackId = il.TrackId
INNER JOIN Invoice i ON
	il.InvoiceId = i.InvoiceId
GROUP BY
	a.ArtistId ,
	a.Name
HAVING
	COUNT(DISTINCT i.BillingCountry ) > 10
	--Gemini addition
ORDER BY 
	SaleCountry DESC;


--Show the percentage contribution of each genre to total revenue.
SELECT
	g.GenreId ,
	g.Name ,
	SUM(il.Quantity * il.UnitPrice ) AS RevenuePerGenre,
	ROUND(((SUM(il.Quantity * il.UnitPrice ))/( SELECT SUM(il2.Quantity * il2.UnitPrice ) FROM InvoiceLine il2))* 100.0, 2) AS PercentContribution
FROM
	Genre g
INNER JOIN Track t ON
	g.GenreId = t.GenreId
INNER JOIN InvoiceLine il ON
	t.TrackId = il.TrackId
GROUP BY
	g.GenreId ,
	g.Name
	--can use CTE to calc revenue first and percentages next
	--can use OVER() on sum to find the grand total instead of a subquery