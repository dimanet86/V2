USE CompanyProjectsV2;
GO
/* DATA INSERTION */
/* Inserting Roles */
INSERT INTO Roles VALUES ('Project Manager'); 
INSERT INTO Roles VALUES ('Data Analyst'); 
INSERT INTO Roles VALUES ('Market Researcher'); 
INSERT INTO Roles VALUES ('Aerospace Engineer'); 
INSERT INTO Roles VALUES ('Software Developer'); 
INSERT INTO Roles VALUES ('Business Strategist'); 
INSERT INTO Roles VALUES ('Environmental Scientist'); 
INSERT INTO Roles VALUES ('Urban Planner'); 
INSERT INTO Roles VALUES ('Community Organizer'); 
INSERT INTO Roles VALUES ('Sustainability Specialist'); 
INSERT INTO Roles VALUES ('Health Informatics Specialist'); 
INSERT INTO Roles VALUES ('Mobile App Developer'); 
INSERT INTO Roles VALUES ('Telemedicine Specialist'); 
INSERT INTO Roles VALUES ('User Experience Designer'); 
INSERT INTO Roles VALUES ('Health Insurance Specialist'); 
INSERT INTO Roles VALUES ('Civil Engineer'); 
INSERT INTO Roles VALUES ('IoT Solutions Architect'); 
INSERT INTO Roles VALUES ('Traffic Engineer'); 
INSERT INTO Roles VALUES ('Waste Management Specialist'); 
INSERT INTO Roles VALUES ('Public Relations Specialist'); 
GO

 /* Inserting Projects */ 
INSERT INTO Projects (project_name, creation_date) VALUES ('Stellar Solutions', '03/15/2024'); 
INSERT INTO Projects (project_name, creation_date) VALUES ('EcoHarmony Initiative', '06/20/2024'); 
INSERT INTO Projects (project_name, creation_date) VALUES ('DataSprint Analytics', '02/01/2024'); 
INSERT INTO Projects (project_name, creation_date) VALUES ('HealthTrack Innovations', '05/10/2024'); 
INSERT INTO Projects (project_name, creation_date) VALUES ('SmartCity Solutions', '01/25/2024'); 
GO

/* Inserting Employees */ 
INSERT INTO Employees VALUES ('Emily', 'Holmes'); 
INSERT INTO Employees VALUES ('Ralph', 'Barnes'); 
INSERT INTO Employees VALUES ('Milton', 'Grant'); 
INSERT INTO Employees VALUES ('Blake', 'Campbell'); 
INSERT INTO Employees VALUES ('James', 'Keller'); 
INSERT INTO Employees VALUES ('Ricky', 'Shelton'); 
INSERT INTO Employees VALUES ('Marcus', 'Sandoval'); 
INSERT INTO Employees VALUES ('Susan', 'Cummings'); 
INSERT INTO Employees VALUES ('Tom', 'Burgess'); 
INSERT INTO Employees VALUES ('Rosa', 'Farmer'); 
INSERT INTO Employees VALUES ('Theodore', 'Robinson'); 
INSERT INTO Employees VALUES ('Laura', 'Dunn'); 
INSERT INTO Employees VALUES ('Harry', 'Henry'); 
INSERT INTO Employees VALUES ('Melvin', 'Roy'); 
INSERT INTO Employees VALUES ('Amelia', 'Holmes'); 
INSERT INTO Employees VALUES ('Effie', 'Riley'); 
INSERT INTO Employees VALUES ('Wesley', 'Bush'); 
INSERT INTO Employees VALUES ('Randy', 'Bell'); 
INSERT INTO Employees VALUES ('Joel', 'Robertson'); 
INSERT INTO Employees VALUES ('John', 'Peters'); 
INSERT INTO Employees VALUES ('Wayne', 'Barton'); 
INSERT INTO Employees VALUES ('David', 'Vargas'); 
INSERT INTO Employees VALUES ('Samuel', 'Hawkins'); 
INSERT INTO Employees VALUES ('Jeffery', 'Nunez'); 
INSERT INTO Employees VALUES ('Beulah', 'Nelson'); 
INSERT INTO Employees VALUES ('Pearl', 'Banks'); 
INSERT INTO Employees VALUES ('Ronald', 'Burke'); 
GO

