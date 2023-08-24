--SELECT *
--FROM ProjectPortfolio..CovidVaccinations
--ORDER BY 3,4

SELECT *
FROM ProjectPortfolio..CovidDeaths
where continent IS NOT NULL
ORDER BY 3,4

--select data we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM ProjectPortfolio..CovidDeaths
where continent IS NOT NULL
order by location, date;


--looking at total cases vs total deaths


SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,1) as DEATHPERCENTAGE 
FROM ProjectPortfolio..CovidDeaths
WHERE location LIKE '%state%' 
AND continent IS NOT NULL
order by location, date;

--looking at total cases vs population
--shows what percentage of population got covid

SELECT location, date, population, total_cases, ROUND((total_cases/population)*100,1) as totalcasepercentage
FROM ProjectPortfolio..CovidDeaths
--WHERE location LIKE '%state%'
--AND continent IS NOT NULL
order by location, date;

--looking at countries with highest infection rate compared to population

SELECT location, population, MAX(total_cases) as MaxInfectionCount , ROUND(MAX((total_cases/population))*100,1) as PercentPopulationInfected 
FROM ProjectPortfolio..CovidDeaths
--WHERE location LIKE '%state%'
--AND continent IS NOT NULL
GROUP BY location, population
order by PercentPopulationInfected DESC;


--showing countries with highest death count per population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount  --cast() is to change the datatype   
FROM ProjectPortfolio..CovidDeaths
--WHERE location LIKE '%nigeria%'
WHERE continent IS NOT NULL
GROUP BY location
order by TotalDeathCount DESC;


SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount  --cast() is to change the datatype   
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NULL
GROUP BY location
order by TotalDeathCount DESC;

--LET'S BREAK THIGNS DOWN BY CONTINENT

--CONTINENT WITH HIGHEST TOTAL DEATHS PER POPULATION

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount  --cast() is to change the datatype   
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
order by TotalDeathCount DESC;

--ACROSS THE WORLD

SELECT sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Deathpercentage
FROM ProjectPortfolio..CovidDeaths
WHERE continent IS NOT NULL
order by 1,2;


--LOOKING AT COVIDVACCINATIONS

SELECT *
FROM ProjectPortfolio..CovidVaccinations

--JOINING COVIDDEATHS AND COVIDVACCINATIONS
--LOOKING AT TOTAL VACCINATION VS POPULATION
--USE CTE...cte acts as a virtual tables(with records and columns) that are created during query execution, used by the query, and deleted after the query executes.


with popvsvac (continent, location, date, population, new_vaccinations, RollingCountOfPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(CONVERT(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingCountOfPeopleVaccinated --to add up values of new_vaccinations by the rows i.e a rolling count
FROM ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccinations vac
    ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 note. ORDER BY does not work with CTE.
)
SELECT *, round((RollingCountOfPeopleVaccinated/population),3)*100
FROM popvsvac



--TEMPORAL TABLE

drop Table if exists #percentpopulationvaccinated
CREATE TABLE #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingCountOfPeopleVaccinated numeric
)
insert into #percentpopulationvaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(CONVERT(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingCountOfPeopleVaccinated --to add up values of new_vaccinations by the rows i.e a rolling count
FROM ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccinations vac
    ON dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null

SELECT *, round((RollingCountOfPeopleVaccinated/population),3)*100
FROM #percentpopulationvaccinated

--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW percentpopulationvaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(CONVERT(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingCountOfPeopleVaccinated --to add up values of new_vaccinations by the rows i.e a rolling count
FROM ProjectPortfolio..CovidDeaths dea
JOIN ProjectPortfolio..CovidVaccinations vac
    ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3