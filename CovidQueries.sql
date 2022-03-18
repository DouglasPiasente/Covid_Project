Select *
from CovidProject..CovidDeaths
where continent is not null
order by 3, 4

--select *
--from CovidProject..CovidVaccinations
--order by 3,4

--Selecting Data I am going to use

Select location, date, total_cases, new_cases, total_deaths, population
from CovidProject..CovidDeaths
where continent is not null
order by 1,2 

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying of covid in Brazil
Select location, date, total_cases, total_deaths, (convert(numeric,total_deaths)/convert(numeric,total_cases)*100) as DeathPercentage
from CovidProject..CovidDeaths
where location = 'Brazil'
and continent is not null
order by 1,2 

--Looking at total cases vc population
--Shows the percentage of population that got covid
Select location, date, total_cases,population, convert(numeric,total_cases)/convert(numeric,population)*100
from CovidProject..CovidDeaths
where location = 'Brazil'
where continent is not null
order by 1,2 

-- Looking at countries withhighest infection rate compared to population
Select location, max(convert(numeric,total_cases)) as HighestInfectionCount ,population, max(convert(numeric,total_cases)/convert(numeric,population))*100 as PercentPopulationInfected
from CovidProject..CovidDeaths
where continent is not null
group by population, location
order by PercentPopulationInfected desc

--Showing the countries with the highest death count per population

Select location, max(convert(numeric,total_deaths)) as TotalDeathCount
from CovidProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--BREAKING DOWN BY CONTINENT

Select continent, max(convert(numeric,total_deaths)) as TotalDeathCount
from CovidProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global Numbers - Total Cases

Select   sum(CONVERT(numeric, new_cases)) as total_cases, sum(convert(numeric,new_deaths)) as total_deaths, (sum(convert(numeric,new_deaths))/sum(CONVERT(numeric, new_cases))*100)  as DeathPercentage
from CovidProject..CovidDeaths
where continent is not null
--group by date
order by 1,2 

--Joining covid deaths with covid vaccination

select *
from CovidProject..CovidDeaths dea
join CovidProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

-- Looking at Total Population vs Vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(numeric,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidProject..CovidDeaths dea
join CovidProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Use CTE

With PopvsVac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(numeric,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidProject..CovidDeaths dea
join CovidProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select * , (RollingPeopleVaccinated/convert(numeric, population))*100
from PopvsVac

-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(numeric,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidProject..CovidDeaths dea
join CovidProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null

Select * , (RollingPeopleVaccinated/convert(numeric, population))*100
from #PercentPopulationVaccinated


-- Creating view to store data for visualizations

Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(numeric,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from CovidProject..CovidDeaths dea
join CovidProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

--Checking the view

Select *
from PercentPopulationVaccinated