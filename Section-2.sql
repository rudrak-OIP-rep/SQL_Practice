--Find tracks priced higher than the most expensive Rock track.
select
	t.trackId,
	t.Name AS TrackName,
	t.UnitPrice
from
	Track t
where
	t.UnitPrice > (
	select
		Max(t2.UnitPrice)
	from
		track t2
	inner Join Genre g on
		t2.GenreId = g.GenreId
	where
		g.name = 'Rock')


--Show customers whose spending is above the global average customer spending.
select
	i.CustomerId,
	c.FirstName || ' ' || c.LastName as FullName
from
	Invoice i
inner join customer c on
	i.CustomerId = c.CustomerId
group by
	i.CustomerId,
	c.FirstName,
	c.LastName
HAVING 
	SUM(i.Total) > (
	select
		round(avg(i2.total),2)
	from
		Invoice i2 )
		
		
--Find albums whose total duration exceeds the average album duration.
With AlbumAndTotalDuration as 
(
select
	t.AlbumId as AlbumNum,
	Sum(t.Milliseconds) as TotalDurationOfAlbum
from
	Track t
group by
	AlbumId
)
select
	AlbumNum,
	a.Title as AlbumName,
	TotalDurationOfAlbum
from
	AlbumAndTotalDuration inner join Album a on AlbumAndTotalDuration.AlbumNum = a.AlbumId 
where
	TotalDurationOfAlbum > (
	select
		Avg(TotalDurationOfAlbum)
	from
		AlbumAndTotalDuration)
		
		
--List employees who support customers from more than 3 countries.
select
	e.EmployeeId ,
	e.FirstName || ' ' || e.LastName as EmployeeFullName,
	count(distinct c.Country ) as NumCountriesSupportedTo
from
	Employee e
Left join Customer c on
	e.EmployeeId = c.SupportRepId
GROUP by
	e.EmployeeId,
	e.FirstName,
	e.LastName
having
	count(distinct c.Country ) > 3
	
	
--Find tracks that were purchased more times than the average purchased track.
with TrackAndTrackSoldNum as (
select
	il.TrackId as TrackNum,
	count(*) as NumOfTimesTrackSold
from
	InvoiceLine il
group by
	il.TrackId
)
select
	TrackNum,
	t.Name as TrackName,
	NumOfTimesTrackSold
from
	TrackAndTrackSoldNum
inner join Track t on
	TrackAndTrackSoldNum.TrackNum = t.TrackId
where
	NumOfTimesTrackSold > (
	select
		avg(NumOfTimesTrackSold)
	from
		TrackAndTrackSoldNum )
		
		
--Show customers who bought tracks from the same genre multiple times.
select
	i.CustomerId,
    c.FirstName || ' ' || c.LastName AS FullName,
    t.GenreId,
    COUNT(*) AS PurchasesFromGenre
from
	Customer c
inner join Invoice i ON
	c.CustomerId = i.CustomerId
inner join InvoiceLine il on
	i.InvoiceId = il.InvoiceId
inner join track t on
	il.TrackId = t.TrackId
group by
	i.CustomerId,
	c.FirstName,
	c.LastName,
	t.GenreId
having
	count(*) > 1
	
	
--Find artists whose revenue exceeds the average artist revenue.
with ArtistAndIncome as (
select
	a.ArtistId ArtistNum,
	a.Name as ArtistName,
	round(sum(il.UnitPrice * il.Quantity ), 2) as RevenuePerAlbum
from
	Artist a
inner join Album a2 on
	a.ArtistId = a2.ArtistId
inner join Track t on
	a2.AlbumId = t.AlbumId
inner join InvoiceLine il on
	t.TrackId = il.TrackId
group by
	a.ArtistId,
	a.Name
)
select
	ArtistNum,
	ArtistName,
	RevenuePerAlbum
from
	ArtistAndIncome
where
	RevenuePerAlbum > (
	select
		Avg(RevenuePerAlbum)
	from
		ArtistAndIncome)
		
		
--List customers who spent more than every customer from Brazil.
WITH CustomerTotals AS (
	-- Step 1: Calculate the total lifetime spend for every single customer
	SELECT
		c.CustomerId,
		c.FirstName || ' ' || c.LastName AS FullName,
		c.Country,
		SUM(i.Total) AS TotalSpending
	FROM
		Customer c
	INNER JOIN Invoice i ON
		c.CustomerId = i.CustomerId
	GROUP BY
		c.CustomerId,
		c.FirstName,
		c.LastName,
		c.Country
)
-- Step 2: Compare everyone against the highest-spending Brazilian customer
SELECT
	CustomerId,
	FullName,
	TotalSpending
FROM
	CustomerTotals
WHERE
	TotalSpending > (
		SELECT
			MAX(TotalSpending)
		FROM
			CustomerTotals
		WHERE
			Country = 'Brazil'
	);