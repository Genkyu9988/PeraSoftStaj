"""Explicitly enable the bounded local experiment; never generates an image."""
import datetime
import json
import os
import sqlite3
import tempfile
from contextlib import closing
from pathlib import Path

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'mody_backend.settings')
import django
django.setup()
from django.conf import settings
from django.db import connection
from mody_api.cloudflare_generation import SCHEMA, LIMIT


def main():
    root = Path(__file__).resolve().parent
    path = root / '.cloudflare.local.json'
    cfg = json.loads(path.read_text(encoding='utf-8'))
    db = Path(settings.DATABASES['default']['NAME'])
    backup = db.with_name(db.stem + '-before-ai-' + datetime.datetime.now().strftime('%Y%m%d-%H%M%S-%f') + '.db')
    with closing(sqlite3.connect(db)) as source, closing(sqlite3.connect(backup)) as dest:
        source.backup(dest)
    with connection.cursor() as cursor:
        cursor.execute(SCHEMA)
        cursor.execute('SELECT COUNT(*) FROM ai_attempts')
        used = cursor.fetchone()[0]
    cfg['generation_enabled'] = True
    cfg['max_attempts'] = LIMIT
    # No reset of the permanent ledger; no change to plan or provider credentials.
    temporary = None
    try:
        with tempfile.NamedTemporaryFile(mode='w', encoding='utf-8', dir=root,
                                         prefix='.cloudflare-secret-', suffix='.tmp', delete=False) as stream:
            temporary = Path(stream.name)
            json.dump(cfg, stream, indent=2)
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(temporary, path)
    finally:
        if temporary is not None:
            temporary.unlink(missing_ok=True)
    print(f'Enabled local Change Color and Spoiler. Attempts already reserved: {used}/{LIMIT}. No AI calls made.')
    print(f'Database backup: {backup}')


if __name__ == '__main__':
    main()
