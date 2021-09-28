select * from "'Covid Deaths$'"

select * from "'Covid Vaccinations$'"

select location, date, total_cases, new_cases, total_deaths, population
from "'Covid Deaths$'"
order by 1,2

--total cases vs total deaths
--percentage of people who die from covid infection or death rate
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as '%deaths'
from "'Covid Deaths$'"
where location = 'Nigeria'
order by 1,2

--total cases vs population
--percentage of population that have covid or infection rate
select location, date, total_cases, population, (total_cases/population)*100 as '%cases'
from "'Covid Deaths$'"
order by 1,2

--country with the highest cases and infection rate

select location, population, max(total_cases) as highest_covid_cases, max(total_cases/population)*100 as 'highest_infection_rate'
from "'Covid Deaths$'"
group by location, population
order by highest_infection_rate desc


--country with the highest death count/population

select location, max(cast(total_deaths as int)) as highest_deaths
from "'Covid Deaths$'"
where continent is not null
group by location
order by highest_deaths desc

--Let's break things down by continent
select continent, max(cast(total_deaths as int)) as highest_deaths
from "'Covid Deaths$'"
where continent is not null
group by continent
order by highest_deaths desc

--Global numbers
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from "'Covid Deaths$'"
--where continent is not null
group by date
order by date

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
sum(cast(new_deaths as int))/sum(new_cases)*100 as death_percentage
from "'Covid Deaths$'"
--where continent is not null

-- looking at total population vs vaccination


select dea.location, dea.date, dea.population, vac. new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location) as total_vac_per_location
from "'Covid Deaths$'" as dea
join "'Covid Vaccinations$'" as vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
order by 2,3

--with CTE
With popvsvac (location, date, population, new_vaccinations, total_vac_per_location)
as
(
  Select dea.location, dea.date, dea.population, vac. new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location) as total_vac_per_location
from "'Covid Deaths$'" as dea
join "'Covid Vaccinations$'" as vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
--order by 2,3
)
select *,(total_vac_per_location/population)*100 as total_vac_per_population
from popvsvac

--with temp table

create table #percentpopulationvacinated 
(
location varchar(255),
date datetime,
population bigint,
new_vacinations bigint,
total_vac_per_location numeric
)

set ansi_warnings off

insert into #percentpopulationvacinated 
Select dea.location, dea.date, dea.population, vac. new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location) as total_vac_per_location
from "'Covid Deaths$'" as dea
join "'Covid Vaccinations$'" as vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null

select *,(total_vac_per_location/population)*100 as total_vac_per_location
from #percentpopulationvacinated

--creating view to store data for later visualization
create view percentpopulationvacinated as
Select dea.location, dea.date, dea.population, vac. new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location) as total_vac_per_location
from "'Covid Deaths$'" as dea
join "'Covid Vaccinations$'" as vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null
--order by 2,3

create view deathbycontinent as
select continent, max(cast(total_deaths as int)) as highest_deaths
from "'Covid Deaths$'"
where continent is not null
group by continent
--order by highest_deaths desc

create view popvsvac as
select dea.location, dea.date, dea.population, vac. new_vaccinations, 
sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location) as total_vac_per_location
from "'Covid Deaths$'" as dea
join "'Covid Vaccinations$'" as vac
on dea.location = vac.location
and dea.date = vac.date 
where dea.continent is not null

create view deathcountbypopuation as
select location, max(cast(total_deaths as int)) as highest_deaths
from "'Covid Deaths$'"
where continent is not null
group by location
--order by highest_deaths desc

create view infectionrate as
select location, date, total_cases, population, (total_cases/population)*100 as '%cases'
from "'Covid Deaths$'"
