"""I validate a fixed synthetic fixture in SQLite and build an offline report."""
import datetime as dt
import json
import sqlite3
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
SCHEMA = '''
PRAGMA foreign_keys=ON;
CREATE TABLE patients(id INTEGER PRIMARY KEY, first_name TEXT NOT NULL CHECK(length(trim(first_name))>0),
last_name TEXT NOT NULL CHECK(length(trim(last_name))>0), email TEXT NOT NULL UNIQUE CHECK(length(trim(email))>0),
city TEXT NOT NULL CHECK(length(trim(city))>0), state TEXT NOT NULL CHECK(length(trim(state))>0),
age INTEGER NOT NULL CHECK(age BETWEEN 0 AND 120), weight REAL NOT NULL CHECK(weight>0));
CREATE TABLE staff(id INTEGER PRIMARY KEY,first_name TEXT NOT NULL,last_name TEXT NOT NULL,job_id INTEGER NOT NULL CHECK(job_id BETWEEN 1 AND 4));
CREATE TABLE diseases(id INTEGER PRIMARY KEY,name TEXT NOT NULL UNIQUE,pathogen TEXT NOT NULL,severity TEXT NOT NULL CHECK(severity IN ('Low','Moderate','Critical')));
CREATE TABLE consultations(id INTEGER PRIMARY KEY,patient_id INTEGER NOT NULL REFERENCES patients(id),
staff_id INTEGER NOT NULL REFERENCES staff(id),disease_id INTEGER NOT NULL REFERENCES diseases(id),
admission TEXT NOT NULL,discharge TEXT NOT NULL CHECK(discharge>=admission),cost INTEGER NOT NULL CHECK(cost>=0));
'''
def fixture():
    return json.loads((ROOT/'data/synthetic_fixture.json').read_text())
def build_db(data=None):
    data = fixture() if data is None else data
    db=sqlite3.connect(':memory:'); db.row_factory=sqlite3.Row; db.executescript(SCHEMA)
    for table in ['patients','staff','diseases','consultations']:
        rows=data[table]
        for row in rows:
            if table=='consultations':
                for x in row[4:6]:
                    if dt.date.fromisoformat(x).isoformat()!=x: raise ValueError('I require ISO dates.')
        db.executemany(f'INSERT INTO {table} VALUES ({",".join("?" for _ in rows[0])})',rows)
    db.commit(); return db
DETAIL='''SELECT c.id, c.patient_id, d.name AS disease, d.pathogen, d.severity, p.age,
c.admission, c.discharge, c.cost, CAST(julianday(c.discharge)-julianday(c.admission) AS INT) AS stay_days
FROM consultations c JOIN diseases d ON d.id=c.disease_id JOIN patients p ON p.id=c.patient_id ORDER BY c.id'''
def summarize(db):
    rows=[dict(x) for x in db.execute(DETAIL)]
    checks={'foreign_key_violations':len(db.execute('PRAGMA foreign_key_check').fetchall()),
      'missing_or_invalid_patients':db.execute("SELECT COUNT(*) FROM patients WHERE trim(first_name)='' OR trim(last_name)='' OR trim(email)='' OR trim(city)='' OR trim(state)='' OR age IS NULL OR age NOT BETWEEN 0 AND 120 OR weight IS NULL OR weight<=0").fetchone()[0],
      'invalid_consultations':sum(x['stay_days']<0 or x['cost']<0 for x in rows)}
    if any(checks.values()): raise ValueError(checks)
    counts={t:db.execute('SELECT COUNT(*) FROM '+t).fetchone()[0] for t in ['patients','staff','diseases','consultations']}
    return {'fixture_version':1,'synthetic':True,'engine':'SQLite portable demonstration; not a SQL Server execution',
            'table_counts':counts,'quality_exceptions':checks,'consultations':len(rows),
            'distinct_patients':len({x['patient_id'] for x in rows}),'total_recorded_cost_ngn':sum(x['cost'] for x in rows),
            'average_stay_days':round(sum(x['stay_days'] for x in rows)/len(rows),3),
            'disease_summary':[dict(x) for x in db.execute('''SELECT d.name AS disease,COUNT(*) AS consultations,SUM(c.cost) AS recorded_cost_ngn
            FROM consultations c JOIN diseases d ON d.id=c.disease_id GROUP BY d.id ORDER BY recorded_cost_ngn DESC''')],
            'rows':rows}
def main():
    with build_db() as db: result=summarize(db)
    out=ROOT/'reports'; out.mkdir(exist_ok=True)
    (out/'metrics.json').write_text(json.dumps(result,indent=2)+'\n')
    template=(ROOT/'scripts/report_template.html').read_text()
    safe=json.dumps(result).replace('<','\\u003c')
    (out/'dashboard.html').write_text(template.replace('__REPORT_DATA__',safe))
    print(json.dumps({k:v for k,v in result.items() if k!='rows'},indent=2))
if __name__=='__main__':main()
