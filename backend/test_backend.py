"""Isolated API tests. Never connects to the user's configured database."""
import copy
import json
import os
from pathlib import Path
import sqlite3
import tempfile
import unittest
from contextlib import closing

ROOT = Path(__file__).resolve().parent
TEMP = tempfile.TemporaryDirectory(prefix='mody_django_test_')
DB = Path(TEMP.name) / 'test.db'
DB.touch()
os.environ.update(DJANGO_SETTINGS_MODULE='mody_backend.settings', MODY_DATABASE_PATH=str(DB),
                  MODY_API_TOKEN='test-only-token', MODY_SECRET_KEY='test-only-secret')
import django
django.setup()
from django.db import connections
from django.test import Client


def selections():
    return {'generate': {'vehicleId': 'car', 'style': 'Sportif', 'extra': '', 'color': '',
                        'colorCategory': 0, 'angle': '', 'parts': {}, 'detailColor': '', 'detailColorCategory': 0},
            'explore': {}, 'aiVideo': {}}


def record(ident='test-record'):
    return {'id': ident, 'createdAt': '2026-10-09T10:00:00.123456Z', 'kind': 'demo',
            'originalImagePath': 'assets/images/sport.jpg', 'input': {'type': 'generate',
            'vehicleId': 'car', 'mode': 'customEdit', 'style': '', 'extra': '', 'color': '',
            'angle': '', 'parts': {}, 'description': 'Test'}}


