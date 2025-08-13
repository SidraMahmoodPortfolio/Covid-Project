-- Exploratory Data Analysis

SELECT *
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

SELECT *
FROM CovidProject..CovidVaccinations
ORDER BY 3,4;

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Total Cases vs Total Deaths

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM CovidProject..CovidDeaths
WHERE location LIKE '%kingdom%'
AND continent IS NOT NULL
ORDER BY 1,2;

-- Total Cases vs Population

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS Percent_Population_Infected
FROM CovidProject..CovidDeaths
WHERE location LIKE '%kingdom%'
AND continent IS NOT NULL
ORDER BY 1,2;

-- Countries with Highest Infection Rate compared to Population

SELECT Location, population, Max(total_cases) AS Highest_Infection_Count, MAX((total_cases/population)*100)
    AS Percent_Population_Infected
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Percent_Population_Infected DESC;

-- Countries with Highest Death Count per Population

SELECT Location, MAX(cast(total_deaths as int)) AS Total_Death_Count
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Total_Death_Count DESC;

-- Continental Deaths

SELECT continent, MAX(cast(total_deaths as int)) AS Total_Death_Count
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC;

SELECT continent, MAX(cast(total_deaths as int)) AS Total_Death_Count
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC;

SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS death_percentage
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY total_cases;

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS death_percentage
FROM CovidProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY total_cases;
 
 SELECT death.continent, death.location, death.date,death.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location,
   death.date) AS Rolling_Count
 FROM CovidProject..CovidDeaths AS death
 INNER JOIN CovidProject..CovidVaccinations AS vac
     ON death.location = vac.location 
     AND death.date = vac.date
WHERE death.continent IS NOT NULL
ORDER BY 2,3;

WITH population_vs_vaccination (Continent, Location, Date, Population, New_Vaccinations, Rolling_Count) AS
(
 SELECT death.continent, death.location, death.date,death.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location,
   death.date) AS Rolling_Count
 FROM CovidProject..CovidDeaths AS death
 INNER JOIN CovidProject..CovidVaccinations AS vac
     ON death.location = vac.location 
     AND death.date = vac.date
WHERE death.continent IS NOT NULL
)
SELECT *, (Rolling_Count/Population)*100
FROM population_vs_vaccination;

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_Count numeric
);

INSERT INTO #PercentPopulationVaccinated
SELECT death.continent, death.location, death.date,death.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location,
  death.date) AS Rolling_Count
FROM CovidProject..CovidDeaths AS death
INNER JOIN CovidProject..CovidVaccinations AS vac
     ON death.location = vac.location 
     AND death.date = vac.date
WHERE death.continent IS NOT NULL;

SELECT *, (Rolling_Count/Population)*100
FROM #PercentPopulationVaccinated;

-- CREATING VIEW TO STORE DATA FOR LATER VISUALISATION

CREATE VIEW Percent_Population_Vaccinated AS
SELECT death.continent, death.location, death.date,death.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location,
  death.date) AS Rolling_Count
FROM CovidProject..CovidDeaths AS death
INNER JOIN CovidProject..CovidVaccinations AS vac
     ON death.location = vac.location 
     AND death.date = vac.date
WHERE death.continent IS NOT NULL

CREATE VIEW Percent_Population_Infected AS
Select Location, Population, MAX(total_cases) as HighestInfectionCount, 
Max((total_cases/population))*100 as PercentPopulationInfected
From CovidProject..CovidDeaths
Group by Location, Population

CREATE VIEW Death_Percentage AS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidProject..CovidDeaths
where continent is not null 

CREATE VIEW Total_Death AS
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
