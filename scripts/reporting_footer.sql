-- I preserve the legacy view column names used by the original PBIX.
CREATE OR ALTER VIEW dbo.View_Financial_Report AS
SELECT D.[DISEASE NAME], COUNT(*) AS Total_Patients,
    SUM(C.[Total cost]) AS Total_Revenue,
    AVG(CONVERT(decimal(10,2),DATEDIFF(day,C.[ADMISSION DATE],C.[Discharge Date]))) AS Avg_Stay_Days
FROM dbo.Consultations C JOIN dbo.Disease_Table D ON D.[Disease id]=C.[DISEASE ID]
GROUP BY D.[DISEASE NAME];
GO
-- I expose one row per consultation to avoid ambiguous dimension filtering.
CREATE OR ALTER VIEW dbo.View_Consultation_Detail AS
SELECT C.[consultations id] AS ConsultationID, C.[Patient id] AS PatientID, C.[Staff id] AS StaffID,
       D.[DISEASE NAME] AS Disease, D.PATHOGEN AS Pathogen, D.SEVERITY AS Severity,
       P.Age, P.CITY AS City, C.[ADMISSION DATE] AS AdmissionDate,
       C.[Discharge Date] AS DischargeDate, C.[Total cost] AS RecordedCostNGN,
       DATEDIFF(day,C.[ADMISSION DATE],C.[Discharge Date]) AS StayDays,
       CONVERT(char(7),C.[ADMISSION DATE],126) AS YearMonth
FROM dbo.Consultations C JOIN dbo.Patients P ON P.[Patient ID]=C.[Patient id]
JOIN dbo.Disease_Table D ON D.[Disease id]=C.[DISEASE ID];
GO
CREATE OR ALTER PROCEDURE dbo.sp_AdmitPatient
    @FirstName varchar(50), @LastName varchar(50), @Email varchar(100),
    @City varchar(50), @State varchar(50), @Age int, @Weight decimal(5,2)
AS
BEGIN
    SET NOCOUNT ON;
    IF NULLIF(LTRIM(RTRIM(@FirstName)), '') IS NULL OR NULLIF(LTRIM(RTRIM(@LastName)), '') IS NULL
        THROW 50001, 'I require both patient names.', 1;
    IF NULLIF(LTRIM(RTRIM(@City)), '') IS NULL OR NULLIF(LTRIM(RTRIM(@State)), '') IS NULL
        THROW 50002, 'I require city and state.', 1;
    IF NULLIF(LTRIM(RTRIM(@Email)), '') IS NULL
        THROW 50003, 'I require an email identifier.', 1;
    IF @Age IS NULL OR @Age NOT BETWEEN 0 AND 120
        THROW 50004, 'I require age between zero and 120.', 1;
    IF @Weight IS NULL OR @Weight <= 0
        THROW 50005, 'I require a positive weight.', 1;
    -- I rely on the unique constraint to cover concurrent duplicate inserts too.
    INSERT dbo.Patients(FIRSTNAME,LASTNAME,EMAIL,CITY,State,Age,Weight)
    VALUES(LTRIM(RTRIM(@FirstName)),LTRIM(RTRIM(@LastName)),LTRIM(RTRIM(@Email)),
           LTRIM(RTRIM(@City)),LTRIM(RTRIM(@State)),@Age,@Weight);
    SELECT CONVERT(int,SCOPE_IDENTITY()) AS NewPatientID;
END;
GO
SELECT 'Patients' AS TableName,COUNT(*) AS [RowCount] FROM dbo.Patients
UNION ALL SELECT 'Staff_Table',COUNT(*) FROM dbo.Staff_Table
UNION ALL SELECT 'Disease_Table',COUNT(*) FROM dbo.Disease_Table
UNION ALL SELECT 'Consultations',COUNT(*) FROM dbo.Consultations;
