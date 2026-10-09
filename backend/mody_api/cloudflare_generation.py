"""Bounded local experiment: one model, bundled vehicles, no automatic retries."""
import base64
import datetime as dt
import io
import json
import logging
import re
import secrets
import urllib.request
from pathlib import Path

from django.conf import settings
from django.db import connection
from PIL import Image, ImageOps
from . import repository as repo
from .models import Vehicle

MODEL = '@cf/black-forest-labs/flux-2-klein-4b'
LIMIT = 15
SCHEMA = '''CREATE TABLE IF NOT EXISTS ai_attempts (
    id TEXT PRIMARY KEY, request_json TEXT NOT NULL,
    state TEXT NOT NULL CHECK(state IN ('pending','completed','failed')),
    record_json TEXT, image BLOB, published INTEGER NOT NULL DEFAULT 0,
    created_at TEXT NOT NULL
)'''


def installed():
    return bool(repo.rows("SELECT name FROM sqlite_master WHERE type='table' AND name='ai_attempts'"))


def config():
    try:
        value = json.loads((settings.BASE_DIR / '.cloudflare.local.json').read_text(encoding='utf-8'))
    except (OSError, ValueError):
        raise repo.ApiError('AI configuration is missing', 503)
    if value.get('generation_enabled') is not True or not value.get('api_token'):
        raise repo.ApiError('AI generation is disabled', 503)
    if value.get('model') != MODEL or not re.fullmatch(r'[a-f0-9]{32}', value.get('account_id', '')):
        raise repo.ApiError('Unsupported AI configuration', 503)
    return value


def image_input(asset):
    root = (settings.BASE_DIR.parent / 'assets').resolve()
    path = (settings.BASE_DIR.parent / asset).resolve()
    if not asset.startswith('assets/') or not path.is_relative_to(root) or not path.is_file():
        raise repo.ApiError('Only bundled vehicle photos are supported')
    if path.stat().st_size > 20 * 1024 * 1024:
        raise repo.ApiError('Vehicle image is too large')
    with Image.open(path) as source:
        if source.width * source.height > 25_000_000:
            raise repo.ApiError('Vehicle image is too large')
        image = ImageOps.exif_transpose(source).convert('RGB')
        image.thumbnail((504, 504))
        result = io.BytesIO()
        image.save(result, format='JPEG', quality=90)
        return result.getvalue()


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, *args, **kwargs):
        return None


def run_provider(cfg, photo, color, *, reference=None, instruction=''):
    boundary = 'mody-' + secrets.token_hex(16)
    prompt = (f'Edit image 0. Change ONLY the car body paint to {color}. '
              'Preserve the exact same car model, shape, wheels, windows, lights, '
              'license plate, background, camera angle and lighting. Photorealistic. '
              'Do not add text or objects.')
    if reference is not None:
        prompt = ('Edit image 0 only. Install the spoiler shown in image 1 on the car in image 0. '
                  'Image 1 is a part reference, not the target vehicle or background. '
                  f'{instruction} Preserve the original car model, paint, wheels, license plate, '
                  'background, camera angle and lighting. Fit the part with realistic scale, '
                  'perspective and mounting. Do not add text or a comparison panel.')
    parts = []
    for name, value in {'prompt': prompt, 'width': '768', 'height': '512'}.items():
        parts.append(f'--{boundary}\r\nContent-Disposition: form-data; name="{name}"\r\n\r\n{value}\r\n'.encode())
    parts.append(f'--{boundary}\r\nContent-Disposition: form-data; name="input_image_0"; filename="vehicle.jpg"\r\nContent-Type: image/jpeg\r\n\r\n'.encode() + photo + b'\r\n')
    if reference is not None:
        parts.append(f'--{boundary}\r\nContent-Disposition: form-data; name="input_image_1"; filename="spoiler.jpg"\r\nContent-Type: image/jpeg\r\n\r\n'.encode() + reference + b'\r\n')
    parts.append(f'--{boundary}--\r\n'.encode())
    url = f'https://api.cloudflare.com/client/v4/accounts/{cfg["account_id"]}/ai/run/{MODEL}'
    request = urllib.request.Request(url, data=b''.join(parts), method='POST', headers={
        'Authorization': 'Bearer ' + cfg['api_token'],
        'Content-Type': 'multipart/form-data; boundary=' + boundary,
    })
    # No redirects, retry adapters or alternative/paid models.
    with urllib.request.build_opener(NoRedirect).open(request, timeout=100) as response:
        raw = response.read(12 * 1024 * 1024 + 1)
    if len(raw) > 12 * 1024 * 1024:
        raise ValueError('Oversized provider response')
    payload = json.loads(raw)
    if payload.get('success') is not True:
        raise ValueError('Provider rejected request')
    decoded = base64.b64decode(payload['result']['image'], validate=True)
    with Image.open(io.BytesIO(decoded)) as image:
        if image.width * image.height > 4_000_000:
            raise ValueError('Oversized image')
        output = io.BytesIO()
        image.convert('RGB').save(output, format='JPEG', quality=92)
        return output.getvalue()


