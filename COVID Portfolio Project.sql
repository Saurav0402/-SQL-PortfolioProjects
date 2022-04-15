select*
From PortfolioProject..CovidDeaths
where continent is NOT NULL
order by 3,4

--select*
--From PortfolioProject..CovidVaccination
--order by 3,4

select location, date, total_cases, new_cases, total_deaths,population
From PortfolioProject..CovidDeaths
where continent is NOT NULL
order by 1,2

--looking at the Total cases vs Total Deaths
--Shows Likelihoodof dying if you contract covid in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathsPercentage
From PortfolioProject..CovidDeaths
Where location like '%India%'
and continent is NOT NULL
order by 1,2

--looking at the Total cases vs Population
--Shows what percentage of population got covid

select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%India%'
order by 1,2

--looking at countries with Highest Infection Rate Compared to Population

select Location, Population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%India%'
Group by Location, Population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population

select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%India%'
where continent is NOT NULL
Group by Location
order by TotalDeathCount desc

--let's Break Things Down By Continent

select location, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%India%'
where continent is NULL
Group by location
order by TotalDeathCount desc

-- Showing continent with the highest death count per population

select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%India%'
where continent is not NULL
Group by continent
order by TotalDeathCount desc

-- Global Numbers

select Sum(new_cases)as total_cases, SUM(cast(new_deaths as int))as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathsPercentage
From PortfolioProject..CovidDeaths
--Where location like '%India%'
where continent is NOT NULL
--group by date
order by 1,2

--Looking atTotal Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int, vac.new_vaccinations )) over (Partition by dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
 JOIN PortfolioProject..CovidVaccination vac
 on dea.location = vac.location
 and dea.date = vac.date
 WHERE dea.continent is not null
 order by 2,3

 --USE CTE

 with popvsvac (continent, location, date, population, new_Vaccination, RollingPeopleVaccinated)
 as
 (
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(bigint, vac.new_vaccinations )) over (Partition by dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
 JOIN PortfolioProject..CovidVaccination vac
 on dea.location = vac.location
 and dea.date = vac.date
 WHERE dea.continent is not null
 --order by 2,3
 )
 select*, (RollingPeopleVaccinated/population)*100 
 from popvsvac

 -- Temp Table
 Drop Table if exists #PercentPopulationVaccinated
 create Table #PercentPopulationVaccinated
 (
 continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )
 Insert into #PercentPopulationVaccinated
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(bigint, vac.new_vaccinations )) over (Partition by dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
 JOIN PortfolioProject..CovidVaccination vac
 on dea.location = vac.location
 and dea.date = vac.date
 WHERE dea.continent is not null
 --order by 2,3
 
 select*, (RollingPeopleVaccinated/population)*100 
 from #PercentPopulationVaccinated

 --Creating View to store data for later visualizations

 Create view PercentPopulationVaccinated as
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(bigint, vac.new_vaccinations )) over (Partition by dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
 JOIN PortfolioProject..CovidVaccination vac
 on dea.location = vac.location
 and dea.date = vac.date
 WHERE dea.continent is not null
 --order by 2,3

 select*
 from PercentPopulationVaccinated


