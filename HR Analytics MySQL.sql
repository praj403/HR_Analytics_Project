-- KPI's HR Analyst
USE hr_data;

-- Add the new columns for date_of_joining, month_full_name, and quarter
ALTER TABLE hr_2
ADD COLUMN date_of_joining DATE,
ADD COLUMN month_full_name VARCHAR(20),
ADD COLUMN quarter VARCHAR(10);
 -- Rename the columns 
ALTER TABLE hr_2  RENAME COLUMN  `Year of Joining` TO year_of_joining;
ALTER TABLE hr_2  RENAME COLUMN  `Month of Joining` TO Month_of_Joining;
ALTER TABLE hr_2  RENAME COLUMN  `Day of Joining` TO day_of_joining;
-- Update the values for the new columns
SET SQL_SAFE_UPDATES = 0;
UPDATE hr_2
SET date_of_joining = STR_TO_DATE(CONCAT(year_of_joining, '-', month_of_joining, '-', day_of_joining), '%Y-%m-%d'),
    month_full_name = CASE month_of_joining
        WHEN 1 THEN 'January'
        WHEN 2 THEN 'February'
        WHEN 3 THEN 'March'
        WHEN 4 THEN 'April'
        WHEN 5 THEN 'May'
        WHEN 6 THEN 'June'
        WHEN 7 THEN 'July'
        WHEN 8 THEN 'August'
        WHEN 9 THEN 'September'
        WHEN 10 THEN 'October'
        WHEN 11 THEN 'November'
        WHEN 12 THEN 'December'
        ELSE 'Invalid Month'
    END,
    quarter = CONCAT('Q', QUARTER(STR_TO_DATE(CONCAT(year_of_joining, '-', month_of_joining, '-', day_of_joining), '%Y-%m-%d')));
    
SELECT * FROM HR_2 ;
 ------------------------------------------------------------------------------------------------------------------------------------------------------------
-- KPI 1 : Average Attrition rate for all Departments

CREATE VIEW KPI_1 AS
SELECT department,
COUNT(EmployeeNumber) AS total_employees,
round(COUNT(CASE WHEN attrition='yes' IS NOT NULL THEN 1 END)) AS total_attritions,
round(COUNT(CASE when attrition='yes' THEN EmployeeNumber END)*100/50000,2) AS `emp_left (%)`,
round(COUNT(CASE when attrition='no' THEN EmployeeNumber END)*100/50000,2) AS `emp_stayed (%)`,
round((COUNT(CASE WHEN attrition='yes' IS NOT NULL THEN 1 END)* 100 / 50000),2) AS 'attrition_rate (%)'
FROM hr_1
GROUP BY department; 

SELECT * FROM KPI_1;

 ------------------------------------------------------------------------------------------------------------------------------------------------------------
-- KPI 2 : Average Hourly rate of Male Research Scientist

CREATE VIEW  KPI_2 AS
SELECT Gender,JobRole,AVG(HourlyRate) AS average_HourlyRate
FROM hr_1
WHERE JobRole="Research Scientist" AND Gender="Male" 
GROUP BY Gender;

SELECT * FROM KPI_2;

 ------------------------------------------------------------------------------------------------------------------------------------------------------------
-- # KPI 3 : Attrition rate Vs Monthly income stats

ALTER TABLE hr_2  RENAME COLUMN  `Employee ID` TO Employeeid;

CREATE VIEW  KPI_3 AS
SELECT 'yes' AS Attrition,FORMAT(SUM(CASE WHEN attrition = 'yes' THEN monthlyincome ELSE 0 END), 0) AS Monthly_Income_TOTAL
FROM hr_1
INNER JOIN hr_2 ON hr_2.employeeid = hr_1.employeenumber
WHERE attrition = 'yes'
UNION
SELECT 'no' AS Attrition,FORMAT(SUM(CASE WHEN attrition = 'no' THEN monthlyincome ELSE 0 END), 0) AS Monthly_Income_TOTAL
FROM hr_1
INNER JOIN hr_2 ON hr_2.employeeid = hr_1.employeenumber
WHERE attrition = 'no';

SELECT * FROM KPI_3;

------------------------------------------------------------------------------------------------------------------------------------------------------------
-- KPI 4 Average working years for each Department

CREATE VIEW  KPI_4 AS
SELECT hr_1.Department,
round(AVG(hr_2.totalworkingyears),2) AS 'AVG Working Year(%)' 
FROM hr_2 INNER JOIN hr_1
ON hr_1.Employeenumber = hr_2.Employeeid
GROUP BY hr_1.Department
ORDER BY hr_1.Department;

SELECT * FROM KPI_4;

------------------------------------------------------------------------------------------------------------------------------------------------------------
-- KPI 5 : Departmentwise No of Employees

CREATE VIEW  KPI_5 AS
 SELECT Department , count(EmployeeNumber) AS No_of_Employee
 FROM hr_1
 GROUP BY Department ;
 
 SELECT * FROM KPI_5;
 
 ------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- KPI 6 : Count of Employees based on Educational Fields

