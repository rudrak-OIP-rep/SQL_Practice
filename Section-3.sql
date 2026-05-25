--Rank tracks by length within each album.
select
	t.TrackId ,
	t.Name as TrackName,
	t.AlbumId ,
	a.Title as AlbumName,
	t.Milliseconds,
	Rank() over(partition by t.AlbumId order by t.Milliseconds desc) as LengthRank
from
	Track t
inner join Album a on
	t.AlbumId = a.AlbumId
	
	
--Find the second-longest track in each album.
WITH RankOnAlbumTrackLength AS (
select
	t.TrackId as TrackNum,
	t.Name as TrackName,
	t.AlbumId as AlbumNum,
	a.Title as AlbumName,
	t.Milliseconds as TrackLength,
	Dense_Rank() over(partition by t.AlbumId order by t.Milliseconds desc) as LengthRank
from
	Track t
inner join Album a on
	t.AlbumId = a.AlbumId
)
select
	TrackNum,
	TrackName,
	AlbumNum,
	AlbumName,
	TrackLength
from
	RankOnAlbumTrackLength
where
	LengthRank = 2
	
	
--Show the top 3 highest-spending customers per country.
with AmountSpentPerCountry as (
select
	i.CustomerId as CustNum,
	i.BillingCountry As CustCountry,
	c.FirstName || ' ' || c.LastName as FullName,
	sum(i.Total) as TotalAmountSpentByCustomer,
	Dense_Rank() Over(partition by i.BillingCountry order by sum(i.Total) desc ) as CustomerRankPerCountry
from
	Invoice i
inner join Customer c on
	i.CustomerId = c.CustomerId
group BY
	i.CustomerId ,
	i.BillingCountry,
	c.FirstName,
	c.LastName
)
select
	CustNum,
	CustCountry,
	FullName,
	TotalAmountSpentByCustomer
from
	AmountSpentPerCountry
where
	CustomerRankPerCountry <= 3;


--Display running yearly sales totals.
with YearlySales as (
select
	STRFTIME('%Y', i.InvoiceDate ) as SaleYear,
	sum(i.Total) as TotalSalesInAYear
from
	Invoice i
group by
	STRFTIME('%Y', i.InvoiceDate )
)
select
	SaleYear,
	TotalSalesInAYear,
	sum(TotalSalesInAYear) Over(order by SaleYear) as RunningYearlySales
from
	YearlySales
	
	
--Find each customer’s previous purchase amount.
SELECT
	i.customerId,
	i.InvoiceDate,
	i.Total as CurrentPurchaseAmt,
	Coalesce((Lag(i.Total, 1) Over(partition by i.CustomerId order by i.InvoiceDate)), 0) as PreviousPurchaseAmt
from
	Invoice i
	
	
--Show sales growth percentage year-over-year.
with SalesPerYear as (
select
	STRFTIME('%Y', i.InvoiceDate ) as SaleYear,
	sum(i.Total) as TotalSales
from
	Invoice i
group by
	STRFTIME('%Y', i.InvoiceDate )
)
select
	SaleYear,
	TotalSales,
	Round(((TotalSales - lag(TotalSales) OVER(order by SaleYear)) * 100.0)/ lag(TotalSales) OVER(order by SaleYear), 2) as SalesGrowthPercentage
from
	SalesPerYear
	
	
--Find the first invoice made by each customer.
with InvoiceMadeByCustomer as (
select
	i.CustomerId as CustNum,
	i.InvoiceDate as InvDate,
	i.InvoiceId as InvNum,
	Row_number() OVER (partition by i.CustomerId
order by
	i.InvoiceDate) as InvoiceRankingPerCustomer
from
	Invoice i 
)
Select
	CustNum,
	InvNum
from
	InvoiceMadeByCustomer
where
	InvoiceRankingPerCustomer = 1