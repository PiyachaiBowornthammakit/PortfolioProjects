Tableau Dashboard : https://public.tableau.com/app/profile/piyachai.bowornthammakit/viz/CovidDashboard_16868233785950/Dashboard1?publish=yes

-- First record coronavirus infected in thailand
SELECT
	TOP 1 date,
	continent,
	location as country,
	total_cases
FROM Project..CovidDeaths
WHERE location = 'Thailand' AND (total_cases is not null AND total_cases != 0)
ORDER BY date;

-- First record coronavirus death in thailand
SELECT
	TOP 1 date,
	continent,
	location as country,
	total_deaths
FROM Project..CovidDeaths
WHERE location = 'Thailand' AND (total_deaths is not null AND total_deaths != 0)
ORDER BY date;

-- total case vs total death in thailand
SELECT
	date,
	continent,
	location as country,
	total_cases,
	total_deaths,
	(total_deaths/total_cases)*100 AS death_percentage
FROM Project..CovidDeaths
WHERE location = 'Thailand' AND (total_cases is not null OR total_deaths is not null);

-- total case vs population in thailand
SELECT
	date,
	continent,
	location as country,
	total_cases,
	population,
	(total_cases/population)*100 AS percentage_population_infected
FROM Project..CovidDeaths
WHERE location = 'Thailand' AND total_cases is not null;

-- Countries with the highest population of COVID-19 cases
SELECT
	continent,
	location as country,
	population,
	MAX(total_cases) AS highest_infection_count,
	MAX(total_cases/population)*100 as percent_population_infected
FROM Project..CovidDeaths
WHERE continent is not null 
GROUP BY continent, location, population
ORDER BY highest_infection_count DESC;

-- contintents with the highest death count
SELECT
	continent,
	MAX(cast(Total_deaths as int)) as total_death_count
FROM Project..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY total_death_count DESC;

-- Countries with the highest deaths from COVID-19
SELECT
	continent,
	location as country,
	population,
	MAX(CAST(total_deaths AS int)) AS total_deaths,
	MAX(CAST(total_deaths AS int)/population)*100 as percent_population_deaths
FROM Project..CovidDeaths
WHERE continent is not null 
GROUP BY continent, location, population
ORDER BY total_deaths DESC;

-- countries with the highest receiving covid vaccine
SELECT
	cv.continent,
	cv.location as country,
	cd.population,
	MAX(CAST(cv.total_vaccinations AS int)) AS total_vaccinations,
	(MAX(CAST(cv.total_vaccinations AS int))/cd.population)*100 AS pencentage_total_vaccinations
FROM Project..CovidVaccinations AS cv
JOIN Project..CovidDeaths AS cd
	ON cv.location = cd.location
WHERE cv.continent is not null
GROUP BY cv.continent, cv.location, cd.population
ORDER BY total_vaccinations DESC;

-- total_case and total_deaths of global
SELECT
	SUM(new_cases) AS total_case,
	SUM(CAST(new_deaths AS int)) as total_deaths,
	SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS death_percentage
FROM Project..CovidDeaths
WHERE continent is not null;

-- Total Population vs Vaccinations in Thailand
SELECT
	cd.date,
	cd.continent,
	cd.location as country,
	cd.population,
	cv.new_vaccinations,
	SUM(CONVERT(int, cv.new_vaccinations)) OVER(Partition by cd.location ORDER BY cd.location, cd.date) AS total_new_vaccinations
FROM Project..CovidDeaths AS cd
JOIN Project..CovidVaccinations AS cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent is not null AND cd.location = 'Thailand'
	AND cv.new_vaccinations is not null
ORDER BY cd.continent, cd.location;

-- Using CTE to perform Calculation on Partition By in previous query
WITH thailand_vac AS (SELECT
	cd.date,
	cd.continent,
	cd.location as country,
	cd.population,
	cv.new_vaccinations,
	SUM(CONVERT(int, cv.new_vaccinations)) OVER(Partition by cd.location ORDER BY cd.location, cd.date) AS total_new_vaccinations
FROM Project..CovidDeaths AS cd
JOIN Project..CovidVaccinations AS cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent is not null AND cd.location = 'Thailand'
	AND cv.new_vaccinations is not null
	)
SELECT *,
	(total_new_vaccinations/population)*100 AS percentage_new_vaccine
FROM thailand_vac;
