/*Test
SELECT *
FROM athlete_events

SELECT *
FROM noc_regions*/

--===================================================================================================================================================================--
-- 1. How many olympics games have been held?

SELECT COUNT(DISTINCT games)
FROM athlete_events

-- Answer: 51 Olympic Games have been held

--===================================================================================================================================================================--
-- 2. List down all Olympics games held so far.
SELECT DISTINCT year, season, city
FROM athlete_events
ORDER BY year

-- Answer: List completed
--===================================================================================================================================================================--
-- 3. Mention the total no of nations who participated in each olympics game?

SELECT games, COUNT(DISTINCT noc) AS number_of_nations
FROM athlete_events
GROUP BY games
ORDER BY games
--Although this query looks good we may be missing some nations that are in the noc_regions table.

-- Let's use a WITH statement to include that table as well to confirm that we didn't miss any nations.
WITH all_countries AS
        (SELECT games, nr.region
        FROM athlete_events AS ae
        JOIN noc_regions AS nr 
		ON nr.noc = ae.noc
        GROUP BY games, nr.region)
SELECT games, COUNT(1) AS number_of_nations
FROM all_countries
GROUP BY games
ORDER BY games
    
-- Results are pretty similar with some slight difference in the number of nations participating in certain games.

-- Answer: Number of nations mentioned in above query

--===================================================================================================================================================================--
-- 4. Which year saw the highest and lowest no of countries participating in olympics?

--Based of the query from question 3, 12 and 204 should be our minimum and maximum.
-- Let's write a query just to get those numbers.

 WITH all_countries AS
              (SELECT games, nr.region
              FROM athlete_events AS ae
              JOIN noc_regions AS nr 
			  ON nr.noc = ae.noc
              GROUP BY games, nr.region),
          tot_countries AS
              (SELECT games, COUNT(1) AS total_countries
              FROM all_countries
              GROUP BY games)
      SELECT DISTINCT
      concat(FIRST_VALUE(games) OVER(ORDER BY total_countries)
      , ' - ', FIRST_VALUE(total_countries) OVER(ORDER BY total_countries)) AS Lowest_Countries,
      concat(FIRST_VALUE(games) OVER(ORDER BY total_countries DESC)
      , ' - ', FIRST_VALUE(total_countries) over(order by total_countries DESC)) AS Highest_Countries
      FROM tot_countries
      ORDER BY 1;

-- Answer: Lowest number of countires participating was 12 in 1896
-- Answer: Highest number of countires participating was 204 in 2016

--===================================================================================================================================================================--
-- 5. Which nation has participated in all of the olympic games?

--Based off the answer to Question 1. We know these nations need to have participated in 51 Olympic Games.

-- To answer this we will need to:
-- a. Find the total number olympic games (Refer to query in Question 1: 51)
-- b. Find the total number of nations that have particpated in the olympics (Refer to all_countries definition in Qustion 4)
-- c. Compare a & b

WITH total_games AS 
	  (SELECT COUNT(DISTINCT games) AS total_games
	   FROM athlete_events),
	 countries AS
      (SELECT games, nr.region AS country
       FROM athlete_events AS ae
       JOIN noc_regions AS nr 
	   ON nr.noc = ae.noc
       GROUP BY games, country),
      countries_participated AS 
      (SELECT country, COUNT(1) AS total_participated_games
       FROM countries
       GROUP BY country)
SELECT cp.*
FROM countries_participated AS cp
JOIN total_games AS tg
ON tg.total_games = cp.total_participated_games
ORDER BY 1

-- Answer: France, Italy, Switzerland, and the United Kingdom (UK) were the only countries that participated in all Olympic Games.

--===================================================================================================================================================================--
-- 6. Identify the sport which was played in all summer olympics.

-- To answer this we will need to:
-- a. Find the total number of summer olympic games
-- b. Find how many games each sport was played in
-- c. Compare a & b

WITH t1 AS 
	  (SELECT COUNT(DISTINCT games) AS total_summer_games
	   FROM athlete_events
	   WHERE season = 'Summer'),
t2 AS 
	(SELECT DISTINCT sport, games
	   FROM athlete_events
	   WHERE season = 'Summer'
	   ORDER BY games),
t3 AS
	(SELECT sport, COUNT(games) AS number_of_games
	 FROM t2
	 GROUP BY sport)
SELECT *
FROM t3
JOIN t1
ON t1.total_summer_games = t3.number_of_games

