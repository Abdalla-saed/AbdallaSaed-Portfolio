select * from [SQL data exploration].. CovidDeaths$
order  by 3,4


select * from [SQL data exploration].. CovidVaccinations$
order  by 3,4

-- selecting data from CovidDeath table
select location, date, total_cases, total_deaths, population
from [SQL data exploration].. CovidDeaths$
order by 1,2

--Total cases number VS Total death number 

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deaths_precentage
from [SQL data exploration]..CovidDeaths$
where location= 'sudan'
order by 1,2


--Total cases VS population
-- Precentage of population with covid
select location, date, population, total_cases, (total_cases/population)*100 as Precentage_of_total_cases
from [SQL data exploration].. CovidDeaths$
--where location = 'sudan'
order by 1,2


--Selecting Countries with highest infection cases

select location, population, max(total_cases) as highest_infection, max((total_cases/population))*100 as precentage_highestpopulation_infection
from [SQL data exploration]..CovidDeaths$
--where location = 'sudan'
group by location, population
order by precentage_highestpopulation_infection desc


--Highest death count of population

select continent, max(cast(total_deaths as int)) as highest_death_rate
from [SQL data exploration].. CovidDeaths$
--where location = 'sudan'
where continent is not null
group by continent
order by highest_death_rate desc


--Global Total cases, Total deaths and thier precentage 

select sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_Deaths, sum(cast(new_deaths as int)) /sum(new_cases)*100 as deaths_precentage
from [SQL data exploration]..CovidDeaths$
--where location= 'sudan'
where continent is not null
--group by continent
order by 1,2



select*
from [SQL data exploration]..CovidVaccinations$ 
order by 1,2


--Joining Covid death table with Vaccination table 
-- exploring the total number of population against vaccinations



select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations, 
SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from [SQL data exploration]..CovidDeaths$ dea
join [SQL data exploration]..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Useing CTE to calculate the precentage of people vaccinated

with popvscac (continent, location, date ,population, rollingpeoplevaccinated, new_vaccinations) as (
select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations, 
SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from [SQL data exploration]..CovidDeaths$ dea
join [SQL data exploration]..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select*, rollingpeoplevaccinated/population*100 as precentage_vaccinated
from popvscac

--TEMP TABLES

drop table if exists #POPULATIONVSVACINATED
create table #populationvaccinated(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #populationvaccinated
select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations, 
SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from [SQL data exploration]..CovidDeaths$ dea
join [SQL data exploration]..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (rollingpeoplevaccinated/population)*100
from #populationvaccinated

--creating a view

create View populationvsvac as

select dea.continent, dea.location, dea.date, dea.population , vac.new_vaccinations, 
SUM(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from [SQL data exploration]..CovidDeaths$ dea
join [SQL data exploration]..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * 
from 
populationvsvac