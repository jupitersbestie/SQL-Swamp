SELECT *
FROM PortfolioProject..COVIDDeaths$
ORDER BY 3, 4

--SELECT *
--FROM PortfolioProject..COVIDVaccinations$
--ORDER BY 3, 4

-- Selecting data to be utilized for project

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..COVIDDeaths$
ORDER BY 1,2

--Looking at total cases vs total deaths
--A look at the likelihood of dying if you contract COVID in a given country
SELECT location, date, total_cases, total_deaths, (CONVERT(FLOAT, total_deaths)/NULLIF(CONVERT(float, total_cases),0))*100 as DeathPercentage
FROM PortfolioProject..COVIDDeaths$
WHERE location like '%states%'
ORDER BY 1,2

--Taking a look at total cases vs population
SELECT location, date, total_cases, population, (CONVERT(FLOAT, total_cases)/NULLIF(CONVERT(float, population),0))*100 as DeathPercentage
FROM PortfolioProject..COVIDDeaths$
--WHERE location like '%states%'
ORDER BY 1,2

-- Looking at countries wit highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX(CONVERT (float, total_cases)/NULLIF(CONVERT(float, population),0))*100 as PercentPopulationInfected
FROM PortfolioProject..COVIDDeaths$
GROUP BY population, location
ORDER BY PercentPopulationInfected desc

--Countries with highest death count per population
SELECT location, population, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..COVIDDeaths$
GROUP BY population, location
ORDER BY TotalDeathCount desc

--Breaking things down by continent
SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..COVIDDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

--Global Numbers
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(CONVERT (float, total_cases)/NULLIF(CONVERT(float, total_deaths),0))*100 as DeathPercentage --(CONVERT(FLOAT, total_deaths)/NULLIF(CONVERT(float, total_cases),0))*100 as DeathPercentage
FROM PortfolioProject..COVIDDeaths$
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


SELECT *
FROM COVIDDeaths$ dea
join COVIDVaccinations$ vac
ON dea.location = vac.location and dea.date = vac.date 
WHERE dea.continent is not null
ORDER BY 2,3

--Total population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM COVIDDeaths$ dea
join COVIDVaccinations$ vac
ON dea.location = vac.location and dea.date = vac.date 
WHERE dea.continent is not null
ORDER BY 2,3

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