def generate(data, operation='changeColor'):
    repo.ensure_schema()
    if operation not in ('changeColor', 'spoiler'):
        raise repo.ApiError('Unsupported operation')
    field = 'color' if operation == 'changeColor' else 'optionId'
    if set(data) != {'id', 'vehicleId', field}:
        raise repo.ApiError('Invalid generation fields')
    ident = data['id']
    if not isinstance(ident, str) or not re.fullmatch(r'[a-f0-9]{32}', ident):
        raise repo.ApiError('Invalid generation ID')
    repo.string(data['vehicleId'], 'vehicleId')
    option = None
    if operation == 'changeColor':
        repo.choice(data['color'], repo.colors(), 'color', True)
    else:
        repo.string(data['optionId'], 'optionId')
        options = repo.rows('''SELECT p.asset_path,m.instruction FROM mod_options m
            JOIN parts p ON p.id=m.part_id WHERE m.operation='Spoiler' AND m.part_id=%s''', [data['optionId']])
        if not options:
            raise repo.ApiError('Unknown spoiler option')
        option = options[0]
    request_json = json.dumps(data, sort_keys=True, ensure_ascii=False)
    if not installed():
        raise repo.ApiError('Run enable_cloudflare.py first', 503)
    previous = repo.rows('SELECT request_json,state,record_json FROM ai_attempts WHERE id=%s', [ident])
    if previous:
        row = previous[0]
        if row['request_json'] != request_json:
            raise repo.ApiError('Generation ID conflict', 409)
        if row['state'] == 'completed':
            return json.loads(row['record_json'])
        # Unknown in-flight outcome is never replayed against the provider.
        raise repo.ApiError('Previous attempt pending or failed; no automatic retry', 409)
    cfg = config()
    vehicle = Vehicle.objects.filter(pk=data['vehicleId']).first()
    if vehicle is None:
        raise repo.ApiError('Unknown vehicle')
    photo = image_input(vehicle.asset_path)
    reference = image_input(option['asset_path']) if option else None
    created = dt.datetime.now(dt.timezone.utc).isoformat(timespec='microseconds').replace('+00:00', 'Z')
    # A single SQL write serializes concurrent requests, permanently reserving a
    # slot before network I/O. Even failures/restarts consume their reserved slot.
    with connection.cursor() as cursor:
        cursor.execute('''INSERT OR IGNORE INTO ai_attempts(id,request_json,state,created_at)
            SELECT %s,%s,'pending',%s WHERE (SELECT COUNT(*) FROM ai_attempts)<%s
            AND NOT EXISTS(SELECT 1 FROM ai_attempts WHERE state='pending')''',
            [ident, request_json, created, LIMIT])
        if cursor.rowcount != 1:
            raise repo.ApiError('15 attempt limit reached or another request is pending', 429)
    try:
        output = (run_provider(cfg, photo, '', reference=reference, instruction=option['instruction'])
                  if option else run_provider(cfg, photo, data['color']))
        record = {'id': 'ai-' + ident, 'createdAt': created, 'kind': 'aiImage',
                  'originalImagePath': vehicle.asset_path, 'outputImagePath': 'mody-media:' + ident,
                  'input': {'type': 'explore', 'vehicleId': vehicle.id, 'operation': operation,
                            'optionId': data.get('optionId', ''), 'color': data.get('color', ''), 'referenceId': ''}}
        with connection.cursor() as cursor:
            cursor.execute("UPDATE ai_attempts SET state='completed',record_json=%s,image=%s WHERE id=%s",
                           [json.dumps(record, ensure_ascii=False), output, ident])
        return record
    except Exception as error:
        logging.getLogger(__name__).warning('AI attempt failed; type=%s http_status=%s',
                                           type(error).__name__, getattr(error, 'code', None))
        with connection.cursor() as cursor:
            cursor.execute("UPDATE ai_attempts SET state='failed' WHERE id=%s", [ident])
        # Never expose provider response bodies, headers or credentials.
        raise repo.ApiError('AI generation failed; attempt counted, no automatic retry', 502) from None


def history():
    if not installed():
        return []
    return [json.loads(r['record_json']) for r in repo.rows(
        "SELECT record_json FROM ai_attempts WHERE state='completed' AND published=1")]


def publish(record):
    if not installed() or not isinstance(record, dict):
        raise repo.ApiError('Unknown AI result')
    ident = record.get('id', '')
    if not isinstance(ident, str) or not re.fullmatch(r'ai-[a-f0-9]{32}', ident):
        raise repo.ApiError('Invalid AI result ID')
    matches = repo.rows("SELECT record_json,published FROM ai_attempts WHERE id=%s AND state='completed'", [ident[3:]])
    normalized = dict(record)
    try:
        instant = dt.datetime.fromisoformat(normalized['createdAt'].replace('Z', '+00:00'))
        if instant.tzinfo is None:
            raise ValueError('Timezone missing')
        normalized['createdAt'] = instant.astimezone(dt.timezone.utc).isoformat(timespec='microseconds').replace('+00:00', 'Z')
    except (KeyError, TypeError, ValueError, AttributeError):
        raise repo.ApiError('Invalid AI timestamp')
    if not matches or json.loads(matches[0]['record_json']) != normalized:
        raise repo.ApiError('Unknown or altered AI result', 409)
    with connection.cursor() as cursor:
        cursor.execute('UPDATE ai_attempts SET published=1 WHERE id=%s', [ident[3:]])
    return 0 if matches[0]['published'] else 1
