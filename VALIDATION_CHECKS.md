# Data-quality checks I run

I run these checks after `healthcare_pipeline_v2.sql`. A healthy synthetic build should return the expected row counts and no rows from the exception queries.

## Row counts I expect

```sql
SELECT 'Patients' AS table_name, COUNT(*) AS row_count FROM Patients
UNION ALL SELECT 'Staff_Table', COUNT(*) FROM Staff_Table
UNION ALL SELECT 'Disease_Table', COUNT(*) FROM Disease_Table
UNION ALL SELECT 'Consultations', COUNT(*) FROM Consultations;
```

I expect 100 patients, 20 staff members, 5 diseases and 200 consultations.

## Null and duplicate checks I run

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

I expect both queries to return no rows.

## Relationship and date checks I run

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

I use the first query to find orphaned foreign keys and the second to find invalid consultation records. I expect both to return no rows.

## Range checks I run

```sql
SELECT * FROM Patients
WHERE Age NOT BETWEEN 0 AND 120
   OR Weight <= 0;

SELECT * FROM Disease_Table
WHERE SEVERITY NOT IN ('Low', 'Moderate', 'Critical');
```

I use these checks to catch invalid demographic values and unexpected severity labels before I refresh the dashboard.

I wrote the checks as readable SQL so I can use them during a code review and later adapt them into automated tests.
