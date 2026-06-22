--Find customers who purchased from every genre.------------------------------
SELECT
	i.CustomerId,
	COUNT( DISTINCT t.GenreId)
FROM
	Invoice i
INNER JOIN InvoiceLine il 
ON
	i.InvoiceId = il.InvoiceId
INNER JOIN Track t ON
	il.TrackId = t.TrackId
GROUP BY
	i.CustomerId
HAVING
	COUNT( DISTINCT t.GenreId) = (
	SELECT
		COUNT(*)
	FROM
		Genre g)
		
		
--Gemini
SELECT
	i.CustomerId,
	COUNT(DISTINCT t.GenreId) AS TotalGenresPurchased
FROM
	Invoice i
INNER JOIN InvoiceLine il ON
	i.InvoiceId = il.InvoiceId
INNER JOIN Track t ON
	il.TrackId = t.TrackId
GROUP BY
	i.CustomerId
HAVING
	COUNT(DISTINCT t.GenreId) = (
		SELECT
			COUNT(*)
		FROM
			Genre
	)
ORDER BY 
	i.CustomerId;


--GPT
SELECT
    c.CustomerId,
    c.FirstName || ' ' || c.LastName AS FullName
FROM Customer c
INNER JOIN Invoice i
    ON c.CustomerId = i.CustomerId
INNER JOIN InvoiceLine il
    ON i.InvoiceId = il.InvoiceId
INNER JOIN Track t
    ON il.TrackId = t.TrackId
GROUP BY
    c.CustomerId,
    c.FirstName,
    c.LastName
HAVING
    COUNT(DISTINCT t.GenreId) = (
        SELECT COUNT(*)
        FROM Genre
    );


--Show albums where every track is longer than 3 minutes.----------------------
WITH AlbumTrackLength AS (
SELECT
	a.AlbumId AS AlbumNum,
	a.Title AS AlbumName,
	t.TrackId AS TrackNum,
	t.Milliseconds AS TrackLen
FROM
	Track t
INNER JOIN Album a ON
	t.AlbumId = a.AlbumId 
)
SELECT
	AlbumNum,
	AlbumName
FROM
	AlbumTrackLength
GROUP BY
	AlbumNum,
	AlbumName
HAVING
	MIN(TrackLen) > 180000
	
	
--Gemini and GPT
SELECT
	a.AlbumId AS AlbumNum,
	a.Title AS AlbumName
FROM
	Track t
INNER JOIN Album a ON
	t.AlbumId = a.AlbumId 
GROUP BY
	a.AlbumId,
	a.Title
HAVING
	MIN(t.Milliseconds) > 180000;


--Find playlists that contain tracks from every media type.--------------------
SELECT
	pt.PlaylistId,
	p.Name as PlaylistName,
	COUNT(DISTINCT MediaTypeId ) AS NumOfMediaType
FROM
	Track t
INNER JOIN PlaylistTrack pt ON
	t.TrackId = pt.TrackId
INNER JOIN Playlist p ON pt.PlaylistId = p.PlaylistId 
GROUP BY
	pt.PlaylistId,
	p.Name
HAVING
	COUNT(DISTINCT t.MediaTypeId ) = (
	SELECT
		COUNT(*)
	FROM
		MediaType)


--Show artists whose every album contains at least one Rock track.-------------------
--GPT
WITH TableIsRock AS (
    SELECT
        a2.ArtistId AS ArtistNum,
        a2.Name AS ArtistName,
        a.AlbumId AS AlbumNum,
        MAX(
            CASE
                WHEN t.GenreId = 1 THEN 1
                ELSE 0
            END
        ) AS IsRock
    FROM Track t
    INNER JOIN Album a
        ON t.AlbumId = a.AlbumId
    INNER JOIN Artist a2
        ON a.ArtistId = a2.ArtistId
    GROUP BY
        a2.ArtistId,
        a2.Name,
        a.AlbumId
)
SELECT
    ArtistNum,
    ArtistName
FROM TableIsRock
GROUP BY
    ArtistNum,
    ArtistName
HAVING
    MIN(IsRock) = 1;

--Gemini
SELECT
	ar.ArtistId,
	ar.Name AS ArtistName
FROM
	Artist ar
INNER JOIN Album al ON
	ar.ArtistId = al.ArtistId
INNER JOIN Track t ON
	al.AlbumId = t.AlbumId
INNER JOIN Genre g ON
	t.GenreId = g.GenreId
