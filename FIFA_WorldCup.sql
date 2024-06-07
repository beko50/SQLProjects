CREATE TABLE FIFA_WC(
WorldCUp_Year INT,
Positions	INT,
Country	VARCHAR,
Games_Played INT,
Win	INT,
Draw INT,
Loss INT,
Goals_For INT,
Goals_Against INT,
Goal_Difference	INT,
Points	INT,
Win_Rate NUMERIC(3,2)
)

SELECT * FROM FIFA_WC

--Importing CSV data
copy FIFA_WC FROM 'C:\Users\USER\Desktop\bensql\FIFA WC Insights.csv' DELIMITER ',' CSV HEADER;

--Creating a new column (win_percentage) that calculates the win_rate in %
ALTER TABLE FIFA_WC
ADD COLUMN win_percentage NUMERIC(5,2)

UPDATE FIFA_WC
SET win_percentage = win_rate * 100

-- Most goals scored in a particular tournament
SELECT country,goals_for FROM FIFA_WC
WHERE worldcup_year = 2002
ORDER BY goals_for DESC

-- Most goals scored in the 21st Century
SELECT country, SUM(goals_for) AS most_goals 
FROM FIFA_WC
GROUP BY country
ORDER BY most_goals DESC, country

--Number of countries that participated in the 21st Century
SELECT COUNT(DISTINCT country) AS Participating_Countries
FROM FIFA_WC

--Countries with their number of appearances
SELECT Country, COUNT(*) AS Appearances
FROM FIFA_WC
GROUP BY Country
ORDER BY Appearances DESC,Country

--Countries with the BEST WIN percentages - 21st Century
SELECT country,
    SUM(win) AS total_wins,
    SUM(games_played) AS total_games_played,
    ROUND((SUM(win)::numeric / SUM(games_played)) * 100,2) AS win_percentage    -- rounds the win_percentages to 2 dec. places
FROM FIFA_WC
GROUP BY country
ORDER BY win_percentage DESC;


--Countries with best offensive record (goals scored per game)
SELECT country,	
	SUM(games_played) AS total_games_played,
	SUM(goals_for) AS total_scored,
	CASE
		WHEN SUM(goals_for) = 0 THEN 0                       -- for countries who never scored goals in WC, division by 0 is an error so CASE statement needed
		ELSE ROUND((SUM(goals_for)::numeric / SUM(games_played)),1)     -- rounds the offensive record to 1 dec. place
	END AS goals_scored_per_game
FROM FIFA_WC
GROUP BY country
ORDER BY goals_scored_per_game DESC,country


-- Countries with worst defensive record (goals conceded per game)
SELECT country,	
	SUM(games_played) AS total_games_played,
	SUM(goals_against) AS total_conceded,
	CASE
		WHEN SUM(goals_against) = 0 THEN 0                       -- for countries who never conceded goals (not possible tho LOL) in WC, division by 0 is an error
		ELSE ROUND((SUM(goals_against)::numeric / SUM(games_played)),1)     -- rounds the offensive record to 1 dec. place
	END AS goals_conceded_per_game
FROM FIFA_WC
GROUP BY country
ORDER BY goals_conceded_per_game DESC,country


--Total number of wins, draws and losses of countries in 21st century
SELECT country,
	SUM(win) AS total_wins,
	SUM(draw) AS total_draws,
	SUM(loss) AS total_losses
FROM FIFA_WC
GROUP BY country
ORDER BY total_wins DESC

-- Countries with MOST POINTS accumulated in 21st century
SELECT country, SUM(points) AS points_accumulated
FROM FIFA_WC
GROUP BY country
ORDER BY points_accumulated DESC,country

-- Tournaments with most goals scored
SELECT worldcup_year, SUM(goals_for) AS tournament_goals_scored
FROM FIFA_WC
GROUP BY worldcup_year
ORDER BY tournament_goals_scored DESC

-- Tournament with least goals conceded
SELECT worldcup_year, SUM(goals_against) AS tournament_goals_conceded
FROM FIFA_WC
GROUP BY worldcup_year
ORDER BY tournament_goals_conceded; 

