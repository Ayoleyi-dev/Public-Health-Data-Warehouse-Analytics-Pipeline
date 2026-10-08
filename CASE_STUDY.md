# Case study: how I built my public-health analytics warehouse

## The problem I chose and why

I wanted to demonstrate more than isolated SQL queries or a static chart. I chose a public-health reporting scenario because it connects directly to my Biochemistry background and my interest in healthcare data. I needed a model that could answer operational questions about patients, diseases, staff, admissions, length of stay and recorded cost.

## My approach

I first separated the model into reference data and activity data. I used `Patients`, `Staff_Table` and `Disease_Table` as reference tables, then used `Consultations` as the central fact table. This gave me a simple star-schema-style structure that I could query and connect to Power BI.

I generated synthetic records with T-SQL. I used deterministic formulas in the improved build so I can recreate the same row counts and relationships instead of depending on uncontrolled random output. I assigned every consultation to an existing patient, staff member and disease, then generated admission dates, discharge dates and costs within defined ranges.

I added database constraints because I wanted the model to prevent common data-quality problems. I enforced primary keys, foreign keys, unique patient emails, valid age and weight ranges, non-negative costs and discharge dates that cannot occur before admission.

I also created `View_Financial_Report` to make disease-level reporting easier. The view returns consultation volume, recorded cost and average stay by disease, pathogen and severity. I created `sp_AdmitPatient` to validate and insert a new patient through one controlled entry point.

## What I found in my dashboard

My Power BI report displays 200 synthetic consultations and approximately ₦6.28 million in recorded consultation cost. I used disease, pathogen, severity, monthly admission and average-age visuals to make the data easier to interpret.

The dashboard shows Influenza with the largest recorded cost in this generated dataset. I interpret that as a volume-driven result from the synthetic records, rather than as a clinical or financial conclusion about real hospitals. I also compare average age across severity groups and use the monthly view to demonstrate how I would look for changes in activity over time.

## What I learned

I learned that a dashboard becomes more trustworthy when I can explain how every number was produced. I had to think about table grain, key relationships, missing values, date logic and metric definitions before presenting the visuals.

I also learned that exploratory scripts are useful while building, but a portfolio project needs a reproducible path. That is why I kept my original script for reference and added a second build script with explicit constraints, predictable seed data and documented validation checks.

## Why this matters for my career

This project gives me evidence for junior data analyst, healthcare data analyst and junior data-engineering applications. It shows that I can:

- translate a business question into a relational data model;
- write SQL for generation, transformation, joins, aggregation and validation;
- protect reporting quality with keys and constraints;
- explain metrics in plain language;
- connect healthcare context with practical analytics work.

As a Biochemistry student who is currently gaining laboratory experience at NAFDAC, I can also see how the same modelling pattern could support samples, assays, researchers, targets and laboratory quality metrics in a LIMS or biomedical data workflow.

## What I would build next

I would add a formal date dimension, clinical outcomes, a PostgreSQL version of the pipeline and automated tests in GitHub Actions. I would also document the Power BI semantic model and refresh process so another analyst could reproduce the report more easily.
