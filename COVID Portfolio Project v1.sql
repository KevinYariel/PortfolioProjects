Select *
From PortfolioProject1..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject1..CovidVaccinations
--order by 3,4

-- Select Data we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject1..CovidDeaths
Where continent is not null
order by 1,2

-- Looking at Total Cases vs. Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (CONVERT(DECIMAL(12,2),total_deaths)/CONVERT(DECIMAL(12,2),total_cases))*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
Where location like '%states%'
order by 1,2

--Looking at Total Cases vs population
--Shows what percentage of population got covid
Select Location, date,Population, total_cases, (CONVERT(DECIMAL(12,2),total_cases)/CONVERT(DECIMAL(12,2),Population))*100 as PercentofPopulationInfected
From PortfolioProject1..CovidDeaths
Where location like '%states%' and
total_cases is NOT NULL and
Population is NOT NULL
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX(CONVERT(DECIMAL(12,2),total_cases)/CONVERT(DECIMAL(12,2),Population))*100 as PercentPopulationInfected
From PortfolioProject1..CovidDeaths
--Where location like '%states%' and
Where total_cases is NOT NULL and
Population is NOT NULL
Group by Location, Population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
--Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location,
dea.Date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


--Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated



--Creating View to store data for later visualizations

Use PortfolioProject1
Go

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
 --(RollingPeopleVaccinated/population)*100
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select*
From PercentPopulationVaccinated
