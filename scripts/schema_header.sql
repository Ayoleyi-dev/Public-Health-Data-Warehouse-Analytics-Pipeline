-- I run this script with sqlcmd or with SQLCMD Mode enabled in SSMS.
:on error exit
USE [master];
GO
IF DB_ID(N'HealthcarePortfolioDemo') IS NULL
    EXEC(N'CREATE DATABASE [HealthcarePortfolioDemo]');
GO
USE [HealthcarePortfolioDemo];
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;
-- I refuse to overwrite an unrelated database with the same name.
IF OBJECT_ID(N'dbo.PortfolioBuildInfo',N'U') IS NULL
   AND EXISTS(SELECT 1 FROM sys.tables WHERE is_ms_shipped=0)
    THROW 51000, 'I require an empty or previously initialized portfolio demo database.', 1;
IF OBJECT_ID(N'dbo.PortfolioBuildInfo',N'U') IS NULL
BEGIN
    CREATE TABLE dbo.PortfolioBuildInfo (Version int NOT NULL);
    INSERT dbo.PortfolioBuildInfo VALUES(1);
END;
IF NOT EXISTS(SELECT 1 FROM dbo.PortfolioBuildInfo WHERE Version=1)
    THROW 51000, 'I do not recognize this demo schema version.', 1;
GO
IF OBJECT_ID(N'dbo.Patients', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Patients
    (
        [Patient ID] INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Patients PRIMARY KEY,
        [FIRSTNAME] VARCHAR(50) NOT NULL CHECK (LEN(LTRIM(RTRIM([FIRSTNAME]))) > 0),
        [LASTNAME] VARCHAR(50) NOT NULL CHECK (LEN(LTRIM(RTRIM([LASTNAME]))) > 0),
        [EMAIL] VARCHAR(100) NOT NULL CHECK (LEN(LTRIM(RTRIM([EMAIL]))) > 0) CONSTRAINT UQ_Patients_Email UNIQUE,
        [CITY] VARCHAR(50) NOT NULL CHECK (LEN(LTRIM(RTRIM([CITY]))) > 0),
        [State] VARCHAR(50) NOT NULL CHECK (LEN(LTRIM(RTRIM([State]))) > 0),
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

IF OBJECT_ID(N'dbo.DimDate',N'U') IS NULL
    CREATE TABLE dbo.DimDate (CalendarDate date NOT NULL PRIMARY KEY, CalendarYear int NOT NULL,
        MonthNumber int NOT NULL CHECK (MonthNumber BETWEEN 1 AND 12), YearMonth char(7) NOT NULL);
GO
