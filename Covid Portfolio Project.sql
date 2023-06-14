select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

--select Data that we are going to be using 

select location,date,total_cases,total_deaths
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract covid in your country

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Lets check the numbers for united States

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid regarding united states

select location,date,population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

select location,population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
Group by location, Population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population 
--We will use cast to change the data type of total_deaths

select location,Max(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc

--Let's break things by Continents

--Showing continents with the higest death count per population 

select continent,Max(cast(total_deaths as int)) as TotalDeathCount 
from PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers

select date,SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
Group by date
order by 1,2

--If we want to know the total number

select SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--Group by date
order by 1,2

--Lets check the second table 

select *
from PortfolioProject..CovidVaccinations

--Lets join the two tables

select *
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

--Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--lets create a new column for a total count of vacinations done for each country

select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as TotalVaccinationCount
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--We will use CTE to calculate the percentage of ppl vaccinated in a country using the TotalVaccinationCount

With PopvsVac (Continent,Location,date,population, New_vaccinations, TotalvaccinationCount)

as
(
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as TotalVaccinationCount
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select*, (TotalVaccinationCount/population)*100
From PopvsVac



--We will do the same thing using TEMP TABLE method

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
TotalvaccinationCount numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as TotalVaccinationCount
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
Select*, (TotalVaccinationCount/population)*100
From #PercentPopulationVaccinated

--Creating View to store data for later visualizations

Create VIEW PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(Convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date) as TotalVaccinationCount
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select*
from PercentPopulationVaccinated