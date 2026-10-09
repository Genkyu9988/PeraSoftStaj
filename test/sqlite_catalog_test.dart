import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:perasoft_staj/main.dart';
import 'package:perasoft_staj/product/cache/creation_repository.dart';
import 'package:perasoft_staj/product/cache/shared_manager.dart';
import 'package:perasoft_staj/product/cache/sqlite_creation_repository.dart';
import 'package:perasoft_staj/product/cache/sqlite_selection_repository.dart';
import 'package:perasoft_staj/product/catalog/catalog_store.dart';
import 'package:perasoft_staj/product/catalog/car_mod_option.dart';
import 'package:perasoft_staj/product/catalog/detail_part_catalog.dart';
import 'package:perasoft_staj/product/catalog/vehicle_catalog.dart';
import 'package:perasoft_staj/product/constants/image_items.dart';
import 'package:perasoft_staj/product/model/app_selections.dart';
import 'package:perasoft_staj/product/model/generate_selection.dart';
import 'package:perasoft_staj/product/model/creation_record.dart';
import 'package:perasoft_staj/product/model/explore_operation.dart';
import 'package:perasoft_staj/product/model/generation_request.dart';
import 'package:perasoft_staj/product/model/generation_result.dart';
import 'package:perasoft_staj/product/service/generation/generation_input_resolver.dart';
import 'package:perasoft_staj/product/widget/vehicle_selection_panel.dart';
import 'package:perasoft_staj/product/widget/mody_asset_image.dart';
import 'package:perasoft_staj/feature/generate/view/widget/detail_adjustment_panel.dart';
import 'helpers/sqlite_v1_fixture.dart';

class _Legacy extends SharedManager {
  String? value;
  int reads = 0;
  @override
  Future<String?> getString(SharedKeys key) async {
    reads++;
    return value;
  }

  @override
  Future<void> saveString(SharedKeys key, String value) async {
    throw StateError('Production must not write preferences');
  }
}

CreationRecord record(
  String id, {
  String vehicle = 'porsche_911',
  bool detail = false,
}) {
  final request = GenerationRequest(
    mode: detail ? GenerateMode.detailEdit : GenerateMode.customEdit,
    vehicleId: vehicle,
    description: 'Test',
    angle: detail ? 'Rear' : '',
    parts: detail ? {'Spoiler': 0} : {},
  );
  return CreationRecord(
    id: id,
    createdAt: DateTime.utc(2026, 10, 9),
    result: DemoGenerationResult(
      request: request,
      originalImagePath: VehicleCatalog.find(vehicle)!.imagePath,
    ),
  );
}

