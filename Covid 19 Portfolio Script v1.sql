

--SELECT *
--FROM CovidVaccinations
--WHERE continent IS NOT NULL
--ORDER BY 3,4

--DATA TO BE USED --

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2

--TOTAL CASES VS TOTAL DEATHS--
--SHOWING LIKELIHOOD FOR BEING INFECTED & DYING FROM COVID IN YOUR COUNTRY--

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM CovidDeaths
WHERE location like '%States%'
AND continent IS NOT NULL
ORDER BY 1,2


--TOTAL CASES AGAINST POPULATION --
--SHOWING TOTAL POPULATION INFECTED WITH COVID--

SELECT location, date, population, total_cases, (total_cases/population)*100 AS PercentagePopulationInfected
FROM CovidDeaths
WHERE location like '%States%'
AND continent IS NOT NULL
ORDER BY 1,2

--COUNTRIES WITH HIGHEST INFECTION RATE--

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentagePopulationInfected
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC

--CONTRIES WITH HIGHEST DEATH COUNT PER POPULATION--

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--CONTINENT DEATH COUNT--

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS BY EACH DAY--
SELECT date, SUM(new_cases) AS TotalDeaths, SUM(cast(new_deaths AS INT)) AS TotalDeaths, SUM(cast(new_deaths as INT))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--GLOBAL NUMBERS TOTAL--
SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths AS INT)) AS TotalDeaths, SUM(cast(new_deaths as INT))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


--TOTAL VACCINATION DAILY USING CTE--

WITH popvsvac (continent, location, date, population, new_vaccinations, DailyTotalVaccinations)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations AS INT)) OVER 
(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS DailyTotalVaccinations
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.continent = vac.continent
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)
Select *, (DailyTotalVaccinations/population)*100
FROM popvsvac

--CREATING A TEMPORARY TABLE--

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date DateTime,
population numeric,
new_vaccinations numeric,
DailyTotalVaccinations numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations AS INT)) OVER 
(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS DailyTotalVaccinations
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.continent = vac.continent
AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

Select *, (DailyTotalVaccinations/population)*100
FROM #PercentPopulationVaccinated


--CREATING VIEWS FOR VISUALIZATION--

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations AS INT)) OVER 
(PARTITION BY dea.location ORDER BY dea.location, dea.date) AS DailyTotalVaccinations
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.continent = vac.continent
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


SELECT *
FROM PercentPopulationVaccinated