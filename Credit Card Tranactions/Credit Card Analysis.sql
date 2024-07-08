--1write a query to print top 5 cities with highest spends 
--and their percentage contribution of total credit card spends 
with city_wise_spend as(
select  city,sum(amount) as city_spend from credit_card_transcations group by city ) ,
rank_cte as(select *,RANK() over(order by city_spend desc )as rank_spent from city_wise_spend),
top_5_spends as (select * from rank_cte where rank_spent <=5),
total_spends as (select sum(cast(amount as bigint)) as total from credit_card_transcations)
select city,round(100.0*city_spend/total,2) as contribution 
from top_5_spends t inner join total_spends on 1=1 ;


--2write a query to print highest spend month and amount spent in that month for each card type
with month_card_spend as(
select card_type,DATEPART(YEAR,transaction_date) as year,DATEPART(month,transaction_date) as month,sum(amount) as spent 
from credit_card_transcations
group by card_type,DATEPART(YEAR,transaction_date),DATEPART(month,transaction_date)),
rank_cte as(
select * ,rank() over (partition by card_type order by spent desc ) as rank from month_card_spend)
select card_type,year,month,spent from rank_cte where rank=1;


--3write a query to print the transaction details(all columns from the table) for each card type when
--it reaches a cumulative of  1,000,000 total spends(We should have 4 rows in the o/p one for each card type)
with cte1 as(
select *,
sum(amount) over(partition by  card_type order by transaction_date,transaction_id) as running_total 
from credit_card_transcations),
rank_cte as 
(select * , rank() over (partition by card_type order by running_total asc) as rnk 
from cte1 
where running_total >=1000000)
select * from rank_cte where rnk =1;


-- 4 write a query to find city which had lowest percentage spend for gold card type
with cte as(select city,card_type,sum(amount) as spent from credit_card_transcations
where card_type='Gold'
group by city,card_type),
spend as(select sum(cast(amount as bigint)) as total from credit_card_transcations)
select top 1 city,spent*100.0/total  as percentage from cte inner join spend on 1=1
 order by percentage asc

 --5 write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type (example format : Delhi , bills, Fuel)
 select distinct city from credit_card_transcations;
 with expense as(
 select city,exp_type,SUM(amount) as expense from credit_card_transcations
 group by city,exp_type)
 ,rank as(
 select *, RANK() over(partition by city order by expense asc) as lowest,
  RANK() over(partition by city order by expense desc) as highest
  from  expense)
select city,
max(case when lowest =1 then exp_type end )as 'lowest_expense_type',
max(case when highest =1then exp_type end) as 'highest_expense_type'
from rank group by city;

--6 write a query to find percentage contribution of spends by females for each expense type
select * from credit_card_transcations;
select exp_type,
sum(case when gender ='F' then amount else 0 end )*100.0/sum(amount) as Female_contribution
from credit_card_transcations
group by exp_type;
--7 which card and expense type combination saw highest month over month growth in Jan-2014
select * from credit_card_transcations;

with summarized_table as(select card_type,exp_type,
DATEPART(YEAR,transaction_date) as year,
DATEPART(month,transaction_date) as month,
sum(amount) as spend from credit_card_transcations
group by card_type,exp_type,
DATEPART(YEAR,transaction_date),
DATEPART(month,transaction_date)
--order by year asc,month asc)
),
prev_month_sales as
(select *,
lag(spend,1) over(partition by card_type,exp_type order by year,month)
as prev_month_spend from summarized_table),
mom_growth as (
select *,(spend-prev_month_spend)*100.0/prev_month_spend  as mom from prev_month_sales)
select top 1 * from mom_growth  where year = 2014 and month =1 order by mom desc;

--8 during weekends which city has highest total spend to total no of transcations ratio 
select  top 1city,sum(amount)/count(*)  as transaction_ratio from credit_card_transcations
where DATEPART(weekday,transaction_date) in (1,7)
group by city 
order by transaction_ratio desc ;


--9- which city took least number of days to reach its 500th transaction after the first transaction in that city
with cte as(
select *,row_number() over(partition by city order by transaction_date,transaction_id) as transaction_no from credit_card_transcations)

select top 1 city,datediff(day,min(transaction_date),max(transaction_date))  as transaction_days from cte where transaction_no in (1,500)
group by city
having COUNT(*) =2
order by transaction_days asc;


