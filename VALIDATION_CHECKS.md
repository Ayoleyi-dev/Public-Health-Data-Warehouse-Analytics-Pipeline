# Data-quality checks

Run these checks after `healthcare_pipeline_v2.sql`. A healthy synthetic build should return zero rows for the exception queries and the expected row counts shown below.

## Expected row counts

```sql
SELECT 'Patients' AS table_name, COUNT(*) AS row_count FROM Patients
UNION ALL SELECT 'Staff_Table', COUNT(*) FROM Staff_Table
UNION ALL SELECT 'Disease_Table', COUNT(*) FROM Disease_Table
UNION ALL SELECT 'Consultations', COUNT(*) FROM Consultations;
```

Expected counts: 100 patients, 20 staff members, 5 diseases and 200 consultations.

## Null and duplicate checks

```sql
SELECT * FROM Patients
WHERE NULLIF(LTRIM(RTRIM(FIRSTNAME)), '') IS NULL
   OR NULLIF(LTRIM(RTRIM(LASTNAME)), '') IS NULL
   OR NULLIF(LTRIM(RTRIM(EMAIL)), '') IS NULL
   OR NULLIF(LTRIM(RTRIM(CITY)), '') IS NULL;

SELECT EMAIL, COUNT(*) AS duplicate_count
FROM Patients
GROUP BY EMAIL
HAVING COUNT(*) > 1;
```

## Relationship and date checks

```sql
SELECT C.*
FROM Consultations AS C
LEFT JOIN Patients AS P ON P.[Patient ID] = C.[Patient id]
LEFT JOIN Staff_Table AS S ON S.[Staff id] = C.[Staff id]
LEFT JOIN Disease_Table AS D ON D.[Disease id] = C.[DISEASE ID]
WHERE P.[Patient ID] IS NULL
   OR S.[Staff id] IS NULL
   OR D.[Disease id] IS NULL;

SELECT * FROM Consultations
WHERE [ADMISSION DATE] IS NULL
   OR [Discharge Date] < [ADMISSION DATE]
   OR [Total cost] < 0;
```

## Range checks

```sql
SELECT * FROM Patients
WHERE Age NOT BETWEEN 0 AND 120
   OR Weight <= 0;

SELECT * FROM Disease_Table
WHERE SEVERITY NOT IN ('Low', 'Moderate', 'Critical');
```

These checks are intentionally written as readable SQL so they can be used during a code review or adapted into automated tests later.
