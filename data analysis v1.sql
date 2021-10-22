-- Select data that is being used

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..['coviddeaths $']
ORDER BY 1,2

-- Looking at total cases vs total deaths (Specific Location)

SELECT location, date, total_cases, total_deaths, round((total_deaths/total_cases * 100),2) AS DeathPercentage
FROM PortfolioProject..['coviddeaths $']
WHERE location like '%states%'
AND continent is not null
ORDER BY 1,2

--Looking at total cases vs population
--Shows what percentage of population got infected with covid

SELECT location, date, population, total_cases, round((total_cases/population * 100),2) AS CovidPercentage
FROM PortfolioProject..['coviddeaths $']
WHERE location like '%states%'
AND continent is not null
ORDER BY 1,2

--Looking at countries with Highest Infection rate compared to population

SELECT location, population, Max(total_cases) AS HighestInfectionCount,
Max(round((total_cases/population * 100),2)) AS PercentPopulationInfected
FROM PortfolioProject..['coviddeaths $']
WHERE continent is not null
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected desc

-- Showing countries with death count per population

SELECT location,Max(cast(total_deaths AS int)) AS TotalDeathCount, population
FROM PortfolioProject..['coviddeaths $']
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location, population
ORDER BY TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing Continents with the highest death count per population

SELECT continent, Max(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..['coviddeaths $']
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as no_of_cases, SUM(cast(new_deaths as int)) as no_of_deaths, 
round(SUM(cast(new_deaths as int)) / SUM(new_cases) * 100 , 2) as DeathPercentage
FROM PortfolioProject..['coviddeaths $']
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1

-- Joining the tables

SELECT * 
FROM PortfolioProject..['coviddeaths $'] dea
JOIN PortfolioProject..covidvaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date

-- Looking at Total Population vs Vaccinations
-- USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, rollingpeoplevaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..['coviddeaths $'] dea
JOIN PortfolioProject..covidvaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (rollingpeoplevaccinated / Population) * 100 AS VacvsPop
FROM PopvsVac

--CREATING TEMP TABLE

DROP TABLE if exists PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population float,
New_vaccinations nvarchar(255),
RollingPeopleVaccinated numeric
)

INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
FROM PortfolioProject..['coviddeaths $'] dea
JOIN PortfolioProject..covidvaccinations$ vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (rollingpeoplevaccinated / Population) * 100 AS VacvsPop
FROM PercentPopulationVaccinated

Create View PercentPopulationVaccinationdone as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['coviddeaths $'] dea
Join PortfolioProject..covidvaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

SELECT * FROM PercentPopulationVaccinationdone
