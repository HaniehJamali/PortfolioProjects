

SELECT *
FROM PortfolioProject..CovidDeath
WHERE continent IS NOT NULL
ORDER BY 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4

--Selecting Data that we want
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeath
WHERE continent IS NOT NULL
ORDER BY 1, 2

--Total Death vs Total Case
SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 As DeathPercentage
FROM PortfolioProject..CovidDeath
WHERE continent IS NOT NULL
ORDER BY 1, 2

--Probability of Dying in Each Country
SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 As DeathPercentage
FROM PortfolioProject..CovidDeath
WHERE location='United Kingdom'AND total_cases IS NOT NULL AND total_deaths IS NOT NULL
ORDER BY 1, 2



--Total Case vs Population (Percentage of Population Got Covid)

SELECT location, date, total_cases, population, (total_cases/population)*100 As GotCovidPercentage
FROM PortfolioProject..CovidDeath
WHERE location='United Kingdom' AND total_cases IS NOT NULL 
ORDER BY 1,2


--Highest Rate of Getting Covid in Each Country
SELECT location, population	, MAX(total_cases) AS MaxCase, MAX((total_cases/population))*100 As MaxRateGotCovid
FROM PortfolioProject..CovidDeath
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY MaxRateGotCovid DESC

--Highest Rate of Death in Each Country
SELECT location,population, MAX(CAST(total_deaths as int)) AS TotalDeath, MAX((total_deaths/population))*100 As MaxRateOfDeath 
FROM PortfolioProject..CovidDeath
WHERE continent IS NOT NULL
Group By location,population
ORDER BY TotalDeath DESC

--Rate of Death in Each Continent
SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeath, MAX((total_deaths/population))*100 As MaxRateOfDeath 
FROM PortfolioProject..CovidDeath
WHERE continent IS NOT NULL
Group By continent
ORDER BY TotalDeath DESC

--Highest Rate of Death in Each Continent (Real Ansewer for This Data Set) 
SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeath, MAX((total_deaths/population))*100 As MaxRateOfDeath 
FROM PortfolioProject..CovidDeath
WHERE continent IS NULL
Group By location
ORDER BY TotalDeath DESC


--Daily World Numbers
 SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths as int)) AS TotalDeaths,
 SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
 FROM PortfolioProject..CovidDeath
 WHERE continent IS NOT NULL
 GROUP BY date
 ORDER BY 1,2

 --Overall World Numbers
  SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths as int)) AS TotalDeaths,
  SUM(CAST(new_deaths as int))/SUM(new_cases) AS DeathPercentage
 FROM PortfolioProject..CovidDeath
 WHERE continent IS NOT NULL


 SELECT *
 FROM PortfolioProject..CovidVaccinations

 --Total Vaccination vs Population
 SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
 SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS TotalVaccination
  FROM PortfolioProject..CovidDeath death
 Join PortfolioProject..CovidVaccinations vac
 	ON death.location=vac.location AND death.date=vac.date
WHERE death.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL
ORDER BY 2, 3


 --Using CTEs
 WITH PopvsVac (Continent, Location, Date, Population, NewVaccination, TotalVaccination) AS
 (
 SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS TotalVaccination
  FROM PortfolioProject..CovidDeath death
 Join PortfolioProject..CovidVaccinations vac
 	ON death.location=vac.location AND death.date=vac.date
WHERE death.continent IS NOT NULL
)

SELECT *, TotalVaccination/Population*100 AS VaccinationPercentage
FROM PopvsVac


--Using Temp Table

DROP Table if Exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
NewVaccination numeric,
TotalVaccination numeric)

INSERT INTO #PercentPopulationVaccinated
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations as numeric)) OVER (PARTITION BY death.location ORDER BY death.location, death.date) AS TotalVaccination
  FROM PortfolioProject..CovidDeath death
 Join PortfolioProject..CovidVaccinations vac
 	ON death.location=vac.location AND death.date=vac.date
WHERE death.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL

SELECT *, TotalVaccination/Population*100 AS VaccinationPercentage
FROM #PercentPopulationVaccinated;



--Creating a View to Store Data
CREATE VIEW PercentPopulationVaccinated AS 
SELECT death.continent, death.location, death.date, death.population, vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations as numeric)) OVER
 (PARTITION BY death.location ORDER BY death.location, death.date) AS TotalVaccination
  FROM PortfolioProject..CovidDeath death
 Join PortfolioProject..CovidVaccinations vac
 	ON death.location=vac.location AND death.date=vac.date
WHERE death.continent IS NOT NULL AND vac.new_vaccinations IS NOT NULL

SELECT *
From PercentPopulationVaccinated
