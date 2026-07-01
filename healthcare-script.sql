USE "HEALTHCARE ANALYSIS REPORT";
GO

-- Optional: Wipe the table clean so we start fresh every time
TRUNCATE TABLE Patients;
DECLARE @Counter INT = 1;

WHILE @Counter <= 100
BEGIN
    INSERT INTO Patients ([FIRSTNAME], [LASTNAME], [EMAIL], [CITY], [State])
    VALUES (
        -- We ensure the list has exactly 5 items and the math matches
        CHOOSE(FLOOR(RAND()*5 + 1), 'Charles', 'Frank', 'Eniola', 'Toyin', 'Toyosi'),
        CHOOSE(FLOOR(RAND()*5 + 1), 'Ebuka', 'lweis', 'Oluwa', 'Adeposi', 'Adeniyi'),
        -- Create a unique email
        'patient' + CAST(@Counter AS VARCHAR(10)) + '@hospital.ng',
        -- Ensure cities match exactly
        CHOOSE(FLOOR(RAND()*5 + 1), 'Yaba', 'Ikorodu', 'Surulere'),
        'Lagos'
    );
    SET @Counter = @Counter + 1;
END;

-- Check the count - it should be exactly 100 now!
SELECT COUNT(*) AS Total_Patients FROM Patients;
SELECT COUNT(*) AS Missing_Names
FROM Patients
WHERE [FIRSTNAME] IS NULL
or [LASTNAME] IS NULL
or [CITY] IS NULL;
SELECT 
    COUNT(*) AS Total_Rows,
    SUM(CASE WHEN [FIRSTNAME] IS NULL THEN 1 ELSE 0 END) AS Null_FirstNames,
    SUM(CASE WHEN [LASTNAME] IS NULL THEN 1 ELSE 0 END) AS Null_LastNames,
    SUM(CASE WHEN [CITY] IS NULL THEN 1 ELSE 0 END) AS Null_Cities
FROM Patients;

-- 1. Fix the First Names
UPDATE Patients 
SET [FIRSTNAME] = 'Recovered_User' 
WHERE [FIRSTNAME] IS NULL;

-- 2. Fix the Last Names
UPDATE Patients 
SET [LASTNAME] = 'Doe' 
WHERE [LASTNAME] IS NULL;

-- 3. Fix the Cities (Assign them to a default HQ)
UPDATE Patients 
SET [CITY] = 'Lagos Island' 
WHERE [CITY] IS NULL;

-- 4. Check the "Health Report" again to prove it worked
SELECT 
    COUNT(*) AS Total_Rows,
    SUM(CASE WHEN [FIRSTNAME] IS NULL THEN 1 ELSE 0 END) AS Null_FirstNames,
    SUM(CASE WHEN [LASTNAME] IS NULL THEN 1 ELSE 0 END) AS Null_LastNames,
    SUM(CASE WHEN [CITY] IS NULL THEN 1 ELSE 0 END) AS Null_Cities
FROM Patients;

USE "HEALTHCARE ANALYSIS REPORT";
GO

-- Optional: Clear the table first
TRUNCATE TABLE Staff_Table;

DECLARE @Counter2 INT = 1;

-- We will hire 20 staff members
WHILE @Counter2 <= 20
BEGIN
    INSERT INTO Staff_Table ([First Name], [Last name], [Job Id])
    VALUES (
        -- Random First Names
        CHOOSE(FLOOR(RAND()*5 + 1), 'Dr. Tunde', 'Nurse Amara', 'Prof. Wole', 'Dr. Ngozi', 'Nurse Kemi'),
        
        -- Random Last Names
        CHOOSE(FLOOR(RAND()*5 + 1), 'Balogun', 'Okoro', 'Adeyemi', 'Nwosu', 'Ibrahim'),
        
        -- Random Job ID (1 to 4)
        FLOOR(RAND()*4 + 1)
    );

    SET @Counter2 = @Counter2 + 1;
END;

-- 1. Fix missing First Names (Default to 'Staff Member')
UPDATE Staff_Table
SET [First Name] = 'Dr. Unknown'
WHERE [First Name] IS NULL;

-- 2. Fix missing Last Names (Default to 'Doe')
UPDATE Staff_Table
SET [Last name] = 'Doe'
WHERE [Last name] IS NULL;

-- 3. Fix missing Job IDs (Default to 2 = Nurse)
UPDATE Staff_Table
SET [Job Id] = 2
WHERE [Job Id] IS NULL;

-- 4. Verify the clean table
SELECT * FROM Staff_Table;

USE "HEALTHCARE ANALYSIS REPORT";
GO

INSERT INTO Disease_Table ([DISEASE NAME], [PATHOGEN], [SEVERITY])
VALUES 
('Malaria', 'Parasite', 'Moderate'),
('Typhoid Fever', 'Bacteria', 'Moderate'),
('Cholera', 'Bacteria', 'Critical'),
('Lassa Fever', 'Virus', 'Critical'),
('Influenza', 'Virus', 'Low');

SELECT * FROM Disease_Table;

USE "HEALTHCARE ANALYSIS REPORT";
GO

-- Optional: Clear table first
TRUNCATE TABLE Consultations;

