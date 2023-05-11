select *
from Glassdoor_DataScientists

/*F1 column is mostly likely just a generated jobtitle for this table
lets rename it to job_id*/
alter table Glassdoor_DataScientists add job_id int identity(1,1) 

/*Change Column names with spaces to standardize and easy for querying*/
exec sp_rename 'Glassdoor_DataScientists.Job Title' , 'job_title'
exec sp_rename 'Glassdoor_DataScientists.Salary Estimate' , 'salary_estimate'
exec sp_rename 'Glassdoor_DataScientists.Job Description' , 'job_description'
exec sp_rename 'Glassdoor_DataScientists.Company Name' , 'company_name'
exec sp_rename 'Glassdoor_DataScientists.Type of ownership' , 'type_ownership'

/*we can use CTE to arrange specific information and the order we want everytime we acces it*/
with CTE_Glassdoor as (
select job_id, job_title, salary_estimate, job_description, Rating, company_name, location, 
Headquarters, Size, Founded, type_ownership, industry
from Glassdoor_DataScientists
)
select *
from CTE_Glassdoor


/*we are encountering some special characters that are unnecessary*/
select job_title
from Glassdoor_DataScientists
where job_title like '%â€“%'

select job_title,REPLACE(REPLACE(REPLACE(job_title, 'â', ''), '€', ''), '“', '') as job_new
from Glassdoor_DataScientists 

alter table Glassdoor_DataScientists add job_title_new varchar(200)

update Glassdoor_DataScientists 
set job_title_new = REPLACE(REPLACE(REPLACE(job_title, 'â', ''), '€', ''), '“', '')

select job_title_new
from Glassdoor_DataScientists
where job_title_new like '%â€“%'
/*so now weve eliminated the recurring special characters in some data in job_title column*/

with CTE_Glassdoor as (
select job_id, job_title_new, salary_estimate, job_description, Rating, company_name, location, 
Headquarters, Size, Founded, type_ownership, industry
from Glassdoor_DataScientists
)
select *
from CTE_Glassdoor

/*under salary_estimate there are values that are non relevant lik e -1 as salary which doesnt make sense
we will delete that*/
delete from Glassdoor_DataScientists
where salary_estimate = '-1'




/*under the salary_estimate column we want to remove (glassdoor est.), Employer Provided Salary: and Employer est. so it only contains
the salary*/
select salary_estimate, replace(replace(replace(salary_estimate,'(Glassdoor est.)',''),'Employer Provided Salary:',''),'(Employer est.)','')
		as salary_estimate_new
from Glassdoor_Datascientists

alter table glassdoor_datascientists add salary_estimate_new char(50) 

update Glassdoor_Datascientists
set salary_estimate_new = replace(replace(replace(salary_estimate,'(Glassdoor est.)',''),'Employer Provided Salary:',''),'(Employer est.)','')




/*we can delete datas that only contains per our on salary estimate*/
select salary_estimate_new, count(salary_estimate_new)
from Glassdoor_Datascientists
where salary_estimate_new like '%Per hour%'
group by salary_estimate_new
/*deletion*/
delete from Glassdoor_Datascientists
where salary_estimate_new like '%Per hour%'


/*these are the data so far..*/
with CTE_Glassdoor as (
select job_id, job_title_new, salary_estimate_new, job_description, Rating, company_name, location, 
Headquarters, Size, Founded, type_ownership, industry
from Glassdoor_DataScientists
)
select *
from CTE_Glassdoor




/*create min and max column for salary estimate so we can make it a numerical later*/
select substring(salary_estimate_new, CHARINDEX('-', salary_estimate_new)+1, LEN(salary_estimate_new))
       substring(salary_estimate_new, 0, charindex('-', salary_estimate_new))
from Glassdoor_DataScientists

alter table Glassdoor_DataScientists add max_salary char(50);
update Glassdoor_DataScientists
set max_salary = substring(salary_estimate_new, CHARINDEX('-', salary_estimate_new)+1, LEN(salary_estimate_new))

alter table Glassdoor_DataScientists add min_salary char(50);
update Glassdoor_DataScientists
set min_salary = substring(salary_estimate_new, 0, charindex('-', salary_estimate_new))

with CTE_Glassdoor as (
select job_id, job_title_new, salary_estimate_new, min_salary, max_salary, job_description, Rating, company_name, location, 
Headquarters, Size, Founded, type_ownership, industry
from Glassdoor_DataScientists
)
select *
from CTE_Glassdoor



/*removing some strings in data data in casting it as int*/ 
select cast(replace(replace(min_salary, '$',''), 'K','000') as int),
	   cast(replace(replace(max_salary, '$',''), 'K','000') as int)
from Glassdoor_DataScientists

alter table Glassdoor_DataScientists add min_salary_new int
update Glassdoor_DataScientists
set min_salary_new = cast(replace(replace(min_salary, '$',''), 'K','000') as int)

