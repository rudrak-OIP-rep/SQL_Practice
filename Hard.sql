/*41SELECT
	c.CustomerId,
	c.FirstName,
	c.LastName,
	sum(i.Total) as AmountSpentByCustomer
FROM
	Customer c
inner join Invoice i on
	c.CustomerId = i.CustomerId
group by
	c.CustomerId,
	c.FirstName,
	c.LastName
order by
	AmountSpentByCustomer desc
limit 3*/


/*42SELECT
	c.CustomerId,
	c.FirstName,
	c.LastName,
	count(i.InvoiceId) as NumberOfInvoicesPerCustomer,
	sum(i.Total) as AmountSpentByCustomer,
	Dense_Rank() OVER(order by sum(i.Total) desc) as Rank
FROM
	Customer c
inner join Invoice i on
	c.CustomerId = i.CustomerId
group by
	c.CustomerId,
	c.FirstName,
	c.LastName;*/


/*43SELECT
	g.Name AS GenreName,
	SUM(il.Quantity) AS TotalQuantitySold
FROM
	Genre g
INNER JOIN Track t ON
	g.GenreId = t.GenreId
INNER JOIN InvoiceLine il ON
	t.TrackId = il.TrackId
GROUP BY
	g.GenreId,
	g.Name
ORDER BY
	TotalQuantitySold DESC
LIMIT 1;*/


/*44SELECT
	a.ArtistId,
	a.Name AS ArtistName,
	sum( il.UnitPrice * il.Quantity ) as TotalRevenue
from
	Artist a
inner join Album a2 on
	a.ArtistId = a2.ArtistId
inner join Track t on
	a2.AlbumId = t.AlbumId
inner join InvoiceLine il ON
	t.TrackId = il.TrackId
GROUP BY
	a.ArtistId,
	a.Name
order By
	TotalRevenue desc
Limit 1;*/


/*45SELECT
	e.EmployeeId,
	e.FirstName || ' ' || e.LastName as EmployeeFullName,
	Coalesce(SUM(i.Total),0) as RevenuePerEmployee
from
	Employee e
left join Customer c on
	e.EmployeeId = c.SupportRepId
left join Invoice i on
	c.CustomerId = i.CustomerId
group by
	e.EmployeeId, e.FirstName, e.LastName
order by
	RevenuePerEmployee desc;*/


/*46with RankedTracks as ( 
SELECT
	i.BillingCountry,
	t.TrackId,
	t.Name as TrackName ,
	SUM(il.Quantity) as TotalQuantitySold,
	Dense_RANK() OVER(PARTITION BY i.BillingCountry ORDER BY SUM(il.Quantity) DESC) AS Rank
from
	Track t
inner join InvoiceLine il on
	t.TrackId = il.TrackId
inner join Invoice i on
	il.InvoiceId = i.InvoiceId
group by
	i.BillingCountry,
	t.TrackId,
	t.Name
)
SELECT
	BillingCountry,
	TrackId,
	TrackName,
	TotalQuantitySold
FROM
	RankedTracks
WHERE
	Rank = 1;*/


/*47SELECT
	i.BillingCountry,
	SUM(i.Total) as total,
	(
		SUM(i.Total) /( SELECT sum(i1.total) from invoice i1) 
	) * 100.0 as ContributionPerCountry
from Invoice i
group by
	i.BillingCountry ;


SELECT
	i.BillingCountry,
	SUM(i.Total) as TotalSales,
	(SUM(i.Total) / SUM(SUM(i.Total)) OVER()) * 100.0 as ContributionPerCountry
FROM 
	Invoice i 
GROUP BY 
	i.BillingCountry
ORDER BY
	ContributionPerCountry DESC;*/


/*48WITH CustomerSpending AS (
    SELECT
        c.CustomerId,
        c.FirstName,
        c.LastName,
        c.Country,
        SUM(i.Total) AS TotalSpent
    FROM Customer c
    INNER JOIN Invoice i
        ON c.CustomerId = i.CustomerId
    GROUP BY
        c.CustomerId,
        c.FirstName,
        c.LastName,
        c.Country
)
SELECT
    cs.CustomerId,
    cs.FirstName,
    cs.LastName,
    cs.Country,
    cs.TotalSpent
FROM CustomerSpending cs
WHERE cs.TotalSpent > (
    SELECT AVG(cs2.TotalSpent)
    FROM CustomerSpending cs2
    WHERE cs2.Country = cs.Country
);*/


