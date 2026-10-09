import json
import secrets
from functools import wraps
from django.conf import settings
from django.db import DatabaseError
from django.http import JsonResponse, HttpResponse
from django.core.exceptions import RequestDataTooBig, ObjectDoesNotExist
from . import repository as repo


def endpoint(methods):
    def decorate(fn):
        @wraps(fn)
        def wrapped(request):
            provided = request.headers.get('Authorization', '')
            if not secrets.compare_digest(provided.encode(), ('Bearer ' + settings.API_TOKEN).encode()):
                return JsonResponse({'error': 'Authentication required'}, status=401)
            if request.method not in methods:
                response = JsonResponse({'error': 'Method not allowed'}, status=405)
                response['Allow'] = ', '.join(methods)
                return response
            try:
                response = fn(request)
                response['Cache-Control'] = 'no-store'
                return response
            except repo.ApiError as error:
                return JsonResponse({'error': error.message}, status=error.status)
            except (ValueError, TypeError, KeyError):
                return JsonResponse({'error': 'Invalid request or stored data'}, status=400)
            except RequestDataTooBig:
                return JsonResponse({'error': 'Request too large'}, status=413)
            except DatabaseError:
                return JsonResponse({'error': 'Database unavailable; retry later'}, status=503)
            except ObjectDoesNotExist:
                return JsonResponse({'error': 'Required server data is missing'}, status=503)
        return wrapped
    return decorate


def body(request):
    if request.content_type != 'application/json':
        raise repo.ApiError('Use application/json', 415)
    value = json.loads(request.body)
    if not isinstance(value, dict):
        raise repo.ApiError('Expected JSON object')
    return value


@endpoint(['GET'])
def health(request):
    repo.ensure_schema()
    return JsonResponse({'status': 'ok', 'apiVersion': 1, 'schemaVersion': 2})


@endpoint(['GET'])
def catalog(request):
    return JsonResponse(repo.catalog())


@endpoint(['GET', 'POST'])
def creations(request):
    from . import cloudflare_generation as ai
    if request.method == 'GET':
        records = repo.get_records() + ai.history()
        records.sort(key=lambda r: r['createdAt'], reverse=True)
        return JsonResponse({'records': records})
    data = body(request)
    if set(data) != {'records'}:
        raise repo.ApiError('Expected records')
    records = data['records']
    if not isinstance(records, list) or len(records) > 5000:
        raise repo.ApiError('Invalid record batch')
    from django.db import transaction
    with transaction.atomic():
        real = [r for r in records if isinstance(r, dict) and r.get('kind') == 'aiImage']
        demos = [r for r in records if r not in real]
        count = repo.append_records(demos)
        count += sum(ai.publish(r) for r in real)
    return JsonResponse({'inserted': count})


@endpoint(['POST'])
def generate_color(request):
    from .cloudflare_generation import generate
    return JsonResponse({'record': generate(body(request))})


@endpoint(['POST'])
def generate_spoiler(request):
    from .cloudflare_generation import generate
    return JsonResponse({'record': generate(body(request), 'spoiler')})


@endpoint(['GET'])
def ai_media(request):
    from .cloudflare_generation import installed
    if not installed():
        raise repo.ApiError('Image not found', 404)
    rows = repo.rows("SELECT image FROM ai_attempts WHERE id=%s AND state='completed'", [request.GET.get('id', '')])
    if not rows:
        raise repo.ApiError('Image not found', 404)
    response = HttpResponse(bytes(rows[0]['image']), content_type='image/jpeg')
    response['X-Content-Type-Options'] = 'nosniff'
    return response


@endpoint(['GET', 'PUT'])
def selections(request):
    if request.method == 'GET':
        data, revision = repo.get_selections()
        response = JsonResponse({'selections': data})
    else:
        data = body(request)
        if set(data) != {'selections'}:
            raise repo.ApiError('Expected selections')
        revision = repo.save_selections(data['selections'], request.headers.get('If-Match'))
        response = JsonResponse({'saved': True})
    response['ETag'] = revision
    return response
