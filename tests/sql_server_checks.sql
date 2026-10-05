:on error exit
USE [HealthcarePortfolioDemo];
GO
SET NOCOUNT ON;
IF (SELECT COUNT(*) FROM dbo.Patients)<>100 THROW 52001,'I expected 100 patients.',1;
IF (SELECT COUNT(*) FROM dbo.Staff_Table)<>20 THROW 52002,'I expected 20 staff.',1;
IF (SELECT COUNT(*) FROM dbo.Disease_Table)<>5 THROW 52003,'I expected five diseases.',1;
IF (SELECT COUNT(*) FROM dbo.Consultations)<>200 THROW 52004,'I expected 200 visits.',1;
IF (SELECT COUNT(*) FROM dbo.DimDate)<>365 THROW 52005,'I expected a complete 2025 calendar.',1;
IF (SELECT SUM([Total cost]) FROM dbo.Consultations)<>5834323 THROW 52006,'I found a cost mismatch.',1;
IF (SELECT COUNT(DISTINCT [Patient id]) FROM dbo.Consultations)<>86 THROW 52007,'I found a distinct-patient mismatch.',1;
IF (SELECT AVG(CONVERT(decimal(10,3),StayDays)) FROM dbo.View_Consultation_Detail)<>7.325 THROW 52008,'I found a stay mismatch.',1;
IF (SELECT SUM(Total_Patients) FROM dbo.View_Financial_Report)<>200 THROW 52009,'I found a legacy-view count mismatch.',1;
IF (SELECT SUM(Total_Revenue) FROM dbo.View_Financial_Report)<>5834323 THROW 52010,'I found a legacy-view cost mismatch.',1;
IF EXISTS(SELECT 1 FROM dbo.Consultations c LEFT JOIN dbo.DimDate d ON d.CalendarDate=c.[ADMISSION DATE] WHERE d.CalendarDate IS NULL)
    THROW 52011,'I found admissions outside my calendar.',1;
-- I test actual constraint failures without leaving changes behind.
SET XACT_ABORT OFF;
BEGIN TRAN;
BEGIN TRY
    UPDATE dbo.Patients SET FIRSTNAME='' WHERE [Patient ID]=1;
    THROW 52999,'I failed to reject a blank name.',1;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER()<>547 THROW;
END CATCH;
BEGIN TRY
    UPDATE dbo.Consultations SET [Patient id]=999 WHERE [consultations id]=1;
    THROW 52999,'I failed to reject an orphan visit.',1;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER()<>547 THROW;
END CATCH;
BEGIN TRY
    UPDATE dbo.Consultations SET [Discharge Date]='20200101' WHERE [consultations id]=1;
    THROW 52999,'I failed to reject invalid dates.',1;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER()<>547 THROW;
END CATCH;
BEGIN TRY
    UPDATE dbo.Consultations SET [Total cost]=-1 WHERE [consultations id]=1;
    THROW 52999,'I failed to reject a negative cost.',1;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER()<>547 THROW;
END CATCH;
BEGIN TRY
    EXEC dbo.sp_AdmitPatient 'Demo','Patient','null@example.invalid','Yaba','Lagos',NULL,65;
    THROW 52999,'I failed to reject a null age.',1;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER()<>50004 THROW;
END CATCH;
BEGIN TRY
    EXEC dbo.sp_AdmitPatient 'Demo','Patient','blank@example.invalid','','Lagos',35,65;
    THROW 52999,'I failed to reject a blank city.',1;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER()<>50002 THROW;
END CATCH;
BEGIN TRY
    EXEC dbo.sp_AdmitPatient 'Demo','Patient','patient1@example.invalid','Yaba','Lagos',35,65;
    THROW 52999,'I failed to reject a duplicate email.',1;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() NOT IN(2601,2627) THROW;
END CATCH;
EXEC dbo.sp_AdmitPatient 'Demo','Patient','valid@example.invalid','Yaba','Lagos',35,65.25;
IF NOT EXISTS(SELECT 1 FROM dbo.Patients WHERE EMAIL='valid@example.invalid' AND [Patient ID]>100 AND Weight=65.25)
    THROW 52012,'I failed the valid-intake check.',1;
ROLLBACK;
PRINT 'I passed SQL Server row-count, reconciliation, constraint and intake checks.';
