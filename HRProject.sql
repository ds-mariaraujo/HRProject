/*
HR Project: The aims of this project are to create a Database Model using the HRDaset table 
and to clear the data which will be used later for building a dashoard in Power BI.
The table HRDaset is used in the HR Departament of a fictitious company and brings us 
information about its employees. 

In order to create the Database Model we will split this table into many related tables.
*/

-- Creating the database to store our HR Project

CREATE DATABASE HRProject

-- Creating the tables of our database

CREATE TABLE position (
position_id INT PRIMARY KEY,
position_name VARCHAR(50)
)

CREATE TABLE marital_status (
marital_status_id INT PRIMARY KEY,
marital_status_name VARCHAR(10)
)

CREATE TABLE department (
dep_id INT PRIMARY KEY,
dep_name VARCHAR(20)
)

CREATE TABLE employment_status (
empl_status_id INT IDENTITY(1,1) PRIMARY KEY,
empl_name VARCHAR(30)
)

CREATE TABLE termination_reason (
term_id INT IDENTITY(1,1) PRIMARY KEY,
term_reason VARCHAR(50)
)

CREATE TABLE recruitment_source (
recr_id INT IDENTITY (1,1) PRIMARY KEY,
recr_source VARCHAR(30)
)

CREATE TABLE performance (
perf_id INT PRIMARY KEY,
perf_name VARCHAR(20)
)

CREATE TABLE manager (
manager_id INT PRIMARY KEY,
manager_name VARCHAR(60)
)

CREATE TABLE citizen_desc (
citizen_id VARCHAR(2) PRIMARY KEY,
citizen_name VARCHAR(20)
)

CREATE TABLE race_desc (
race_id VARCHAR(5) PRIMARY KEY,
race_name VARCHAR(40)
)


-- Populating the tables

-- CORRECTING DIVERGENCE BEFORE POPULATING THE position TABLE
-- DIVERGENCE IN THE HRDataset TABLE ON THE PositionID COLUMN

-- Position 'Production Manager' has PositionID = 18 but for EmpID = 10144 
-- his positionID is set as 17 instead. We know that is the PositionID that is wrong because his 
-- Department is 'Production'. So we are correcting it:

UPDATE HRDataset
SET PositionID = 18
WHERE EmpID = 10144

-- Checking:

SELECT EmpID, PositionID, Position
FROM HRDataset
WHERE EmpID = 10144

-- Position 'Software Engineer' has PositionID = 24 but for EmpID = 10131
-- his positionID is set as 23 instead. We know that is the PositionID that is wrong because his 
-- Department is 'Software Engineering'. So we are correcting it:

UPDATE HRDataset
SET PositionID = 24
WHERE EmpID = 10131

-- Checking:

SELECT EmpID, PositionID, Position
FROM HRDataset
WHERE EmpID = 10131

-- PositionID = 13 is being associated to 3 different positions, they are: IT Manager - Support, 
-- IT Manager - Infra and IT Manager - DB. Therefore, we will redefine them in order to have a unique
-- ID for each position. We will correct these in the following way: 
-- 1) keep the ID 13 for the position IT Manager - Support
-- 2) Define the PositionID = 17 (that is now free) for the position of IT Manager - Infra
-- 3) Define the PositionID = 31 for the position IT Manager - DB

UPDATE HRDataset
SET PositionID = 17
WHERE Position = 'IT Manager - Infra'

UPDATE HRDataset
SET PositionID = 31
WHERE Position = 'IT Manager - DB'

-- Checking:

SELECT PositionID, Position
FROM HRDataset
WHERE PositionID IN (13,17,31)

-- Now we can populate the position table:

INSERT INTO position
SELECT DISTINCT PositionID, Position
FROM HRDataset

INSERT INTO marital_status VALUES 
(0, 'Single'),
(1, 'Married'),
(2, 'Divorced'),
(3, 'Separated'),
(4, 'Widowed')

INSERT INTO gender VALUES  
(0, 'Female'),
(1, 'Male')


-- CORRECTING DIVERGENCE BEFORE POPULATING THE department TABLE
-- DIVERGENCE IN THE HRDataset TABLE ON THE DeptID COLUMN

