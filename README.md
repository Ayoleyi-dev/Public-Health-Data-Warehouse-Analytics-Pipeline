# Public Health Data Warehouse & Analytics Pipeline

This project demonstrates an end-to-end healthcare analytics workflow using synthetic data: a relational SQL Server warehouse, repeatable T-SQL data generation and validation, and a Power BI reporting layer.

> **Data notice:** All patient, staff, disease and consultation records in this repository are synthetic. They do not represent real patients or clinical outcomes.

![Power BI dashboard preview](Screenshot%202025-11-20%20105745.png)

## What this project demonstrates

- Designing a simple star-schema-style healthcare model.
- Loading reproducible synthetic dimension and fact data with T-SQL.
- Enforcing relationships and business rules with keys and constraints.
- Running data-quality checks for nulls, duplicate emails, invalid dates and orphan records.
- Producing operational and financial metrics for Power BI.
- Translating a biochemistry background into a healthcare and laboratory-data context.

## Architecture

```text
Patients ───────┐
                ├──> Consultations <── Staff_Table
Disease_Table ──┘
                         │
                         └──> Power BI dashboard
```

`Consultations` is the fact table. `Patients`, `Staff_Table` and `Disease_Table` are reference dimensions. The model records admissions, discharge dates, disease categories, assigned staff and consultation cost.

| Layer | Implementation | Purpose |
|---|---|---|
| Source / generation | T-SQL synthetic records | Repeatable development data |
| Warehouse | SQL Server tables and foreign keys | Structured, queryable storage |
| Quality layer | SQL checks and reporting views | Detect bad or inconsistent records |
| Reporting | Power BI Desktop (`HEALTHCARE ANALYSIS ISUALIZATION.pbix`) | KPI and trend analysis |

## Repository guide

| File | Description |
|---|---|
| `healthcare_pipeline_v2.sql` | Clean, rerunnable SQL Server build and seed script |
| `healthcare-script.sql` | Original exploratory script retained for reference |
| `DATA_DICTIONARY.md` | Table, column and metric definitions |
| `VALIDATION_CHECKS.md` | Data-quality checks and expected outcomes |
| `HEALTHCARE ANALYSIS ISUALIZATION.pbix` | Power BI report |
| `Screenshot 2025-11-20 105745.png` | Dashboard preview |
| `Screenshot 2025-11-20 105851.png` | Relationship diagram |

## Key questions answered

The dashboard supports questions such as:

1. How many consultations were recorded, and what was the total cost?
2. Which diseases generate the greatest consultation volume and revenue?
3. How does average length of stay vary by disease and severity?
4. How are admissions distributed across months and pathogen categories?
5. Are there invalid, incomplete or referentially inconsistent records?

The current synthetic dashboard shows 200 consultations and approximately ₦6.28 million in total recorded consultation cost. These figures are generated examples and should not be interpreted as real public-health statistics.

## Run the project

### Requirements

- SQL Server or SQL Server Express
- SQL Server Management Studio or Azure Data Studio
- Power BI Desktop (optional, for the report)

### Steps

1. Create an empty database named `HEALTHCARE ANALYSIS REPORT`.
2. Open `healthcare_pipeline_v2.sql` in SSMS and run it against that database.
3. Run the queries in `VALIDATION_CHECKS.md` and confirm that the checks return zero quality exceptions.
4. Open the PBIX file in Power BI Desktop.
5. If Power BI requests a connection, update the SQL Server data source to your local instance and refresh.

The build script is intended for synthetic development data. It clears and reseeds the four project tables, so do not run it against production data.

## Biochemistry and laboratory-data relevance

The same modelling pattern can support a laboratory information workflow:

| Healthcare model | Laboratory / computational analogue |
|---|---|
| `Patients` | Samples or biological sources |
| `Staff_Table` | Analysts, researchers or laboratory technicians |
| `Disease_Table` | Targets, biomarkers or variant categories |
| `Consultations` | Assays, runs or sample-level measurements |

This connection is useful for healthcare analytics, LIMS reporting and biomedical data roles because it combines domain understanding with SQL, data-quality and dashboard skills.

## Limitations and next improvements

- The records are synthetic and generated for demonstration.
- The current model does not include a proper date dimension or clinical outcomes.
- The PBIX report is a desktop artifact; the SQL and documentation are the reproducible parts of the project.
- Future work could add PostgreSQL compatibility, a date dimension, automated tests in CI and a documented Power BI semantic model.

## Author

**Ayoleyi Gbenga-Ayodeji Marvelous** — Biochemistry undergraduate and Data & Analytics Officer.

- Portfolio: <https://ayoleyi-portfolio.vercel.app/>
- GitHub: <https://github.com/Ayoleyi-dev>
- LinkedIn: <https://www.linkedin.com/in/ayoleyi-gbenga-ayodeji-aa99b6395>
