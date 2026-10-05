"""I render the SQL Server build from my committed fixture and templates."""
import json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
def render():
    data=json.loads((ROOT/'data/synthetic_fixture.json').read_text())
    q=lambda x: "'"+x.replace("'","''")+"'" if isinstance(x,str) else str(x)
    s="-- I reseed my dedicated demo tables atomically.\nBEGIN TRY\nBEGIN TRANSACTION;\n"
    for table in ['Consultations','Patients','Staff_Table','Disease_Table','DimDate']:
        s+=f'DELETE FROM dbo.{table};\n'
    tables=[('Patients','patients','[Patient ID],FIRSTNAME,LASTNAME,EMAIL,CITY,State,Age,Weight'),('Staff_Table','staff','[Staff id],[First Name],[Last name],[Job Id]'),('Disease_Table','diseases','[Disease id],[DISEASE NAME],PATHOGEN,SEVERITY'),('Consultations','consultations','[consultations id],[Patient id],[Staff id],[DISEASE ID],[ADMISSION DATE],[Discharge Date],[Total cost]')]
    for table,key,cols in tables:
        s+=f'SET IDENTITY_INSERT dbo.{table} ON;\nINSERT dbo.{table} ({cols}) VALUES\n'+',\n'.join('('+','.join(map(q,row))+')' for row in data[key])+f';\nSET IDENTITY_INSERT dbo.{table} OFF;\n'
    s+=""";WITH Dates AS (
SELECT CONVERT(date,'20250101',112) AS d
UNION ALL SELECT DATEADD(day,1,d) FROM Dates WHERE d<CONVERT(date,'20251231',112))
INSERT dbo.DimDate SELECT d,YEAR(d),MONTH(d),CONVERT(char(7),d,126) FROM Dates OPTION(MAXRECURSION 366);
COMMIT;
END TRY
BEGIN CATCH
IF XACT_STATE()<>0 ROLLBACK;
THROW;
END CATCH;
GO
"""
    return (ROOT/'scripts/schema_header.sql').read_text()+s+(ROOT/'scripts/reporting_footer.sql').read_text()
if __name__=='__main__':
    (ROOT/'healthcare_pipeline_v2.sql').write_text(render())
