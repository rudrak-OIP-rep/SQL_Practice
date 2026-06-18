--1.Write a query to add a customer that hasn't made a purchase yet, but who already has an appointed support representative.
INSERT
	INTO
	Customer(CustomerId, FirstName, LastName, Company, Address, City, State, Country, PostalCode, Phone, Fax, Email, SupportRepId)
VALUES(60, 'Rudra', 'Kolipaka', 'SQL Devs', '123 Main St', 'New York', 'NY', 'USA', '10012', '+1 (212) 124-4567', Null, 'Rudrak@email.com', 5)

select * from Customer c




--2.Write a query (without using SQL clauses WHERE, GROUP BY, ORDER BY, JOIN, or HAVING) that results in the number of customers who have a company.
    --BONUS: How can you get the same results using a different approach? Use a WHERE clause and write the other query, too.

SELECT
	COUNT(c.Company) AS CustomersWithCompany
FROM
	Customer c;



SELECT
	SUM(CASE
WHEN c.Company IS NULL THEN 0
		ELSE 1
	END) AS CustomersWithCompany
FROM
		Customer c
		
		
		
SELECT
	COUNT(*) AS CustomersWithCompany
FROM
	(
	SELECT
		*
	FROM
		Customer c
	WHERE
		c.Company IS NOT NULL 
		)

		
--3.List all customers along with the number of invoices they have. Show how much they spent in total and include customers with zero invoices. 
    --Display customer names and surnames in the same column, and add a column IsUSA next to it and populate with 'Y' if the customer's address is in the USA; otherwise populate with 'N'.

SELECT
	c.CustomerId ,
	c.FirstName || ' ' || c.LastName AS FullName,
	COUNT(i.InvoiceId) AS NumOfInvoices,
	COALESCE(SUM(i.Total),0) AS TotalAmountSpentByCustomer,
	(CASE
		WHEN c.country = 'USA' THEN 'Y'
		ELSE 'N'
	END) AS IsUSA
FROM
	Customer c
LEFT JOIN Invoice i ON
	c.CustomerId = i.CustomerId
GROUP BY
	c.CustomerId,
	c.FirstName,
	c.LastName,
	c.country
ORDER BY
	c.CustomerId
	
	

--4.Calculate the total number and the total average of invoices for each billing country. Round the average to two decimals and include the highest amount per country at the end. 
  --Only include countries with more than 7 invoices and sort by total average (the lowest amounts first) and then by num of invoices (the highest num first).

SELECT
	i.BillingCountry AS Country,
	COUNT(i.InvoiceId) AS NumOfInvoicesPerCountry,
	ROUND(AVG(i.Total), 2) AS AvgOfInvAmtPerCountry,
	MAX(i.Total) AS HighestAmtPerCountry
FROM
	Invoice i
GROUP BY
	i.BillingCountry
HAVING
	COUNT(i.InvoiceId) > 7
ORDER BY
	AvgOfInvAmtPerCountry ASC,
	NumOfInvoicesPerCountry DESC
	
	
	
--5.Update the billing state of invoices to 'Unknown' where it doesn't exist. Do that for all countries except 'USA' where there is no billing postal code.

UPDATE
	Invoice
SET
	BillingState = 'Unknown'
WHERE
	BillingState IS NULL
	AND (
		BillingCountry != 'USA'
		OR (BillingCountry = 'USA' AND BillingPostalCode IS NULL)
	);

SELECT * FROM Invoice i 

UPDATE
	Invoice
SET
	BillingState = 
CASE
		WHEN BillingCountry != 'USA' THEN 'Unknown'
		WHEN BillingCountry = 'USA' AND BillingPostalCode IS NULL THEN 'Unknown'
	END;	
	


	
--6.For each genre, display the number of tracks and the average track length in minutes rounded to one decimal. Only include the tracks sold in Portugal.

SELECT
	t.GenreId AS GenreNum,
	g.Name AS GenreName,
	COUNT(t.TrackId) AS NumOfTracksPerGenre,
	ROUND(AVG(t.Milliseconds/60000.0),1) AS AvgTrackLengthPerGenreInMins
FROM
	Genre g
INNER JOIN Track t ON
	g.GenreId = t.GenreId
INNER JOIN InvoiceLine il ON
	t.TrackId = il.TrackId
INNER JOIN Invoice i ON
	il.InvoiceId = i.InvoiceId
WHERE
	i.BillingCountry = 'Portugal'
GROUP BY
	t.GenreId,
	g.Name