CREATE VIEW  KPI_6 AS
 SELECT EducationField , count(EmployeeNumber) AS No_of_Employee
 FROM hr_1
GROUP BY  EducationField ;
 
 SELECT * FROM KPI_6;
 
 ------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- KPI 7 : Job Role Vs Work life balance

CREATE VIEW  KPI_7 AS
SELECT hr_1.JobRole,
sum(hr_2.WorkLifeBalance) 
FROM hr_2 INNER JOIN hr_1
ON hr_1.Employeenumber = hr_2.Employeeid
GROUP BY hr_1.JobRole
ORDER BY hr_1.JobRole;

SELECT * FROM KPI_7;

------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- # KPI 8 : Attrition rate Vs Year since last promotion relation

CREATE VIEW  KPI_8 AS
SELECT
    CASE
        WHEN hr_2.yearssincelastpromotion BETWEEN 1 AND 5 THEN '1-5'
        WHEN hr_2.yearssincelastpromotion BETWEEN 6 AND 10 THEN '6-10'
        WHEN hr_2.yearssincelastpromotion BETWEEN 11 AND 15 THEN '11-15'
        WHEN hr_2.yearssincelastpromotion BETWEEN 16 AND 20 THEN '16-20'
        WHEN hr_2.yearssincelastpromotion BETWEEN 21 AND 25 THEN '21-25'
        WHEN hr_2.yearssincelastpromotion BETWEEN 26 AND 30 THEN '26-30'
        WHEN hr_2.yearssincelastpromotion BETWEEN 31 AND 35 THEN '31-35'
        WHEN hr_2.yearssincelastpromotion BETWEEN 36 AND 40 THEN '36-40'
        ELSE '41+'
    END AS yearssincelastpromotion_group,
    COUNT(CASE WHEN hr_1.attrition = 'no' THEN hr_1.EmployeeNumber END) AS emp_stayed,
    COUNT(CASE WHEN hr_1.attrition = 'yes' THEN hr_1.EmployeeNumber END) AS emp_left,
    COUNT(hr_1.EmployeeNumber) AS total_emp
FROM hr_1
INNER JOIN hr_2 ON hr_1.Employeenumber = hr_2.Employeeid
GROUP BY yearssincelastpromotion_group
ORDER BY yearssincelastpromotion_group;

SELECT * FROM KPI_8;

------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- KPI 9 : Gender based Percentage of Employee
 
 CREATE VIEW  KPI_9 AS
SELECT Gender,
round(count(EmployeeNumber)*100/50000,2) AS'(%) of Employee'
FROM hr_1
GROUP BY gender;

SELECT * FROM KPI_9;

------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- KPI 10 : Monthly New Hire vs Attrition Trendline
 
CREATE VIEW KPI_10 AS
SELECT hr_2.month_full_name AS Monthly_New_Hire,
       ROUND(COUNT(CASE WHEN attrition = 'yes' THEN 1 END)) AS total_attritions
FROM hr_1
INNER JOIN hr_2 ON hr_1.Employeenumber = hr_2.Employeeid
GROUP BY hr_2.month_full_name
ORDER BY FIELD(hr_2.month_full_name,'January', 'February', 'March', 'April', 'May', 'June', 'July','August', 'September', 'October', 'November', 'December');

SELECT * FROM KPI_10;

------------------------------------------------------------------------------------------------------------------------------------------------------------
 -- KPI 11 : Deptarment  wise job satisfaction
 
 CREATE VIEW KPI_11 AS
SELECT
    Department,
    COUNT(CASE WHEN JobSatisfaction = 1 THEN 1 END) AS Count_of_JobSatisfaction_1,
    COUNT(CASE WHEN JobSatisfaction = 2 THEN 1 END) AS Count_of_JobSatisfaction_2,
    COUNT(CASE WHEN JobSatisfaction = 3 THEN 1 END) AS Count_of_JobSatisfaction_3,
    COUNT(CASE WHEN JobSatisfaction = 4 THEN 1 END) AS Count_of_JobSatisfaction_4,
    COUNT(JobSatisfaction) AS Total_Count_of_JobSatisfaction
FROM hr_1
GROUP BY Department;
 
 SELECT * FROM KPI_11;
 
  -- OR --
  
 -- KPI 12 : Job Role wise job satisfaction
 
 CREATE VIEW KPI_12 AS
SELECT JobRole,
    COUNT(CASE WHEN JobSatisfaction = 1 THEN 1 END) AS Count_of_JobSatisfaction_1,
    COUNT(CASE WHEN JobSatisfaction = 2 THEN 1 END) AS Count_of_JobSatisfaction_2,
    COUNT(CASE WHEN JobSatisfaction = 3 THEN 1 END) AS Count_of_JobSatisfaction_3,
    COUNT(CASE WHEN JobSatisfaction = 4 THEN 1 END) AS Count_of_JobSatisfaction_4,
    COUNT(JobSatisfaction) AS Total_Count_of_JobSatisfaction
FROM hr_1
GROUP BY JobRole;
 
 SELECT * FROM KPI_12;