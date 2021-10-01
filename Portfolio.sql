-- Looking at the general data
SELECT *
FROM PortfolioPorject..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT *
FROM PortfolioPorject..CovidVaccinations
ORDER BY 3,4

-- Select Data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioPorject..CovidDeaths$
ORDER BY 1,2

-- Looking at Total Cases VS Total Deaths in Argentina
SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases) * 100 AS Deathporcentaje 
FROM PortfolioPorject..CovidDeaths$
WHERE location like '%Arg%' AND location IS NOT NULL
ORDER BY 1,2

-- Looking at Total Cases VS Populatio
SELECT location, date, total_cases, population,(total_cases/population) * 100 AS Caseporcentaje 
FROM PortfolioPorject..CovidDeaths$
WHERE location like '%Arg%' AND location IS NOT NULL
ORDER BY 1,2

-- Looking at countries with highest infection rated compared to population
SELECT location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population)) * 100 AS PopulationInfected 
FROM PortfolioPorject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PopulationInfected DESC

-- Breaking things down by continent
SELECT continent, MAX(CAST(total_deaths AS INT)) AS HighestDeathCount  
FROM PortfolioPorject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC
 
 -- Showing the countries with the highest death count per population
SELECT location, MAX(CAST(total_deaths AS INT)) AS HighestDeathCount  
FROM PortfolioPorject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY HighestDeathCount DESC

--Calculatig global numbers
SELECT  SUM(CAST(new_cases AS INT)) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases) * 100 AS Deathporcentaje 
FROM PortfolioPorject..CovidDeaths$
WHERE continent IS NOT NULL 
ORDER BY 1,2

-- Looking total population vs vaccinations
-- Shows percentage of population that has recieved at least one covid vaccine

SELECT dea.continent, dea. location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinated
--(PeopleVaccinated/population)*100
FROM PortfolioPorject..CovidDeaths$ dea
JOIN PortfolioPorject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- Creating a CTE to perform calculation on partition by in previous query
WITH Popvsvac (contienent, location, date,population, new_vaccionations, PeopleVaccinated)
AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinated
FROM PortfolioPorject..CovidDeaths$ dea
JOIN PortfolioPorject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *,(PeopleVaccinated/population) AS PorcentageVaccinated
FROM Popvsvac

--Using CTE to perform calculation on partition by in previous query
DROP TABLE IF EXISTS #PercentPeopleVaccinated
CREATE TABLE #PercentPeopleVaccinated(
contienent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
PeopleVaccinated numeric,
)

INSERT INTO #PercentPeopleVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinated
FROM PortfolioPorject..CovidDeaths$ dea
JOIN PortfolioPorject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date

SELECT *, (PeopleVaccinated/population)*100
FROM #PercentPeopleVaccinated

--Creating a view to store data for visualizations
CREATE VIEW PercentPeopleVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS PeopleVaccinated
FROM PortfolioPorject..CovidDeaths$ dea
JOIN PortfolioPorject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL