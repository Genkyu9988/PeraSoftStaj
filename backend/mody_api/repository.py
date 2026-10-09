import datetime as dt
import hashlib
import json
from django.db import connection, transaction
from .contracts import OPERATIONS, VIDEOS, GENERATE_FIELDS, EXPLORE_FIELDS, DIRECT_FIELDS
from .models import AppSetting, Vehicle


class ApiError(Exception):
    def __init__(self, message, status=400):
        self.message, self.status = message, status


def rows(sql, params=()):
    with connection.cursor() as cursor:
        cursor.execute(sql, params)
        names = [col[0] for col in cursor.description]
        return [dict(zip(names, row)) for row in cursor.fetchall()]


def ensure_schema():
    with connection.cursor() as cursor:
        cursor.execute('PRAGMA user_version')
        if cursor.fetchone()[0] != 2:
            raise ApiError('Unsupported database schema', 503)


@transaction.atomic
def catalog():
    ensure_schema()
    tables = {name: rows(f'SELECT * FROM {name} ORDER BY {ordering}') for name, ordering in [
        ('vehicles', 'position,id'), ('part_categories', 'position'),
        ('angle_categories', 'position'), ('reference_cars', 'position'),
        ('catalog_sections', 'id'), ('catalog_entries', 'position')]}
    tables['detail_part_options'] = rows('SELECT d.*,p.asset_path FROM detail_part_options d JOIN parts p ON p.id=d.part_id ORDER BY d.category_id,d.slot')
    tables['mod_options'] = rows('SELECT m.*,p.asset_path FROM mod_options m JOIN parts p ON p.id=m.part_id ORDER BY m.operation,m.position')
    return {'schemaVersion': 2, 'tables': tables}


def section(name):
    return [json.loads(r['value_json']) for r in rows('SELECT value_json FROM catalog_entries WHERE section_id=%s ORDER BY position', [name])]


def string(value, name, max_length=2000):
    if not isinstance(value, str) or len(value) > max_length:
        raise ApiError(f'Invalid {name}')
    return value


def colors():
    categories = section('generate_option_catalog.colorCategories')
    base = [r['entry_key'] for r in rows('SELECT entry_key FROM catalog_entries WHERE section_id=%s', ['generate_option_catalog.baseColors'])]
    return [name if i == 0 else f'{category} {name}' for i, category in enumerate(categories) for name in base]


def choice(value, allowed, name, required=False):
    string(value, name)
    if (required or value) and value not in allowed:
        raise ApiError(f'Unknown {name}')


def validate_parts(parts, angle):
    if not isinstance(parts, dict) or len(parts) > 100:
        raise ApiError('Invalid parts')
    for category, slot in parts.items():
        if type(slot) is not int or slot < 0:
            raise ApiError('Invalid part slot')
        if not rows('''SELECT d.part_id FROM detail_part_options d JOIN angle_categories a
                    ON a.category_id=d.category_id WHERE a.angle=%s AND d.category_id=%s AND d.slot=%s''', [angle, category, slot]):
            raise ApiError('Unknown part or wrong angle')


def normalize_record(record):
    if not isinstance(record, dict) or set(record) != {'id', 'createdAt', 'kind', 'originalImagePath', 'input'}:
        raise ApiError('Invalid record shape')
    ident = string(record['id'], 'id', 200)
    if not ident or record['kind'] != 'demo':
        raise ApiError('Only identified demo records are supported')
    try:
        instant = dt.datetime.fromisoformat(string(record['createdAt'], 'createdAt', 50).replace('Z', '+00:00'))
        if instant.tzinfo is None:
            raise ValueError('Timezone required')
        instant = instant.astimezone(dt.timezone.utc)
    except (ValueError, OverflowError):
        raise ApiError('Invalid timestamp')
    source = string(record['originalImagePath'], 'originalImagePath')
    inp = record['input']
    if not isinstance(inp, dict):
        raise ApiError('Invalid input')
    kind = inp.get('type')
    fields = GENERATE_FIELDS if kind == 'generate' else EXPLORE_FIELDS if kind == 'explore' else ['template'] if kind == 'video' else None
    if fields is None or set(inp) != set(['type', 'vehicleId'] + fields + (['parts'] if kind == 'generate' else [])):
        raise ApiError('Invalid input fields')
    for field in ['vehicleId'] + fields:
        string(inp[field], field)
    if kind == 'generate' and (not isinstance(inp['parts'], dict) or any(type(v) is not int for v in inp['parts'].values())):
        raise ApiError('Invalid parts')
    normalized = dict(record, createdAt=instant.isoformat(timespec='microseconds').replace('+00:00', 'Z'))
    return normalized, instant


