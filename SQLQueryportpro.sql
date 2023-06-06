select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4


--select *
--from PortfolioProject..CovidVacinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2


--looking at Total cases vs Total Deaths
--likelihood of dying if you contract covid in Nigeria.

select location, date, total_cases, total_deaths, 
    CONVERT(DECIMAL(18, 3), (CONVERT(DECIMAL(18, 3), total_deaths) / CONVERT(DECIMAL(18, 3), total_cases)))*100 as [DeathsPercentage]
from portfolioProject..CovidDeaths
where location like '%Nigeria%'
order by 1,2


--Looking at Total cases vs Population
-- Shows whatpercentage of  population of Nigeria got Covid

select location, date, population, total_cases,  
    CONVERT(DECIMAL(18, 3), (CONVERT(DECIMAL(18, 3), total_cases) / CONVERT(DECIMAL(18, 3), population)))*100 as [PercentagepopulationInfected]
from portfolioProject..CovidDeaths
where location like '%Nigeria%'
order by 1,2


-- Looking at countries with highest infection rate compared to population

select location, population, MAX(total_cases) as HighestInfectedCount,  
    CONVERT(DECIMAL(18, 3),MAX((CONVERT(DECIMAL(18, 3), total_cases) / CONVERT(DECIMAL(18, 3), population))))*100 as [PercentagepopulationInfected]
from portfolioProject..CovidDeaths
where continent is not null
--where location like '%Nigeria%'
Group by location,population
order by PercentagepopulationInfected desc


--Countries with the Highest Death count per Population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount 
from portfolioProject..CovidDeaths
where continent is not null
--where location like '%Nigeria%'
Group by location
order by TotalDeathCount desc


--LETS BREAK THINGS DOWN BY CONTINENT

--showing continent with highest death count per population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
from portfolioProject..CovidDeaths
where continent is not null
--where location like '%Nigeria%'
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

select SUM(new_cases) as total_cases, SUM(new_deaths )as totaldeaths
from portfolioProject..CovidDeaths
--where location like '%Nigeria%'
Where continent is not null
--Group by date
order by 1,2


--Looking at Total population vs Vaccinations


select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
,Sum(CAST(vac.new_vaccinations as int)) OVER (partition by dea.location Order by dea.location,dea.Date) as RollingpeopleVaccinated
--,(RollingpeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVacinations as vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingpeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
,Sum(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location,dea.Date) as RollingpeopleVaccinated
--,(RollingpeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVacinations as vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingpeopleVaccinated/Population)*100
from PopvsVac



--TEMP TABLE


DROP Table if exists #PercemtpopulationVaccinated
Create Table #PercemtpopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingpeopleVaccinated numeric
)


Insert into #PercemtpopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
,Sum(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location,dea.Date) as RollingpeopleVaccinated
--,(RollingpeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVacinations as vac
     on dea.location = vac.location
	 and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingpeopleVaccinated/Population)*100
from #PercemtpopulationVaccinated


--Creating View to store data for later visualization

Create View PercentpopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
,Sum(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location,dea.Date) as RollingpeopleVaccinated
--,(RollingpeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVacinations as vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
--order by 2,3