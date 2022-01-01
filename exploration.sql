/*

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views
*/

SELECT 
    *
FROM
    coviddeaths
WHERE
    continent IS NOT NULL
        AND location LIKE 'United States'
ORDER BY 4
;

-- Select Data that we are going to be starting with

SELECT 
    Location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM
    coviddeaths
WHERE
    continent NOT LIKE '0'
ORDER BY 1 , 2
;

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT 
    Location,
    date,
    total_cases,
    total_deaths,
    (total_deaths / total_cases) * 100 AS DeathPercentage
FROM
    coviddeaths
WHERE
    location LIKE '%states%'
        AND continent NOT LIKE '0'
ORDER BY 1 , 2
;

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

SELECT 
    Location,
    date,
    Population,
    total_cases,
    (total_cases / population) * 100 AS PercentPopulationInfected
FROM
    coviddeaths
WHERE
    location LIKE '%states%'
ORDER BY 1 , 2
;

-- Countries with Highest Infection Rate compared to Population

SELECT 
    Location,
    Population,
    MAX(total_cases) AS HighestInfectionCount,
    MAX((total_cases / population)) * 100 AS PercentPopulationInfected
FROM
    coviddeaths
GROUP BY Location , Population
ORDER BY PercentPopulationInfected DESC
;

-- Countries with Highest % of Population Dead to Covid

SELECT 
    Location,
    MAX(Total_deaths) AS TotalDeathCount,
    MAX((total_deaths / population)) * 100 AS PercentPopulationDead
FROM
    coviddeaths
WHERE
    continent NOT LIKE '0'
GROUP BY Location
ORDER BY PercentPopulationDead DESC
;


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count

SELECT 
    continent, MAX(Total_deaths) AS TotalDeathCount
FROM
    coviddeaths
WHERE
    continent NOT LIKE '0'
GROUP BY continent
ORDER BY TotalDeathCount DESC
;


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
From coviddeaths
-- Where location like '%states%'
where continent not like '0'

order by 1,2
;


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.people_vaccinated,
    vac.people_vaccinated / dea.population * 100 as '%_at_least_one_Covid_vaccine'
FROM
    coviddeaths dea
        JOIN
    covidvaccinations vac ON dea.location = vac.location
        AND dea.date = vac.date
WHERE
    dea.continent NOT LIKE '0' 
    -- and dea.location LIKE '%states%'
ORDER BY 2 , 3
;

-- Shows Percentage of Population that is fully vaccinated
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.people_fully_vaccinated,
    vac.people_fully_vaccinated / dea.population * 100 as '%_fully_vaccinated'
FROM
    coviddeaths dea
        JOIN
    covidvaccinations vac ON dea.location = vac.location
        AND dea.date = vac.date
WHERE
    dea.continent NOT LIKE '0' 
    -- and dea.location LIKE '%states%'
ORDER BY 2 , 3
;


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, People_Fully_Vaccinated, Percent_Fully_Vaccinated)
as
(
SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.people_fully_vaccinated,
    vac.people_fully_vaccinated / dea.population * 100 as '%_fully_vaccinated'
FROM
    coviddeaths dea
        JOIN
    covidvaccinations vac ON dea.location = vac.location
        AND dea.date = vac.date
WHERE
    dea.continent NOT LIKE '0' 
    -- and dea.location LIKE '%states%'
ORDER BY 2 , 3
)
Select *
From PopvsVac
;



-- Using Temp Table to perform Calculation in previous query

DROP Table if exists PercentPopulationVaccinated;
Create Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population bigint,
People_Fully_Vaccinated bigint,
Percent_Fully_Vaccinated double(6,4)
)
;

Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.people_fully_vaccinated as People_Fully_Vaccinated,
    vac.people_fully_vaccinated / dea.population * 100 as Percent_Fully_Vaccinated

From coviddeaths dea
Join covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent not like '0'
order by 2,3
;

Select *
From PercentPopulationVaccinated
;




-- Creating Some Views to store data for later visualizations

Create View PercentPopulationVaccinatedbyCountry as
Select dea.continent, dea.location, dea.population, max(vac.people_fully_vaccinated) as People_Fully_Vaccinated, max(vac.people_fully_vaccinated) / population * 100 as Percent_Fully_Vaccinated 
From coviddeaths dea
Join covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent not like '0'
group by location
order by population desc
;

Create View DeathCountByContinent as
SELECT 
    continent, MAX(Total_deaths) AS TotalDeathCount
FROM
    coviddeaths
WHERE
    continent NOT LIKE '0'
GROUP BY continent
ORDER BY TotalDeathCount DESC
; 
