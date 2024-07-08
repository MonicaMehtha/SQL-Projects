select * from athletes
select * from athlete_events 

--1 which team has won the maximum gold medals over the years.
select  top 1 team,count(*)  as golds_won from athletes A inner join athlete_events  E 
on A.id =E.athlete_id where medal ='Gold'
group by team 
order by count(*) desc;

--2 for each team print total silver medals and year in which they won maximum silver medal..output 3 columns
-- team,total_silver_medals, year_of_max_silver
with cte as(
select team,year,count(distinct event) as year_wise_silver from athletes A inner join athlete_events  E 
on A.id =E.athlete_id where medal ='Silver'
group by team,year),
rank_cte as(
select *,RANK() over ( partition by team order by year_wise_silver desc) as rnk from cte),
max_silver_won_year as(
select team,year from rank_cte where rnk =1),
total_silver_won as (
select team,sum(year_wise_silver) as  total_silvers from cte group by team)
select S.team,total_silvers, max(year) as max_silvers_won_year 
from total_silver_won S
inner join max_silver_won_year Y on S.team =Y.team
group by S.team,total_silvers;


--3-which player has won maximum gold medals  amongst the players 
--which have won only gold medal (never won silver or bronze) over the years
with cte as(
select * from athlete_events E 
inner join 
athletes A on E.athlete_id =A.id where Medal ='Gold' and  name  not in 
(select distinct name from athletes A inner join athlete_events E on A.id=E.athlete_id where medal  in ('Bronze','Silver')))
select  top 1 name,count(*) as gold_won_max from cte group by name order by COUNT(*) desc;

--4 in each year which player has won maximum gold medal . Write a query to print year,player name 
--and no of golds won in that year . In case of a tie print comma separated player names.
with golds_won as(
select name,year,count(medal) as gold_medal from athlete_events E 
inner join 
athletes A on E.athlete_id =A.id where medal ='Gold'
group by name,year),
rank_cte as
(select *,RANK() over(partition by year order by gold_medal desc) as rnk from golds_won)
select STRING_AGG(name,',') as players,year,gold_medal from rank_cte where rnk =1
group by year,gold_medal;

--5 in which event and year India has won its first gold medal,first silver medal and first bronze medal
--print 3 columns medal,year,sport
select distinct event,year,medal from (
select event,year,medal,
rank() over (partition by medal order by year asc) as rnk
from athlete_events E 
inner join 
athletes A on E.athlete_id =A.id where team = 'India' and medal in('Gold','Silver','Bronze')) A
where rnk =1

--6 find players who won gold medal in summer and winter olympics both.

select name  from  athlete_events E 
inner join 
athletes A on E.athlete_id =A.id 
where medal ='Gold'
group by name
having COUNT(distinct season) =2

--7 find players who won gold, silver and bronze medal in a single olympics. print player name along with year.
select name,year from  athlete_events E 
inner join 
athletes A on E.athlete_id =A.id where medal in('Gold','Silver','Bronze')
group by name,year
having count(distinct medal ) =3
order by year;

--8 find players who have won gold medals in consecutive 3 summer olympics in the same event . Consider only olympics 2000 onwards. 
--Assume summer olympics happens every 4 year starting 2000. print player name and event name.
select name,event from (
select athlete_id,name,event,year, 
lag(year,1) over (partition by athlete_id,event order by year asc) as prev_game ,
lead(year,1) over (partition by athlete_id,event order by year asc) as next_game
from  athlete_events E 
inner join 
athletes A on E.athlete_id =A.id where year >=2000 and season ='Summer' and medal = 'Gold'

)A where prev_game = year- 4 and next_game = year+4 order by name;


