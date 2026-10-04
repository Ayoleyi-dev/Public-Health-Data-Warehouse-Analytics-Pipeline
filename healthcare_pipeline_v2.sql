/*
    Public Health Data Warehouse & Analytics Pipeline
    Version 2 - reproducible synthetic SQL Server build

    Purpose:
      * Create the project tables when they do not exist.
      * Rebuild deterministic synthetic data for local development.
      * Enforce basic data-quality and referential-integrity rules.
      * Expose a reporting view and a validated patient-intake procedure.

    This script is intentionally destructive for the four project tables.
    Use it only with synthetic development data.
*/

USE [HEALTHCARE ANALYSIS REPORT];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

IF OBJECT_ID(N'dbo.Patients', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Patients
    (
        [Patient ID] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Patients PRIMARY KEY,
        [FIRSTNAME] VARCHAR(50) NOT NULL,
        [LASTNAME] VARCHAR(50) NOT NULL,
        [EMAIL] VARCHAR(100) NOT NULL CONSTRAINT UQ_Patients_Email UNIQUE,
        [CITY] VARCHAR(50) NOT NULL,
        [State] VARCHAR(50) NOT NULL,
        [Age] TINYINT NOT NULL CONSTRAINT CK_Patients_Age CHECK ([Age] BETWEEN 0 AND 120),
        [Weight] DECIMAL(5,2) NOT NULL CONSTRAINT CK_Patients_Weight CHECK ([Weight] > 0)
    );
END;
GO

IF OBJECT_ID(N'dbo.Staff_Table', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Staff_Table
    (
        [Staff id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Staff PRIMARY KEY,
        [First Name] VARCHAR(50) NOT NULL,
        [Last name] VARCHAR(50) NOT NULL,
        [Job Id] INT NOT NULL CONSTRAINT CK_Staff_JobId CHECK ([Job Id] BETWEEN 1 AND 4)
    );
END;
GO

IF OBJECT_ID(N'dbo.Disease_Table', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Disease_Table
    (
        [Disease id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Disease PRIMARY KEY,
        [DISEASE NAME] VARCHAR(80) NOT NULL CONSTRAINT UQ_Disease_Name UNIQUE,
        [PATHOGEN] VARCHAR(30) NOT NULL,
        [SEVERITY] VARCHAR(20) NOT NULL CONSTRAINT CK_Disease_Severity CHECK ([SEVERITY] IN ('Low', 'Moderate', 'Critical'))
    );
END;
GO

IF OBJECT_ID(N'dbo.Consultations', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Consultations
    (
        [consultations id] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Consultations PRIMARY KEY,
        [Patient id] INT NOT NULL,
        [Staff id] INT NOT NULL,
        [DISEASE ID] INT NOT NULL,
        [ADMISSION DATE] DATE NOT NULL,
        [Discharge Date] DATE NOT NULL,
        [Total cost] DECIMAL(12,2) NOT NULL CONSTRAINT CK_Consultations_Cost CHECK ([Total cost] >= 0),
        CONSTRAINT FK_Consultations_Patient FOREIGN KEY ([Patient id]) REFERENCES dbo.Patients([Patient ID]),
        CONSTRAINT FK_Consultations_Staff FOREIGN KEY ([Staff id]) REFERENCES dbo.Staff_Table([Staff id]),
        CONSTRAINT FK_Consultations_Disease FOREIGN KEY ([DISEASE ID]) REFERENCES dbo.Disease_Table([Disease id]),
        CONSTRAINT CK_Consultations_Dates CHECK ([Discharge Date] >= [ADMISSION DATE])
    );
END;
GO

/* Rebuild order follows the foreign-key dependencies. */
BEGIN TRANSACTION;

DELETE FROM dbo.Consultations;
DELETE FROM dbo.Disease_Table;
DELETE FROM dbo.Staff_Table;
DELETE FROM dbo.Patients;

DBCC CHECKIDENT ('dbo.Consultations', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('dbo.Disease_Table', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('dbo.Staff_Table', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT ('dbo.Patients', RESEED, 0) WITH NO_INFOMSGS;

INSERT INTO dbo.Patients ([FIRSTNAME], [LASTNAME], [EMAIL], [CITY], [State], [Age], [Weight])
SELECT
    CHOOSE(n, 'Charles', 'Frank', 'Eniola', 'Toyin', 'Toyosi'),
    CHOOSE(((n + 1) % 5) + 1, 'Ebuka', 'Lewis', 'Oluwa', 'Adeposi', 'Adeniyi'),
    CONCAT('patient', n, '@hospital.ng'),
    CHOOSE(((n + 2) % 5) + 1, 'Yaba', 'Ikorodu', 'Surulere', 'Ikeja', 'Lagos Island'),
    'Lagos',
    CONVERT(TINYINT, 18 + ((n * 17) % 68)),
    CONVERT(DECIMAL(5,2), 45.00 + ((n * 13) % 40) + ((n % 4) * 0.25))
FROM (VALUES
    (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),
    (11),(12),(13),(14),(15),(16),(17),(18),(19),(20),
    (21),(22),(23),(24),(25),(26),(27),(28),(29),(30),
    (31),(32),(33),(34),(35),(36),(37),(38),(39),(40),
    (41),(42),(43),(44),(45),(46),(47),(48),(49),(50),
    (51),(52),(53),(54),(55),(56),(57),(58),(59),(60),
    (61),(62),(63),(64),(65),(66),(67),(68),(69),(70),
    (71),(72),(73),(74),(75),(76),(77),(78),(79),(80),
    (81),(82),(83),(84),(85),(86),(87),(88),(89),(90),
    (91),(92),(93),(94),(95),(96),(97),(98),(99),(100)
) AS Numbers(n);

INSERT INTO dbo.Staff_Table ([First Name], [Last name], [Job Id])
VALUES
    ('Dr. Tunde', 'Balogun', 1), ('Nurse Amara', 'Okoro', 2),
    ('Prof. Wole', 'Adeyemi', 3), ('Dr. Ngozi', 'Nwosu', 1),
    ('Nurse Kemi', 'Ibrahim', 2), ('Dr. Tunde', 'Okoro', 1),
    ('Nurse Amara', 'Adeyemi', 2), ('Prof. Wole', 'Nwosu', 3),
    ('Dr. Ngozi', 'Ibrahim', 1), ('Nurse Kemi', 'Balogun', 2),
    ('Dr. Tunde', 'Adeyemi', 1), ('Nurse Amara', 'Nwosu', 2),
    ('Prof. Wole', 'Ibrahim', 3), ('Dr. Ngozi', 'Balogun', 1),
    ('Nurse Kemi', 'Okoro', 2), ('Dr. Tunde', 'Nwosu', 1),
    ('Nurse Amara', 'Ibrahim', 2), ('Prof. Wole', 'Balogun', 3),
    ('Dr. Ngozi', 'Okoro', 1), ('Nurse Kemi', 'Adeyemi', 2);

INSERT INTO dbo.Disease_Table ([DISEASE NAME], [PATHOGEN], [SEVERITY])
VALUES
    ('Malaria', 'Parasite', 'Moderate'),
    ('Typhoid Fever', 'Bacteria', 'Moderate'),
    ('Cholera', 'Bacteria', 'Critical'),
    ('Lassa Fever', 'Virus', 'Critical'),
    ('Influenza', 'Virus', 'Low');

;WITH Numbers AS
(
    SELECT TOP (200) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects AS a
    CROSS JOIN sys.all_objects AS b
)
INSERT INTO dbo.Consultations
    ([Patient id], [Staff id], [DISEASE ID], [ADMISSION DATE], [Discharge Date], [Total cost])
SELECT
    ((n - 1) % 100) + 1,
    ((n - 1) % 20) + 1,
    ((n - 1) % 5) + 1,
    DATEADD(DAY, -((n * 7) % 365), CONVERT(DATE, GETDATE())),
    DATEADD(DAY, -((n * 7) % 365) + 1 + (n % 14), CONVERT(DATE, GETDATE())),
    CONVERT(DECIMAL(12,2), 5000 + ((n * 1379) % 50000))
FROM Numbers;

COMMIT TRANSACTION;
GO

CREATE OR ALTER VIEW dbo.View_Financial_Report
AS
SELECT
    D.[DISEASE NAME],
    D.[PATHOGEN],
    D.[SEVERITY],
    COUNT_BIG(*) AS [Total Consultations],
    SUM(C.[Total cost]) AS [Total Revenue],
    AVG(CONVERT(DECIMAL(10,2), DATEDIFF(DAY, C.[ADMISSION DATE], C.[Discharge Date]))) AS [Average Stay Days]
FROM dbo.Consultations AS C
INNER JOIN dbo.Disease_Table AS D ON D.[Disease id] = C.[DISEASE ID]
GROUP BY D.[DISEASE NAME], D.[PATHOGEN], D.[SEVERITY];
GO

CREATE OR ALTER PROCEDURE dbo.sp_AdmitPatient
    @FirstName VARCHAR(50),
    @LastName VARCHAR(50),
    @Email VARCHAR(100),
    @City VARCHAR(50),
    @State VARCHAR(50),
    @Age TINYINT,
    @Weight DECIMAL(5,2)
AS
BEGIN
    SET NOCOUNT ON;

    IF NULLIF(LTRIM(RTRIM(@FirstName)), '') IS NULL
        THROW 50001, 'First name is required.', 1;
    IF NULLIF(LTRIM(RTRIM(@LastName)), '') IS NULL
        THROW 50002, 'Last name is required.', 1;
    IF NULLIF(LTRIM(RTRIM(@Email)), '') IS NULL
        THROW 50003, 'Email is required.', 1;
    IF @Age > 120
        THROW 50004, 'Age must be between 0 and 120.', 1;
    IF @Weight <= 0
        THROW 50005, 'Weight must be greater than zero.', 1;
    IF EXISTS (SELECT 1 FROM dbo.Patients WHERE [EMAIL] = @Email)
        THROW 50006, 'A patient with this email already exists.', 1;

    INSERT INTO dbo.Patients ([FIRSTNAME], [LASTNAME], [EMAIL], [CITY], [State], [Age], [Weight])
    VALUES (@FirstName, @LastName, @Email, @City, @State, @Age, @Weight);

    SELECT CAST(SCOPE_IDENTITY() AS INT) AS [New Patient ID];
END;
GO

/* Final build summary */
SELECT 'Patients' AS [Table], COUNT(*) AS [Rows] FROM dbo.Patients
UNION ALL SELECT 'Staff_Table', COUNT(*) FROM dbo.Staff_Table
UNION ALL SELECT 'Disease_Table', COUNT(*) FROM dbo.Disease_Table
UNION ALL SELECT 'Consultations', COUNT(*) FROM dbo.Consultations;
