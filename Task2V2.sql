USE CompanyProjectsV2;
GO

-- 1. Retrieve a list of all roles in the company, which should include the number of employees for each of role assigned
SELECT R.role_name, E.[Number of employees] 
FROM (
    SELECT role_id, COUNT(role_id) [Number of employees] 
    FROM EmployeeProjectsRoles
    GROUP BY role_id
) E
JOIN Roles R
ON E.role_id = R.role_id

-- 2. Get roles which has no employees assigned
SELECT E.emp_id, R.role_id, R.role_name 
FROM EmployeeProjectsRoles E
RIGHT JOIN Roles R
ON E.role_id = R.role_id
WHERE emp_id IS NULL

-- 3. Get projects list where every project has list of roles supplied with number of employees
WITH CTE (emp_id, role_id, pid, num) AS 
(
    SELECT *, COUNT(emp_id) 
    OVER (PARTITION BY project_id) 
    AS [Number of employees on project]
    FROM EmployeeProjectsRoles
) 
SELECT CTE.pid, P.project_name, R.role_name, CTE.num AS [# of employees per project]
FROM CTE
JOIN Roles R 
ON CTE.role_id = R.role_id
JOIN Projects P
ON CTE.pid = P.project_id
GO

-- 4. For every project count how many tasks there are assigned for every employee in average
-- I did it in three ways

-- First: 
WITH TasksPlus (p_id, emp_id, num_tasks) AS (
    SELECT project_id, emp_id, CAST(COUNT(task_id) AS float) AS [# tasks per emp] 
    FROM Tasks
    GROUP BY GROUPING SETS((emp_id, project_id))
) 
SELECT p_id, AVG(num_tasks) 
OVER(PARTITION BY p_id)
FROM TasksPlus
GO

-- And second:
WITH tasks_avg (emp_id, pid, count)
AS (
    SELECT emp_id, project_id, CAST(COUNT(task_id) AS float) AS [Avg of tasks per employee]
    FROM Tasks
    GROUP BY emp_id, project_id
    )
SELECT pid, AVG(count) 
FROM tasks_avg
GROUP BY pid
GO

-- Third, my favourite :)
SELECT project_id, CAST(CAST(COUNT(task_id) AS float) / COUNT (DISTINCT emp_id) AS float) AS [Avg of tasks per employee]
FROM Tasks
GROUP BY project_id


-- 5. Determine duration for each project 
-- I have chosen days as a scale
-- duration_days is a computed column returning number of days since creation_date
-- if project is closed, then it returns close date - creation date,
-- if it's not closed it returns current date - creation date
-- column value may be negative if project hasn't been started yet
SELECT project_name, duration_days 
FROM Projects

-- 6. Identify which employees has the lowest number tasks with non-closed statuses.
DECLARE @min_tasks INT; 
SELECT @min_tasks = MIN(A.[How many tasks]) 
FROM
(
    SELECT emp_id, COUNT(task_id) 
     AS [How many tasks] FROM Tasks 
     WHERE [status] != 'Accepted (closed)'
     GROUP BY emp_id
) A

SELECT T.emp_id, firstName, lastName, T.[Num of tasks assigned]
FROM
(
    SELECT emp_id, COUNT(task_id) AS [Num of tasks assigned] 
    FROM Tasks 
    GROUP BY emp_id
    HAVING COUNT(task_id) = @min_tasks
) T
JOIN Employees E 
ON T.emp_id = E.emp_id
GO

-- 7. Identify which employees has the most tasks with non-closed statuses with failed deadlines.
SELECT T.emp_id, COUNT(T.task_id) AS [# of tasks with failed dl]
FROM 
(
    SELECT * FROM Tasks
    WHERE GETDATE() > deadline
) T
GROUP BY T.emp_id
GO

-- 8. Move forward deadline for non-closed tasks in 5 days.
UPDATE Tasks
SET deadline = DATEADD(day, 5, deadline)
WHERE [status] != 'Accepted (Closed)'
GO

-- 9. For each project count how many there are tasks which were not started yet.
-- Assuming that 'Open' status means 'Not started', because otherwise 'Not started' is ambiguos

-- For this task I'm updating data for tasks table 
-- setting some tasks for project 10 and 40 to 'Need work' status

EXEC proc_task_status_change @task_id = 102, @emp_id = 4, @status = 'Need work';
EXEC proc_task_status_change @task_id = 119, @emp_id = 11, @status = 'Need work';
GO

SELECT DISTINCT T.project_id, P.project_name, COUNT(*) 
OVER(PARTITION BY T.project_id) AS [# not started]
FROM Tasks T
JOIN Projects P
ON T.project_id = P.project_id
WHERE [status] = 'Open'
GO

-- 10. For each project which has all tasks marked as closed move status to closed. Close date for such project should match close date for the last accepted task.

    -- For this task I'm first choosing project with id = 20 and updating all tasks status to 'Accepted (closed)'
    -- using previously defined stored procedure proc_task_status_change

-- First, I'm updating data for demonstration purposes
DECLARE @task_id INT
DECLARE @emp_id INT
DECLARE @new_status NVARCHAR(20)

DECLARE cur CURSOR FOR
SELECT task_id, emp_id, 'Accepted (closed)' AS new_status FROM Tasks WHERE project_id = 20

OPEN cur
FETCH NEXT FROM cur INTO @task_id, @emp_id, @new_status

WHILE @@FETCH_STATUS = 0 
BEGIN
    EXEC proc_task_status_change @task_id, @emp_id, @new_status
    FETCH NEXT FROM cur INTO @task_id, @emp_id, @new_status
END 
CLOSE cur
DEALLOCATE cur
GO

-- Next, actual task query: 
-- Finding projects with all tasks closed and the most recent task closing date per project
-- and using query result to update project table 

WITH CTE1 (tid, chd, pid) AS (
    SELECT T.task_id, T.change_date, Tsks.project_id 
    FROM TaskLog T
    JOIN Tasks Tsks
    ON T.task_id = Tsks.task_id
), CTE2 (pid, cdate) AS
(
    SELECT DISTINCT pid, MAX(chd) 
    OVER (PARTITION BY pid) AS close_date
    FROM CTE1
    WHERE pid IN (
        SELECT DISTINCT project_id 
        FROM Tasks
        GROUP BY project_id
        HAVING COUNT(CASE WHEN [status] <> 'Accepted (closed)' THEN 1 ELSE NULL END) = 0
    )
) 
UPDATE Projects
SET close_date = CTE2.cdate, closed = 1
FROM Projects
INNER JOIN CTE2 ON Projects.project_id = CTE2.pid
GO

-- 11. Determine employees across all projects which has not non-closed tasks assigned.
WITH CTE (emp_id) AS (
    SELECT emp_id
    FROM Tasks
    GROUP BY emp_id
    HAVING COUNT(CASE WHEN [status] <> 'Accepted (closed)' THEN 1 ELSE NULL END) = 0
) 
SELECT CTE.emp_id, E.firstName, E.lastName
FROM CTE 
JOIN Employees E
ON CTE.emp_id = E.emp_id
GO

 -- 12. Assign given project task (using task name as identifier) to an employee which has minimum tasks with open status.
-- Let's randomly choose row with Employee ID  and minimum number of tasks, as it may be the case that employee
-- with min number of tasks is not unique.
-- Then I'm using approach I used in Task 10 to update table

WITH CTE1 (emp_id, [# of tasks]) AS
(
    SELECT emp_id, COUNT(task_id) AS [# of tasks]
    FROM Tasks
    WHERE [status] = 'Open'
    GROUP BY emp_id
), CTE2 (emp_id, num_tasks) AS 
(
    SELECT TOP 1 emp_id, MIN([# of tasks]) 
    OVER (ORDER BY [# of tasks])
    FROM CTE1
    ORDER BY NEWID()
) 
UPDATE Tasks
SET emp_id = CTE2.emp_id
FROM CTE2
WHERE task_name = 'Design IoT solutions.'
GO