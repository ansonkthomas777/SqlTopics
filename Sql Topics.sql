create database testing
use testing
/*TABLE EMPLOYEE----*/
create table EMPLOYEE(EMP_ID int constraint emp_id_pk primary key identity (100,1) not null,
EMP_NAME nvarchar(40) null,
SALARY MONEY NULL,
START_DATE DATETIME NULL,
TERM_DATE DATETIME NULL
)

/*TABLE DIVISION*/
create table DIVISION(DIV_ID int constraint div_id_pk  primary key identity (200,1) not null,
DIV_NAME nvarchar(40) null,
VP_EMP_ID INT NOT NULL CONSTRAINT vp_emp_fk FOREIGN KEY(VP_EMP_ID) REFERENCES EMPLOYEE(EMP_ID)
)

/*TABLE TEAM*/
create table TEAM (TEAM_ID int constraint team_id_pk primary key  identity (300,1) not null,
TEAM_NAME nvarchar(40) null,
DIV_ID INT,
CONSTRAINT div_id_fk FOREIGN KEY(DIV_ID) REFERENCES DIVISION(DIV_ID)
)

/*TABLE TEAM_ASSIGNMENT*/
/*
create table TEAM_ASSIGNMENT (ASSIGN_ID int identity (1,1) primary key not null,
TEAM_ID int NOT NULL,
EMP_ID INT NOT NULL,
MGR_EMP_ID INT NOT NULL,
FOREIGN KEY (EMP_ID) REFERENCES EMPLOYEE(EMP_ID),
FOREIGN KEY (TEAM_ID) REFERENCES TEAM(TEAM_ID),
FOREIGN KEY (MGR_EMP_ID) REFERENCES EMPLOYEE(EMP_ID)
)
*/
/*1----Provide the division name for any divisions having more than two (2) teams or more than fourteen (14) employees.----------------*/



 CREATE VIEW TEAMCOUNT
 AS SELECT DIV_ID,COUNT(DIV_ID) AS 'COUNTTEAM' FROM TEAM
GROUP BY DIV_ID
GO


CREATE VIEW COUNTOFEMPLOYEE
 AS SELECT TEAM_ID,COUNT(TEAM_ID) AS 'EMPLOYEESCOUNT' FROM TEAM_ASSIGNMENT
GROUP BY TEAM_ID
GO



SELECT DIVISION.DIV_ID, DIV_NAME 
FROM DIVISION, TEAM, TEAM_ASSIGNMENT, COUNTOFEMPLOYEE, TEAMCOUNT 
WHERE DIVISION.DIV_ID = TEAM.DIV_ID AND TEAM.TEAM_ID = TEAM_ASSIGNMENT.TEAM_ID 
AND COUNTOFEMPLOYEE.TEAM_ID = TEAM.TEAM_ID AND TEAMCOUNT.DIV_ID =DIVISION.DIV_ID
AND (COUNTOFEMPLOYEE.EMPLOYEESCOUNT >= 14 OR TEAMCOUNT.COUNTTEAM > 2)
GROUP BY DIVISION.DIV_ID, DIVISION.DIV_NAME

			   /*2-------Provide the team name for any teams managed by “Jamie Jones”.-----*/

  SELECT  DISTINCT TEAM.TEAM_ID,TEAM.TEAM_NAME,EMPLOYEE.EMP_NAME FROM TEAM INNER JOIN TEAM_ASSIGNMENT
   ON TEAM.TEAM_ID=TEAM_ASSIGNMENT.TEAM_ID INNER JOIN EMPLOYEE ON TEAM_ASSIGNMENT.MGR_EMP_ID=EMPLOYEE.EMP_ID
    WHERE TEAM_ASSIGNMENT.MGR_EMP_ID=(SELECT EMP_ID FROM EMPLOYEE WHERE EMP_NAME='Jamie Jones')


  /*3----------Provide the names of all Vice Presidents who lead divisions that have no teams.-------*/

   select DISTINCT DIVISION.VP_EMP_ID,EMPLOYEE.EMP_NAME FROM DIVISION INNER JOIN EMPLOYEE ON 
   DIVISION.VP_EMP_ID=EMPLOYEE.EMP_ID  WHERE DIVISION.DIV_ID IN(SELECT DIVISION.DIV_ID FROM DIVISION 
   WHERE DIVISION.DIV_ID NOT IN(SELECT DIV_ID FROM  TEAM))

 /*4--------What calendar month has had the greatest number of employee terminations-----------*/
  

  SELECT top 1 MONTH(TERM_DATE) as CalMonth
