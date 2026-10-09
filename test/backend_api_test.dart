import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:perasoft_staj/main.dart';
import 'package:perasoft_staj/product/cache/api_repositories.dart';
import 'package:perasoft_staj/product/cache/creation_repository.dart';
import 'package:perasoft_staj/product/cache/sqlite_creation_repository.dart';
import 'package:perasoft_staj/product/cache/sqlite_catalog.dart';
import 'package:perasoft_staj/product/catalog/catalog_codec.dart';
import 'package:perasoft_staj/product/catalog/catalog_store.dart';
import 'package:perasoft_staj/product/catalog/vehicle_catalog.dart';
import 'package:perasoft_staj/product/model/app_selections.dart';
import 'package:perasoft_staj/product/model/generate_selection.dart';
import 'package:perasoft_staj/product/model/creation_record.dart';
import 'package:perasoft_staj/product/model/generation_request.dart';
import 'package:perasoft_staj/product/model/generation_result.dart';
import 'package:perasoft_staj/product/service/backend/mody_api_client.dart';

void main() {
  late Map<String, dynamic> catalog;
  setUpAll(() async {
    sqfliteFfiInit();
    final store = SqliteCreationRepository(
      legacyRepository: MemoryCreationRepository(),
      factory: databaseFactoryFfi,
      databasePath: inMemoryDatabasePath,
    );
    catalog = await SqliteCatalog.exportTables(await store.database);
    await store.close();
    CatalogStore.resetForTests();
  });
  setUp(CatalogStore.resetForTests);
  tearDown(CatalogStore.resetForTests);
  ModyApiClient client(Future<http.Response> Function(http.Request) handler) =>
      ModyApiClient(
        baseUrl: 'http://127.0.0.1:8765',
        token: 'test-token',
        client: MockClient(handler),
      );
  http.Response json(Object data, {String? etag}) => http.Response(
    jsonEncode(data),
    200,
    headers: {'content-type': 'application/json', 'etag': ?etag},
  );

  test(
    'HTTP uses versioned path and bearer, never redirects credentials',
    () async {
      final api = client((request) async {
        expect(request.url.path, '/api/v1/catalog');
        expect(request.headers['Authorization'], 'Bearer test-token');
        expect(request.followRedirects, isFalse);
        return json(catalog);
      });
      final result = await api.request('GET', 'catalog');
      CatalogStore.install(CatalogCodec.decode(result.data));
      expect(VehicleCatalog.all, hasLength(12));
      api.close();
    },
  );

  test('Absent token cannot silently use local data', () async {
    final api = ModyApiClient(
      baseUrl: 'http://127.0.0.1:8765',
      token: '',
      client: MockClient((_) async => throw StateError('Must not send')),
    );
    await expectLater(
      api.request('GET', 'catalog'),
      throwsA(isA<BackendException>()),
    );
    api.close();
  });

  for (final status in [401, 409, 412, 503, 302]) {
    test('HTTP $status propagates a storage failure', () async {
      final api = client((_) async => http.Response('{}', status));
      await expectLater(
        api.request('GET', 'creations'),
        throwsA(
          isA<BackendException>().having((e) => e.status, 'status', status),
        ),
      );
      api.close();
    });
  }

  test(
    'Malformed successful response is not treated as empty history',
    () async {
      final api = client((_) async => http.Response('not json', 200));
      await expectLater(
        ApiCreationRepository(api).load(),
        throwsA(isA<BackendException>()),
      );
      api.close();
    },
  );

  test('History preserves immutable record IDs on retry', () async {
    final bodies = <String>[];
    final record = CreationRecord(
      id: 'stable',
      createdAt: DateTime.utc(2026),
      result: DemoGenerationResult(
        request: GenerationRequest(
          mode: GenerateMode.customEdit,
          vehicleId: 'porsche_911',
          description: 'Test',
        ),
        originalImagePath: 'assets/images/sport.jpg',
      ),
    );
    final api = client((request) async {
      if (request.method == 'GET') {
        return json({
          'records': [record.toJson()],
        });
      }
      bodies.add(request.body);
      return json({'inserted': bodies.length == 1 ? 1 : 0});
    });
    final repo = ApiCreationRepository(api);
    expect(await repo.load(), [record]);
    await repo.save([record]);
    await repo.save([record]);
    expect(bodies[0], bodies[1]);
    api.close();
  });

  test(
    'Selection writes require load and advance ETag in serialized order',
    () async {
      var revision = 0;
      final vehicles = <String>[];
      final api = client((request) async {
        if (request.method == 'GET') {
          return json({'selections': AppSelections().toJson()}, etag: '"0"');
        }
        expect(request.headers['If-Match'], '"$revision"');
        vehicles.add(
          jsonDecode(request.body)['selections']['generate']['vehicleId']
              as String,
        );
        revision++;
        return json({'saved': true}, etag: '"$revision"');
      });
      final repo = ApiSelectionRepository(api);
      expect(await repo.save(AppSelections()), isFalse);
      await repo.load();
      final selected = AppSelections(
        generate: const GenerateSelection(vehicleId: 'porsche_911'),
      );
      final first = repo.save(selected);
      selected.generate = const GenerateSelection(vehicleId: 'mustang_gt');
      final second = repo.save(selected);
      expect(await Future.wait([first, second]), [true, true]);
      expect(vehicles, ['porsche_911', 'mustang_gt']);
      api.close();
    },
  );

  test(
    'Stale selection revision returns false without blind overwrite',
    () async {
      var puts = 0;
      final api = client((request) async {
        if (request.method == 'GET') {
          return json({'selections': AppSelections().toJson()}, etag: '"old"');
        }
        puts++;
        return http.Response('{}', 412);
      });
      final repo = ApiSelectionRepository(api);
      await repo.load();
      expect(await repo.save(AppSelections()), isFalse);
      expect(puts, 1);
      api.close();
    },
  );

  test('Unsupported catalog schema is rejected', () {
    expect(
      () => CatalogCodec.decode({...catalog, 'schemaVersion': 99}),
      throwsFormatException,
    );
  });

  testWidgets(
    'Django bootstrap displays error then retries without seed fallback',
    (tester) async {
      CatalogStore.requireDatabase = true;
      var failed = true;
      final api = client((request) async {
        if (failed) throw http.ClientException('offline');
        return switch (request.url.path) {
          '/api/v1/catalog' => json(catalog),
          '/api/v1/selections' => json({
            'selections': AppSelections().toJson(),
          }, etag: '"0"'),
          '/api/v1/creations' => json({'records': []}),
          _ => http.Response('{}', 404),
        };
      });
      await tester.pumpWidget(DjangoAppLoader(client: api));
      await tester.pumpAndSettle();
      expect(find.text('Backend bağlantısı kurulamadı'), findsOneWidget);
      expect(() => VehicleCatalog.all, throwsStateError);
      failed = false;
      await tester.tap(find.text('Tekrar Dene'));
      await tester.pumpAndSettle();
      expect(find.text('Style Builder'), findsOneWidget);
      expect(VehicleCatalog.all, hasLength(12));
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