-- The 'Software Engineering' departament corresponds to the DeptID = 4 but
-- for the employee EmpID 10131 the DeptID is set as 1. As his position is 'Software Engineer'
-- we can conclude that his EmpID shoud be 4 instead of 1. The same occurs for the EmpID = 10311: 
-- his DeptID is set as 6 and his departament as 'Production'. As his position is 'Production Technician I' 
-- we can conclude that it is his EmpID that is wrong, it should be 5 instead of 6

-- Let's correct these information then:

UPDATE HRDataset
SET DeptID = CASE Department
				WHEN 'Software Engineering' THEN 4
				WHEN 'Production' THEN 5
			END
WHERE Department IN ('Software Engineering', 'Production')

-- Checking:

SELECT EmpID, DeptID,department
FROM HRDataset
WHERE EmpID IN (10131, 10311)

SELECT DeptID,Department
FROM HRDataset
ORDER BY Department

-- Now we can populate the department table:

INSERT INTO department           
SELECT DISTINCT DeptID, Department
FROM HRDataset

INSERT INTO employment_status(empl_name) VALUES  
('Active'),
('Terminated for Cause'),
('Voluntarily Terminated')

INSERT INTO termination_reason
SELECT DISTINCT TermReason
FROM HRDataset

INSERT INTO recruitment_source
SELECT DISTINCT RecruitmentSource
FROM HRDataset

INSERT INTO performance VALUES
(1, 'PIP'),
(2, 'Needs Improvement'),
(3, 'Fully Meets'),
(4, 'Exceeds')


-- CORRECTING DIVERGENCE BEFORE POPULATING THE manager TABLE

-- In some rows in which the manager name is Webster Butler, the manager ID is missing,
-- So, the next lines are to correct it:

SELECT ManagerID, ManagerName
FROM HRDataset
WHERE ManagerName = 'Webster Butler'

UPDATE HRDataset
SET ManagerID = 39
WHERE ManagerName = 'Webster Butler'
AND ManagerID IS NULL

-- Checking if there is any mismatch with managerID and managerName in the HRDataset table

SELECT COUNT (DISTINCT ManagerID) AS manager_id_count
FROM HRDataset
UNION ALL
SELECT COUNT (DISTINCT ManagerName) AS manager_name_count
FROM HRDataset

SELECT ManagerID, ManagerName
FROM HRDataset
ORDER BY ManagerName

-- There are 23 different managerIDs and only 21 manager names
-- Michael Albert was associated with two IDs, 22 and only in one line it shows 30, so we will assume that the correct ID is 22
-- Brandon R. LeBlanc also was associated with two IDs, 1 and only in one line it shows 3, so we will assume that the correct ID is 1

-- The following lines correct these discrepancies:

UPDATE HRDataset
SET ManagerID = CASE ManagerName
					WHEN 'Michael Albert' THEN 22
					WHEN 'Brandon R. LeBlanc' THEN 1
				END
WHERE ManagerName IN ('Michael Albert','Brandon R. LeBlanc')

-- Now we can insert the ManagerID and ManagerName into the table manager

INSERT INTO manager
SELECT DISTINCT ManagerID, ManagerName
FROM HRDataset

INSERT INTO diversity_job_fair VALUES
(0, 'No'),
(1, 'Yes')

INSERT INTO termination VALUES
(0, 'No'),
(1, 'Yes')

INSERT INTO citizen_desc VALUES
('E', 'Eligible NonCitizen'),
('N', 'Non-Citizen'),
('US', 'US Citizen')

INSERT INTO race_desc VALUES
('AI/AN', 'American Indian or Alaska Native'),
('A', 'Asian'),
('B/AA', 'Black or African American'),
('H', 'Hispanic'),
('2+', 'Two or more races'),
('W', 'White')


-- DATA CLEANING IN THE MAIN TABLE (HRDataset) 

-- CORRECTING DIVERGENCE IN THE HRDataset TABLE ON THE PerfScoreID COLUMN

-- The PerfScore = 1 corresponds to 'PIP' and in one line (EmpID = 10311) it shows 'Fully Meets' instead
-- Also, the PerfScoreID = 3 corresponds to 'Fully Meets' and in one line (EmpID = 10305) it shows 'PIP' instead
-- Assuming that the PerfScoreID is wrong, we will keep the column referring to the 
-- PerfomanceScore and change the respective PerfScoreID

-- The following code corrects these discrepancies:

UPDATE HRDataset
SET PerfScoreID = CASE PerformanceScore
					WHEN 'Fully Meets' THEN 3
					WHEN 'PIP' THEN 1
				  END
