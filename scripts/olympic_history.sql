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
-- 3. Mention the total no of nations who participated in each olympics game?
-- 4. Which year saw the highest and lowest no of countries participating in olympics?
-- 5. Which nation has participated in all of the olympic games?

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
-- 8. Fetch the total no of sports played in each olympic games.
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
-- 13. Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.

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
--===================================================================================================================================================================--
-- 17. Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.
-- 18. Which countries have never won gold medal but have won silver/bronze medals?
-- 19. In which Sport/event, India has won highest medals.
-- 20. Break down all olympic games where india won medal for Hockey and how many medals in each olympic games.