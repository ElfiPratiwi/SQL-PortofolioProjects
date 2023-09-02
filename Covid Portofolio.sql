-- THE QUERY BELLOW IS MY JOURNEY TO MAKE MY FIRST PORTOFOLIO

use covid;

 select *
 from coviddeaths
 where continent is not null;
 
 -- SELECT DATA THAT WE ARE GONNA USE
 select
	location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
from
	coviddeaths
order by 1,2;

-- LOOKING AT THE TOTAL CASES VS TOTAL DEATHS 
-- SHOWS LIKELIHOOD OF DYING IF YOU CONTRACT THE COVID IN YOUR COUNTRY
select
	location,
    date,
    total_cases,
    (total_deaths/total_cases)*100 as deathpercentage
from
	coviddeaths
where location= "Indonesia"
order by 1,2;

-- LOOKING AT THE TOTAL CASES VS POPULATION
-- SHOWS WHAT PERCENTAGE OF POPULATION GOT COVID
select
	location,
    date,
    total_cases,
    population,
    (total_cases/population)*100 as percentagepopulationinfected
from
	coviddeaths
where location= "Indonesia"
order by 1,2;

-- LOOKING AT COUNTRY WITH HIGHEST RATE COMPARE TO POPULATION
select
	location,
    population,
    max(total_cases) as hihgestinfection,
    max((total_cases/population))*100 as percentofpopulationinfected
from
	coviddeaths
group by
    population,
    location
order by percentofpopulationinfected desc;

-- SHOWING THE COUNTRY WITH THE HIGHEST DEATH COUNT PER POPULATION
select
	location,
    max(cast(total_deaths as signed)) as totaldeathcases
from
	coviddeaths
where continent is not null
group by
	location
order by 
	totaldeathcases desc;
    
-- LETS BREAK THINGS DOWN BY CONTINENT
    
-- SHOWING THE CONTINENT WITH THE HIGHEST COUNT PER POPULATION
select
	continent,
    max(cast(total_deaths as signed)) as totaldeathcases
from
	coviddeaths
where continent is not null
group by
	continent
order by 
	totaldeathcases desc;
    
-- GLOBAL NUMBERS
select
	date,
    sum(new_cases) as total_cases,
    sum(cast(new_deaths as signed)) as total_deaths,
    sum(cast(new_deaths as signed))/ sum(new_cases)*100 as death_percentage
from
	coviddeaths
where continent is not null
group by date
order by 1,2;

-- SHOWING TOTAL CASES AND TOTAL DEATHS ALL OVER THE WORLD
select 
	sum(new_cases) as total_cases,
    sum(cast(new_deaths as signed)) as total_deaths
from 
	coviddeaths
where continent is not null;


-- LOOKING AT TOTAL POPULATION VS VACCINATION
-- USE CTE
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
select 
	dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    sum(cast(vac.new_vaccinations as signed)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from coviddeaths dea
join covidvaccinations vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null
-- order by 2,3
)
select*, (RollingPeopleVaccinated/population)*100
from PopvsVac;


-- creating view to store data for later visualization CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION
create view Global_Numbers as
select
	date,
    sum(new_cases) as total_cases,
    sum(cast(new_deaths as signed)) as total_deaths,
    sum(cast(new_deaths as signed))/ sum(new_cases)*100 as death_percentage
from
	coviddeaths
where continent is not null
group by date
order by 1,2;


create view total_cases_and_deaths as
select 
	sum(new_cases) as total_cases,
    sum(cast(new_deaths as signed)) as total_deaths
from 
	coviddeaths
where continent is not null;


-- SHOWING HOW TO SEE THE VIEW YOU ALREADY MADE
select * from Global_Numbers;

select * from total_cases_and_deaths;



