CREATE TABLE CovidDeath(
iso_code	VARCHAR(30),
continent	VARCHAR(30),
locations	VARCHAR(100),
dates	DATE,
population	BIGINT,
total_cases	INTEGER,
new_cases	INTEGER,
new_cases_smoothed	NUMERIC(10,3),
total_deaths INTEGER,
new_deaths	INTEGER,
new_deaths_smoothed	DECIMAL(10,3),
total_cases_per_million	DECIMAL(10,3),
new_cases_per_million	DECIMAL(10,3),
new_cases_smoothed_per_million	DECIMAL(10,3),
total_deaths_per_million	DECIMAL(10,3),
new_deaths_per_million	DECIMAL(10,3),
new_deaths_smoothed_per_million	DECIMAL(10,3),
reproduction_rate	DECIMAL(10,3),
icu_patients	INTEGER,
icu_patients_per_million DECIMAL(10,3),
hosp_patients	INTEGER,
hosp_patients_per_million	DECIMAL(10,3),
weekly_icu_admissions	DECIMAL(10,3),
weekly_icu_admissions_per_million	DECIMAL(10,3),
weekly_hosp_admissions	DECIMAL(10,3),
weekly_hosp_admissions_per_million DECIMAL(10,3)
)
SELECT * FROM CovidDeath

--Total cases vs Total deaths  
-- shows the likelihood of dying if person contracts COVID in Ghana 
SELECT locations,dates,total_cases,total_deaths,(total_deaths::NUMERIC/total_cases)*100 AS death_rate FROM CovidDeath  
WHERE locations = 'Ghana'
ORDER BY death_rate DESC

--Total cases vs Population
-- shows the rate at which people are contracting covid in Ghana and Africa
SELECT locations,dates,population,total_cases,(total_cases::NUMERIC/population)*100 AS contraction_rate FROM CovidDeath  --total_patients cannot be added to WHERE clause, CTE is needed
WHERE locations = 'Ghana' OR continent = 'Africa' AND dates BETWEEN '2020-12-01' AND '2021-01-01'      --dates between December 2020 and January 2021
ORDER BY 1,2

 WITH CTE AS (                             --CTE(common table expressions) allows to define aliases in a query
  SELECT (total_deaths::NUMERIC/total_cases)*100 AS death_rate, locations
  FROM CovidDeath
)
SELECT total_patients, locations
FROM CTE
WHERE locations = 'Ghana' OR total_patients > 200;  

-- Number of cities within locations
SELECT locations,COUNT(locations) AS cities FROM CovidDeath
GROUP BY locations

-- Grouping total deaths by continents
SELECT locations,population,MAX(total_deaths) AS Death_Counts FROM CovidDeath
WHERE continent IS NULL   
GROUP BY locations,population
ORDER BY Death_Counts DESC

-- Countries with the highest CONTRACTION rate
SELECT locations,population,MAX(total_cases) AS Total_Contraction, MAX(total_cases::NUMERIC/population)*100 AS Percent_Contracted FROM CovidDeath
--WHERE locations LIKE '%Africa%'
GROUP BY locations,population
ORDER BY Percent_Contracted DESC

--Countries with the highest DEATHS
SELECT locations,population,MAX(total_deaths) AS Max_Deaths FROM CovidDeath
WHERE continent IS NOT NULL     --excludes the continent
GROUP BY locations,population
ORDER BY Max_Deaths DESC



-- CREATING NEW TABLE 
CREATE TABLE CovidVaccination(
iso_code	VARCHAR(30),
continent	VARCHAR(30),
locations	VARCHAR(100),
dates	DATE,
new_tests	BIGINT,
total_tests	BIGINT,
total_tests_per_thousand NUMERIC(10,3),
new_tests_per_thousand	NUMERIC(10,3),
new_tests_smoothed	BIGINT,
new_tests_smoothed_per_thousand	NUMERIC(10,3),
positive_rate	NUMERIC(10,3),
tests_per_case	NUMERIC(10,3),
tests_units	VARCHAR,
total_vaccinations	BIGINT,
people_vaccinated	BIGINT,
people_fully_vaccinated	BIGINT,
new_vaccinations	BIGINT,
new_vaccinations_smoothed	BIGINT,
total_vaccinations_per_hundred	NUMERIC(10,3),
people_vaccinated_per_hundred	NUMERIC(10,3),
people_fully_vaccinated_per_hundred	NUMERIC(10,3),
new_vaccinations_smoothed_per_million BIGINT    
)
SELECT * FROM CovidVaccination

-- JOINING THE 2 TABLES CovidDeath and CovidVaccination
SELECT cd.continent,cd.locations,cd.dates,cd.population,cv.new_vaccinations
FROM CovidDeath cd
INNER JOIN CovidVaccination cv
ON cd.locations = cv.locations AND cd.dates = cv.dates
WHERE cd.locations = 'Ghana' OR cd.locations = 'Canada'
ORDER BY cd.continent DESC,cv.new_vaccinations DESC

-- Rolling count (Fibonacci sequence) for values in a column (FIBONACCI_COUNT)
SELECT cd.continent,cd.locations,cd.dates,cd.population,cv.new_vaccinations,
SUM(cv.new_vaccinations::BIGINT) OVER (PARTITION BY cd.locations ORDER BY cd.locations,cd.dates) AS Fibonacci_Count
FROM CovidDeath cd 
INNER JOIN CovidVaccination cv
ON cd.locations = cv.locations AND cd.dates = cv.dates


-- CREATING VIEWS (a virtual table created from the result of a SELECT query)
CREATE VIEW PeopleVaccinated AS 
SELECT cd.continent,cd.locations,cd.dates,cd.population,cv.new_vaccinations,
SUM(cv.new_vaccinations::BIGINT) OVER (PARTITION BY cd.locations ORDER BY cd.locations,cd.dates) AS Fibonacci_Count
FROM CovidDeath cd
INNER JOIN CovidVaccination cv
ON cd.locations = cv.locations AND cd.dates = cv.dates
WHERE cd.continent IS NOT NULL

SELECT * FROM PeopleVaccinated