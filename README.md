# Public Health Data Warehouse & Analytics Pipeline

I built this project to show how I can take a healthcare reporting problem, model the data in SQL Server, validate the records and present the results in Power BI. I used synthetic records for patients, staff, diseases and consultations so I could demonstrate the workflow without exposing real patient information.

> **Data notice:** I generated every patient, staff, disease and consultation record in this repository for demonstration. The data does not represent real patients or clinical outcomes.

![Power BI dashboard preview](Screenshot%202025-11-20%20105745.png)

## Why I built it
I wanted to answer a practical public-health reporting problem. A healthcare organisation needs a reliable way to connect patient information, disease categories, staff assignments, admissions and costs. I created this warehouse to make those relationships queryable and to give a reporting user a clear view of activity, cost and trends.

## What I built

- I designed a relational model with one consultation fact table and three reference tables.
- I generated a repeatable synthetic dataset with T-SQL.
- I added primary keys, foreign keys, uniqueness rules, range checks and date checks.
- I wrote data-quality queries for nulls, duplicate emails, orphan records, invalid dates and invalid ranges.
- I created a financial reporting view for disease-level consultation volume, cost and average stay.
- I added a validated patient-intake stored procedure.
- I connected the model to a Power BI dashboard for KPI and trend reporting.

## Architecture

```text
Patients ───────┐
                ├──> Consultations <── Staff_Table
Disease_Table ──┘
                         │
                         └──> Power BI dashboard
```

I use `Consultations` as the fact table. I use `Patients`, `Staff_Table` and `Disease_Table` as reference dimensions. I record admission dates, discharge dates, disease categories, assigned staff and consultation cost in the fact table.

| Layer | What I implemented | Why I included it |
|---|---|---|
| Data generation | T-SQL synthetic records | I can recreate the same development dataset |
| Warehouse | SQL Server tables and foreign keys | I can query structured and related records |
| Quality layer | SQL checks and a reporting view | I can detect bad records before reporting |
| Reporting | Power BI Desktop | I can communicate KPIs and trends visually |

## Repository guide

| File | What I use it for |
|---|---|
| `healthcare_pipeline_v2.sql` | I use this as the clean SQL Server build and seed script |
| `healthcare-script.sql` | I retain this as my original exploratory script |
| `DATA_DICTIONARY.md` | I document my tables, columns and metrics here |
| `VALIDATION_CHECKS.md` | I document the quality checks I run here |
| `CASE_STUDY.md` | I explain my problem, process, findings and decisions here |
| `HEALTHCARE ANALYSIS ISUALIZATION.pbix` | I use this Power BI report for visual analysis |
| `Screenshot 2025-11-20 105745.png` | I use this as the dashboard preview |
| `Screenshot 2025-11-20 105851.png` | I use this as the relationship diagram |

## Questions I answer

With this model and dashboard, I answer questions such as:

1. How many consultations did I record, and what was the total cost?
2. Which disease categories produced the greatest consultation volume and recorded cost?
3. How did average length of stay vary across disease categories and severity levels?
4. How did admissions change across months and pathogen categories?
5. Did I have incomplete, invalid or referentially inconsistent records before reporting?

In my current synthetic dashboard, I display 200 consultations and approximately ₦6.28 million in recorded consultation cost. I treat these as generated demonstration figures rather than real public-health statistics.

## How I run the project

### Requirements I use

- SQL Server or SQL Server Express
- SQL Server Management Studio or Azure Data Studio
- Power BI Desktop for the dashboard

### My setup process

1. I create an empty database named `HEALTHCARE ANALYSIS REPORT`.
2. I open `healthcare_pipeline_v2.sql` in SSMS and run it against that database.
3. I run the queries in `VALIDATION_CHECKS.md` and confirm that the exception queries return no rows.
4. I open the PBIX file in Power BI Desktop.
5. I update the SQL Server data source to my local instance and refresh the report when Power BI requests a connection.

I use the build script only for synthetic development data because it clears and reseeds the four project tables.

## How I connect it to my degree

As a Biochemistry undergraduate, I designed this project around the same data relationships that appear in laboratory information systems. I can map the healthcare entities to laboratory and computational biology entities:

| Healthcare model | Laboratory or computational analogue |
|---|---|
| `Patients` | Samples or biological sources |
| `Staff_Table` | Analysts, researchers or laboratory technicians |
| `Disease_Table` | Targets, biomarkers or variant categories |
| `Consultations` | Assays, runs or sample-level measurements |

This connection helps me present a credible route into healthcare analytics, LIMS reporting and biomedical data work. I combine domain knowledge from biochemistry with SQL, data-quality controls and dashboard development.

## Limitations I documented

- I generated the records synthetically for demonstration.
- I have not added a full date dimension or clinical outcomes yet.
- I treat the PBIX file as a desktop reporting artifact; the SQL and documentation contain the reproducible workflow.
- I have not executed SQL Server or Power BI inside this workspace, so I have verified the SQL structure and logic here and left application execution for a SQL Server environment.

## Improvements I plan to make next

- I plan to add a proper date dimension and reusable calendar measures.
- I plan to add PostgreSQL-compatible pipeline code for junior data-engineering roles.
- I plan to add automated SQL checks in continuous integration.
- I plan to document the Power BI semantic model and refresh process in more detail.

## About me

I am **Ayoleyi Gbenga-Ayodeji Marvelous**, a Biochemistry undergraduate, Data & Analytics Officer and aspiring healthcare data professional.

- Portfolio: <https://ayoleyi-portfolio.vercel.app/>
- GitHub: <https://github.com/Ayoleyi-dev>
- LinkedIn: <https://www.linkedin.com/in/ayoleyi-gbenga-ayodeji-aa99b6395>
