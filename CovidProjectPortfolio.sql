--All the data from Covid deaths
	SELECT * 
	FROM PortfolioProject.dbo.Covid_Deaths
	ORDER BY 3, 4

	SELECT location, date, total_cases, new_cases, total_deaths, population
	FROM PortfolioProject.dbo.Covid_Deaths
	ORDER BY 1, 2

--total cases vs total deaths
--shows likelihood of dying from covid if infected in the United States
	SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
	FROM PortfolioProject.dbo.Covid_Deaths
	WHERE location like '%states%'
	ORDER BY 1, 2

--total cases vs population
--percentage of population infected with covid
	SELECT location, date, total_cases, population, (total_cases/population)*100 As PercentageOfPopulationInfected
	FROM PortfolioProject.dbo.Covid_Deaths
	ORDER BY 1, 2

--Countries with highest infection rate compared to population
	SELECT location, population, MAX(total_cases) AS Highest_Cases, MAX(total_cases/population)*100 As HighestInfectedCountries
	FROM PortfolioProject.dbo.Covid_Deaths
	GROUP BY location, population
	ORDER BY HighestInfectedCountries DESC

--Countries with highest death count per population
	SELECT location, MAX(cast(total_deaths AS int)) AS Highest_Deaths
	FROM PortfolioProject.dbo.Covid_Deaths
	WHERE continent IS NOT NULL
	GROUP BY location
	ORDER BY Highest_Deaths DESC

--Continent with highest death count
		SELECT continent, MAX(cast(total_deaths AS int)) AS Highest_Deaths
		FROM PortfolioProject.dbo.Covid_Deaths
		WHERE continent IS NOT NULL
		GROUP BY Continent
		ORDER BY Highest_Deaths DESC

	--Total global death percentage
	SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths AS int))/SUM(New_cases)*100 AS
	Death_Percentage	
	FROM PortfolioProject.dbo.Covid_Deaths
	WHERE continent IS NOT NULL
	--GROUP BY date
	ORDER BY 1, 2


	--Total Population vs Vaccinations
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS Rolling_Vaccination_Count,
	--(Rolling_Vaccination_Count/Population)*100 (here Rolling_Vaccination_Count could not be used as it was just created. CTE or temp table are needed. 
		FROM PortfolioProject.dbo.Covid_Deaths dea
	JOIN PortfolioProject.dbo.Covid_Vaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
		WHERE dea.continent IS NOT NULL
		ORDER BY 2, 3
	
	--Using CTE
	WITH PopulationVaccination (Continent, location, date, population,new_vaccinations, Rolling_Vaccination_Count)
	as
	(
		SELECT dea.continent, dea.location, dea.date, dea.population, new_vaccinations,
	SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS Rolling_Vaccination_Count
	--(Rolling_Vaccination_Count/Population)*100
	FROM PortfolioProject.dbo.Covid_Deaths dea
	JOIN PortfolioProject.dbo.Covid_Vaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
		WHERE dea.continent IS NOT NULL
		)

		SELECT *, (Rolling_Vaccination_Count/population)*100 AS PercenatgeOfPopulationVaccinated
		FROM PopulationVaccination
		

		--Temp Table
		DROP TABLE IF EXISTS PercentageOfPeopleVaccinated
		CREATE TABLE PercentageOfPeopleVaccinated
		(
		Continent nvarchar(255),
		location nvarchar(255),
		Date datetime,
		Population numeric,
		New_vaccinations numeric,
		Rolling_Vaccination_Count numeric
		)
		INSERT INTO PercentageOfPeopleVaccinated
		SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS Rolling_Vaccination_Count
	--(Rolling_Vaccination_Count/Population)*100
	FROM PortfolioProject.dbo.Covid_Deaths dea
	JOIN PortfolioProject.dbo.Covid_Vaccinations vac
		ON dea.location = vac.location
				AND dea.date = vac.date

	SELECT *, (Rolling_Vaccination_Count/Population)*100 AS PercentagePeopleVaccinated
	FROM PercentageOfPeopleVaccinated

	--Creating VIEW to store data for later visualizations
	CREATE VIEW PercentageOfPeopleVaccinated
	AS
		SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS Rolling_Vaccination_Count
	--(Rolling_Vaccination_Count/Population)*100
	FROM PortfolioProject.dbo.Covid_Deaths dea
	JOIN PortfolioProject.dbo.Covid_Vaccinations vac
		ON dea.location = vac.location
				AND dea.date = vac.date



	

		

	
	
	
