/*review the table*/
select * from sales_data_sample ;

/*Analysis 01 -Sales by product line*/
select PRODUCTLINE,  
 sum(sales) REVENUE 
from sales_data_sample
group by PRODUCTLINE
order by 2 desc ;

/*Analysis 02 -Sales by Year*/
select YEAR_ID ,
sum(SALES) YEARLY_REVENUE 
from sales_data_sample
order by 1 desc ;

/*Analysis 03 -Sales by Dealsize*/
select DEALSIZE ,
sum(SALES) REVENUE
from sales_data_sample
group by DEALSIZE
order by 2 desc ;

/*Analysis 04 -Best month for sale in a specific year*/
select MONTH_ID , YEAR_ID ,
SUM(sales) REVENUE
from sales_data_sample
group by STATUS
order by 2 desc;

/*Analysis 05 -Quantity ordered in a specific month in year 2005*/
select MONTH_ID ,
SUM(QUANTITYORDERED) QUANTITY ,
COUNT(ordernumber) FREQUENCEY
from sales_data_sample
where YEAR_ID= 2004
group by MONTH_ID
order by 2 desc;

/*Analysis 06 --November seems to be the month, what product do they sell in November, Classic I believe*/
select MONTH_ID YEAR_ID , PRODUCTLINE ,
SUM(SALES) REVENUE ,
COUNT(ORDERNUMBER) FREQ 
from sales_data_sample 
where YEAR_ID = 2004 and MONTH_ID = 11 
GROUP BY MONTH_ID , PRODUCTLINE
ORDER BY 3 DESC ;

/*Analysis 07 -----What is the best product in United States?*/

select country, YEAR_ID, PRODUCTLINE, sum(sales) Revenue
from sales_data_sample
where country = 'USA'
group by  country, YEAR_ID, PRODUCTLINE
order by 4 desc ;

/*Analysis 07 -----What is the best product in United States?*/

;with rfm as 
(
	select 
		CUSTOMERNAME, 
		sum(sales) MonetaryValue,
		avg(sales) AvgMonetaryValue,
		count(ORDERNUMBER) Frequency,
		max(ORDERDATE) last_order_date,
		(select max(ORDERDATE) from sales_data_sample) max_order_date,
		DATEDIFF(DD, max(ORDERDATE), (select max(ORDERDATE) from sales_data_sample)) Recency
	from sales_data_sample
	group by CUSTOMERNAME
),
rfm_calc as
(

	select r.*,
		NTILE(4) OVER (order by Recency desc) rfm_recency,
		NTILE(4) OVER (order by Frequency) rfm_frequency,
		NTILE(4) OVER (order by MonetaryValue) rfm_monetary
	from rfm r
)
select 
	c.*, rfm_recency+ rfm_frequency+ rfm_monetary as rfm_cell,
	cast(rfm_recency as char) + cast(rfm_frequency as char) + cast(rfm_monetary  as char)rfm_cell_string
into #rfm
from rfm_calc c

select CUSTOMERNAME , rfm_recency, rfm_frequency, rfm_monetary,
	case 
		when rfm_cell_string in (111, 112 , 121, 122, 123, 132, 211, 212, 114, 141) then 'lost_customers'  --lost customers
		when rfm_cell_string in (133, 134, 143, 244, 334, 343, 344, 144) then 'slipping away, cannot lose' -- (Big spenders who haven’t purchased lately) slipping away
		when rfm_cell_string in (311, 411, 331) then 'new customers'
		when rfm_cell_string in (222, 223, 233, 322) then 'potential churners'
		when rfm_cell_string in (323, 333,321, 422, 332, 432) then 'active' --(Customers who buy often & recently, but at low price points)
		when rfm_cell_string in (433, 434, 443, 444) then 'loyal'
	end rfm_segment

from #rfm
 
