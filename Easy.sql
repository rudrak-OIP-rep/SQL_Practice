/*1SELECT
	c.FirstName as Customer_first_name,
	c.LastName as Customer_last_name
FROM
	Customer c ;*/


/*2SELECT
	c.Country
FROM
	Customer c
GROUP BY
	c.Country ;*/


/*3SELECT
	i.InvoiceId,
	i.Total
FROM
	Invoice i
WHERE
	i.Total > 10;*/


/*4SELECT
	c.CustomerId ,
	c.FirstName ,
	c.LastName ,
	c.Country
FROM
	Customer c
WHERE
	c.Country = 'USA'
ORDER BY
	c.LastName ;*/


/*5SELECT
	t.TrackId ,
	t.Name,
	t.UnitPrice 
FROM
	Track t
WHERE
	t.UnitPrice > 0.99;*/


/*6SELECT
	e.EmployeeId ,
	e.FirstName,
	e.LastName,
	concat(e.FirstName, ' ', e.LastName ) as full_name
FROM
	Employee e;*/


/*7SELECT
	DISTINCT c.City
FROM
	Customer c*/


/*8SELECT
	*
FROM
	Invoice i
ORDER BY
	i.InvoiceDate desc;*/


/*9SELECT
	t.TrackId,
	t.Name,
	t.Composer
FROM
	Track t
WHERE
	Name like 'A%';*/


/*10SELECT
	t.TrackId,
	t.Name,
	length(t.Name) as trackNameLength
FROM
	Track t*/


/*11SELECT
	i.InvoiceId,
	i.InvoiceDate,
	i.BillingAddress,
	ROUND(i.Total, 1) as roundedInvoiceTotal
FROM
	Invoice i*/


/*12UPDATE Customer
SET fax = 'N/A'
WHERE fax is NULL ;*/


/*13SELECT
	UPPER(c.FirstName) AS upperCaseFirstName
FROM
	Customer c*/


/*14SELECT DATETIME() as currentDateTime;*/


/*15SELECT t.TrackId, t.Name, t.Milliseconds / 1000.0 as lengthInSeconds FROM Track t*/



