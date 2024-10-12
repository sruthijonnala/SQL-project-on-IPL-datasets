--Create a table named IPL_Matches with appropriate data types for columns
CREATE TABLE matches (
match_id int,
city varchar,
date date,
player_of_match varchar,
venue varchar,
neutral_venue int,
team1 varchar, 
team2 varchar, 
toss_winner varchar, 
toss_decision varchar, 
winner varchar,
result_mode varchar, 
result_margin int,
eliminator varchar,
method_dl varchar,
umpire1 varchar, 
umpire2 varchar
);
SELECT * FROM matches;

--Create a table named deliveries with appropriate data types for columns

CREATE TABLE deliveries (
match_id int, 
inning int, 
over int, 
ball int, 
batsman varchar, 
non_striker varchar, 
bowler varchar, 
batsman_runs int,
extra_runs int, 
total_runs int,
wicket_ball int,
dismissal_kind varchar,
player_dismissed varchar,
fielder varchar,
extras_type varchar,
batting_team varchar, 
bowling_team varchar
);
select * from deliveries;

--Import data from csv file IPL_matches.csv attached in resources to the table matches which was created in Q1
COPY IPL_BALL FROM 'C:\Program Files\PostgreSQL\Data\IPLMatches+IPLBall/IPL_Ball.csv' CSV HEADER;

--Import data from csv file IPL_Ball.csv attached in resources to the table deliveries which was created in Q2
COPY IPL_Matches FROM 'C:\Program Files\PostgreSQL\Data\IPLMatches+IPLBall/IPL_matches.csv' CSV HEADER NULL 'NA';

--Select the top 20 rows of the deliveries table after ordering them by id, inning, over, ball in ascending order.
select * from deliveries
order by match_id,inning,over,ball
limit 20;

--Select the top 20 rows of the matches table.
select * from matches limit 20;

--Fetch data of all the matches played on 2nd May 2013 from the matches table
select * from matches where date = '2013-05-02';

--Fetch data of all the matches where the result mode is runs and margin of victory is more than 100 runs.
select * from matches where result_mode = 'runs' and result_margin > 100;

--Fetch data of all the matches where the final scores of both teams tied and order it in descending order of the date.
select * from matches where result_mode = 'tie'
order by date desc;

--Get the count of cities that have hosted an IPL match.
select count(city) from matches;
select * from deliveries;

--Create table deliveries_v02 with all the columns of the table deliveries and an additional column ball_result containing values boundary, dot or other depending on the total_run (boundary for >= 4, dot for 0 and other for any other number)
create table deliveries_v02 as
(select *, case
when ball >= 4 THEN 'boundary'
              when ball = 0 THEN 'dot'
			  else 'other'
			  end as ball_result
			  from deliveries);
select * from deliveries_v02;


--Write a query to fetch the total number of boundaries and dot balls from the deliveries_v02 table.
select ball_result, count(ball_result) 
from deliveries_v02
where ball_result = 'boundary' and ball_result = 'dot'
group by ball_result;

--Write a query to fetch the total number of boundaries scored by each team from the deliveries_v02 table and order it in descending order of the number of boundaries scored
select ball_result, count(ball_result) from deliveries_v02
where ball_result in('boundary','dot')
group by ball_result;
select ball_result, count(*)from deliveries_v02 group by ball_result;

--Write a query to fetch the total number of boundaries scored by each team from the deliveries_v02 table and order it in descending order of the number of boundaries scored.
select bowling_team, count(ball_result) as boundarycount
from deliveries_v02 where ball_result = 'boundary'
group by bowling_team order by count(ball_result) desc;

--Write a query to fetch the total number of dot balls bowled by each team and order it in descending order of the total number of dot balls bowled.
select bowling_team, count(ball_result) as boundarycount
from deliveries_v02 where ball_result = 'dot'
group by bowling_team order by boundarycount desc; 

