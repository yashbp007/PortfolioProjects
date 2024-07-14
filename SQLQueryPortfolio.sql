
select *
from PortfolioProject..CovidDeaths
where continent is not null -- because in some places the continent and the location are similar
order by 3,4

--Select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

select Location , date , total_cases, new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
Order by 1,2 

--Looking at total cases vs total deaths
--shows likelihood of dying if you contract covid i your country

select Location , date , total_cases, total_deaths , (total_deaths/total_cases)*100 as DeathsPercentage 
from PortfolioProject..CovidDeaths
--where location like '%india%'
Order by 1,2 

--looking at thr total cases vs population 
--shows what percentage of population got covid 

select Location , date , total_cases, population , (total_deaths/population)*100 as DeathsPercentage 
from PortfolioProject..CovidDeaths
--where location like '%india%'
Order by 1,2 

--looking at the countries with highest infection rate compared to population 

select Location , population , MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentagePopulationInfected 
from PortfolioProject..CovidDeaths
--where location like '%india%'
group by location, population
Order by PercentagePopulationInfected desc

--showing countries with highest Death Count per Population 

select Location , population , MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentagePopulationInfected 
from PortfolioProject..CovidDeaths
--where location like '%india%'
group by location, population
Order by PercentagePopulationInfected desc

select Location , MAX(Cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
group by location
Order by TotalDeathCount desc


--lets break things down by continent 

select continent , MAX(Cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
group by continent
Order by TotalDeathCount desc

--shoiwing the continent woth hoghest death count per poplulation 

select continent , MAX(Cast(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
group by continent
Order by TotalDeathCount desc

--global numbers

select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int )) as total_deaths , SUM(cast(new_deaths as int )) / SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%india%'
where continent is not null
--Group by date
Order by 1,2 



--Looking at toatl Population vs Vaccinations

SELECT dea.continent , dea.location, dea.date,dea.population,vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations )) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
-- cant use need a cte or temp table, (rollingpeoplevaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOiN PortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
where vac.new_vaccinations is not null
and dea.continent is not null
order by 1,2,3


--use cte

with PopvsVac (continent ,location,date,Population,new_vaccinations,rollingpeoplevaccinated)
as 
(
SELECT dea.continent , dea.location, dea.date,dea.population,vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations )) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
-- cant use need a cte or temp table, (rollingpeoplevaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOiN PortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
where vac.new_vaccinations is not null
and dea.continent is not null
--order by 1,2,3
)
select *, (rollingpeoplevaccinated/population)*100 
from PopvsVac


--temp table 

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
loaction nvarchar(255),
Date datetime, 
Population numeric,
New_vaccinations numeric,
rollingpeoplevaccinated numeric 
)

insert into #PercentPopulationVaccinated
SELECT dea.continent , dea.location, dea.date,dea.population,vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations )) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
-- cant use need a cte or temp table, (rollingpeoplevaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOiN PortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
where vac.new_vaccinations is not null
and dea.continent is not null
--order by 1,2,3

select *, (rollingpeoplevaccinated/population)*100 
from #PercentPopulationVaccinated



-- create a view 

create view PercentPopulationVaccinated as
SELECT dea.continent , dea.location, dea.date,dea.population,vac.new_vaccinations
, SUM(convert(int,vac.new_vaccinations )) over (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
-- cant use need a cte or temp table, (rollingpeoplevaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOiN PortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
	 and dea.date = vac.date
where vac.new_vaccinations is not null
and dea.continent is not null
--order by 1,2,3

select * 
from PercentPopulationVaccinated