def validate_new(record):
    inp = record['input']
    vehicle = Vehicle.objects.filter(pk=inp['vehicleId']).first()
    if vehicle is None or record['originalImagePath'] != vehicle.asset_path:
        raise ApiError('Unknown vehicle or mismatched original photo')
    if inp['type'] == 'video':
        choice(inp['template'], VIDEOS, 'template', True)
    elif inp['type'] == 'explore':
        choice(inp['operation'], OPERATIONS, 'operation', True)
        title = OPERATIONS[inp['operation']]
        if inp['operation'] == 'changeColor':
            choice(inp['color'], colors(), 'color', True)
        elif inp['operation'] == 'cloneCarStyle':
            if not rows('SELECT id FROM reference_cars WHERE id=%s', [inp['referenceId']]):
                raise ApiError('Unknown reference')
        elif inp['operation'] in list(OPERATIONS)[1:16]:
            if not rows('SELECT part_id FROM mod_options WHERE operation=%s AND part_id=%s', [title, inp['optionId']]):
                raise ApiError('Unknown option')
    else:
        choice(inp['mode'], ['styleBuilder', 'customEdit', 'detailEdit'], 'mode', True)
        if inp['mode'] == 'customEdit' and not inp['description'].strip():
            raise ApiError('Description required')
        if inp['mode'] == 'styleBuilder':
            choice(inp['style'], section('generate_option_catalog.styles'), 'style')
            choice(inp['extra'], section('generate_option_catalog.extras'), 'extra')
            choice(inp['color'], colors(), 'color')
            if not any(inp[k] for k in ['style', 'extra', 'color']):
                raise ApiError('Style choice required')
        if inp['mode'] == 'detailEdit':
            choice(inp['angle'], [r['angle'] for r in rows('SELECT DISTINCT angle FROM angle_categories')], 'angle', True)
            choice(inp['color'], colors(), 'color')
            validate_parts(inp['parts'], inp['angle'])


def read_records():
    grouped = {}
    for part in rows('SELECT * FROM creation_parts ORDER BY position'):
        grouped.setdefault(part['creation_id'], {})[part['category']] = part['selected_index']
    result = []
    epoch = dt.datetime(1970, 1, 1, tzinfo=dt.timezone.utc)
    for row in rows('SELECT * FROM creations ORDER BY created_at_us DESC,id DESC'):
        kind = row['request_type']
        inp = {'type': kind, 'vehicleId': row['vehicle_id']}
        if kind == 'generate':
            inp.update({field: row[field] for field in GENERATE_FIELDS})
            inp['parts'] = grouped.get(row['id'], {})
        elif kind == 'explore':
            inp.update(operation=row['operation'], optionId=row['option_id'], color=row['color'], referenceId=row['reference_id'])
        else:
            inp['template'] = row['template']
        result.append({'id': row['id'], 'createdAt': (epoch + dt.timedelta(microseconds=row['created_at_us'])).isoformat(timespec='microseconds').replace('+00:00', 'Z'),
                       'kind': row['kind'], 'originalImagePath': row['original_image_path'], 'input': inp})
    return result


@transaction.atomic
def get_records():
    ensure_schema()
    return read_records()


