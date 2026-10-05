"""I check fixture integrity, rejected bad records and reproducible artifacts."""
import copy
import json
import sqlite3
import sys
import unittest
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'scripts'))
from build_report import build_db,fixture,summarize
from generate_sql import render
class PipelineTests(unittest.TestCase):
    def test_expected_metrics_and_reconciliation(self):
        with build_db() as db: m=summarize(db)
        self.assertEqual(m['table_counts'],dict(patients=100,staff=20,diseases=5,consultations=200))
        self.assertEqual(m['distinct_patients'],86)
        self.assertEqual(m['total_recorded_cost_ngn'],5834323)
        self.assertEqual(m['average_stay_days'],7.325)
        self.assertEqual(sum(x['consultations'] for x in m['disease_summary']),200)
        self.assertEqual(sum(x['recorded_cost_ngn'] for x in m['disease_summary']),5834323)
        self.assertEqual(sum(m['quality_exceptions'].values()),0)
    def test_invalid_fixtures_are_rejected(self):
        cases=[('patients',1,''),('patients',3,'patient2@example.invalid'),('patients',6,None),
               ('patients',6,121),('patients',7,0),('consultations',1,999),
               ('consultations',2,999),('consultations',3,999),('consultations',6,-1),
               ('consultations',5,'2020-01-01'),('consultations',4,'2025-02-30'),('diseases',3,'Unknown')]
        for table,col,bad in cases:
            with self.subTest(table=table,col=col,bad=bad):
                data=copy.deepcopy(fixture());data[table][0][col]=bad
                with self.assertRaises((sqlite3.IntegrityError,ValueError)):build_db(data)
    def test_reproducible_sql_and_report(self):
        self.assertEqual((ROOT/'healthcare_pipeline_v2.sql').read_text(),render())
        with build_db() as db: a=summarize(db)
        with build_db() as db: b=summarize(db)
        self.assertEqual(a,b)
        self.assertEqual(a,json.loads((ROOT/'reports/metrics.json').read_text()))
        html=(ROOT/'reports/dashboard.html').read_text()
        payload=html.split('<script id="report-data" type="application/json">')[1].split('</script>')[0]
        self.assertEqual(a,json.loads(payload))
if __name__=='__main__':unittest.main()
