--Find customers who made more than 5 purchases.
/*select
	i.CustomerId ,
	COUNT(i.InvoiceId) as NumOfPurchases
from
	Invoice i
group by
	CustomerId
having
	NumOfPurchases > 5*/


--Show albums containing fewer than 5 tracks.
/*SELECT
	t.AlbumId ,
	COUNT(t.TrackId) as NumOfTracksPerAlbum
from
	Track t
group by
	t.AlbumId
having NumOfTracksPerAlbum<5;*/


--Find genres with average track length greater than 4 minutes.
/*select
	t.GenreId,
	round((avg(t.Milliseconds)/ 60000), 2) as TrackInMins
from
	Track t
group by
	t.GenreId
having
	avg(t.Milliseconds) > 240000;*/


--Display countries having more than 10 customers.
/*SELECT
	i.BillingCountry,
	count(distinct i.CustomerId) as TotalCustPerCountry
from
	Invoice i
group by
	i.BillingCountry
having
	count(distinct i.CustomerId) > 10;

SELECT
	Country,
	COUNT(CustomerId) AS TotalCustPerCountry
FROM
	Customer
GROUP BY
	Country
HAVING
	COUNT(CustomerId) > 10;*/


--Show playlists containing more than 50 tracks.
/*select
	pt.PlaylistId ,
	p.Name as PlaylistName,
	COUNT(pt.TrackId) as NumOfTracksInPlaylist
from
	PlaylistTrack pt
inner join playlist p on
	pt.PlaylistId = p.PlaylistId
GROUP BY
	pt.PlaylistId,
	p.Name
having
	COUNT(pt.TrackId) > 50*/


--Find artists who have released more than 3 albums.
select
	a.ArtistId ,
	ar.Name as ArtistName,
	Count(a.AlbumId) AS NumOfAlbumsPerArtist
from
	Album a
inner join Artist ar on
	a.ArtistId = ar.ArtistId
group By
	a.ArtistId,
	ar.Name
having
	Count(a.AlbumId) > 3;


--List customers whose average invoice total exceeds $8.
/*select
	i.CustomerId,
	c.firstName || ' ' || c.LastName as FullName,
	Round(AVG(i.Total), 2) as Average
from
	Invoice i
inner join Customer c on
	i.CustomerId = c.CustomerId
group by
	i.CustomerId,
	c.firstName,
	c.LastName
having
	AVG(i.Total) > 8;*/


--Find billing cities with total sales greater than their country’s average city sales.
select
	i.BillingCity ,
	sum(i.Total) as TotalSalesPerCity
from
	Invoice i
group by
	i.BillingCity
having
	sum(i.Total) > (
	select
		Round(avg(i2.Total), 2) as TotalSalesPerCountryPerCity
	from
		Invoice i2
	where
		i2.BillingCity = i.BillingCity
	group by
		i.BillingCity )

		
		
WITH CitySales AS (
    SELECT
        i.BillingCountry,
        i.BillingCity,
        SUM(i.Total) AS TotalSalesPerCity
    FROM Invoice i
    GROUP BY
        i.BillingCountry,
        i.BillingCity
)
SELECT
    cs.BillingCountry,
    cs.BillingCity,
    cs.TotalSalesPerCity
FROM CitySales cs
WHERE cs.TotalSalesPerCity > (
    SELECT
        AVG(cs2.TotalSalesPerCity)
    FROM CitySales cs2
    WHERE cs2.BillingCountry = cs.BillingCountry
);




WITH CitySales AS (
	-- Step 1: Get the total sales for each city
	SELECT
		BillingCountry,
		BillingCity,
		SUM(Total) AS TotalSalesPerCity
	FROM
		Invoice
	GROUP BY
		BillingCountry,
		BillingCity
),
CountryAverages AS (
	-- Step 2: Calculate the average of those city totals per country
	SELECT
		BillingCountry,
		BillingCity,
		TotalSalesPerCity,
		AVG(TotalSalesPerCity) OVER(PARTITION BY BillingCountry) AS AvgCitySalesPerCountry
	FROM
		CitySales
)
-- Step 3: Filter for cities beating their country's average
SELECT
	BillingCity,
	TotalSalesPerCity
FROM
	CountryAverages
WHERE
	TotalSalesPerCity > AvgCitySalesPerCountry;