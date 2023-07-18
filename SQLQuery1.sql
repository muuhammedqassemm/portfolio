select * 
from portfolioproject..CovidDeath$ 
where continent is not null 
order by 3,4 

--select *  We are selecting the data that we will use 
--from portfolioproject..Covidvaccination$
--order by 3,4
select location, date, total_cases, new_cases, total_deaths, population
from CovidDeath$  
--order by 1,2 the order by is refered to the coloum index 
-- looking for total cases VS. total deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPrecentage
from CovidDeath$  
where location like '%states%'
order by 1,2
--Looking for total cases VS. population 

select location, date, population, total_cases, (total_cases/population)*100  as CasesPrecentage
from portfolioproject..CovidDeath$
where location like '%states%'
order by 1,2
-- Looking for countries with higher infection rate compared to population

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, (MAX(total_cases) / population) * 100 AS PercentagePopulationInfection
FROM portfolioproject..CovidDeath$
GROUP BY location, population
ORDER BY PercentagePopulationInfection desc

-- showing countries with highest death count per population

SELECT location, MAX(cast (total_deaths as int )) AS TotalDeathCount
FROM portfolioproject..CovidDeath$
where continent is not null 
GROUP BY location
ORDER BY TotalDeathCount DESC

--breaking data by continent

SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM portfolioproject..CovidDeath$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

--showing continents with the highst death count per population

SELECT continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
FROM portfolioproject..CovidDeath$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY population DESC;

-- Global numbers 
select SUM(new_cases) as total_casses, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/ SUM(new_cases)*100 as Deathpresentage 
from portfolioproject..CovidDeath$
--where continent is not null
--group by date 
order by 1,2

--- looking for total population V.S total vaccination

SELECT dea.continent, dea.date, dea.location, dea.population_density, vac.new_vaccinations,
       SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.date, dea.location ) AS Rolling_people_vaccinated
FROM portfolioproject..Covidvaccination$ dea
JOIN portfolioproject..Covidvaccination$ vac ON dea.location = vac.location AND dea.date = vac.date
ORDER BY Rolling_people_vaccinated ASC, dea.location DESC;

-- use CTE
WITH popvsvacc AS (
  SELECT dea.continent, dea.date, dea.location, dea.population_density, vac.new_vaccinations,
         SUM(CAST(vac.new_vaccinations AS float)) OVER (PARTITION BY dea.location ORDER BY dea.date, dea.location) AS Rolling_people_vaccinated
  FROM portfolioproject..Covidvaccination$ dea
  JOIN portfolioproject..Covidvaccination$ vac ON dea.location = vac.location AND dea.date = vac.date
)
SELECT *,(Rolling_people_vaccinated / population_density) * 100 as Poeple_vaccinated 
FROM popvsvacc;

-- Temp table
IF OBJECT_ID('tempdb..#precentpopulationvaccinated') IS NOT NULL
    DROP TABLE #precentpopulationvaccinated;

CREATE TABLE #precentpopulationvaccinated (
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATETIME,
    population NUMERIC,
    New_vaccination NUMERIC,
    Rolling_people_vaccinated NUMERIC
);

INSERT INTO #precentpopulationvaccinated
SELECT dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.date, dea.location) AS Rolling_people_vaccinated
FROM portfolioproject..Covidvaccination$ dea
JOIN portfolioproject..Covidvaccination$ vac ON dea.location = vac.location AND dea.date = vac.date;

SELECT *,
    CASE
        WHEN population <> 0 THEN (Rolling_people_vaccinated / population) * 100
        ELSE 0
    END AS People_vaccinated
FROM #precentpopulationvaccinated;

-- golbal numbers by continent
select location, SUM(new_cases) as total_casses, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/ SUM(new_cases)*100 as Deathpresentage 
from portfolioproject..CovidDeath$
where continent is not null
group by location 
order by 1,2

--showing continent with the highst death count per population 


SELECT continent, SUM(CONVERT(int, new_deaths)) AS total_death_count
FROM [portfolioproject].[dbo].[CovidDeath$]
WHERE continent IS NOT NULL
GROUP BY continent;

--creating view to store data for later visualisation 

CREATE VIEW precentpopulationvaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population_density, vac.new_vaccinations,
    CASE
        WHEN dea.population_density <> 0 THEN (SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (PARTITION BY dea.location ORDER BY dea.date, dea.location) / dea.population_density) * 100
        ELSE 0
    END AS People_vaccinated
FROM portfolioproject..Covidvaccination$ dea
JOIN portfolioproject..Covidvaccination$ vac ON dea.location = vac.location AND dea.date = vac.date;

select * from precentpopulationvaccinated