WHERE PerformanceScore IN ('Fully Meets','PIP')

-- Checking:

SELECT EmpID, PerfScoreID, PerformanceScore
FROM HRDataset
WHERE EmpID IN (10305, 10311)


-- CORRECTING DIVERGENCE IN THE HRDataset TABLE ON THE EmpStatusID COLUMN

-- 1) There are two lines (EmpID = 10182, 10305) in our dataset where the EmploymentStatus is 'Terminated for Cause' 
-- but their EmpStatusID is wrong, it is showing as 1 while should be 2. We can conclude that is the EmpStatusID 
-- that is wrong because there are the dates of termination for these employees.
-- 2) There are a lot of rows showing the EmploymentStatus as 'Active' but their EmpStatusID is wrong 
-- (showing 2 and 3), so we need to change them to 1 to coicide with our definition
-- 3) We are changing the EmpStatusID to 2 (instead of 4) where the EmploymentStatus is 'Terminated for Cause' to coicide with our definition
-- 4) We are changing the EmpStatusID to 3 (instead of 5) where the EmploymentStatus is 'Voluntarily Terminated' to coicide with our definition

-- The following code corrects these discrepancies:

UPDATE HRDataset
SET EmpStatusID = 2,
	EmploymentStatus = 'Terminated for Cause' 
WHERE EmpID IN (10182, 10305)

UPDATE HRDataset
SET EmpStatusID = 1
WHERE EmploymentStatus = 'Active'

UPDATE HRDataset
SET EmpStatusID = 2
WHERE EmploymentStatus = 'Terminated for Cause' 

UPDATE HRDataset
SET EmpStatusID = 3
WHERE EmploymentStatus = 'Voluntarily Terminated'

-- Checking:

SELECT EmpID, EmpStatusID, EmploymentStatus
FROM HRDataset
WHERE EmpID IN (10182, 10305)
ORDER BY EmpStatusID

SELECT EmpStatusID, EmploymentStatus
FROM HRDataset
ORDER BY EmpStatusID


-- CHANGING THE TERMINATION REASON COLUMN IN THE HRDaset TABLE

-- Here we are replacing the termination reason with only the termination ID as defined on the table termination_reason

UPDATE HRDataset
SET TermReason = term.term_id
FROM HRDataset hr
LEFT JOIN termination_reason term
ON hr.TermReason = term.term_reason

-- Checking:

select TermReason
from HRDataset


-- CHANGING THE RECRUITMENT SOURCE COLUMN IN THE HRDaset TABLE

-- Here we are replacing the recruitment source name with only the recruitment source ID as defined on the table recruitment_source

UPDATE HRDataset
SET RecruitmentSource = rec.recr_id
FROM HRDataset hr
LEFT JOIN recruitment_source rec
ON hr.RecruitmentSource = rec.recr_source

-- Checking:

SELECT RecruitmentSource
FROM HRDataset
ORDER BY RecruitmentSource


-- CHANGING THE CITIZEN DESC COLUMN IN THE HRDaset TABLE

-- Here we are replacing the citizen descendancy name with only the citizen descendancy ID as defined on the table citizen_desc

UPDATE HRDataset
SET CitizenDesc = cit.citizen_id
FROM HRDataset hr
LEFT JOIN citizen_desc cit
ON hr.CitizenDesc = cit.citizen_name

-- Checking:

SELECT EmpID, CitizenDesc
FROM HRDataset 
ORDER BY CitizenDesc


-- CHANGING THE RACE DESC COLUMN IN THE HRDaset TABLE

-- Here we are replacing the race descendancy name with only the race descendancy ID as defined on the table race_desc

UPDATE HRDataset
SET RaceDesc = race.race_id
FROM HRDataset hr
LEFT JOIN race_desc race
ON hr.RaceDesc = race.race_name

-- Checking:

SELECT EmpID, RaceDesc
FROM HRDataset 
ORDER BY RaceDesc


-- CREATION OF MAIN TABLE 'Employee'