/* Inserting Tasks */
INSERT INTO Tasks (task_name, project_id, deadline) VALUES ('Conduct market research.', 10, '06/30/2024'); 
INSERT INTO Tasks (task_name, project_id, deadline) VALUES ('Develop prototypes.', 10, '07/15/2024'); 
INSERT INTO Tasks (task_name, project_id, deadline) VALUES ('Collaborate with engineering teams.', 10, '08/01/2024'); 
INSERT INTO Tasks (task_name, project_id, deadline) VALUES ('Create a comprehensive business plan.', 10, '08/15/2024'); 
INSERT INTO Tasks (task_name, project_id, deadline) VALUES ('Establish partnerships with leading space agencies.', 10, '08/30/2024'); 
INSERT INTO Tasks (task_name, project_id, deadline) VALUES ('Conduct environmental impact assessments.', 20, '07/30/2024'); 
INSERT INTO Tasks (task_name, project_id, deadline) VALUES ('Design and implement sustainable waste management.', 20, '08/15/2024'); 
INSERT INTO Tasks (task_name, project_id, deadline) VALUES ('Develop educational programs.', 20, '08/30/2024'); 
INSERT INTO Tasks (task_name, project_id, deadline) VALUES ('Collaborate with local governments.', 20, '09/15/2024'); 
INSERT INTO Tasks (task_name, project_id, deadline) VALUES ('Organize community clean-up events.', 20, '09/30/2024'); 
INSERT INTO Tasks (task_name, project_id, deadline) VALUES ('Collect and clean datasets.', 30, '06/15/2024'); 
INSERT INTO Tasks (task_name, project_id, deadline) VALUES ('Build predictive models.', 30, '06/30/2024'); 
INSERT INTO Tasks (task_name, project_id, deadline) VALUES ('Perform exploratory data analysis.', 30, '07/15/2024'); 
INSERT INTO Tasks (task_name, project_id, deadline) VALUES ('Create data visualizations.', 30, '07/30/2024'); 
INSERT INTO Tasks (task_name, project_id, deadline) VALUES ('Implement data-driven decision-making frameworks.', 30, '08/15/2024'); 
INSERT INTO Tasks (task_name, project_id, deadline) VALUES ('Research and analyze data on healthcare.', 40, '08/30/2024'); 
INSERT INTO Tasks (task_name, project_id, deadline) VALUES ('Develop a mobile health app.', 40, '09/15/2024'); 
INSERT INTO Tasks (task_name, project_id, deadline) VALUES ('Collaborate with medical professionals.', 40, '09/30/2024'); 
INSERT INTO Tasks (task_name, project_id, deadline) VALUES ('Conduct usability testing.', 40, '10/15/2024'); 
INSERT INTO Tasks (task_name, project_id, deadline) VALUES ('Establish partnerships with health insurance providers.', 40, '10/30/2024'); 
INSERT INTO Tasks (task_name, project_id, deadline) VALUES ('Evaluate existing infrastructure.', 50, '05/15/2024'); 
INSERT INTO Tasks (task_name, project_id, deadline) VALUES ('Design IoT solutions.', 50, '05/30/2024'); 
INSERT INTO Tasks (task_name, project_id, deadline) VALUES ('Develop a traffic management system.', 50, '06/15/2024'); 
INSERT INTO Tasks (task_name, project_id, deadline) VALUES ('Implement smart waste management solutions.', 50, '06/30/2024'); 
INSERT INTO Tasks (task_name, project_id, deadline) VALUES ('Conduct public awareness campaigns.', 50, '07/15/2024'); 
GO

