import 'package:perasoft_staj/product/catalog/catalog_codec.dart';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:perasoft_staj/product/catalog/catalog_store.dart';
import 'package:perasoft_staj/product/catalog/vehicle_catalog.dart';
import 'package:perasoft_staj/product/catalog/detail_part_catalog.dart';
import 'package:perasoft_staj/product/catalog/car_mod_option.dart';
import 'package:perasoft_staj/product/catalog/reference_car_catalog.dart';

/// Versioned seed data is used only by schema migrations. Opening the app never
/// upserts seed rows over the user's catalog edits.
class SqliteCatalog {
  static final seedSections = CatalogCodec.seedSections;

  static Future<void> create(DatabaseExecutor db) async {
    await db.execute(
      'ALTER TABLE vehicles ADD COLUMN position INTEGER NOT NULL DEFAULT 0',
    );
    await db.execute('ALTER TABLE vehicles ADD COLUMN sample_position INTEGER');
    for (var i = 0; i < VehicleCatalog.seedAll.length; i++) {
      final vehicle = VehicleCatalog.seedAll[i];
      final sample = VehicleCatalog.seedSamples.indexWhere(
        (v) => v.id == vehicle.id,
      );
      await db.update(
        'vehicles',
        {'position': i, 'sample_position': sample < 0 ? null : sample},
        where: 'id = ?',
        whereArgs: [vehicle.id],
      );
    }
    await db.execute('''CREATE TABLE part_categories (
      id TEXT PRIMARY KEY NOT NULL, position INTEGER NOT NULL UNIQUE)''');
    await db.execute('''CREATE TABLE parts (
      id TEXT PRIMARY KEY NOT NULL CHECK(length(id)>0),
      asset_path TEXT NOT NULL CHECK(length(asset_path)>0))''');
    await db.execute('''CREATE TABLE detail_part_options (
      category_id TEXT NOT NULL REFERENCES part_categories(id) ON DELETE RESTRICT,
      slot INTEGER NOT NULL CHECK(slot>=0),
      part_id TEXT NOT NULL REFERENCES parts(id) ON DELETE RESTRICT,
      PRIMARY KEY(category_id, slot), UNIQUE(category_id, part_id))''');
    await db.execute(
      '''CREATE TABLE angle_categories (
      angle TEXT NOT NULL, category_id TEXT NOT NULL REFERENCES part_categories(id),
      position INTEGER NOT NULL, PRIMARY KEY(angle, category_id), UNIQUE(angle, position))''',
    );
    await db.execute('''CREATE TABLE mod_options (
      operation TEXT NOT NULL, part_id TEXT NOT NULL REFERENCES parts(id),
      position INTEGER NOT NULL, label TEXT NOT NULL, instruction TEXT NOT NULL,
      legacy_name TEXT NOT NULL DEFAULT '', PRIMARY KEY(operation, part_id),
      UNIQUE(operation, position))''');
    await db.execute('''CREATE TABLE reference_cars (
      id TEXT PRIMARY KEY NOT NULL, label TEXT NOT NULL, asset_path TEXT NOT NULL,
      position INTEGER NOT NULL UNIQUE)''');
    await db.execute('''CREATE TABLE catalog_sections (
      id TEXT PRIMARY KEY NOT NULL, value_type TEXT NOT NULL
      CHECK(value_type IN ('list','strings','integers')))''');
    await db.execute('''CREATE TABLE catalog_entries (
      section_id TEXT NOT NULL REFERENCES catalog_sections(id) ON DELETE RESTRICT,
      entry_key TEXT NOT NULL, position INTEGER NOT NULL,
      value_json TEXT NOT NULL, PRIMARY KEY(section_id, entry_key),
      UNIQUE(section_id, position))''');
    await db.execute('''CREATE TABLE app_settings (
      key TEXT PRIMARY KEY NOT NULL, value_json TEXT NOT NULL)''');

    final partPaths = <String, String>{};
    for (var i = 0; i < DetailPartCatalog.seedAll.length; i++) {
      final category = DetailPartCatalog.seedAll[i];
      await db.insert('part_categories', {'id': category.title, 'position': i});
      for (final part in category.options) {
        partPaths[part.id] = part.assetPath;
      }
    }
    for (final group in CarModCatalog.seedGroups.values) {
      for (final part in group) {
        if (partPaths.containsKey(part.id) &&
            partPaths[part.id] != part.imagePath) {
          throw StateError('Conflicting seed part ${part.id}');
        }
        partPaths[part.id] = part.imagePath;
      }
    }
    for (final part in partPaths.entries) {
      await db.insert('parts', {'id': part.key, 'asset_path': part.value});
    }
    for (final category in DetailPartCatalog.seedAll) {
      for (var i = 0; i < category.options.length; i++) {
        await db.insert('detail_part_options', {
          'category_id': category.title,
          'slot': i,
          'part_id': category.options[i].id,
        });
      }
    }
    for (final angle in DetailPartCatalog.seedByAngle.entries) {
      for (var i = 0; i < angle.value.length; i++) {
        await db.insert('angle_categories', {
          'angle': angle.key,
          'category_id': angle.value[i].title,
          'position': i,
        });
      }
    }
    for (final group in CarModCatalog.seedGroups.entries) {
      for (var i = 0; i < group.value.length; i++) {
        final option = group.value[i];
        await db.insert('mod_options', {
          'operation': group.key,
          'part_id': option.id,
          'position': i,
          'label': option.label,
          'instruction': option.instruction,
          'legacy_name': option.legacyName,
        });
      }
    }
    for (var i = 0; i < ReferenceCarCatalog.seedItems.length; i++) {
      final item = ReferenceCarCatalog.seedItems[i];
      await db.insert('reference_cars', {
        'id': item.id,
        'label': item.label,
        'asset_path': item.imagePath,
        'position': i,
      });
    }
    for (final section in seedSections.entries) {
      final value = section.value;
      final type = value is List
          ? 'list'
          : value is Map<String, int>
          ? 'integers'
          : 'strings';
      await db.insert('catalog_sections', {
        'id': section.key,
        'value_type': type,
      });
      final entries = value is List
          ? {for (var i = 0; i < value.length; i++) '$i': value[i]}
          : value as Map;
      var position = 0;
      for (final entry in entries.entries) {
        await db.insert('catalog_entries', {
          'section_id': section.key,
          'entry_key': entry.key,
          'position': position++,
          'value_json': jsonEncode(entry.value),
        });
      }
    }
    // Old indices become stable FK-backed slots. They must never be reordered
    // or reused; adding a new option appends a new slot.
    await db.execute('ALTER TABLE creation_parts RENAME TO creation_parts_v1');
    await db.execute('''CREATE TABLE creation_parts (
      creation_id TEXT NOT NULL REFERENCES creations(id) ON DELETE CASCADE,
      category TEXT NOT NULL, selected_index INTEGER NOT NULL,
      position INTEGER NOT NULL CHECK(position>=0),
      PRIMARY KEY(creation_id, category), UNIQUE(creation_id, position),
      FOREIGN KEY(category,selected_index) REFERENCES detail_part_options(category_id,slot)
        ON DELETE RESTRICT ON UPDATE RESTRICT)''');
    await db.execute(
      'INSERT INTO creation_parts SELECT * FROM creation_parts_v1',
    );
    await db.execute('DROP TABLE creation_parts_v1');
    await db.execute(
      '''CREATE TRIGGER stable_detail_slots BEFORE UPDATE OF category_id,slot,part_id
      ON detail_part_options BEGIN SELECT RAISE(ABORT, 'Detail slots are immutable'); END''',
    );
  }