@transaction.atomic
def append_records(batch):
    ensure_schema()
    if not isinstance(batch, list) or len(batch) > 5000:
        raise ApiError('Invalid record batch')
    existing = {r['id']: r for r in read_records()}
    count = 0
    for raw in batch:
        record, instant = normalize_record(raw)
        ident, inp = record['id'], record['input']
        if ident in existing:
            if existing[ident] != record:
                raise ApiError('History ID conflict; existing record was not changed', 409)
            continue
        validate_new(record)
        delta = instant - dt.datetime(1970, 1, 1, tzinfo=dt.timezone.utc)
        micros = (delta.days * 86400 + delta.seconds) * 1000000 + delta.microseconds
        values = {'id': ident, 'vehicle_id': inp['vehicleId'], 'created_at_us': micros, 'kind': 'demo',
                  'original_image_path': record['originalImagePath'], 'request_type': inp['type'],
                  **{field: inp.get(field, '') for field in DIRECT_FIELDS},
                  'option_id': inp.get('optionId', ''), 'reference_id': inp.get('referenceId', '')}
        with connection.cursor() as cursor:
            columns = ','.join(values)
            placeholders = ','.join(['%s'] * len(values))
            cursor.execute(f'INSERT INTO creations ({columns}) VALUES ({placeholders})', list(values.values()))
            for position, (category, slot) in enumerate(inp.get('parts', {}).items()):
                cursor.execute('INSERT INTO creation_parts(creation_id,category,selected_index,position) VALUES (%s,%s,%s,%s)', [ident, category, slot, position])
        existing[ident] = record
        count += 1
    return count


def etag(text):
    return '"' + hashlib.sha256(text.encode()).hexdigest() + '"'


def get_selections():
    value = AppSetting.objects.get(pk='selections').value_json
    return json.loads(value), etag(value)


def validate_selections(value):
    if not isinstance(value, dict) or set(value) != {'generate', 'explore', 'aiVideo'}:
        raise ApiError('Invalid selection document')
    generate = value['generate']
    if not isinstance(generate, dict) or set(generate) != {'vehicleId', 'style', 'extra', 'color', 'colorCategory', 'angle', 'parts', 'detailColor', 'detailColorCategory'}:
        raise ApiError('Invalid generate selections')
    vehicle_ids = set(Vehicle.objects.values_list('id', flat=True))
    choice(generate['vehicleId'], vehicle_ids, 'vehicle')
    choice(generate['style'], section('generate_option_catalog.styles'), 'style')
    choice(generate['extra'], section('generate_option_catalog.extras'), 'extra')
    choice(generate['color'], colors(), 'color')
    choice(generate['detailColor'], colors(), 'detailColor')
    choice(generate['angle'], [r['angle'] for r in rows('SELECT DISTINCT angle FROM angle_categories')], 'angle')
    validate_parts(generate['parts'], generate['angle'])
    max_color = len(section('generate_option_catalog.colorCategories'))
    def category(number):
        if type(number) is not int or not 0 <= number < max_color:
            raise ApiError('Invalid color category')
    category(generate['colorCategory'])
    category(generate['detailColorCategory'])
    for group in ['explore', 'aiVideo']:
        cards = value[group]
        allowed = set(OPERATIONS.values()) if group == 'explore' else set(section('ai_video_items.transformations') + section('ai_video_items.driveScenes') + section('ai_video_items.filters'))
        if not isinstance(cards, dict) or not set(cards) <= allowed:
            raise ApiError('Unknown selection card')
        for title, card in cards.items():
            if not isinstance(card, dict) or set(card) != {'image', 'option', 'colorCategory', 'referenceImage'}:
                raise ApiError('Invalid card selection')
            choice(card['image'], vehicle_ids, 'vehicle')
            string(card['option'], 'option')
            string(card['referenceImage'], 'referenceImage')
            category(card['colorCategory'])
            if card['option']:
                if title == 'Change Color':
                    choice(card['option'], colors(), 'color')
                elif group == 'aiVideo' or not rows('SELECT part_id FROM mod_options WHERE operation=%s AND part_id=%s', [title, card['option']]):
                    raise ApiError('Unknown card option')
            if card['referenceImage'] and (title != 'Clone Car Style' or not rows('SELECT id FROM reference_cars WHERE id=%s', [card['referenceImage']])):
                raise ApiError('Unknown card reference')


@transaction.atomic
def save_selections(value, expected):
    ensure_schema()
    current = AppSetting.objects.get(pk='selections')
    if not expected or expected != etag(current.value_json):
        raise ApiError('Selections changed on the server; reload before editing', 412)
    validate_selections(value)
    current.value_json = json.dumps(value, ensure_ascii=False, separators=(',', ':'))
    current.save(update_fields=['value_json'])
    return etag(current.value_json)