alter table Glassdoor_DataScientists add max_salary_new int
update Glassdoor_DataScientists
set max_salary_new = cast(replace(replace(max_salary, '$',''), 'K','000') as int)

/*data so far*/
with CTE_Glassdoor as (
select job_id, job_title_new, min_salary_new, max_salary_new, job_description, Rating, company_name, location, 
Headquarters, Size, Founded, type_ownership, industry
from Glassdoor_DataScientists
)
select *
from CTE_Glassdoor
/*now we have made the salaries in int, this will be good in preparation for calculation in the future for analysis and visualizations*/




/*company name contains its respective company rating which already has its own column, we should delete it.*/
select left(company_name, len(company_name)-3)
from Glassdoor_DataScientists

alter table Glassdoor_DataScientists add company_name_new varchar(150)
update Glassdoor_DataScientists
set company_name_new = left(company_name, len(company_name)-3)

with CTE_Glassdoor as (
select job_id, job_title_new, min_salary_new, max_salary_new, job_description, Rating, company_name_new, location, 
Headquarters, Size, Founded, type_ownership, industry
from Glassdoor_DataScientists
)
select *
from CTE_Glassdoor






/*column location contains city and state, it might be better we separate it in different columns.*/
select substring(location, 0, charindex(',', location)) as city,
	   substring(location, charindex(',',location)+1, len(location)) as state
from Glassdoor_DataScientists

alter table Glassdoor_DataScientists add city_company varchar(50)
update Glassdoor_DataScientists
set city_company = substring(location, 0, charindex(',', location))

alter table Glassdoor_DataScientists add state_company varchar(50)
update Glassdoor_DataScientists
set state_company = substring(location, charindex(',',location)+1, len(location))

with CTE_Glassdoor as (
select job_id, job_title_new, min_salary_new, max_salary_new, job_description, Rating, company_name_new, city_company, state_company, 
Headquarters, Size, Founded, type_ownership, industry
from Glassdoor_DataScientists
)
select *
from CTE_Glassdoor





/*column headquarters contains city and state or country, it might be better we separate it in different columns.*/
select substring(headquarters, 0, charindex(',', headquarters)) as city,
	   substring(headquarters, charindex(',',headquarters)+1, len(headquarters)) as state/country
from Glassdoor_DataScientists

alter table Glassdoor_DataScientists add city_headquarters varchar(50)
update Glassdoor_DataScientists
set city_headquarters = substring(headquarters, 0, charindex(',', headquarters))

alter table Glassdoor_DataScientists add state_country_headquarters varchar(50)
update Glassdoor_DataScientists
set state_country_headquarters = substring(headquarters, charindex(',',headquarters)+1, len(headquarters))

with CTE_Glassdoor as (
select job_id, job_title_new, min_salary_new, max_salary_new, job_description, Rating, company_name_new, city_company, state_company, 
city_headquarters, state_country_headquarters, size, Founded, type_ownership, industry
from Glassdoor_DataScientists
)
select *
from CTE_Glassdoor



/*we have observed that we have values like -1, and unknown on coompany size table we should get it rid of that*/
select distinct size
from Glassdoor_DataScientists
order by size

delete from Glassdoor_DataScientists
where size in ('-1', 'Unknown')
/*lets leave it like that*/



/*deleted datas with founded value is -1 and with number company job listing/job_id is 1*/
delete from Glassdoor_DataScientists
where company_name_new in (
	select company_name_new
	from Glassdoor_DataScientists
	where founded = '-1' 
	group by company_name_new
	having count(*) = 1
)
select job_id ,company_name_new, founded, count(company_name_new)
from Glassdoor_DataScientists
where founded = '-1'
group by company_name_new, founded, job_id
order by company_name_new
/*doing some research*/
/*ARL =1949
  CC = 1991
  F &G = 1959
  KTI = 2008
  Numeric LLC = 1999
  p2 1999
  teas 1942
  church 1830*/
 /*updated all blank founded datas */
update Glassdoor_DataScientists
set founded = 1830
where company_name_new like '%The Church of Jesus Christ of Latter-day Saints%'


/*Lets remove the company text under type of ownership*/
/*important note:Both Government Company and Public Limited Company are governed by the Companies Act, 2013. 
The basic difference between both of them is that the Government firm is managed/owned by the governmental 
bodies but the Public  Company is owned/managed by the public who buys the shares of the PLC.*/
select trim(replace(replace(type_ownership,'Company', ''), '-',''))
from Glassdoor_DataScientists

alter table Glassdoor_DataScientists add type_ownership_new varchar(50)
update Glassdoor_DataScientists
set type_ownership_new = trim(replace(replace(type_ownership,'Company', ''), '-',''))
/*lets leave it like that*/



/*DATA CLEANED*/
with CTE_Glassdoor as (
select job_id, job_title_new, min_salary_new, max_salary_new, job_description, rating, company_name_new, city_company, state_company, 
city_headquarters, state_country_headquarters, size, Founded, type_ownership_new, industry
from Glassdoor_DataScientists
)
select *
from CTE_Glassdoor


















