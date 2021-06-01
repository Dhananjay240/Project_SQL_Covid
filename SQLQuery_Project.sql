select *
from Project_SQL..covid_death$
order by 3,4 

select *
from Project_SQL..covid_vaccination$
order by 3,4

Select location, date, population, total_cases, new_deaths, total_deaths
from Project_SQL..covid_death$
order by 1,2

--Looking at total cases vs total deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercent
from Project_SQL..covid_death$
where location like '%India%'
order by 1,2

--Looking at the total cases vs population

Select location, date, total_cases, population, (total_cases/population)*100 as CasePercent
from Project_SQL..covid_death$
where location like '%India%'
order by 1,2

--Countries with highest infection rate as compared to population

select location, population, max(total_cases) as highest, max((total_cases/population))*100 as Death_Per
from Project_SQL..covid_death$
--where location like '%India%'
group by location, population
order by Death_Per desc

-- Countries with highest death rates 

select location, max(total_deaths) as deathcount
from Project_SQL..covid_death$
group by location
order by deathcount desc

--select *
--from Project_SQL..covid_death$
--where continent is not null
--order by 3,4

-- Showing countries only with highest Death Counts per population

select location, max(cast(total_deaths as int)) as deathcount
from Project_SQL..covid_death$
where continent is not null
group by location
order by deathcount desc

-- Showing continents with highest number deaths

select continent, max(cast(total_deaths as int)) as deathcount
from Project_SQL..covid_death$
where continent is not null
group by continent
order by deathcount desc

select location, max(cast(total_deaths as int)) as totaldeath
from Project_SQL..covid_death$
where continent is null
group by location
order by totaldeath desc

-- Global Number

select sum(new_cases) as cases, sum(cast(new_deaths as int)) as deaths

from Project_SQL..covid_death$
where continent is not null
--group by date
order by 1,2


select dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date ) as Vaccinations
from Project_SQL..covid_death$ dea
join Project_SQL..covid_vaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 3,2

with popvsvac (continent, date, location, population, new_vaccinations, Vaccinations)
as
(
select dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date ) as Vaccinations
from Project_SQL..covid_death$ dea
join Project_SQL..covid_vaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	--order by 3,2
	)
select *, (Vaccinations/population)*100 as PercentPop
from popvsvac

-- From temp table

drop table if exists #Population_Vaccinated
create table #Population_Vaccinated 
(
continent nvarchar(255),
date datetime,
location varchar(255),
population numeric,
new_vaccinations numeric,
Vaccinations numeric
)
 
insert into #Population_Vaccinated
select dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date ) as Vaccinations
from Project_SQL..covid_death$ dea
join Project_SQL..covid_vaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
 --where dea.continent is not null
 where dea.location like '%India%'
	--order by 3,2

select *, (Vaccinations/population)*100 as PercentPop
from #Population_Vaccinated

--Creating views to look for datasets later
Create view #Populaion_Vaccinated as

select dea.continent, dea.date, dea.location, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date ) as Vaccinations
from Project_SQL..covid_death$ dea
join Project_SQL..covid_vaccination$ vac
	on dea.location = vac.location
	and dea.date = vac.date
 --where dea.continent is not null
 where dea.location like '%India%'
	--order by 3,2

