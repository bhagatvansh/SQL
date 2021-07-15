Select location,date,continent,total_cases,new_cases,total_deaths,population
From PortfolioProject..CovidDeaths$
Order by 1,2;

--Looking at Total Cases V/S Total Deaths
--Likelihood of losing your life if you contract Covid-19
Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
Where location like '%India%'
Order by 1,2;

-- Infection percentage in India
Select location,date,total_cases,population,(total_cases/population)*100 as InfectionPercentage
From PortfolioProject..CovidDeaths$
Where location = 'India'
Order by 1,2;

--Countries with highest infection rate compared to Population
Select location,MAX(total_cases) as TotalInfectionCount,population,MAX((total_cases/population))*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths$
Group by location,population
Order by PercentagePopulationInfected desc;

--Countries with highest death count per population
Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by location
Order by TotalDeathCount desc;

--Breaking down number of deaths by Continents including null values
Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is null
Group by location
Order by TotalDeathCount desc;

--Highest death counts by continents (5 continents) without null values
Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is not null
Group by continent
Order by TotalDeathCount desc;

--Global stats per day
Select date, SUM(new_cases) as TotalCases,sum(cast(new_deaths as int)) as TotalDeaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as GlobalDeathPercentage
From PortfolioProject..CovidDeaths$
where continent is not null
Group by date
Order by 1,2;

--Global stats overall
Select SUM(new_cases) as TotalCases,sum(cast(new_deaths as int)) as TotalDeaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as GlobalDeathPercentage
From PortfolioProject..CovidDeaths$
where continent is not null
Order by 1,2;

--Total Vaccinations v/s Population

Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3;

--USE CTE

With PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
)
Select *,(RollingPeopleVaccinated/population)*100
from PopvsVac;

--Temp Table

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null

Select *,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated;

--Creating view to store data for later visualization

Create View PercentPopulationVaccinated as 
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null;

Select * 
From PercentPopulationVaccinated;

--Creating view for global stats 

Create view GlobalStats as
Select SUM(new_cases) as TotalCases,sum(cast(new_deaths as int)) as TotalDeaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as GlobalDeathPercentage
From PortfolioProject..CovidDeaths$
where continent is not null;

Select *
From GlobalStats;