/*56SELECT
	*
from
	Track t
WHERE
	t.TrackId NOT in (
	SELECT
		il.TrackId
	from
		InvoiceLine il);*/


/*59SELECT
	e.EmployeeId,
	e.FirstName,
	e.LastName
FROM
	Employee e
WHERE
	e.EmployeeId not in (
	SELECT
		e2.ReportsTo
	from
		Employee e2 
		where e2.ReportsTo is not null)*/


/*60with CountPerCountryPerYear as (
SELECT
	STRFTIME('%Y', i.invoiceDate ) as BillingYear,
	i.billingCountry as Country,
	count(i.BillingCountry) ModePerYear
from
	Invoice i
group by
	STRFTIME('%Y', i.invoiceDate ),
	i.billingCountry
)
select
	BillingYear,
	Country,
	Max(ModePerYear)
from
	CountPerCountryPerYear
	Group by BillingYear
	
	
-- Step 1: Count invoices per country per year, and assign a rank!
WITH RankedCountries AS (
	SELECT
		STRFTIME('%Y', i.InvoiceDate) AS BillingYear,
		i.BillingCountry AS Country,
		COUNT(i.InvoiceId) AS InvoiceCount,
		RANK() OVER(PARTITION BY STRFTIME('%Y', i.InvoiceDate) ORDER BY COUNT(i.InvoiceId) DESC) AS Rank
	FROM
		Invoice i
	GROUP BY
		STRFTIME('%Y', i.InvoiceDate),
		i.BillingCountry
)
-- Step 2: Only pull the ones that ranked #1
SELECT
	BillingYear,
	Country,
	InvoiceCount
FROM
	RankedCountries
WHERE
	Rank = 1;	*/


/*55SELECT
	i.InvoiceDate as SaleDay,
	Sum(i.Total) as TotalSalePerSaleDay,
	SUM(SUM(Total)) OVER (
ORDER BY
	InvoiceDate
    ) AS RunningTotalSales
FROM
	Invoice i
group by
	SaleDay */


/*49select
	t.AlbumId,
	t.TrackId,
	Max(t.Milliseconds) as TrackLength
from
	Track t
group by
	AlbumId

-- Step 1: Rank the tracks by length within each album
WITH RankedTracks AS (
	SELECT
		t.AlbumId,
		t.TrackId,
		t.Milliseconds AS TrackLength,
		RANK() OVER(PARTITION BY t.AlbumId ORDER BY t.Milliseconds DESC) AS Rank
	FROM
		Track t
)
-- Step 2: Filter for only the longest tracks (Rank 1)
SELECT
	AlbumId,
	TrackId,
	TrackLength
FROM
	RankedTracks
WHERE
	Rank = 1;*/


/*50SELECT
    a.AlbumId,
    a.Title AS AlbumName
FROM Album a
WHERE NOT EXISTS (
    SELECT 1
    FROM Track t
    WHERE t.AlbumId = a.AlbumId
      AND t.UnitPrice <= 0.99
);

SELECT
	a.AlbumId,
	a.Title as AlbumName
FROM
	Album a
INNER JOIN Track t ON
	a.AlbumId = t.AlbumId
GROUP BY
	a.AlbumId,
	a.Title
HAVING
	MIN(t.UnitPrice) > 0.99;*/

/*51with CustomersYearNumOfInvoices as
	(
SELECT
		c.CustomerId as cust ,
		STRFTIME('%Y', i.invoiceDate ) as YearOfPurchase,
		Row_number() over(Partition by c.CustomerId Order by c.CustomerId) as NumOfPurchaseYears
from
		Customer c
inner join Invoice i on
		c.CustomerId = i.CustomerId
group By
		c.CustomerId ,
		STRFTIME('%Y', i.invoiceDate )
)
SELECT cust, Count(NumOfPurchaseYears) from CustomersYearNumOfInvoices
Group By cust
having Count(NumOfPurchaseYears) > 1;*/