GROUP BY
	ar.ArtistId,
	ar.Name
HAVING
	-- Check 1: Count all unique albums for this artist
	COUNT(DISTINCT al.AlbumId) 
	= 
	-- Check 2: Count unique albums ONLY if they contain a Rock track
	COUNT(DISTINCT CASE WHEN g.Name = 'Rock' THEN al.AlbumId END);


--Find customers who never purchased Rock tracks.--------------------------------
WITH CustomersWithRock AS (
SELECT 
	g.GenreId AS GenreNum,
	g.Name AS GenreName,
	c.CustomerId AS CustNum
FROM
	Customer c
INNER JOIN Invoice i ON
	c.CustomerId = i.CustomerId
INNER JOIN InvoiceLine il ON
	i.InvoiceId = il.InvoiceId
INNER JOIN Track t ON
INNER JOIN Genre g ON
	t.GenreId = g.GenreId
GROUP BY
	g.GenreId ,
	c.CustomerId
HAVING
	g.Name = 'Rock')
SELECT
	c.CustomerId ,
	c.FirstName || ' ' || c.LastName AS FullName
FROM
	Customer c
WHERE
	c.CustomerId NOT IN (
	SELECT
		CustNum
	FROM
		CustomersWithRock)
		

--GPT
SELECT
    c.CustomerId,
    c.FirstName || ' ' || c.LastName AS FullName
FROM Customer c
WHERE c.CustomerId NOT IN
(
    SELECT i.CustomerId
    FROM Invoice i
    JOIN InvoiceLine il
        ON i.InvoiceId = il.InvoiceId
    JOIN Track t
        ON il.TrackId = t.TrackId
    JOIN Genre g
        ON t.GenreId = g.GenreId
    WHERE g.Name = 'Rock'
);


--Gemini
WITH CustomersWithRock AS (
	SELECT DISTINCT
		c.CustomerId AS CustNum
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
	WHERE
		g.Name = 'Rock'
)
SELECT
	c.CustomerId,
	c.FirstName || ' ' || c.LastName AS FullName
FROM
	Customer c
WHERE
	c.CustomerId NOT IN (
		SELECT
			CustNum
		FROM
			CustomersWithRock
	);


--Show employees whose customers all belong to the same country.---------------------------------------
SELECT
	e.EmployeeId ,
	e.FirstName || ' ' || e.LastName AS EmpoloyeeFullName,
	COUNT(DISTINCT c.Country)
FROM
	Customer c
INNER JOIN Employee e ON c.SupportRepId = e.EmployeeId 
GROUP BY
	e.EmployeeId,
	e.FirstName,
	e.LastName
HAVING COUNT(DISTINCT c.Country) = 1


--GPT
SELECT
    e.EmployeeId,
    e.FirstName || ' ' || e.LastName AS EmployeeFullName
FROM Employee e
JOIN Customer c
    ON e.EmployeeId = c.SupportRepId
GROUP BY
    e.EmployeeId,
    e.FirstName,
    e.LastName
HAVING MIN(c.Country) = MAX(c.Country);


--Find albums where no track has ever been sold.-----------------------------------
SELECT
	t.AlbumId,
	a.Title
FROM
	Track t
LEFT JOIN InvoiceLine il ON
	t.TrackId = il.TrackId
INNER JOIN Album a ON
	t.AlbumId = a.AlbumId
WHERE
	il.TrackId IS NULL
GROUP BY
	t.AlbumId,
	a.Title
	

--GPT-1 HAVING
SELECT
    a.AlbumId,
    a.Title
FROM Album a
JOIN Track t
    ON a.AlbumId = t.AlbumId
LEFT JOIN InvoiceLine il
    ON t.TrackId = il.TrackId
GROUP BY
    a.AlbumId,
    a.Title
HAVING
    COUNT(il.TrackId) = 0;


--GPT-2 NOT EXISTS
SELECT
    a.AlbumId,
    a.Title
FROM Album a
WHERE NOT EXISTS
(
    SELECT 1
    FROM Track t
    JOIN InvoiceLine il
        ON t.TrackId = il.TrackId
    WHERE t.AlbumId = a.AlbumId
);


--Gemini
SELECT
    a.AlbumId,
    a.Title
FROM Album a
WHERE NOT EXISTS
(
    SELECT 1
    FROM Track t
    JOIN InvoiceLine il
        ON t.TrackId = il.TrackId
    WHERE t.AlbumId = a.AlbumId
);