FROM EMPLOYEE
GROUP BY MONTH(TERM_DATE)
ORDER BY COUNT(TERM_DATE) DESC

 /*5-------Provide the team name and sum of salaries for
  teams that don’t report to a Vice President.-----*/

  CREATE VIEW TEST
AS SELECT TEAM_ASSIGNMENT.team_id, TEAM_ASSIGNMENT.EMP_ID FROM TEAM_ASSIGNMENT
INNER JOIN TEAM ON TEAM.TEAM_ID = TEAM_ASSIGNMENT.TEAM_ID
INNER JOIN EMPLOYEE ON EMPLOYEE.EMP_ID = TEAM_ASSIGNMENT.EMP_ID
GROUP BY TEAM.TEAM_ID, TEAM_ASSIGNMENT.EMP_ID, TEAM_ASSIGNMENT.TEAM_ID
GO

SELECT TEAM.TEAM_NAME, SUM(SALARY) AS SUMOFSALARY
FROM TEAM, EMPLOYEE
JOIN TEST ON TEST.EMP_ID = employee.EMP_ID
join TEAM_ASSIGNMENT on TEAM_ASSIGNMENT.TEAM_ID = test.team_id
join division on division.VP_EMP_ID = EMPLOYEE.EMP_ID
where test.TEAM_ID = team.TEAM_ID AND TEAM_ASSIGNMENT.MGR_EMP_ID NOT IN (
	SELECT division.vp_EMP_ID FROM division)
GROUP BY TEAM.TEAM_NAME

DROP VIEW TEST

 /*6---How many team managers are also Vice Presidents---*/

 SELECT count(distinct TEAM_ASSIGNMENT.MGR_EMP_ID)
FROM TEAM_ASSIGNMENT
join team on TEAM.TEAM_ID = TEAM_ASSIGNMENT.TEAM_ID
join division on division.DIV_ID = team.DIV_ID
WHERE TEAM_ASSIGNMENT.MGR_EMP_ID in (select division.VP_EMP_ID from division) 

 /*7----Provide the name of the most senior team manager
  who reports to Vice President, “Ralph Raines”----*/

  SELECT top 1 EMP_NAME
FROM EMPLOYEE
join TEAM_ASSIGNMENT on team_assignment.EMP_ID = employee.EMP_ID
join team on team.TEAM_ID = TEAM_ASSIGNMENT.TEAM_ID
join division on division.DIV_ID = team.DIV_ID
WHERE Division.VP_EMP_ID = (select employee.EMP_ID from employee where EMP_NAME='Ralph Raines')
ORDER BY START_DATE desc

 /*8---Provide the sum of salaries for the employees hired before the
  Vice President in charge of the greatest number of teams....*/

  SELECT employee.EMP_ID, SALARY as SUMOFSALARY
FROM EMPLOYEE
join TEAM_ASSIGNMENT on team_assignment.EMP_ID = employee.EMP_ID
join team on team.TEAM_ID = TEAM_ASSIGNMENT.TEAM_ID
join division on division.DIV_ID = team.DIV_ID
WHERE START_DATE < (
	select top 1 start_date from employee 
	join TEAM_ASSIGNMENT on team_assignment.EMP_ID = employee.EMP_ID
	join team on team.TEAM_ID = TEAM_ASSIGNMENT.TEAM_ID
	join division on division.DIV_ID = team.DIV_ID
	where employee.emp_id = TEAM_ASSIGNMENT.MGR_EMP_ID 
	AND TEAM_ASSIGNMENT.MGR_EMP_ID = division.VP_EMP_ID)

  /*
 SELECT SUM(EMPLOYEE.SALARY) FROM EMPLOYEE WHERE CAST(EMPLOYEE.START_DATE AS datetime)<
 (select CAST(EMPLOYEE.START_DATE AS datetime) from EMPLOYEE INNER JOIN DIVISION ON EMPLOYEE.EMP_ID=DIVISION.VP_EMP_ID
  WHERE EMPLOYEE.EMP_ID=100)

  SELECT MAX(TEAM.TEAM_ID) FROM(SELECT COUNT(TEAM.TEAM_ID)TEAM_ID FROM TEAM INNER JOIN DIVISION ON
   TEAM.DIV_ID=DIVISION.DIV_ID GROUP BY TEAM.DIV_ID)TEAM
  */

  
  

  
  