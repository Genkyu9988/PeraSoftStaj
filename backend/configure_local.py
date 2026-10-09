"""Configure an EXISTING database. No seed writes, replacement or data reset."""
import argparse
import datetime
import json
import secrets
import sqlite3
from contextlib import closing
from pathlib import Path

def configure(database, emulator_url):
    root = Path(__file__).resolve().parent
    source = Path(database).resolve(strict=True)
    with closing(sqlite3.connect(source.as_uri() + '?mode=ro', uri=True)) as db:
        if db.execute('PRAGMA user_version').fetchone()[0] != 2:
            raise RuntimeError('Expected Mody AI SQLite schema version 2')
        if db.execute('PRAGMA integrity_check').fetchone()[0] != 'ok' or db.execute('PRAGMA foreign_key_check').fetchall():
            raise RuntimeError('Database integrity check failed')
        for table in ['vehicles', 'creations', 'parts', 'catalog_entries', 'app_settings']:
            db.execute(f'SELECT COUNT(*) FROM {table}').fetchone()
        if not db.execute("SELECT 1 FROM app_settings WHERE key='selections'").fetchone():
            raise RuntimeError('Selections have not been migrated to SQLite')
        # SQLite backup API includes any committed WAL contents safely.
        backup = source.with_name(source.stem + '-before-django-' + datetime.datetime.now().strftime('%Y%m%d-%H%M%S-%f') + '.db')
        with closing(sqlite3.connect(backup)) as dest:
            db.backup(dest)
    config_file = root / '.local.json'
    if config_file.exists():
        config = json.loads(config_file.read_text(encoding='utf-8'))
        if Path(config['database_path']).resolve() != source:
            raise RuntimeError('Configuration already points at a different database; refusing to change it')
    else:
        config = {'database_path': str(source), 'secret_key': secrets.token_urlsafe(48),
                  'api_token': secrets.token_urlsafe(40)}
        config_file.write_text(json.dumps(config, indent=2), encoding='utf-8')
    flutter = {'MODY_DATA_SOURCE': 'django', 'MODY_API_URL': emulator_url,
               'MODY_API_TOKEN': config['api_token']}
    (root / 'flutter.local.json').write_text(json.dumps(flutter, indent=2), encoding='utf-8')
    print(f'Database: {source}\nBackup: {backup}\nLocal configuration written (tokens not printed).')

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--database', required=True)
    parser.add_argument('--emulator-url', default='http://10.0.2.2:8765')
    args = parser.parse_args()
    configure(args.database, args.emulator_url)
