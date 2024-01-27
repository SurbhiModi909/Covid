SELECT *
FROM [Project ]..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 3,4

SELECT *
FROM [Project ]..CovidVaccinations
ORDER BY 3,4

--Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [Project ]..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2 

-- Calculating the mortality rate for Covid cases
-- Determines the probability of death upon contracting Covid in United States

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM [Project ]..CovidDeaths
WHERE location like '%States%'
AND continent is NOT NULL
ORDER BY 1,2 

-- Comparing total population against the overall population size
-- Determines the percentage of total population of the country affected by Covid

SELECT Location, date, population, total_cases, (total_cases/population) * 100 as PercentPopulationInfected
FROM [Project ]..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2 

--Indentifying countries with highest infection rate per capita

SELECT Location, population, MAX(total_cases) as HigestInfectionCount, MAX((total_cases/population)) * 100 as PercentPopulationInfected
FROM [Project ]..CovidDeaths
WHERE continent is NOT NULL
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC 

--Identifying countries with highest deaths per capita

SELECT Location, MAX(Cast(Total_deaths as int)) as TotalDeathCount
FROM [Project ]..CovidDeaths
WHERE continent is NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC 

--ANALYSIS ACROSS CONTINENTS

-- Identifying Total Death count by continents 

SELECT continent, MAX(Cast(Total_deaths as int)) as TotalDeathCount
FROM [Project ]..CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC 

--

--GLOBAL ANALYSIS 

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM [Project ]..CovidDeaths
WHERE continent is not null 
ORDER BY 1,2

--Analysing Total population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Project ]..CovidDeaths dea
JOIN [Project ]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
ORDER BY 2,3

--Using CTE to perform Calculation on Partition By in previous query

WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Project]..CovidDeaths dea
Join [Project ]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 
--order by 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopVsVac

-- Creating View to store data for Visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM [Project ]..CovidDeaths dea
Join [Project ]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null 

SELECT *
FROM PercentPopulationVaccinated

--QUERIES USED FOR TABLEAU

--Table 1 - Total Cases, Deaths and Death Percentage around the World

CREATE VIEW Table1_TotalAroundTheWorld AS
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as INT)) as total_deaths, SUM(CAST(new_deaths as INT))/SUM(New_Cases)*100 as DeathPercentage
FROM [Project ]..CovidDeaths
WHERE continent is not null 

--Table 2 -Continent Wise Total Death Count

CREATE VIEW Table2_ContinentWiseTotalDeathCount AS
SELECT location, SUM(CAST(new_deaths as INT)) as TotalDeathCount
FROM [Project ]..CovidDeaths
WHERE continent is NULL
AND location not in ('World', 'European Union', 'International')
GROUP BY location 

--Table 3 - Highest Infection Count

CREATE VIEW Table3_HighestInfectionCount AS
SELECT Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected 
FROM [Project ]..CovidDeaths
GROUP BY location, population

--Table 4 Datewise Highest Infection Count

CREATE VIEW Table4_DatewiseHighestInfectionCount AS
SELECT Location, Population, Date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected 
FROM [Project ]..CovidDeaths
GROUP BY location, population, date

--Tableau Dashboard Link
https://public.tableau.com/app/profile/surbhi.modi8337/viz/CovidDashboard_17063149353950/Dashboard1?publish=yes