--Write a query to fetch the total number of dismissals by dismissal kinds where dismissal kind is not NA
select count(dismissal_kind) from deliveries
where NOT dismissal_kind = 'NA';
SELECT dismissal_kind, COUNT(*) AS "Number of Dismissals"
FROM deliveries_v02
WHERE dismissal_kind <> 'NA'
GROUP BY dismissal_kind;


--Write a query to get the top 5 bowlers who conceded maximum extra runs from the deliveries table
select bowler, max(extra_runs) as totalextraruns
from deliveries group by bowler order by totalextraruns desc limit 5;


--Write a query to create a table named deliveries_v03 with all the columns of deliveries_v02 table and two additional column (named venue and match_date) of venue and date from table matches
create table deliveries_v03 as (select d.*, m.venue, m.date from deliveries_v02 as d 
 join matches as m
on d.match_id = m.match_id);

select * from deliveries_v03;


--Write a query to fetch the total runs scored for each venue and order it in the descending order of total runs scored.
select venue, sum(total_runs) as sumofruns
from deliveries_v03 group by venue order by sumofruns desc;


--Write a query to fetch the year-wise total runs scored at Eden Gardens and order it in the descending order of total runs scored.
select Year(match_date) as year, sum(total_runs) as totalruns from deliveries_v03
having venue = 'Eden Gardens'
Group by Year(match_date) order by totalruns desc;

--19
SELECT YEAR(date) AS year,
       SUM(total_runs) AS "Total Runs Scored"
FROM deliveries_v03
WHERE venue = 'Eden Gardens'
GROUP BY YEAR(date)
ORDER BY "Total Runs Scored" DESC;

SELECT extract(year from date) as year, sum(total_runs) from deliveries_v03
group by extract(year from dtae);

select * from matches;

--Get unique team1 names from the matches table, you will notice that there are two entries for Rising Pune Supergiant one with Rising Pune Supergiant and another one with Rising Pune Supergiants.  Your task is to create a matches_corrected table with two additional columns team1_corr and team2_corr containing team names with replacing Rising Pune Supergiants with Rising Pune Supergiant. Now analyse these newly created columns.
create table matches_corrected as select *, replace(team1, 'Rising Pune Supergiants', 'Rising Pune Supergiant') as team1_corr
, replace(team2, 'Rising Pune Supergiants', 'Rising Pune Supergiant') as team2_corr from matches;
select distinct team1_corr from matches_corrected;

--Create a new table deliveries_v04 with the first column as ball_id containing information of match_id, inning, over and ball separated by (For ex. 335982-1-0-1 match_id-inning-over-ball) and rest of the columns same as deliveries_v03)
create table deliveries_v04 as select match_id||'-'||inning||'-'||over||'-'||ball as ball_id, *
from deliveries_v03;

select * from deliveries_v04;

--Compare the total count of rows and total count of distinct ball_id in deliveries_v04;
select count(distinct ball_id) as count1,
count(*) as count2
from deliveries_v04;

--Create table deliveries_v05 with all columns of deliveries_v04 and an additional column for row number partition over ball_id. (HINT : Syntax to add along with other columns,  row_number() over (partition by ball_id) as r_num)
create table deliveries_v05 as 
(select *, row_number () over 
(partition by ball_id) as r_nmb from deliveries_v04);



select * from deliveries_v05;

--Use the r_num created in deliveries_v05 to identify instances where ball_id is repeating. (HINT : select * from deliveries_v05 WHERE r_num=2;)
select * from deliveries_v05 WHERE r_nmb in ('2','3');

--Use subqueries to fetch data of all the ball_id which are repeating. (HINT: SELECT * FROM deliveries_v05 WHERE ball_id in (select BALL_ID from deliveries_v05 WHERE r_num=2);
SELECT * FROM deliveries_v05 WHERE ball_id in (select BALL_ID from deliveries_v05 WHERE r_nmb=2);

select * from deliveries_v02
where ball_result = 'Boundary';

select  match_id, batting_team count(total_runs) from deliveries_v02 
group by match_id,batting_team;