--covid-19 data explortion globally 

--Skills used joins ,CTE's,Temp tables, Window functions,Aggregate functions,Creating views,Converting Datatypes

--Select the data we are using
SELECT * FROM PortfolioProject..coviddeaths order by 3,4

SELECT * FROM PortfolioProject..covidvaccinations order by 3,4


--looking at total cases vs total deaths

SELECT location,date,total_cases,new_cases,total_deaths,population,
(total_deaths/total_cases)*100 as deathpercentage
FROM PortfolioProject..coviddeaths 
where location='india'
order by 2,3

--looking at total cases vs population
--shows percent of people who got covid
select location,date,population,total_cases,new_cases,total_deaths,
(total_cases/population)*100 as percentpopulationinfected
from PortfolioProject..coviddeaths
where location='india'
order by 2,3

--looking at highest infected countries compared to population
select location,population,max(total_cases) as highestinfectioncount,
max((total_cases/population)*100) as percentpopulationinfected
from PortfolioProject..coviddeaths
group by location,population
order by percentpopulationinfected desc

--showing countries with highest death count per population
select location,max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..coviddeaths
where continent is not null
group by location
order by totaldeathcount desc

--Let's break things out by continent
--showing continents with death counts
select continent,max(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..coviddeaths 
where continent is not null
group by continent
order by totaldeathcount desc

--Global numbers by date
select date,sum(new_cases) as totalcases,sum(cast(new_deaths as int)) as totaldeaths,
(sum(new_cases)/sum(cast(new_deaths as int)))*100 as deathpercentage
from PortfolioProject..coviddeaths
where continent is not null
group by date
order by 1,2

--Looking at total population vs vaccinated population
with PopvsVac(continent,location,date,population,new_vaccinations,rollingpeoplevaccinated)
as
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations vac
  on dea.location=vac.location
  and dea.date=vac.date
  where dea.continent is not null
  )
  Select *,(rollingpeoplevaccinated/population)*100 
  From PopvsVac
  

  --Temp table
  DROP TABLE if exists #percentpopulationvaccinated
  Create table #percentpopulationvaccinated
  (
  Continent nvarchar(255),
  Location nvarchar(255),
  Date datetime,
  Population numeric,
  New_vaccinations numeric,
  rollingpeoplevaccinated numeric)


  Insert into #percentpopulationvaccinated
  SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations vac
  on dea.location=vac.location
  and dea.date=vac.date
  --where dea.continent is not null
 
  Select *,(rollingpeoplevaccinated/population)*100 
  From #percentpopulationvaccinated

  --creating table to store data for later visualizations
  Create view percentpopulationvaccinated as
  SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from PortfolioProject..coviddeaths dea
join PortfolioProject..covidvaccinations vac
  on dea.location=vac.location
  and dea.date=vac.date
  where dea.continent is not null


