import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:perasoft_staj/product/cache/creation_cache_manager.dart';
import 'package:perasoft_staj/product/cache/shared_manager.dart';
import 'package:perasoft_staj/product/cache/sqlite_creation_repository.dart';
import 'package:perasoft_staj/product/catalog/car_mod_option.dart';
import 'package:perasoft_staj/product/catalog/reference_car_catalog.dart';
import 'package:perasoft_staj/product/catalog/vehicle_catalog.dart';
import 'package:perasoft_staj/product/model/ai_video_template.dart';
import 'package:perasoft_staj/product/model/creation_record.dart';
import 'package:perasoft_staj/product/model/explore_operation.dart';
import 'package:perasoft_staj/product/model/generation_request.dart';
import 'package:perasoft_staj/product/model/generation_result.dart';
import 'package:perasoft_staj/feature/creations/view_model/creation_history_cubit.dart';
import 'package:perasoft_staj/feature/generate/view/mody_home_view.dart';
import 'package:perasoft_staj/feature/garage/view/garage_view.dart';
import 'package:perasoft_staj/product/model/generate_selection.dart';
import 'package:perasoft_staj/main.dart';
import 'helpers/controlled_generation_service.dart';

class _Preferences extends SharedManager {
  final values = <SharedKeys, String>{};
  int reads = 0;
  bool failRead = false;
  @override
  Future<String?> getString(SharedKeys key) async {
    reads++;
    if (failRead) throw StateError('Preferences unavailable');
    return values[key];
  }

  @override
  Future<void> saveString(SharedKeys key, String value) async {
    values[key] = value;
  }
}

CreationRecord _record(String id, {GenerationInput? request, DateTime? at}) {
  final input =
      request ??
      GenerationRequest(
        mode: GenerateMode.customEdit,
        vehicleId: 'porsche_911',
        description: "Mat boya; 'quoted'\nTürkçe 🚗",
      );
  return CreationRecord(
    id: id,
    createdAt: at ?? DateTime.utc(2026, 10, 9),
    result: DemoGenerationResult(
      request: input,
      originalImagePath: VehicleCatalog.find(input.vehicleId)!.imagePath,
    ),
  );
}

