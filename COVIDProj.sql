select *
from Portfolio..CovidDeaths;

select location, date, total_cases, new_cases, total_deaths, population
from Portfolio..CovidDeaths
order by 1,2
;

-- total cases v/s total deaths
select location, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from Portfolio..CovidDeaths;

-- total_cases v/s population
select location, total_cases, population, round((total_cases/population)*100,4) as percent_affected
from Portfolio..CovidDeaths
order by 1,2;

-- totalcases in each country
select location, max(total_cases) as totalcases, population, max((total_cases/population)*100) as infectedpercent
from Portfolio..CovidDeaths
group by location, population
order by infectedpercent desc;

-- totaldeath in each country
select location, max(cast(total_deaths as int)) as totaldeath -- using cast as integer because the datatype total_deaths in not integer hence showing errors	
from Portfolio..CovidDeaths
group by location, population
order by totaldeath desc;

--globalnumbers
select location, max(cast(total_deaths as int)) as totaldeath 	
from Portfolio..CovidDeaths
where continent is not null
group by location
order by totaldeath desc;

--totalpopulation vs vaccination
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
sum( cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location) as vaccinated_populs
from Portfolio..CovidDeaths dea
join Portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
;

--use CTE 
with popvsvac (Location, Date, Population, New_vaccinations, vaccinated_populs
) as 
(
select dea.location, dea.date,dea.population, vac.new_vaccinations,
sum( cast(vac.new_vaccinations as bigint)) over(partition by dea.location order by dea.location) as vaccinated_populs
from Portfolio..CovidDeaths dea
join Portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
)
select *
from popvsvac
;

-- TEMPTABLE

drop table if exists percentpeoplevaccinated
create table percentpeoplevaccinated
(
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
vaccinated_populs numeric
)

insert into percentpeoplevaccinated
select dea.location, dea.date,dea.population, vac.new_vaccinations,
sum( cast(vac.new_vaccinations as bigint)) over(partition by dea.location order by dea.location) as vaccinated_populs
from Portfolio..CovidDeaths dea
join Portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

select *
from percentpeoplevaccinated;

-- Creating view for visualisation
create view percentvaccipopuls as
select dea.location, dea.date,dea.population, vac.new_vaccinations,
sum( cast(vac.new_vaccinations as bigint)) over(partition by dea.location order by dea.location) as vaccinated_populs
from Portfolio..CovidDeaths dea
join Portfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