void main() {
  sqfliteFfiInit();
  late Directory temp;
  late String dbPath;
  late SqliteCreationRepository store;
  late _Legacy legacy;
  SqliteCreationRepository open() => SqliteCreationRepository(
    legacyRepository: MemoryCreationRepository(),
    factory: databaseFactoryFfi,
    databasePath: dbPath,
  );
  Future<void> reopen() async {
    await store.close();
    store = open();
    await store.database;
  }

  setUp(() async {
    CatalogStore.resetForTests();
    temp = await Directory.systemTemp.createTemp('modyai_catalog_test_');
    dbPath = '${temp.path}/modyai.db';
    store = open();
    legacy = _Legacy();
  });
  tearDown(() async {
    await store.close();
    CatalogStore.resetForTests();
    final parent = Directory.systemTemp.absolute.path;
    if (temp.absolute.path.startsWith(
      '$parent${Platform.pathSeparator}modyai_catalog_test_',
    )) {
      await temp.delete(recursive: true);
    }
  });

  test('Production cannot read seeds before SQLite loads', () async {
    CatalogStore.requireDatabase = true;
    expect(() => VehicleCatalog.all, throwsStateError);
    await store.database;
    expect(VehicleCatalog.all, hasLength(12));
    expect(CarModCatalog.groups['Spoiler'], hasLength(3));
    expect(DetailPartCatalog.forAngle('Rear').first.options, hasLength(3));
    expect(ImageItems.aiVideoCovers, ImageItems.seedAiVideoCovers);
  });

  test(
    'v1 to v2 migration preserves history, child identity and marker',
    () async {
      await createSqliteV1(dbPath);
      final history = await store.load();
      final db = await store.database;
      expect(await db.getVersion(), 2);
      expect(history.single.id, 'v1-history');
      expect((history.single.result.request as GenerationRequest).parts, {
        'Spoiler': 0,
      });
      expect(await db.rawQuery('PRAGMA foreign_key_check'), isEmpty);
      expect(await db.query('creation_parts'), hasLength(1));
      expect(
        (await db.query('migration_log')).single['completed_at_utc'],
        '2026-10-08T00:00:00.000Z',
      );
      await reopen();
      expect(await store.load(), history);
      expect(await (await store.database).query('vehicles'), hasLength(12));
    },
  );

  test(
    'failed v1 upgrade rolls back schema and retains original rows',
    () async {
      await createSqliteV1(dbPath, invalidSlot: true);
      await expectLater(store.database, throwsA(isA<DatabaseException>()));
      final raw = await databaseFactoryFfi.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(singleInstance: false),
      );
      try {
        expect(await raw.getVersion(), 1);
        expect(
          (await raw.query('creation_parts')).single['selected_index'],
          99,
        );
        expect(
          await raw.query(
            'sqlite_master',
            where: 'name=?',
            whereArgs: ['parts'],
          ),
          isEmpty,
        );
        expect(await raw.query('creations'), hasLength(1));
      } finally {
        await raw.close();
      }
    },
  );

  test(
    'SQL-only vehicle is restored, resolved, saved and not overwritten on restart',
    () async {
      final db = await store.database;
      await db.insert('vehicles', {
        'id': 'sql_car',
        'label': 'SQL Araba',
        'asset_path': 'assets/images/sport.jpg',
        'position': -1,
        'sample_position': 5,
      });
      await reopen();
      expect(VehicleCatalog.all.first.id, 'sql_car');
      expect(VehicleCatalog.samples.last.id, 'sql_car');
      final created = record('sql-result', vehicle: 'sql_car');
      await store.save([created]);
      final settings = SqliteSelectionRepository(store, legacy);
      expect(
        await settings.save(
          AppSelections(
            generate: const GenerateSelection(vehicleId: 'sql_car'),
          ),
        ),
        isTrue,
      );
      await reopen();
      expect(await store.load(), [created]);
      expect(
        (await SqliteSelectionRepository(
          store,
          legacy,
        ).load()).generate.vehicleId,
        'sql_car',
      );
    },
  );

  Future<void> addSpoiler() async {
    final db = await store.database;
    await db.transaction((txn) async {
      await txn.insert('parts', {
        'id': 'spoiler.sql',
        'asset_path': 'assets/images/spoiler.jpg',
      });
      await txn.insert('detail_part_options', {
        'category_id': 'Spoiler',
        'slot': 3,
        'part_id': 'spoiler.sql',
      });
      await txn.insert('mod_options', {
        'operation': 'Spoiler',
        'part_id': 'spoiler.sql',
        'position': 3,
        'label': 'SQL Spoiler',
        'instruction': 'Use SQL spoiler',
        'legacy_name': '',
      });
    });
    await reopen();
  }

  test(
    'SQL-only spoiler is usable in Detail Edit and Explore after restart',
    () async {
      await addSpoiler();
      expect(
        DetailPartCatalog.forAngle('Rear').first.options.last.id,
        'spoiler.sql',
      );
      final plan = const GenerationInputResolver().resolve(
        GenerationRequest(
          mode: GenerateMode.detailEdit,
          vehicleId: 'porsche_911',
          angle: 'Rear',
          parts: {'Spoiler': 3},
        ),
      );
      expect(plan.parts.single.reference.id, 'spoiler.sql');
      final explore = const GenerationInputResolver().resolve(
        ExploreGenerationRequest(
          operation: ExploreOperation.spoiler,
          vehicleId: 'porsche_911',
          optionId: 'spoiler.sql',
        ),
      );
      expect(explore.option!.instruction, 'Use SQL spoiler');
      final created = CreationRecord(
        id: 'new-part',
        createdAt: DateTime.utc(2026),
        result: DemoGenerationResult(
          request: plan.request,
          originalImagePath: plan.vehicle.assetPath,
        ),
      );
      await store.save([created]);
      await reopen();
      expect(await store.load(), [created]);
    },
  );

  test(
    'Existing part slots cannot be reassigned and used options cannot be deleted',
    () async {
      final db = await store.database;
      await store.save([record('detail', detail: true)]);
      await expectLater(
        db.update(
          'detail_part_options',
          {'part_id': 'spoiler.sport_wing'},
          where: 'category_id=? AND slot=?',
          whereArgs: ['Spoiler', 0],
        ),
        throwsA(isA<DatabaseException>()),
      );
      await expectLater(
        db.delete(
          'detail_part_options',
          where: 'category_id=? AND slot=?',
          whereArgs: ['Spoiler', 0],
        ),
        throwsA(isA<DatabaseException>()),
      );
      expect(await db.rawQuery('PRAGMA foreign_key_check'), isEmpty);
    },
  );

  test(
    'Editing catalog photo does not invalidate old history snapshot',
    () async {
      final db = await store.database;
      final old = record('old');
      await store.save([old]);
      await db.update(
        'vehicles',
        {'asset_path': 'assets/images/race.jpg'},
        where: 'id=?',
        whereArgs: ['porsche_911'],
      );
      await reopen();
      expect(await store.load(), [old]);
      final next = record('next');
      await store.save([old, next]);
      expect(
        (await store.load()).map((r) => r.result.originalImagePath).toSet(),
        {'assets/images/sport.jpg', 'assets/images/race.jpg'},
      );
    },
  );

  test(
    'Settings import once, preserve raw legacy and serialize fast saves',
    () async {
      legacy.value = jsonEncode(
        AppSelections(
          generate: const GenerateSelection(
            vehicleId: 'porsche_911',
            style: 'Sportif',
          ),
        ).toJson(),
      );
      final original = legacy.value;
      var settings = SqliteSelectionRepository(store, legacy);
      expect((await settings.load()).generate.style, 'Sportif');
      final saves = <Future<bool>>[];
      for (final style in ['Klasik', 'SUV', 'Şehir']) {
        saves.add(
          settings.save(
            AppSelections(generate: GenerateSelection(style: style)),
          ),
        );
      }
      expect(await Future.wait(saves), everyElement(isTrue));
      expect(legacy.value, original);
      expect(legacy.reads, 1);
      legacy.value = '{broken';
      await reopen();
      settings = SqliteSelectionRepository(store, legacy);
      expect((await settings.load()).generate.style, 'Şehir');
      expect(legacy.reads, 1);
    },
  );

  test(
    'Malformed legacy selections do not get marked, retry preserves recovery',
    () async {
      legacy.value = '{broken';
      final settings = SqliteSelectionRepository(store, legacy);
      await expectLater(settings.load(), throwsFormatException);
      final db = await store.database;
      expect(await db.query('app_settings'), isEmpty);
      expect(
        await db.query(
          'migration_log',
          where: 'migration_key=?',
          whereArgs: [SqliteSelectionRepository.migrationKey],
        ),
        isEmpty,
      );
      expect(legacy.value, '{broken');
      legacy.value = '{}';
      await settings.load();
      expect(await db.query('app_settings'), hasLength(1));
    },
  );

  test(
    'Catalog corruption fails explicitly instead of silently using seed content',
    () async {
      final db = await store.database;
      await db.update(
        'catalog_entries',
        {'value_json': 'not-json'},
        where: 'section_id=?',
        whereArgs: ['image_items.aiVideoCovers'],
      );
      await store.close();
      store = open();
      await expectLater(store.database, throwsFormatException);
    },
  );

  test(
    'SQL covers and lists are source of truth including empty lists',
    () async {
      final db = await store.database;
      await db.update(
        'catalog_entries',
        {'value_json': jsonEncode('assets/images/race.jpg')},
        where: 'section_id=? AND entry_key=?',
        whereArgs: ['image_items.aiVideoCovers', 'Cliff Fly'],
      );
      await db.delete(
        'catalog_entries',
        where: 'section_id=?',
        whereArgs: ['ai_video_items.filters'],
      );
      await reopen();
      expect(ImageItems.aiVideoCovers['Cliff Fly'], 'assets/images/race.jpg');
    },
  );

  testWidgets(
    'SQL-only vehicle appears and is selectable in actual vehicle panel',
    (tester) async {
      await tester.runAsync(() async {
        final db = await store.database;
        await db.insert('vehicles', {
          'id': 'sql_ui',
          'label': 'SQL Araba',
          'asset_path': 'assets/images/sport.jpg',
          'position': -1,
        });
        await reopen();
      });
      String? selected;
      await tester.pumpWidget(
        MyApp(
          home: Scaffold(
            body: SizedBox(
              height: 550,
              child: VehicleSelectionPanel(
                selected: '',
                onSelected: (id) => selected = id,
                onApply: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('SQL Araba'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('vehicle-sql_ui')));
      expect(selected, 'sql_ui');
    },
  );

  testWidgets('SQL-only spoiler appears in the actual Detail Edit panel', (
    tester,
  ) async {
    await tester.runAsync(addSpoiler);
    final spoiler = DetailPartCatalog.forAngle('Rear').first;
    await tester.pumpWidget(
      MyApp(
        home: Scaffold(
          body: SizedBox(
            height: 500,
            child: DetailAdjustmentPanel(
              categories: [spoiler],
              selections: const {},
              onSelected: (_, _) {},
              onApply: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(spoiler.options, hasLength(4));
    expect(find.byType(ModyAssetImage), findsNWidgets(4));
  });
}