/* Helper procedure for passing random IDs to a table  */
CREATE PROCEDURE proc_fill_table_EPR
AS
INSERT INTO EmployeeProjectsRoles
SELECT E.emp_id, R.role_id, P.project_id
FROM Employees E, Roles R, Projects P
WHERE E.emp_id = FLOOR((RAND() * 19  + 1))  
AND R.role_id = FLOOR((RAND() * 200  + 1000) / 10) * 10
AND P.project_id = FLOOR((RAND() * 50  + 10) / 10) * 10
GO

/* Filling Employees Project Roles, thus assining employees to projects and assigning roles to employees */
DECLARE @counter INT
SET @counter = 1
WHILE (@counter < 20) 
BEGIN
EXEC proc_fill_table_EPR
SET @counter = @counter + 1
END
EXEC proc_fill_table_EPR
GO

/* 
    Procedure for tracking Task Status changes.
    Let's accept the following workflow:
    1. We have some interface to this database and users (employees)
    2. Let's assume everyone authorized under their own account can change task statuses
       via this interface
    3. When user applies changes procedure below is invoked and parameters passed properly
    4. Procedure below tracks task status change and employee who changes status 
       under his/her account 
    This is similar to SalesForce, for example
*/
CREATE PROCEDURE proc_task_status_change @task_id INT, @emp_id INT, @status NVARCHAR(20)
AS
BEGIN TRANSACTION
UPDATE Tasks
SET [status] = @status, emp_id = @emp_id
WHERE task_id = @task_id
INSERT INTO TaskLog (task_id, emp_id, change_date, [status])
VALUES (@task_id, @emp_id, GETDATE(), @status)
COMMIT
GO

/* Procedure assigning tasks to employees */ 
CREATE PROCEDURE pr_assign_tasks @task_id INT, @emp_id INT
AS 
UPDATE Tasks
SET emp_id = @emp_id
WHERE task_id = @task_id
GO

-- Tasks for project 10
EXEC pr_assign_tasks @task_id = 100, @emp_id = 4;
EXEC pr_assign_tasks @task_id = 101, @emp_id = 8;
EXEC pr_assign_tasks @task_id = 102, @emp_id = 11;
EXEC pr_assign_tasks @task_id = 103, @emp_id = 13;
EXEC pr_assign_tasks @task_id = 104, @emp_id = 19;
-- Tasks for project 20
EXEC pr_assign_tasks @task_id = 105, @emp_id = 1;
EXEC pr_assign_tasks @task_id = 106, @emp_id = 2;
EXEC pr_assign_tasks @task_id = 107, @emp_id = 19;
EXEC pr_assign_tasks @task_id = 108, @emp_id = 2;
EXEC pr_assign_tasks @task_id = 109, @emp_id = 1;
-- Tasks for project 30
EXEC pr_assign_tasks @task_id = 110, @emp_id = 14;
EXEC pr_assign_tasks @task_id = 111, @emp_id = 9;
EXEC pr_assign_tasks @task_id = 112, @emp_id = 17;
EXEC pr_assign_tasks @task_id = 113, @emp_id = 5;
EXEC pr_assign_tasks @task_id = 114, @emp_id = 8;
-- Tasks for project 40
EXEC pr_assign_tasks @task_id = 115, @emp_id = 10;
EXEC pr_assign_tasks @task_id = 116, @emp_id = 15;
EXEC pr_assign_tasks @task_id = 117, @emp_id = 15;
EXEC pr_assign_tasks @task_id = 118, @emp_id = 10;
EXEC pr_assign_tasks @task_id = 119, @emp_id = 10;
-- Tasks for project 50
EXEC pr_assign_tasks @task_id = 120, @emp_id = 4;
EXEC pr_assign_tasks @task_id = 121, @emp_id = 15;
EXEC pr_assign_tasks @task_id = 122, @emp_id = 16;
EXEC pr_assign_tasks @task_id = 123, @emp_id = 17;
EXEC pr_assign_tasks @task_id = 124, @emp_id = 16;
GO