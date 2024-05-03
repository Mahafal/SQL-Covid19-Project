
Select *
From SQLProject..CovidDeaths$
Where continent is not null
Order by 3, 4

Select *
From SQLProject..CovidVaccinations$
Order by 3, 4

-- CovidDeaths Table
-- Select Data that will be useing 

Select location, date, total_cases, new_cases,total_deaths, population
From SQLProject..CovidDeaths$
Order by 1, 2

Select location, date, new_vaccinations
From SQLProject..CovidVaccinations$
Order by 1, 2



-- Total Cases Vs Total Deaths
-- Shows likelihood of death when infected of Covid in Saudi Arabia 

Select location, date, total_cases, total_deaths,  (total_deaths/total_cases) * 100 As Deaths_Percentage
From SQLProject..CovidDeaths$
Where Location = 'Saudi Arabia' 
And continent is not null
Order by 1, 2 


-- Total cases Vs population
-- Show what percentage of the population got Covid in Saudi Arabia 

Select location, date, population, total_cases, (total_cases/population) * 100 As Cases_Percentage
From SQLProject..CovidDeaths$
Where Location = 'Saudi Arabia' 
And continent is not null
Order by 1, 2


-- Show the countries that have the highest infection rates relative to their population 

Select location, population, Max(total_cases) As highest_infection_Count, 
Max((total_cases/population)) * 100 As Percentage_Population_Infected
From SQLProject..CovidDeaths$
Where population is not null 
And continent is not null
Group by location, population
Order by 4 desc


-- Show the continent with the highest deathes count per population

Select location, Max(cast(total_deaths As int)) As Total_Deaths
From SQLProject..CovidDeaths$
Where continent is not null
Group by location
Order by 2 desc


-- Show the continent with the highest deathes count per population

Select continent, Max(cast(total_deaths As int)) As Total_Deaths
From SQLProject..CovidDeaths$
Where population is not null 
And continent is not null
Group by continent
Order by 2 desc


-- Global Numbers


-- Show the number of new deaths Vs the number of new cases globally per date

Select date, Sum(new_cases) As New_Cases, Sum(cast(new_deaths As int)) As New_Deaths, 
Sum(cast(new_deaths As int))/Sum(new_cases) * 100 As Deaths_Percentage
From SQLProject..CovidDeaths$
Where continent is not null
Group by date
Order by 1, 2 


-- Show Total number of new deaths Vs the number of new

Select Sum(new_cases) As New_Cases, Sum(cast(new_deaths As int)) As New_Deaths,  
Sum(cast(new_deaths As int))/Sum(new_cases) * 100 As Deaths_Percentage
From SQLProject..CovidDeaths$
Where continent is not null
Order by 1, 2 



-- CovidDeaths , CovidVaccinations Tables
-- Select Data that will be useing 


Select *
From SQLProject..CovidDeaths$ dea
	JOIN SQLProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.Date = vac.Date
	

-- Show the number of people in the world who have been vaccinated


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) As Rolling_people_vaccinate
From SQLProject..CovidDeaths$ dea
	JOIN SQLProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.Date = vac.Date
	Where dea.continent is not null
	Order by 2,3


	-- Population Vs Vaccination
	-- CTE

	With PopVsVacc (continent, location, date, population, new_vaccinations, Rolling_people_vaccinate)
	As
	(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) As Rolling_people_vaccinate
From SQLProject..CovidDeaths$ dea
	JOIN SQLProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.Date = vac.Date
	Where dea.continent is not null
	) 
Select *, (Rolling_people_vaccinate/population) * 100 As PopVsVac
From PopVsVacc

-- Tem Table 
-- -- Population Vs Vaccination At Saudi Arabia 

Drop Table If Exists  #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(continent varchar(255),
Location varchar(255),
date datetime,
population numeric, 
new_vaccination numeric,
Rolling_people_vaccinate numeric)

Insert Into #PercentagePopulationVaccinated 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) As Rolling_people_vaccinate
From SQLProject..CovidDeaths$ dea
	JOIN SQLProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.Date = vac.Date
	Where dea.continent is not null
	And dea.location = 'Saudi Arabia'
	And population is not null

	Select *, (Rolling_people_vaccinate/population) * 100 As PopVsVac
	From #PercentagePopulationVaccinated


	-- Craete Viwe To store Data for later visualing

Create View PercentagePopulationVaccinated As
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) As Rolling_people_vaccinate
From SQLProject..CovidDeaths$ dea
	JOIN SQLProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.Date = vac.Date
	Where dea.continent is not null
	And dea.location = 'Saudi Arabia'
	And population is not null

Select *
From PercentagePopulationVaccinated


