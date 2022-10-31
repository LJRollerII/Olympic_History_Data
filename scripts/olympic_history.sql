/*Test
SELECT *
FROM athlete_events

SELECT *
FROM noc_regions*/

--===============================================================================================================--

-- 1. How many olympics games have been held?

SELECT COUNT(DISTINCT games)
FROM athlete_events

-- Answer: 51 Olympic Games have been held

--===============================================================================================================--
-- 2. List down all Olympics games held so far.
-- 3. Mention the total no of nations who participated in each olympics game?
-- 4. Which year saw the highest and lowest no of countries participating in olympics?
-- 5. Which nation has participated in all of the olympic games?

--===============================================================================================================--
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

--===============================================================================================================--


-- 7. Which Sports were just played only once in the olympics?
-- 8. Fetch the total no of sports played in each olympic games.
-- 9. Fetch details of the oldest athletes to win a gold medal.
-- 10. Find the Ratio of male and female athletes participated in all olympic games.
--===============================================================================================================--
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

--===============================================================================================================--
-- 12. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).
-- 13. Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.
-- 14. List down total gold, silver and broze medals won by each country.
-- 15. List down total gold, silver and broze medals won by each country corresponding to each olympic games.
-- 16. Identify which country won the most gold, most silver and most bronze medals in each olympic games.
-- 17. Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.
-- 18. Which countries have never won gold medal but have won silver/bronze medals?
-- 19. In which Sport/event, India has won highest medals.
-- 20. Break down all olympic games where india won medal for Hockey and how many medals in each olympic games.