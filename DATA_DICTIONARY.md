# Data dictionary

I use one consultation fact table and three reference tables in this warehouse. I kept the column names compatible with my existing Power BI report.

## `Patients`

| Column | How I use it | Rule I apply |
|---|---|---|
| `Patient ID` | I use this as the surrogate patient identifier. | I generate it as the primary key. |
| `FIRSTNAME` / `LASTNAME` | I store synthetic patient names here. | I require both values. |
| `EMAIL` | I store a synthetic contact value here. | I require it and enforce uniqueness. |
| `CITY` / `State` | I store the synthetic patient location here. | I require both values. |
| `Age` | I store age in years here. | I allow values from 0 to 120. |
| `Weight` | I store weight in kilograms here. | I require a value greater than zero. |

## `Staff_Table`

| Column | How I use it |
|---|---|
| `Staff id` | I use this as the surrogate staff identifier. |
| `First Name` / `Last name` | I store synthetic staff names here. |
| `Job Id` | I use this as the numeric role category. |

## `Disease_Table`

| Column | How I use it |
|---|---|
| `Disease id` | I use this as the surrogate disease identifier. |
| `DISEASE NAME` | I store the disease category here. |
| `PATHOGEN` | I store the pathogen category here. |
| `SEVERITY` | I store Low, Moderate or Critical here. |

## `Consultations`

| Column | How I use it | Rule I apply |
|---|---|---|
| `consultations id` | I use this as the consultation identifier. | I generate it as the primary key. |
| `Patient id` | I connect each consultation to a patient here. | I require a matching patient key. |
| `Staff id` | I connect each consultation to a staff member here. | I require a matching staff key. |
| `DISEASE ID` | I connect each consultation to a disease here. | I require a matching disease key. |
| `ADMISSION DATE` | I record the admission date here. | I require a date. |
| `Discharge Date` | I record the discharge date here. | I require it to be on or after admission. |
| `Total cost` | I record the synthetic consultation cost in naira here. | I require a value greater than or equal to zero. |

## Derived metrics I use

- I calculate **consultation count** with `COUNT(*)` from `Consultations`.
- I calculate **total recorded cost** with `SUM([Total cost])`.
- I calculate **average stay** from the difference between admission and discharge dates.
- I calculate **average age by severity** after joining consultations to patients and diseases.