--29 Summer Olympic Games, so well be looking for the sport that were played 29 times.
--Answer: Swimming, Cycling, Fencing, Gymnastics, and Athletics (Track & Field) were played at all Summer Games.

--===================================================================================================================================================================--
-- 7. Which Sports were just played only once in the olympics?

WITH t1 AS
      (SELECT DISTINCT games, sport
       FROM athlete_events),
     t2 AS
       (SELECT sport, COUNT(1) AS num_of_games
        FROM t1
        GROUP BY sport)
SELECT t2.*, t1.games
FROM t2
JOIN t1 
ON t1.sport = t2.sport
WHERE t2.num_of_games = 1
ORDER BY t1.sport;



-- Answer: Basque Pelota, Cricket, Croquet, Jeu De Paume, Military Ski Patrol, Motorboating, Racquets, Roque, and Rugby Sevens were only played once at the Olympics.

--===================================================================================================================================================================--
-- 8. Fetch the total no of sports played in each olympic games.

WITH t1 AS
        (SELECT DISTINCT games, sport
      	FROM athlete_events),
        t2 AS
      	(SELECT games, COUNT(1) AS no_of_sports
      	FROM t1
      	GROUP BY games)
SELECT * 
FROM t2
ORDER BY no_of_sports DESC;


-- Answer: Number of sports played in each olympics mentioned in above query

--===================================================================================================================================================================--

-- 9. Fetch details of the oldest athletes to win a gold medal.
-- 10. Find the Ratio of male and female athletes participated in all olympic games.
--===================================================================================================================================================================--
-- 11. Fetch the top 5 athletes who have won the most gold medals.

SELECT name, COUNT(1) AS total_medals
FROM athlete_events
WHERE medal = 'Gold'
GROUP BY name
ORDER BY total_medals DESC
-- There are multiple ties after the second athlete with the most medals.
-- We can't use LIMIT 5 if we want to answer this question fairly (Due to the multiple ties)


--Let's use a WITH statement to get all of the athletes

WITH t1 AS
	(SELECT name, COUNT(1) AS total_medals
	FROM athlete_events
	WHERE medal = 'Gold'
	GROUP BY name
	ORDER BY total_medals DESC),
t2 AS
	(SELECT *, DENSE_RANK() OVER(ORDER BY total_medals DESC) AS rnk
	FROM t1)
SELECT *
FROM t2
WHERE rnk <= 5

-- Dense rank does not skip numbers after a tie like rank does.
-- Multiple ties for the 3rd, 4th, and 5th most medals.
-- Answer: Based on medal count 18 athletes qualify top 5 athletes who have won the most gold medals.

--===================================================================================================================================================================--
-- 12. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).

WITH t1 AS
          (SELECT name, team, COUNT(1) AS total_medals
           FROM athlete_events
           WHERE medal IN ('Gold', 'Silver', 'Bronze')
           GROUP BY name, team
           ORDER BY total_medals DESC),
     t2 AS
          (SELECT *, DENSE_RANK() OVER (ORDER BY total_medals DESC) AS rnk
           FROM t1)
SELECT name, team, total_medals
FROM t2
WHERE rnk <= 5;


-- Multiple ties for the 3rd, 4th, and 5th most medals.
-- Answer: Based on medal count 14 athletes qualify top 5 athletes who have won the most medals.

--===================================================================================================================================================================--

-- 13. Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.

WITH t1 AS
         (SELECT nr.region, COUNT(1) AS total_medals
          FROM athlete_events AS ae
          JOIN noc_regions AS nr 
		  ON nr.noc = ae.noc
          WHERE medal <> 'NA'
          GROUP BY nr.region
          ORDER BY total_medals DESC),
     t2 AS
         (SELECT *, DENSE_RANK() OVER (ORDER BY total_medals DESC) AS rnk
          FROM t1)
SELECT *
FROM t2
WHERE rnk <= 5;


-- Answer: USA, Russia, Germany, United Kingdom (UK), and France are the top 5 countries with the most medals won.

--===================================================================================================================================================================--
-- 14. List down total gold, silver and broze medals won by each country.

SELECT nr.region AS country, ae.medal, COUNT(1) AS total_medals 
FROM athlete_events AS ae
JOIN noc_regions AS nr
ON ae.noc = nr.noc
WHERE medal <> 'NA'
GROUP BY country, medal
ORDER BY country, medal
-- This query does give us the number of gold, silver, and bronze medals won by each country.
-- We want to make each type of medal its own column