  static Future<Map<String, dynamic>> exportTables(
    DatabaseExecutor db,
  ) async => {
    'schemaVersion': 2,
    'tables': {
      'vehicles': await db.rawQuery(
        'SELECT * FROM vehicles ORDER BY position,id',
      ),
      'part_categories': await db.rawQuery(
        'SELECT * FROM part_categories ORDER BY position',
      ),
      'angle_categories': await db.rawQuery(
        'SELECT * FROM angle_categories ORDER BY position',
      ),
      'reference_cars': await db.rawQuery(
        'SELECT * FROM reference_cars ORDER BY position',
      ),
      'catalog_sections': await db.rawQuery(
        'SELECT * FROM catalog_sections ORDER BY id',
      ),
      'catalog_entries': await db.rawQuery(
        'SELECT * FROM catalog_entries ORDER BY position',
      ),
      'detail_part_options': await db.rawQuery(
        'SELECT d.*,p.asset_path FROM detail_part_options d JOIN parts p ON p.id=d.part_id ORDER BY d.category_id,d.slot',
      ),
      'mod_options': await db.rawQuery(
        'SELECT m.*,p.asset_path FROM mod_options m JOIN parts p ON p.id=m.part_id ORDER BY m.operation,m.position',
      ),
    },
  };

  static Future<Map<String, Object>> read(DatabaseExecutor db) async =>
      CatalogCodec.decode(await exportTables(db));

  static Future<void> install(Database db) async {
    final snapshot = await db.transaction(read);
    CatalogStore.install(snapshot);
  }
}