DECLARE @Counter3 INT = 1;
DECLARE @AdmitDate DATE;
DECLARE @StayDuration INT;

-- We will generate 200 visits
WHILE @Counter3 <= 200
BEGIN
    -- 1. Generate a random Admission Date (within the last 365 days)
    SET @AdmitDate = DATEADD(DAY, -FLOOR(RAND()*365), GETDATE());

    -- 2. Generate a random Length of Stay (1 to 14 days)
    SET @StayDuration = FLOOR(RAND() * 14 + 1);

    INSERT INTO Consultations (
        [Patient id], 
        [Staff id], 
        [DISEASE ID], 
        [ADMISSION DATE], 
        [Discharge Date], 
        [Total cost]
    )
    VALUES (
        -- Random Patient ID (1-100)
        FLOOR(RAND() * 100 + 1),
        
        -- Random Staff ID (1-20)
        FLOOR(RAND() * 20 + 1),
        
        -- Random Disease ID (1-5)
        FLOOR(RAND() * 5 + 1),
        
        -- The Admission Date we calculated
        @AdmitDate,
        
        -- The Discharge Date (Admission + Duration)
        DATEADD(DAY, @StayDuration, @AdmitDate),
        
        -- Random Cost (Between 5,000 and 55,000 Naira)
        CAST(FLOOR(RAND() * 50000 + 5000) AS DECIMAL(10,2))
    );

    SET @Counter3 = @Counter3 + 1;
END;

-- Show the final result!
SELECT * FROM Consultations;

-- ANALYSIS OF THE DATA 
SELECT 
    P.[FIRSTNAME], 
    P.[LASTNAME], 
    D.[DISEASE NAME], 
    C.[ADMISSION DATE], 
    C.[Total cost]
FROM Consultations C
JOIN Patients P ON C.[Patient id] = P.[Patient ID]
JOIN Disease_Table D ON C.[DISEASE ID] = D.[Disease id];

-- to get the highest paying and highest affecting diseases 
SELECT 
    D.[DISEASE NAME],
    COUNT(*) AS Total_Patients,         
    SUM(C.[Total cost]) AS Total_Revenue 
FROM Consultations C
JOIN Disease_Table D ON C.[DISEASE ID] = D.[Disease id]
GROUP BY D.[DISEASE NAME]               
ORDER BY Total_Revenue DESC;            

SELECT 
    D.[DISEASE NAME],
    AVG(DATEDIFF(DAY, C.[ADMISSION DATE], C.[Discharge Date])) AS Avg_Days_Stayed
FROM Consultations C
JOIN Disease_Table D ON C.[DISEASE ID] = D.[Disease id]
GROUP BY D.[DISEASE NAME];

CREATE VIEW View_Financial_Report AS
SELECT 
    D.[DISEASE NAME],
    COUNT(*) AS Total_Patients,
    SUM(C.[Total cost]) AS Total_Revenue,
    AVG(DATEDIFF(DAY, C.[ADMISSION DATE], C.[Discharge Date])) AS Avg_Stay_Days
FROM Consultations C
JOIN Disease_Table D ON C.[DISEASE ID] = D.[Disease id]
GROUP BY D.[DISEASE NAME];

SELECT * FROM View_Financial_Report;

ALTER TABLE Patients
ADD [Age] INT,
[Weight] DECIMAL;
GO

CREATE PROCEDURE sp_AdmitPatient
    @FirstName VARCHAR(50),
    @LastName VARCHAR(50),
    @Email VARCHAR(50),
    @City VARCHAR(50),
    @State VARCHAR(50),
    @Age INT,
    @Weight DECIMAL(5,2)
AS
BEGIN
    INSERT INTO Patients ([FirstName], [LastName], [Email], [City], [State], [Age], [Weight])
    VALUES (@FirstName, @LastName, @Email, @City, @State, @Age, @Weight);
END;
GO

EXEC sp_AdmitPatient @Firstname = 'Sarah', @Lastname = 'Connor', @Email='sarah.c@sky.net' , @City = 'Lagos', @State = 'Lagos', @Age= 35, @Weight = 60.5;

UPDATE Patients
SET 
    Age = FLOOR(RAND(CHECKSUM(NEWID())) * 85) + 1,
    Weight = CAST((RAND(CHECKSUM(NEWID())) * 68) + 2 AS DECIMAL(5,2))
WHERE Age IS NULL; 
GO

ALTER PROCEDURE sp_AdmitPatient
    @FirstName VARCHAR(50),
    @LastName VARCHAR(50),
    @Email VARCHAR(50),
    @City VARCHAR(50),
    @State VARCHAR(50),
    @Age INT,
    @Weight DECIMAL(5,2)
AS
BEGIN
    INSERT INTO Patients ([FirstName], [LastName], [Email], [City], [State], [Age], [Weight])
    VALUES (@FirstName, @LastName, @Email, @City, @State, @Age, @Weight);
END;
GO

EXEC sp_AdmitPatient @Firstname = 'Tunde', @Lastname = 'AJAYI', @Email='Tunde.c@sky.net' , @City = 'ogun', @State = 'ogun', @Age= 25, @Weight = 40.5;

SELECT * FROM Patients;