-- We will use the crosstab function to make each type of medal its own column
--CREATE EXTENSION tablefunc; (Query has been run. Extenstion enabled)
-- We'll use coalesce to change the nulls to 0.

SELECT country,
COALESCE(gold, 0) AS gold,
COALESCE(silver, 0) AS silver,
COALESCE(bronze, 0) AS bronze
FROM crosstab('SELECT nr.region AS country, ae.medal, COUNT(1) AS total_medals 
			   FROM athlete_events AS ae
			   JOIN noc_regions AS nr
			   ON ae.noc = nr.noc
			   WHERE medal <> ''NA''
			   GROUP BY country, medal
			   ORDER BY country, medal',
			   'values (''Bronze''),(''Gold''), ((''Silver''))')
			AS result(country varchar,
					  bronze bigint,
					  gold bigint,
					  silver bigint)
ORDER BY gold DESC, silver DESC, bronze DESC

--- The reason we ordered the results bronze, gold, silver is because when you run ther crosstab query string that is the order of medals the query gives you.				  
--- Answer: List completed

--===================================================================================================================================================================--
-- 15. List down total gold, silver and broze medals won by each country corresponding to each olympic games.

--CREATE EXTENSION TABLEFUNC;

SELECT SUBSTRING(games,1,POSITION(' - ' IN games) - 1) AS games,
SUBSTRING(games,POSITION(' - ' IN games) + 3) AS country,
COALESCE(gold, 0) AS gold,
COALESCE(silver, 0) AS silver,
COALESCE(bronze, 0) AS bronze
FROM CROSSTAB('SELECT concat(games, '' - '', nr.region) as games,
               medal,
               COUNT(1) as total_medals
               FROM olympics_history AS ae
               JOIN noc_regions AS nr 
			   ON nr.noc = ae.noc
               WHERE medal <> ''NA''
               GROUP BY games,nr.region,medal
               Order BY games,medal',
            'values (''Bronze''), (''Gold''), (''Silver'')')
    AS FINAL_RESULT(games text, bronze bigint, gold bigint, silver bigint);



--- Answer: List completed

--===================================================================================================================================================================--
-- 16. Identify which country won the most gold, most silver and most bronze medals in each olympic games.

-- First part of query will give you total number of medals for each country per games
-- Second part of the query we'll need to partition for each Olympic Games.

WITH TEMP AS
(SELECT SUBSTRING(games_country, 1, position('-' IN games_country )- 1) AS games,
SUBSTRING(games_country, position('-' IN games_country )+ 2) AS country,
COALESCE(gold, 0) AS gold,
COALESCE(silver, 0) AS silver,
COALESCE(bronze, 0) AS bronze
FROM crosstab('SELECT CONCAT(games, '' - '', nr.region) AS game_country, ae.medal, COUNT(1) AS total_medals 
			   FROM athlete_events AS ae
			   JOIN noc_regions AS nr
			   ON ae.noc = nr.noc
			   WHERE medal <> ''NA''
			   GROUP BY games, nr.region, medal
			   ORDER BY games, nr.region, medal',
			   'values (''Bronze''),(''Gold''), ((''Silver''))')
			AS result(games_country varchar,
					  bronze bigint,
					  gold bigint,
					  silver bigint)
	ORDER BY games_country)
SELECT DISTINCT games,
CONCAT(FIRST_VALUE(country) OVER(PARTITION BY games ORDER BY gold DESC), ' - ', 
	   FIRST_VALUE(gold) OVER(PARTITION BY games ORDER BY gold DESC)) AS Max_Gold,
CONCAT(FIRST_VALUE(country) OVER(PARTITION BY games ORDER BY silver DESC), ' - ', 
	   FIRST_VALUE(silver) OVER(PARTITION BY games ORDER BY silver DESC)) AS Max_Silver,
CONCAT(FIRST_VALUE(country) OVER(PARTITION BY games ORDER BY  bronze DESC), ' - ', 
	   FIRST_VALUE(bronze) OVER(PARTITION BY games ORDER BY bronze DESC)) AS Max_Bronze
FROM TEMP
ORDER BY games

-- Answer: Countries indentified using query above
--===================================================================================================================================================================--
-- 17. Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.
-- 18. Which countries have never won gold medal but have won silver/bronze medals?
-- 19. In which Sport/event, India has won highest medals.
-- 20. Break down all olympic games where india won medal for Hockey and how many medals in each olympic games.