/*52SELECT MonthOfPurchase, MAX(TotalSalesPerMonth) from
(
SELECT SUBSTR(i.InvoiceDate, 6,2) as MonthOfPurchase, Sum(i.Total) as TotalSalesPerMonth from Invoice i 
group by SUBSTR(i.InvoiceDate, 6,2)
)

SELECT 
	SUBSTR(i.InvoiceDate, 6, 2) as MonthOfPurchase, 
	SUM(i.Total) as TotalSalesPerMonth 
FROM 
	Invoice i 
GROUP BY 
	MonthOfPurchase
ORDER BY 
	TotalSalesPerMonth DESC
LIMIT 1;*/

/*53with TracksAndGenres AS
(
select
	i.CustomerId as CustNum,
	t.GenreId, 
	row_number() over(PARTITION BY i.CustomerId order by i.CustomerId) as NumOfGenres
from
	Invoice i
inner join InvoiceLine il on
	i.InvoiceId = il.InvoiceId
inner join Track t on
	il.TrackId = t.TrackId
Group By
	i.CustomerId ,
	t.GenreId
)
select
	CustNum
from
	TracksAndGenres
where
	NumOfGenres = (
	select
		Max(GenreId)
	from
		genre)


SELECT
    i.CustomerId
FROM Invoice i
INNER JOIN InvoiceLine il
    ON i.InvoiceId = il.InvoiceId
INNER JOIN Track t
    ON il.TrackId = t.TrackId
GROUP BY
    i.CustomerId
HAVING
    COUNT(DISTINCT t.GenreId) = (
        SELECT COUNT(*)
        FROM Genre
    );*/

/*54with DupcitiesTbl as (
select
	i.InvoiceId ,
	i.CustomerId ,
	i.BillingCity dupCity,
	Row_number() OVER(partition by i.BillingCity order by BillingCity) as DupCitiesNum
from
	Invoice i
order by
	i.BillingCity 
)
SELECT dupCity from DupcitiesTbl
where DupCitiesNum  = 2;

SELECT
	i.BillingCity
FROM
	Invoice i
GROUP BY
	i.BillingCity
HAVING
	COUNT(i.InvoiceId) > 1;*/


/*57select
	p.PlaylistId,
	count(distinct g.GenreId ) as GenresPerPlaylist
from
	Playlist p
inner join PlaylistTrack pt on
	p.PlaylistId = pt.PlaylistId
inner join Track t on
	pt.TrackId = t.TrackId
inner join Genre g on
	t.GenreId = g.GenreId
group by
	p.PlaylistId
having
	GenresPerPlaylist > 3*/

/*58(GPT)WITH CustomerYearlySales AS (
    SELECT
        c.CustomerId,
        STRFTIME('%Y', i.InvoiceDate) AS PurchaseYear,
        SUM(i.Total) AS TotalSpent
    FROM Customer c
    INNER JOIN Invoice i
        ON c.CustomerId = i.CustomerId
    GROUP BY
        c.CustomerId,
        STRFTIME('%Y', i.InvoiceDate)
),
YearComparison AS (
    SELECT
        CustomerId,
        PurchaseYear,
        TotalSpent,
        LAG(TotalSpent) OVER (
            PARTITION BY CustomerId
            ORDER BY PurchaseYear
        ) AS PreviousYearSpent
    FROM CustomerYearlySales
)
SELECT
    CustomerId,
    PurchaseYear,
    TotalSpent,
    PreviousYearSpent
FROM YearComparison
WHERE TotalSpent > PreviousYearSpent;*/

/*58(Gemini)WITH YearlySpend AS (
	-- Step 1: Calculate total spend per customer per year
	SELECT
		CustomerId,
		STRFTIME('%Y', InvoiceDate) AS SpendYear,
		SUM(Total) AS TotalSpend
	FROM
		Invoice
	GROUP BY
		CustomerId,
		STRFTIME('%Y', InvoiceDate)
),
YearOverYear AS (
	-- Step 2: Pull the previous year's spend using LAG()
	SELECT
		CustomerId,
		SpendYear,
		TotalSpend,
		LAG(TotalSpend) OVER(PARTITION BY CustomerId ORDER BY SpendYear) AS PreviousYearSpend
	FROM
		YearlySpend
)
-- Step 3: Filter for the instances where spend went up
SELECT
	CustomerId,
	SpendYear,
	TotalSpend,
	PreviousYearSpend
FROM
	YearOverYear
WHERE
	TotalSpend > PreviousYearSpend;