import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:perasoft_staj/product/catalog/vehicle_catalog.dart';

/// The shipped v1 schema, deliberately independent of the current migration.
Future<void> createSqliteV1(String path, {bool invalidSlot = false}) async {
  final db = await databaseFactoryFfi.openDatabase(
    path,
    options: OpenDatabaseOptions(
      version: 1,
      singleInstance: false,
      onCreate: (db, version) async {
        await db.execute(
          '''CREATE TABLE vehicles (
        id TEXT NOT NULL PRIMARY KEY CHECK(length(id)>0), label TEXT NOT NULL, asset_path TEXT NOT NULL)''',
        );
        await db.execute(
          '''CREATE TABLE creations (
        id TEXT NOT NULL PRIMARY KEY CHECK(length(id)>0),
        vehicle_id TEXT NOT NULL REFERENCES vehicles(id) ON DELETE RESTRICT,
        created_at_us INTEGER NOT NULL, kind TEXT NOT NULL CHECK(kind='demo'),
        original_image_path TEXT NOT NULL, request_type TEXT NOT NULL
          CHECK(request_type IN ('generate','explore','video')),
        mode TEXT NOT NULL DEFAULT '',style TEXT NOT NULL DEFAULT '',extra TEXT NOT NULL DEFAULT '',
        color TEXT NOT NULL DEFAULT '',angle TEXT NOT NULL DEFAULT '',description TEXT NOT NULL DEFAULT '',
        operation TEXT NOT NULL DEFAULT '',option_id TEXT NOT NULL DEFAULT '',
        reference_id TEXT NOT NULL DEFAULT '',template TEXT NOT NULL DEFAULT '')''',
        );
        await db.execute(
          '''CREATE TABLE creation_parts (
        creation_id TEXT NOT NULL REFERENCES creations(id) ON DELETE CASCADE,
        category TEXT NOT NULL CHECK(length(category)>0),selected_index INTEGER NOT NULL CHECK(selected_index>=0),
        position INTEGER NOT NULL CHECK(position>=0),PRIMARY KEY(creation_id,category),UNIQUE(creation_id,position))''',
        );
        await db.execute(
          'CREATE TABLE migration_log (migration_key TEXT NOT NULL PRIMARY KEY,completed_at_utc TEXT NOT NULL)',
        );
        for (final vehicle in VehicleCatalog.seedAll) {
          await db.insert('vehicles', {
            'id': vehicle.id,
            'label': vehicle.label,
            'asset_path': vehicle.imagePath,
          });
        }
        await db.insert('creations', {
          'id': 'v1-history',
          'vehicle_id': 'porsche_911',
          'created_at_us': DateTime.utc(2026, 10, 8).microsecondsSinceEpoch,
          'kind': 'demo',
          'original_image_path': 'assets/images/sport.jpg',
          'request_type': 'generate',
          'mode': 'detailEdit',
          'angle': 'Rear',
        });
        await db.insert('creation_parts', {
          'creation_id': 'v1-history',
          'category': 'Spoiler',
          'selected_index': invalidSlot ? 99 : 0,
          'position': 0,
        });
        await db.insert('migration_log', {
          'migration_key': 'shared_preferences_creations_v1',
          'completed_at_utc': '2026-10-08T00:00:00.000Z',
        });
      },
    ),
  );
  await db.close();
}