class BackendTests(unittest.TestCase):
    def setUp(self):
        connections.close_all()
        if DB.exists():
            DB.unlink()  # Exact disposable test DB, not the configured user DB.
        with closing(sqlite3.connect(DB)) as db, db:
            db.executescript((ROOT / 'tests/schema.sql').read_text(encoding='utf-8'))
            db.execute("INSERT INTO vehicles VALUES ('car','Test car','assets/images/sport.jpg',0,0)")
            db.execute("INSERT INTO parts VALUES ('spoiler.test','assets/images/spoiler.jpg')")
            db.execute("INSERT INTO part_categories VALUES ('Spoiler',0)")
            db.execute("INSERT INTO detail_part_options VALUES ('Spoiler',0,'spoiler.test')")
            db.execute("INSERT INTO angle_categories VALUES ('Rear','Spoiler',0)")
            db.execute("INSERT INTO mod_options VALUES ('Spoiler','spoiler.test',0,'Test spoiler','Use spoiler','')")
            db.execute("INSERT INTO app_settings VALUES ('selections',?)", [json.dumps(selections())])
            sections = {'generate_option_catalog.styles': ['Sportif'], 'generate_option_catalog.extras': ['Spoiler'],
                        'generate_option_catalog.colorCategories': ['Mat'], 'generate_option_catalog.baseColors': {'Mavi': 0xff126EDB},
                        'ai_video_items.transformations': [], 'ai_video_items.driveScenes': ['Cliff Drive'], 'ai_video_items.filters': []}
            for name, data in sections.items():
                db.execute('INSERT INTO catalog_sections VALUES (?,?)', [name, 'list' if isinstance(data, list) else 'integers'])
                for index, (key, value) in enumerate(enumerate(data) if isinstance(data, list) else data.items()):
                    db.execute('INSERT INTO catalog_entries VALUES (?,?,?,?)', [name, str(key), index, json.dumps(value)])
        self.client = Client(HTTP_AUTHORIZATION='Bearer test-only-token')

    def tearDown(self):
        connections.close_all()

    def post(self, batch):
        return self.client.post('/api/v1/creations', {'records': batch}, content_type='application/json')

    def test_auth_required_for_all_routes(self):
        for name in ['health', 'catalog', 'creations', 'selections']:
            self.assertEqual(Client().get('/api/v1/' + name).status_code, 401)
        self.assertEqual(Client(HTTP_AUTHORIZATION='Bearer wrong').get('/api/v1/catalog').status_code, 401)

    def test_health_and_catalog_are_readable(self):
        self.assertEqual(self.client.get('/api/v1/health').json()['schemaVersion'], 2)
        tables = self.client.get('/api/v1/catalog').json()['tables']
        self.assertEqual(tables['vehicles'][0]['id'], 'car')
        self.assertEqual(tables['detail_part_options'][0]['asset_path'], 'assets/images/spoiler.jpg')

    def test_methods_restricted(self):
        self.assertEqual(self.client.delete('/api/v1/creations').status_code, 405)
        self.assertEqual(self.client.post('/api/v1/catalog').status_code, 405)

    def test_content_type_and_shape(self):
        self.assertEqual(self.client.post('/api/v1/creations', 'hi', content_type='text/plain').status_code, 415)
        self.assertEqual(self.client.post('/api/v1/creations', '{', content_type='application/json').status_code, 400)
        self.assertEqual(self.client.post('/api/v1/creations', {}, content_type='application/json').status_code, 400)

    def test_create_retry_and_timestamp_roundtrip(self):
        data = record()
        self.assertEqual(self.post([data]).json()['inserted'], 1)
        self.assertEqual(self.post([data]).json()['inserted'], 0)
        self.assertEqual(self.client.get('/api/v1/creations').json()['records'], [data])

    def test_duplicate_id_conflict_is_atomic(self):
        self.post([record()])
        changed = record(); changed['input']['description'] = 'changed'
        self.assertEqual(self.post([record('new'), changed]).status_code, 409)
        self.assertEqual(len(self.client.get('/api/v1/creations').json()['records']), 1)

    def test_invalid_vehicle_rejects_entire_batch(self):
        wrong = record('wrong'); wrong['input']['vehicleId'] = "' OR 1=1 --"
        self.assertEqual(self.post([record(), wrong]).status_code, 400)
        self.assertEqual(self.client.get('/api/v1/creations').json()['records'], [])

    def test_mismatched_photo_and_non_demo_rejected(self):
        wrong = record(); wrong['originalImagePath'] = 'wrong.jpg'
        self.assertEqual(self.post([wrong]).status_code, 400)
        wrong = record(); wrong['kind'] = 'video'
        self.assertEqual(self.post([wrong]).status_code, 400)

    def test_detail_fk_and_wrong_angle(self):
        detail = record(); detail['input'].update(mode='detailEdit', angle='Rear', parts={'Spoiler': 0})
        self.assertEqual(self.post([detail]).status_code, 200)
        bad = copy.deepcopy(detail); bad['id'] = 'bad'; bad['input']['parts']['Spoiler'] = 1
        self.assertEqual(self.post([bad]).status_code, 400)
        bad['input']['parts']['Spoiler'] = True
        self.assertEqual(self.post([bad]).status_code, 400)

    def test_video_and_explore(self):
        video = record('video'); video['input'] = {'type':'video','vehicleId':'car','template':'cliffDrive'}
        explore = record('explore'); explore['input'] = {'type':'explore','vehicleId':'car','operation':'spoiler',
                                                       'optionId':'spoiler.test','color':'','referenceId':''}
        self.assertEqual(self.post([video, explore]).json()['inserted'], 2)
        self.assertEqual(len(self.client.get('/api/v1/creations').json()['records']), 2)

    def test_catalog_edit_keeps_old_history_and_allows_idempotent_retry(self):
        old = record(); self.post([old])
        with closing(sqlite3.connect(DB)) as db, db:
            db.execute("UPDATE vehicles SET asset_path='assets/images/race.jpg'")
        self.assertEqual(self.post([old]).json()['inserted'], 0)
        self.assertEqual(self.client.get('/api/v1/creations').json()['records'][0]['originalImagePath'], old['originalImagePath'])

    def test_selection_etag_prevents_stale_overwrite(self):
        read = self.client.get('/api/v1/selections')
        changed = selections(); changed['generate']['style'] = ''
        saved = self.client.put('/api/v1/selections', {'selections':changed}, content_type='application/json', HTTP_IF_MATCH=read['ETag'])
        self.assertEqual(saved.status_code, 200)
        self.assertNotEqual(saved['ETag'], read['ETag'])
        stale = self.client.put('/api/v1/selections', {'selections':selections()}, content_type='application/json', HTTP_IF_MATCH=read['ETag'])
        self.assertEqual(stale.status_code, 412)
        self.assertEqual(self.client.get('/api/v1/selections').json()['selections'], changed)

    def test_selection_without_revision_or_with_unknown_vehicle_rejected(self):
        self.assertEqual(self.client.put('/api/v1/selections', {'selections':selections()}, content_type='application/json').status_code, 412)
        read = self.client.get('/api/v1/selections')
        bad = selections(); bad['generate']['vehicleId'] = 'unknown'
        self.assertEqual(self.client.put('/api/v1/selections', {'selections':bad}, content_type='application/json', HTTP_IF_MATCH=read['ETag']).status_code, 400)

    def test_new_sql_vehicle_visible_via_api(self):
        with closing(sqlite3.connect(DB)) as db, db:
            db.execute("INSERT INTO vehicles VALUES ('new','New SQL car','assets/images/sport.jpg',1,NULL)")
        self.assertEqual(len(self.client.get('/api/v1/catalog').json()['tables']['vehicles']), 2)

    def test_empty_history_snapshot_does_not_delete(self):
        self.post([record()])
        self.assertEqual(self.post([]).json()['inserted'], 0)
        self.assertEqual(len(self.client.get('/api/v1/creations').json()['records']), 1)


if __name__ == '__main__':
    try:
        result = unittest.main(exit=False, verbosity=2).result
    finally:
        connections.close_all()
        TEMP.cleanup()
    raise SystemExit(0 if result.wasSuccessful() else 1)