void main() {
  sqfliteFfiInit();
  late Directory directory;
  late String databasePath;
  late _Preferences preferences;
  late SqliteCreationRepository repository;

  SqliteCreationRepository createRepository() => SqliteCreationRepository(
    legacyRepository: CreationCacheManager(preferences),
    factory: databaseFactoryFfi,
    databasePath: databasePath,
  );

  Future<Database> inspect() => databaseFactoryFfi.openDatabase(
    databasePath,
    options: OpenDatabaseOptions(
      singleInstance: false,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
    ),
  );

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('modyai_sqlite_test_');
    databasePath = path.join(directory.path, 'test.db');
    preferences = _Preferences();
    repository = createRepository();
  });
  tearDown(() async {
    await repository.close();
    final tempRoot = path.normalize(Directory.systemTemp.absolute.path);
    final target = path.normalize(directory.absolute.path);
    if (!path.isWithin(tempRoot, target) ||
        !path.basename(target).startsWith('modyai_sqlite_test_')) {
      throw StateError('Unsafe temporary test cleanup path');
    }
    await directory.delete(recursive: true);
  });

  final inputs = <GenerationInput>[
    GenerationRequest(
      mode: GenerateMode.styleBuilder,
      vehicleId: 'porsche_911',
      style: 'Sportif',
      extra: 'Jant',
      color: 'Özel Mor',
    ),
    GenerationRequest(
      mode: GenerateMode.customEdit,
      vehicleId: 'mustang_gt',
      description: "Mat boya; 'quoted'\nTürkçe 🚗",
    ),
    GenerationRequest(
      mode: GenerateMode.detailEdit,
      vehicleId: 'porsche_911',
      angle: 'Rear',
      parts: {'Spoiler': 2, 'Exhaust': 0},
      color: 'Mavi',
    ),
    for (final operation in ExploreOperation.values)
      ExploreGenerationRequest(
        operation: operation,
        vehicleId: 'porsche_911',
        optionId: operation.input == ExploreInput.option
            ? CarModCatalog.groups[operation.title]!.first.id
            : '',
        color: operation.input == ExploreInput.color ? 'Özel Mor' : '',
        referenceId: operation.input == ExploreInput.reference
            ? ReferenceCarCatalog.items.first.id
            : '',
      ),
    for (final template in AiVideoTemplate.values)
      AiVideoGenerationRequest(template: template, vehicleId: 'porsche_911'),
  ];

  for (var i = 0; i < inputs.length; i++) {
    test('SQLite round trip for request $i survives close/reopen', () async {
      final original = _record('record-$i', request: inputs[i]);
      await repository.save([original]);
      await repository.close();
      repository = createRepository();
      expect(await repository.load(), [original]);
      expect(
        (await repository.load()).single.isVideoDemo,
        inputs[i] is AiVideoGenerationRequest,
      );
    });
  }

  test(
    'Fresh schema seeds catalog, enables FK and marks empty migration',
    () async {
      expect(await repository.load(), isEmpty);
      final db = await inspect();
      try {
        expect(await db.getVersion(), SqliteCreationRepository.schemaVersion);
        expect(
          await db.query('vehicles'),
          hasLength(VehicleCatalog.all.length),
        );
        expect(await db.query('migration_log'), hasLength(1));
        expect(await db.rawQuery('PRAGMA foreign_key_check'), isEmpty);
        expect(await db.rawQuery('PRAGMA integrity_check'), [
          {'integrity_check': 'ok'},
        ]);
      } finally {
        await db.close();
      }
    },
  );

  test(
    'Migrates every type exactly once, retaining preferences and selections',
    () async {
      final records = [
        for (var i = 0; i < inputs.length; i++)
          _record('$i', request: inputs[i]),
      ];
      await CreationCacheManager(preferences).save(records);
      preferences.values[SharedKeys.selections] = 'unchanged selections';
      final before = Map<SharedKeys, String>.from(preferences.values);
      expect(await repository.load(), unorderedEquals(records));
      expect(preferences.values, before);
      final readCount = preferences.reads;
      await repository.close();
      preferences.failRead = true; // SQLite is now independent of old cache.
      repository = createRepository();
      expect(await repository.load(), unorderedEquals(records));
      expect(preferences.reads, readCount);
      expect(preferences.values, before);
    },
  );

  test(
    'Save before explicit load imports old records before adding new ones',
    () async {
      final old = _record('old');
      final fresh = _record('new');
      await CreationCacheManager(preferences).save([old]);
      await repository.save([fresh]);
      expect(await repository.load(), unorderedEquals([old, fresh]));
    },
  );

  for (final corrupt in ['{broken', '{"version":99,"records":[]}']) {
    test(
      'Invalid legacy data remains untouched and migration is retryable: $corrupt',
      () async {
        preferences.values[SharedKeys.creations] = corrupt;
        await expectLater(repository.load(), throwsFormatException);
        expect(preferences.values[SharedKeys.creations], corrupt);
        final db = await inspect();
        try {
          expect(await db.query('creations'), isEmpty);
          expect(await db.query('migration_log'), isEmpty);
        } finally {
          await db.close();
        }
        await CreationCacheManager(preferences).save([_record('recovered')]);
        expect((await repository.load()).single.id, 'recovered');
      },
    );
  }

  test(
    'Legacy duplicate IDs cannot silently merge or mark migration complete',
    () async {
      final row = _record('duplicate').toJson();
      preferences.values[SharedKeys.creations] = jsonEncode({
        'version': 1,
        'records': [row, row],
      });
      await expectLater(repository.load(), throwsFormatException);
      final db = await inspect();
      try {
        expect(await db.query('migration_log'), isEmpty);
      } finally {
        await db.close();
      }
    },
  );

  test('Legacy read failure can recover on same repository', () async {
    preferences.failRead = true;
    await expectLater(repository.load(), throwsStateError);
    preferences.failRead = false;
    expect(await repository.load(), isEmpty);
  });

  test(
    'Immutable IDs are idempotent; stale snapshots do not erase history',
    () async {
      final a = _record('a');
      final b = _record('b');
      await repository.save([a]);
      await repository.save([a, b]);
      await repository.save([a]);
      await repository.save([]);
      expect(await repository.load(), unorderedEquals([a, b]));
      await expectLater(repository.save([a, a]), throwsFormatException);
      await expectLater(
        repository.save([_record('a', at: DateTime.utc(2027))]),
        throwsStateError,
      );
      expect(await repository.load(), unorderedEquals([a, b]));
    },
  );

  test('Timestamps preserve microseconds and chronological order', () async {
    final a = _record('a', at: DateTime.utc(2026, 10, 9));
    final b = _record(
      'b',
      at: a.createdAt.add(const Duration(microseconds: 1)),
    );
    await repository.save([b, a]);
    expect(await repository.load(), [b, a]);
  });

  test(
    'Parent/child constraints enforce 1:N, composite PK and cascade',
    () async {
      final detail = _record('detail', request: inputs[2]);
      await repository.save([detail, _record('other')]);
      final db = await inspect();
      try {
        final rows = await db.query('creation_parts', orderBy: 'position');
        expect(rows.map((r) => r['category']), ['Spoiler', 'Exhaust']);
        await expectLater(
          db.insert('creation_parts', rows.first),
          throwsA(isA<DatabaseException>()),
        );
        await expectLater(
          db.insert('creation_parts', {
            ...rows.first,
            'creation_id': 'missing',
          }),
          throwsA(isA<DatabaseException>()),
        );
        await expectLater(
          db.delete('vehicles', where: 'id = ?', whereArgs: ['porsche_911']),
          throwsA(isA<DatabaseException>()),
        );
        await db.delete('creations', where: 'id = ?', whereArgs: ['detail']);
        expect(await db.query('creation_parts'), isEmpty);
        expect((await db.query('creations')).single['id'], 'other');
      } finally {
        await db.close();
      }
    },
  );

  test(
    'SQL failure rolls back all new parents and child rows; retry works',
    () async {
      await repository.load();
      final db = await inspect();
      try {
        await db.execute(
          "CREATE TRIGGER reject_bad BEFORE INSERT ON creations WHEN NEW.id = 'bad' BEGIN SELECT RAISE(ABORT, 'test failure'); END",
        );
        final detail = _record('good', request: inputs[2]);
        await expectLater(
          repository.save([detail, _record('bad')]),
          throwsA(isA<DatabaseException>()),
        );
        expect(await repository.load(), isEmpty);
        expect(await db.query('creation_parts'), isEmpty);
        await db.execute('DROP TRIGGER reject_bad');
        await repository.save([detail]);
        expect(await repository.load(), [detail]);
      } finally {
        await db.close();
      }
    },
  );

  test(
    'Migration failure rolls back import and marker; original stays recoverable',
    () async {
      preferences.failRead = true;
      await expectLater(repository.load(), throwsStateError); // schema exists
      final db = await inspect();
      try {
        await db.execute(
          "CREATE TRIGGER reject_bad BEFORE INSERT ON creations WHEN NEW.id = 'bad' BEGIN SELECT RAISE(ABORT, 'test failure'); END",
        );
        preferences.failRead = false;
        final records = [_record('good', request: inputs[2]), _record('bad')];
        await CreationCacheManager(preferences).save(records);
        final original = preferences.values[SharedKeys.creations];
        await expectLater(repository.load(), throwsA(isA<DatabaseException>()));
        expect(await db.query('creations'), isEmpty);
        expect(await db.query('creation_parts'), isEmpty);
        expect(await db.query('migration_log'), isEmpty);
        expect(preferences.values[SharedKeys.creations], original);
        await db.execute('DROP TRIGGER reject_bad');
        expect(await repository.load(), unorderedEquals(records));
      } finally {
        await db.close();
      }
    },
  );

  testWidgets(
    'SQLite-backed Generate success survives app and database restart',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.runAsync(() async {
        await CreationCacheManager(preferences).save([
          _record('old-image'),
          _record('old-video', request: inputs.last),
        ]);
        await repository.load();
      });
      final service = ControlledGenerationService();
      await tester.pumpWidget(
        MyApp(
          historyRepository: repository,
          home: ModyHomeView(
            generationService: service,
            initialSelection: const GenerateSelection(
              vehicleId: 'porsche_911',
              style: 'Sportif',
            ),
          ),
        ),
      );
      final history = tester
          .element(find.byType(ModyHomeView))
          .read<CreationHistoryCubit>();
      await tester.runAsync(history.load);
      await tester.pumpAndSettle();
      final button = find.text('Arabamı Modifiye Et');
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pump();
      service.succeed();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('generationResultPage')), findsOneWidget);
      await tester.runAsync(() => history.pendingSave);
      expect(history.state.images, hasLength(2));
      expect(history.state.videos, hasLength(1));
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.runAsync(() async {
        await repository.close();
        repository = createRepository();
        await repository.load();
      });
      await tester.pumpWidget(
        MyApp(historyRepository: repository, home: const GarageView()),
      );
      final restored = tester
          .element(find.byType(GarageView))
          .read<CreationHistoryCubit>();
      await tester.runAsync(restored.load);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey("creation-count-Mody's")))
            .data,
        '2',
      );
      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('creation-count-Videolar')))
            .data,
        '1',
      );
      expect(restored.state.records, hasLength(3));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  test('Future database version is not downgraded or erased', () async {
    await repository.save([_record('keep')]);
    await repository.close();
    final db = await inspect();
    try {
      await db.setVersion(99);
    } finally {
      await db.close();
    }
    repository = createRepository();
    await expectLater(repository.load(), throwsA(anything));
    final after = await inspect();
    try {
      expect(await after.getVersion(), 99);
      expect((await after.query('creations')).single['id'], 'keep');
    } finally {
      await after.close();
    }
  });

  test(
    'Concurrent loads/saves keep distinct records without duplicate IDs',
    () async {
      await Future.wait([repository.load(), repository.load()]);
      await Future.wait([
        repository.save([_record('a')]),
        repository.save([_record('b')]),
      ]);
      expect(
        (await repository.load()).map((r) => r.id),
        unorderedEquals(['a', 'b']),
      );
      expect(preferences.reads, 1);
    },
  );
}
