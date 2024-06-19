CREATE DATABASE CompanyProjectsV2;
GO

USE CompanyProjectsV2;
GO

/* ROLES */
CREATE TABLE Roles (
    role_id INT IDENTITY(1000, 10),
    role_name NVARCHAR(128) NOT NULL UNIQUE,
    PRIMARY KEY (role_id)
);
GO

/* EMPLOYEES */
CREATE TABLE Employees (
    emp_id INT IDENTITY(1,1),
    firstName NVARCHAR(128) NOT NULL,
    lastName NVARCHAR(128) NOT NULL,
    CONSTRAINT PK_employee_id PRIMARY KEY(emp_id)
)
GO

/* PROJECTS */
CREATE TABLE Projects(
    project_id INT IDENTITY(10, 10),
    project_name NVARCHAR(128) NOT NULL,
    creation_date DATE DEFAULT GETDATE(),
    close_date DATE,
    closed BIT DEFAULT 0,
    CONSTRAINT U_pname UNIQUE(project_name),
    CONSTRAINT PK_project_id PRIMARY KEY(project_id),
    CONSTRAINT CK_CloseDateRequired CHECK (closed = 0 OR (closed = 1 AND close_date IS NOT NULL)),
    CONSTRAINT CK_NoCloseDateIfNotClosed CHECK (closed = 1 OR close_date IS NULL)
);
GO

ALTER TABLE Projects
ADD duration_days AS
CASE WHEN close_date IS NULL THEN DATEDIFF(day, creation_date, GETDATE())
ELSE DATEDIFF(day, creation_date, close_date)
END
GO

/* 'Composite entity' table for dealing with many-to-many relationship roles-projects-employees */
CREATE TABLE EmployeeProjectsRoles (
    emp_id INT,
    role_id INT,
    project_id INT,
    CONSTRAINT PK_row_num PRIMARY KEY(emp_id, role_id, project_id),
    CONSTRAINT FK_employee FOREIGN KEY (emp_id) REFERENCES Employees(emp_id),
    CONSTRAINT FK_project FOREIGN KEY (project_id) REFERENCES Projects(project_id),
    CONSTRAINT FK_role FOREIGN KEY (role_id) REFERENCES Roles(role_id)
);
GO

/* TASKS */
CREATE TABLE Tasks(
    task_id INT IDENTITY(100, 1),
    task_name NVARCHAR(255) NOT NULL,
    [status] NVARCHAR(20) CHECK ([status] IN ('Open', 'Need work', 'Done', 'Accepted (closed)')) DEFAULT 'Open', 
    emp_id INT,
    project_id INT NOT NULL,
    deadline DATE NOT NULL,
    CONSTRAINT PK_task_id PRIMARY KEY (task_id),
    CONSTRAINT FK_task_employee_assigned FOREIGN KEY (emp_id) REFERENCES Employees(emp_id),
    CONSTRAINT FK_task_project FOREIGN KEY (project_id) REFERENCES Projects(project_id)
);
GO

/*Task log*/
CREATE TABLE TaskLog(
    num INT IDENTITY(1, 1) PRIMARY KEY,
    task_id INT NOT NULL, 
    emp_id INT NOT NULL,
    change_date DATE NOT NULL,
    [status] NVARCHAR(20) CHECK ([status] IN ('Open', 'Need work', 'Done', 'Accepted (closed)')), 
    CONSTRAINT FK_employee_making_change FOREIGN KEY (emp_id) REFERENCES Employees(emp_id),
    CONSTRAINT FK_task_id FOREIGN KEY (task_id) REFERENCES Tasks(task_id)
);
GO
