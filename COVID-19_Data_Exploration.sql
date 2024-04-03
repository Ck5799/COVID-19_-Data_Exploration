SELECT *
FROM [PortfolioProject].[dbo].[CovidDeaths]
Where continent is not null
Order by 3,4

--Select Data that we are going to be using

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM [PortfolioProject].[dbo].[CovidDeaths]
Order by 1,2


---Looking At Total Cases Vs Total Deaths and calculating the likelihood of death for a country 
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 As DeathPercentage
FROM [PortfolioProject].[dbo].[CovidDeaths]
where location = 'India'
Order by 1,2


---Looking At Total Cases Vs Population and see the total cases wrt population for INDIA
SELECT location,date,total_cases,population,(total_cases/population)*100 As PercentageWithCovid
FROM [PortfolioProject].[dbo].[CovidDeaths]
where location like 'India'
Order by 1,2

---Looking At Countries with highest infection rate wrt population
SELECT location,MAX(total_cases) As HighestInfection ,population,MAX((total_cases/population)*100) As PercentageInfected
FROM [PortfolioProject].[dbo].[CovidDeaths]
group by location,population
Order by PercentageInfected DESC

---Looking At Continents with highest Death rate wrt population
SELECT location,MAX(cast(total_deaths as int)) As HighestDeath
FROM [PortfolioProject].[dbo].[CovidDeaths]
Where continent is  null
group by location
Order by HighestDeath DESC

---Looking At Countries with highest Death rate wrt population
SELECT continent,location,MAX(cast(total_deaths as int)) As HighestDeath
FROM [PortfolioProject].[dbo].[CovidDeaths]
Where continent is not null
group by continent,location
Order by continent ASC,HighestDeath DESC


--Global Progression of cases and deaths each day
SELECT date, sum(cast(new_cases as int)) As TotalCases,sum(cast(new_deaths as int)) As TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 As GlobalDeathPercentage
FROM [PortfolioProject].[dbo].[CovidDeaths]
Where continent is not null
group by date
Order by 1,2


--Total Population VS Vaccinated
select death.continent,death.location, death.date, death.population,vacc.new_vaccinations,SUM(convert(int,vacc.new_vaccinations) )OVER (Partition by death.location order by death.location,death.date) As TotalVaccination

from PortfolioProject..CovidDeaths death
join PortfolioProject..CovidVaccinations vacc
	on death.location= vacc.location
	and death.date=vacc.date
where death.continent is Not null
order by 2,3


--Using CTE

with populationVSvaccination(continent, location, date,population,new_vaccinations ,TotalVaccination)
as
(
select death.continent,death.location, death.date, death.population,vacc.new_vaccinations,SUM(convert(int,vacc.new_vaccinations) )OVER (Partition by death.location order by death.location,death.date) As TotalVaccination
from PortfolioProject..CovidDeaths death
join PortfolioProject..CovidVaccinations vacc
	on death.location= vacc.location
	and death.date=vacc.date
where death.continent is Not null
--order by 2,3
)

select *, (TotalVaccination/population)*100 as PercentageVaccinated
from populationVSvaccination
order by 2,3

--temp table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select *
From PercentPopulationVaccinated