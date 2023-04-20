/* Intro */

-- Getting General view of CovidDeaths data --
SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4;

SELECT *
FROM CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY 3, 4;

-- Selecting Data that is going to be used --

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;


/* Looking at Total CAses vs Total Deaths */
-- Shows likelihood of dying one contracted COVID in the Dominican Republic --

SELECT 	location, 
		date, 
		total_cases, 
		total_deaths, 
		(total_deaths/total_cases) * 100 AS Death_Percentage
FROM CovidDeaths
WHERE location LIKE '%Dominican%' AND continent IS NOT NULL
ORDER BY 1, 2;


-- Looking at Total Cases vs Population
-- Shows what percentage of population got COVID

SELECT 	location, 
		date, 
		total_cases, 
		population, 
		(total_cases/population) * 100 AS Percentage_Population_Infected
FROM CovidDeaths
WHERE location LIKE '%Dominican%' AND continent IS NOT NULL
ORDER BY 1, 2;

-- Looking at Countries with Higest Infection Rate compared to Population

SELECT 
	location, 
	population, 
	MAX(total_cases) AS Highest_Infection_Count, 
	MAX((total_cases/population)) * 100 AS Percentage_Population_Infected
FROM CovidDeaths
--WHERE location LIKE '%Dominican%'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Percentage_Population_Infected DESC;

-- Showing Countries with Highest Death Count per Population

SELECT location, MAX(CAST(total_deaths AS int)) AS Total_Death_Count
FROM CovidDeaths
--WHERE location like '%Dominican%' 
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_Death_Count DESC;

/*** Breaking down data BY Continent ***/
-- Showing Continent with the Highest --

SELECT continent, MAX(CAST(total_deaths AS int)) AS Total_Death_Count
FROM CovidDeaths
--WHERE location like '%Dominican%' 
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC;

-- Global Numbers --

SELECT 	date, 
		SUM(new_cases) AS Total_Cases, 
		SUM(CAST(new_deaths AS int)) AS Total_Deaths, 
		SUM(CAST(new_deaths AS int)) / SUM (new_cases) * 100 AS Death_Percentage
FROM CovidDeaths
-- WHERE location LIKE '%Dominican%' 
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;

SELECT 	SUM(new_cases) AS Total_Cases, 
		SUM(CAST(new_deaths AS int)) AS Total_Deaths, 
		SUM(CAST(new_deaths AS int)) / SUM (new_cases) * 100 AS Death_Percentage
FROM CovidDeaths
-- WHERE location LIKE '%Dominican%' 
WHERE continent IS NOT NULL
-- GROUP BY date
ORDER BY 1, 2;

/* Getting General view of CovidVaccination data */

-- Joining tables --
-- Looking at Total Population vs Vaccination --

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

-- Use CTE--

WITH Pop_vs_Vac (continent, location, date, population, new_vaccinations, Rolling_People_Vaccinated)
AS 
(SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) 
	OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated --,(Rolling_People_Vaccinated/population) * 100
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3
)

SELECT *, (Rolling_People_Vaccinated/population)*100
FROM Pop_vs_Vac

-- Temp Table --

DROP TABLE IF EXISTS #Percent_Population_Vaccinated
CREATE TABLE #Percent_Population_Vaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccination numeric,
Rolling_People_Vaccinated numeric
)

INSERT INTO #Percent_Population_Vaccinated
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated --,(Rolling_People_Vaccinated/population) * 100
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
-- WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3;

SELECT *, (Rolling_People_Vaccinated / population) * 100
FROM #Percent_Population_Vaccinated


-- Creating view to store data for later visualization --

CREATE VIEW Percent_Population_Vaccinated AS
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS Rolling_People_Vaccinated --,(Rolling_People_Vaccinated/population) * 100
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
-- ORDER BY 2,3;

SELECT *
FROM Percent_Population_Vaccinated;