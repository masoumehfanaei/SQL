SELECT *
FROM portfolio.dbo.CovidDeath 
ORDER BY 3,4;

SELECT location,sum(total_cases) AS TotalCases
FROM portfolio.dbo.CovidDeath 
group by location
order by 2 Desc

SELECT date,sum(total_cases) AS TotalCases
FROM portfolio.dbo.CovidDeath 
group by date
order by 2 Desc

SELECT cvd.date, sum(cast(cvd.total_cases AS numeric)) 
,sum(cast(cvv.total_vaccinations as numeric))
FROM portfolio.dbo.CovidDeath cvd
JOIN portfolio.dbo.CovidVaccination cvv
   on cvd.date=cvv.date and
      cvd.location=cvv.location
group by cvd.date
;


DELETE FROM portfolio.dbo.CovidDeath
where location='European Union' or location = 'North America'

SELECT *
FROM portfolio.dbo.CovidVaccination 
ORDER BY 3,4;

--select data that we are going to be using
SELECT location,date,total_cases, new_cases,total_deaths
FROM portfolio.dbo.CovidDeath ORDER BY 1,2;

SELECT population
FROM portfolio.dbo.CovidVaccination;

--looking total cases vs total deaths
SELECT location,date,total_cases, new_cases,total_deaths, (total_deaths/total_cases) AS Deathpercentage
FROM portfolio.dbo.CovidDeath 
ORDER BY 1,2;
--show liklihood of dying if you contract covid in your country
SELECT location,date,total_cases, new_cases,total_deaths, (total_deaths/total_cases) AS Deathpercentage
FROM portfolio.dbo.CovidDeath 
WHERE location = 'Iran'
ORDER BY 1,2;

SELECT location,date,total_cases, new_cases,total_deaths, (total_deaths/total_cases)*100 AS Deathpercentage
FROM portfolio.dbo.CovidDeath 
WHERE location LIKE '%states%'
ORDER BY 1,2;

--looking at total cases vs population
--shows what percentage of population got covid
SELECT location,date,total_cases,population , (total_cases/population)*100 AS Infectpercentage
FROM portfolio.dbo.CovidDeath 
WHERE location LIKE '%states%'
ORDER BY 1,2;

--looking at countries with highest infection rate compared to population
SELECT location,MAX(total_cases),population , MAX(total_cases/population)*100 AS Infectpercentage
FROM portfolio.dbo.CovidDeath 
GROUP BY location, population
ORDER BY Infectpercentage DESC;

--showing countries with highest death count per population
SELECT location,MAX(total_deaths) AS MaxOfTotalDeaths,population , MAX(total_deaths/population)*100 AS Deathpercentage
FROM portfolio.dbo.CovidDeath 
WHERE continent is NOT NULL
GROUP BY location, population
ORDER BY Deathpercentage DESC;

SELECT location,MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM portfolio.dbo.CovidDeath 
WHERE continent is NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;

--let's break things down by continent
SELECT continent,MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM portfolio.dbo.CovidDeath 
WHERE continent is NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

--global numbers
SELECT date,sum(new_cases) AS GlobalCases, sum(cast(new_deaths as int)) AS GlobalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 AS DeathPercentage
FROM portfolio.dbo.CovidDeath 
WHERE continent is not null
GROUP BY date
ORDER BY 2;


--looking at total population vs vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, Sum(cast(vac.new_vaccinations AS int)) over (partition by  dea.location )
FROM portfolio.dbo.CovidDeath dea
JOIN portfolio.dbo.CovidVaccination vac
    ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3;

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, Sum(cast(vac.new_vaccinations AS int)) over (partition by  dea.location order by dea.location, dea.date )
as RollingPeopleVaccinated
FROM portfolio.dbo.CovidDeath dea
JOIN portfolio.dbo.CovidVaccination vac
    ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3;

--create table

CREATE TABLE #PercentPopulationVaccinated
   ( continent varchar(30),
     location varchar(30), 
	 date datetime, 
	 population numeric, 
	 new_vaccinations numeric,
     RollingPeopleVaccinated numeric)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, Sum ( cast(vac.new_vaccinations AS int)) over (partition by  dea.location order by dea.location, dea.date )
as RollingPeopleVaccinated
FROM portfolio.dbo.CovidDeath dea
JOIN portfolio.dbo.CovidVaccination vac
    ON dea.location=vac.location
	AND dea.date=vac.date 
WHERE dea.continent is not null

SELECT * FROM #PercentPopulationVaccinated;




--CTE
With PopvsVac
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From portfolio..CovidDeath dea
Join portfolio..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)

Select (RollingPeopleVaccinated/Population)*100 From PopvsVac 
where new_vaccinations is not null;



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated6 as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio.dbo.CovidDeath dea
Join Portfolio.dbo.CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 





