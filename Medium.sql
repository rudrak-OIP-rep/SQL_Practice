/*16SELECT
	c.CustomerId,
	c.FirstName,
	c.LastName,
	i.InvoiceId
FROM
	Customer c
Inner join Invoice i on
	c.CustomerId = i.CustomerId;*/


/*17SELECT
	c.CustomerId,
	c.FirstName,
	c.LastName,
	COUNT(i.InvoiceId) as TotalInvoicesPerCustomer
FROM
	Customer c
Inner join Invoice i on
	c.CustomerId = i.CustomerId
GROUP BY
	c.CustomerId,
	c.FirstName,
	c.LastName;*/


/*18SELECT
	i.BillingCountry,
	SUM(i.Total) AS totalSales
from
	Invoice i
GROUP BY
	i.BillingCountry ;*/


/*19SELECT
	t.TrackId,
	t.Name,
	t.UnitPrice
FROM
	Track t
ORDER BY
	t.UnitPrice desc
LIMIT(5);*/


/*20SELECT
	t.GenreId,
	g.name as GenreName,
	round(AVG(t.Milliseconds), 2)as AverageTrackLengthPerGenre
FROM
	Track t
inner join Genre g on
	t.GenreId = g.GenreId
GROUP by
	t.GenreId,
	g.Name;*/


/*21SELECT
	a.Title as AlbumTitle,
	a2.Name as ArtistName
FROM
	Album a
INNER JOIN Artist a2 ON
	a.ArtistId = a2.ArtistId;*/


/*22SELECT
	a.AlbumId,
	a.Title,
	count(t.TrackId) as NumberOfTracksPerAlbum
FROM
	Album a
LEFT JOIN Track t on
	a.AlbumId = t.AlbumId
group by
	a.AlbumId,
	a.Title;*/


/*23SELECT
	c.CustomerId,
	c.FirstName,
	c.LastName,
	SUM(i.Total) as AmountSpentByCustomer
from
	Customer c
left join Invoice i ON
	c.CustomerId = i.CustomerId
GROUP BY
	c.CustomerId,
	c.FirstName,
	c.LastName
Having
	SUM(i.Total) > 45;*/


/*24SELECT
	i.InvoiceId,
	concat(c.FirstName, ' ', c.LastName) as FullName,
	i.Total
FROM
	Invoice i
inner join Customer c on
	i.CustomerId = c.CustomerId
ORDER BY
	i.InvoiceId;*/


/*25SELECT
	t.TrackId,
	t.Name,
	t.Milliseconds
From
	Track t
where
	t.Milliseconds = (
	select
		max(t1.Milliseconds)
	from
		Track t1)*/


/*26SELECT
	e.EmployeeId,
	e.FirstName,
	e.LastName,
	c.CustomerId,
	c.FirstName,
	c.LastName
from
	Employee e
Inner join Customer c on
	e.EmployeeId = c.SupportRepId
ORDER BY e.EmployeeId, c.CustomerId;*/


/*27SELECT
	e.EmployeeId,
	e.FirstName,
	e.LastName,
	count(c.CustomerId) as CustomerSupportedByEachEmployee
from
	Employee e
Left join Customer c on
	e.EmployeeId = c.SupportRepId
GROUP BY
	e.EmployeeId,
	e.FirstName,
	e.LastName
ORDER BY
	e.EmployeeId,
	e.FirstName,
	e.LastName;*/


/*28SELECT
	g.Name as GenreName,
	t.TrackId,
	t.Name as TrackName
FROM
	Track t
inner join Genre g on
	g.GenreId = t.GenreId
where g.Name = 'Rock'
order by
	t.TrackId;*/


/*29SELECT
	i.InvoiceId,
	COUNT(il.InvoiceLineId) as NumberOfInvoiceLineItemsPerInvoice
FROM
	Invoice i
inner join InvoiceLine il on
	i.InvoiceId = il.InvoiceId
group by
	i.InvoiceId
HAVING
	COUNT(il.InvoiceLineId) > 3
order by
	COUNT(il.InvoiceLineId);*/


/*30SELECT
	t.TrackId,
	t.Name as TrackName,
	ifnull(SUM(il.Quantity), 0) as QuantitySoldPerTrack
FROM
	Track t
LEFT join InvoiceLine il on
	t.TrackId = il.TrackId
GROUP BY
	t.TrackId,
	t.Name;*/


/*31SELECT
	p.PlaylistId,
	p.Name as PlaylistName,
	COUNT(pt.TrackId) as NumberOfTracksPerPlaylist
From
	Playlist p
left JOIN PlaylistTrack pt on
	p.PlaylistId = pt.PlaylistId
inner join track t on
	t.TrackId = p.PlaylistId
GROUP BY
	p.PlaylistId*/


/*32SELECT max(i.InvoiceDate ) as RecentInvoiceDate from Invoice i ;*/


/*33SELECT
    *
FROM Customer c
WHERE c.CustomerId NOT IN (
    SELECT i.CustomerId
    FROM Invoice i
);*/


/*34SELECT
	t.TrackId,
	t.Name as TrackName,
	t.UnitPrice
FROM
	Track t
WHERE
	t.UnitPrice > (
	SELECT
		AVG(t2.UnitPrice)
	from
		Track t2 )*/


/*35SELECT
	c.CustomerId,
	c.FirstName,
	c.LastName,
	c.Email
FROM
	Customer c
WHERE
	c.Email like '%gmail%';*/


/*36SELECT
    InvoiceId,
    CustomerId,
    InvoiceDate,
    Total
FROM Invoice
WHERE InvoiceDate BETWEEN '2009-01-01' AND '2009-12-31';


SELECT
	i.InvoiceId,
	i.CustomerId,
	i.InvoiceDate,
	i.Total
FROM
	Invoice i
WHERE
	i.InvoiceDate >= '2010-01-01' 
	AND i.InvoiceDate < '2011-01-01'
ORDER BY
	i.InvoiceDate;*/


/*37SELECT
	i.BillingCountry,
	sum(i.Total) as SalesPerCountry
from
	Invoice i
GROUP BY
	i.BillingCountry
Order By
	sum(i.Total) DESC
limit(3);*/


/*38SELECT
	strftime('%Y', i.InvoiceDate) AS SaleYear,
	sum(i.Total) as SalesByYear
from
	Invoice i
GROUP BY
	SaleYear;*/


/*39SELECT
	t.TrackId,
	t.Name as TrackName,
	t.Milliseconds As TrackLength,
	(CASE
		when t.Milliseconds > 500000 then 'Long'
		else 'Short'
	END) as Category
from
	Track t */


/*40SELECT
	a.AlbumId,
	a.Title as AlbumTitle,
	Count(t.TrackId) as NumberOfTracksPerAlbum
From
	Track t
Right Join Album a on
	t.AlbumId = a.AlbumId
group by
	a.AlbumId,
	a.Title
HAVING
	Count(t.TrackId) > 10
Order by
	a.AlbumId*/