CREATE TABLE employee (
emp_id INT PRIMARY KEY,
emp_name VARCHAR(50),
gender VARCHAR(1),
marital_status_id INT FOREIGN KEY REFERENCES marital_status(marital_status_id),
dep_id INT FOREIGN KEY REFERENCES department(dep_id),
position_id INT FOREIGN KEY REFERENCES position(position_id),
salary INT,
manager_id INT FOREIGN KEY REFERENCES manager(manager_id),
home_state VARCHAR(5),
zip INT,
dob DATE,
citizen_id VARCHAR(2) FOREIGN KEY REFERENCES citizen_desc(citizen_id),
hispanic_latino VARCHAR(3),
race_id VARCHAR(5) FOREIGN KEY REFERENCES race_desc(race_id),
div_job_fair BIT,
recr_id INT FOREIGN KEY REFERENCES recruitment_source(recr_id),
term_binary BIT,
empl_status_id INT FOREIGN KEY REFERENCES employment_status(empl_status_id),
date_hire DATE,
date_termination DATE,
term_id INT FOREIGN KEY REFERENCES termination_reason(term_id),
perf_id INT FOREIGN KEY REFERENCES performance(perf_id),
engagement_survey DECIMAL(3,2),
emp_satisfaction INT,
special_proj_count INT,
last_perf_date DATE,
days_late_last_30 INT,
absences INT
)

INSERT INTO employee 
SELECT EmpID, Employee_Name, Sex, MaritalStatusID, DeptID, PositionID, Salary, ManagerID, [State], Zip, DOB, CitizenDesc, HispanicLatino, 
	   RaceDesc, FromDiversityJobFairID, RecruitmentSource, Termd, EmpStatusID, DateofHire, DateofTermination, TermReason, PerfScoreID, 
	   EngagementSurvey, EmpSatisfaction, SpecialProjectsCount, LastPerformanceReview_Date, DaysLateLast30, Absences
FROM HRDataset

-- Checking:

SELECT *
FROM employee


-- DATA CLEANING

-- Changing the name format on the employee table to First Name + Last Name

UPDATE employee
SET emp_name = SUBSTRING(emp_name,CHARINDEX(',',emp_name)+1,(LEN(emp_name) - CHARINDEX(',',emp_name))) +' '+ SUBSTRING(emp_name,0,CHARINDEX(',',emp_name)) 

-- Changing the name Brandon R. LeBlanc on manager table to Brandon R LeBlanc 
-- (without the . ) to coicide with the same employer in the employee table

UPDATE manager
SET manager_name = 'Brandon R LeBlanc'
WHERE manager_id = 1


-- Cheching for duplicates on the Employer ID and Employer Name

SELECT emp_id, COUNT(emp_id) AS count_emp_id
FROM employee
GROUP BY emp_id
HAVING COUNT(emp_id) > 1

SELECT emp_name, COUNT(emp_name) AS count_emp_name
FROM employee
GROUP BY emp_name
HAVING COUNT(emp_name) > 1

/*
Both queries above show no results, which means that there are no duplicates on the 
Employer ID or Employer Name, in other words, all the rows in our fact table are unique
*/


-- DATA EXPLORATION (work in progress...)

-- Average Salary per Departament

SELECT emp.dep_id, dep.dep_name, AVG(salary) AS avg_salary_by_departament
FROM employee emp
LEFT JOIN department dep
ON emp.dep_id = dep.dep_id
GROUP BY emp.dep_id, dep.dep_name
ORDER BY AVG(salary) DESC

/*
This query shows that the department with the highest average salary ($ 250000) is the 
Executive Office while the lowest average salary ($ 59953) is in the Production department 
*/


-- Top 10 of Highest Salaries of the company and their respective Employer Names and Positions

-- Top 10 of Lowest Salaries of the company and their respective Employer Names and Positions

-- Average Age of all Employers who is currently working in the company

-- Average time worked on the company for the Employers who left

-- Number of employers hired per Recruitment Source

-- Count and Percentage (over the total number of employers) of Employers per Employment Status

-- Percentage of employers who left the company per Termination Reason

-- Percentage of Employers per Race

-- Count of male and female Employers who worked and is still working in the company

-- Total spent by the company with the Salaries of all Employers

-- Average of Employment Satisfation for all employers

-- Average of Employment Satisfation for employers who left the company and for the ones who is still working there

-- Average of the number of Absences

-- Average of the number of Absences for employers who left the company and for the ones who is still working there

-- Average of the number of days Employers were late (for the last 30 days)

-- Average of the number of days Employers were late (for the last 30 days) for employers who left the company and for the ones who is still working there

