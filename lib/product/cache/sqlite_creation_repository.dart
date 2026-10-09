import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:perasoft_staj/product/cache/creation_repository.dart';
import 'package:perasoft_staj/product/catalog/vehicle_catalog.dart';
import 'package:perasoft_staj/product/model/creation_record.dart';
import 'sqlite_catalog.dart';

/// Local, append-only demo history. Preferences are read once for migration;
/// the original preferences value is retained as a recovery copy.
final class SqliteCreationRepository implements CreationRepository {
  SqliteCreationRepository({
    required CreationRepository legacyRepository,
    DatabaseFactory? factory,
    String? databasePath,
  }) : _legacy = legacyRepository,
       _factory = factory ?? databaseFactory,
       _path = databasePath;

  static const fileName = 'modyai.db';
  static const schemaVersion = 2;
  static const migrationKey = 'shared_preferences_creations_v1';
  final CreationRepository _legacy;
  final DatabaseFactory _factory;
  final String? _path;
  Future<Database>? _opening;
  bool _closed = false;

  /// One connection shared by catalog, settings and history repositories.
  Future<Database> get database => _database();

  Future<Database> _database() {
    if (_closed) throw StateError('Repository is closed');
    return _opening ??= _open().catchError((Object error, StackTrace stack) {
      // A read/open/migration error can be retried via the existing UI.
      _opening = null;
      Error.throwWithStackTrace(error, stack);
    });
  }

  Future<Database> _open() async {
    final location =
        _path ?? path.join(await _factory.getDatabasesPath(), fileName);
    final db = await _factory.openDatabase(
      location,
      options: OpenDatabaseOptions(
        version: schemaVersion,
        singleInstance: false,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: _createSchema,
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) await SqliteCatalog.create(db);
        },
        onDowngrade: (db, oldVersion, newVersion) async {
          throw StateError('Unsupported database version: $oldVersion');
        },
      ),
    );
    try {
      await SqliteCatalog.install(db);
      final completed = await db.query(
        'migration_log',
        where: 'migration_key = ?',
        whereArgs: [migrationKey],
      );
      if (completed.isEmpty) {
        // Validate everything before any record is inserted. Never silently
        // replace unreadable legacy data with an empty database.
        final legacy = _validated(await _legacy.load());
        await db.transaction((txn) async {
          final alreadyMigrated = await txn.query(
            'migration_log',
            where: 'migration_key = ?',
            whereArgs: [migrationKey],
          );
          if (alreadyMigrated.isNotEmpty) return;
          await _append(txn, legacy);
          await txn.insert('migration_log', {
            'migration_key': migrationKey,
            'completed_at_utc': DateTime.now().toUtc().toIso8601String(),
          });
        });
      }
      return db;
    } catch (_) {
      await db.close();
      rethrow;
    }
  }

  static Future<void> _createSchema(Database db, int version) async {
    await db.execute('''
      CREATE TABLE vehicles (
        id TEXT NOT NULL PRIMARY KEY CHECK(length(id) > 0),
        label TEXT NOT NULL,
        asset_path TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE creations (
        id TEXT NOT NULL PRIMARY KEY CHECK(length(id) > 0),
        vehicle_id TEXT NOT NULL REFERENCES vehicles(id) ON DELETE RESTRICT,
        created_at_us INTEGER NOT NULL,
        kind TEXT NOT NULL CHECK(kind = 'demo'),
        original_image_path TEXT NOT NULL,
        request_type TEXT NOT NULL
          CHECK(request_type IN ('generate', 'explore', 'video')),
        mode TEXT NOT NULL DEFAULT '',
        style TEXT NOT NULL DEFAULT '',
        extra TEXT NOT NULL DEFAULT '',
        color TEXT NOT NULL DEFAULT '',
        angle TEXT NOT NULL DEFAULT '',
        description TEXT NOT NULL DEFAULT '',
        operation TEXT NOT NULL DEFAULT '',
        option_id TEXT NOT NULL DEFAULT '',
        reference_id TEXT NOT NULL DEFAULT '',
        template TEXT NOT NULL DEFAULT ''
      )
    ''');
    await db.execute('''
      CREATE TABLE creation_parts (
        creation_id TEXT NOT NULL REFERENCES creations(id) ON DELETE CASCADE,
        category TEXT NOT NULL CHECK(length(category) > 0),
        selected_index INTEGER NOT NULL CHECK(selected_index >= 0),
        position INTEGER NOT NULL CHECK(position >= 0),
        PRIMARY KEY (creation_id, category),
        UNIQUE (creation_id, position)
      )
    ''');
    await db.execute('''
      CREATE TABLE migration_log (
        migration_key TEXT NOT NULL PRIMARY KEY,
        completed_at_utc TEXT NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX creations_vehicle_idx ON creations(vehicle_id)',
    );
    await db.execute(
      'CREATE INDEX creations_type_date_idx ON creations(request_type, created_at_us)',
    );
    await db.execute(
      'CREATE INDEX creations_date_idx ON creations(created_at_us)',
    );
    final batch = db.batch();
    for (final vehicle in VehicleCatalog.seedAll) {
      batch.insert('vehicles', {
        'id': vehicle.id,
        'label': vehicle.label,
        'asset_path': vehicle.imagePath,
      });
    }
    await batch.commit(noResult: true);
    await SqliteCatalog.create(db);
  }

  @override
  Future<List<CreationRecord>> load() async {
    final db = await _database();
    // Parent and child rows are read from a single consistent snapshot.
    return db.transaction(_read);
  }

  @override
  Future<void> save(List<CreationRecord> records) async {
    final db = await _database();
    final validated = _validated(records);
    await db.transaction((txn) => _append(txn, validated));
  }

  static List<CreationRecord> _validated(List<CreationRecord> records) {
    final ids = <String>{};
    return [
      for (final record in records)
        if (ids.add(record.id))
          CreationRecord.fromJson(record.toJson(), validateCatalog: false)
        else
          throw const FormatException('Duplicate creation ID'),
    ];
  }

  static Future<void> _append(
    Transaction txn,
    List<CreationRecord> records,
  ) async {
    final existing = {for (final r in await _read(txn)) r.id: r};
    final batch = txn.batch();
    for (final record in records) {
      final previous = existing[record.id];
      if (previous != null) {
        if (previous != record) {
          throw StateError('An immutable history ID has different contents');
        }
        continue;
      }
      // Existing history is a snapshot. Only NEW writes must match today's
      // catalog; changing a catalog photo must not break older results.
      CreationRecord.fromJson(record.toJson());
      final json = record.toJson();
      final input = json['input']! as Map<String, Object?>;
      batch.insert('creations', {
        'id': record.id,
        'vehicle_id': record.vehicleId,
        'created_at_us': record.createdAt.microsecondsSinceEpoch,
        'kind': json['kind'],
        'original_image_path': json['originalImagePath'],
        'request_type': input['type'],
        for (final key in _directFields) key: input[key] ?? '',
        'option_id': input['optionId'] ?? '',
        'reference_id': input['referenceId'] ?? '',
      });
      final parts = input['parts'] as Map<String, int>? ?? const {};
      var position = 0;
      for (final part in parts.entries) {
        batch.insert('creation_parts', {
          'creation_id': record.id,
          'category': part.key,
          'selected_index': part.value,
          'position': position++,
        });
      }
    }
    // No REPLACE or delete-all: a stale snapshot cannot erase newer history.
    await batch.commit(noResult: true);
  }

  static const _directFields = [
    'mode',
    'style',
    'extra',
    'color',
    'angle',
    'description',
    'operation',
    'template',
  ];

  static Future<List<CreationRecord>> _read(Transaction txn) async {
    final rows = await txn.query(
      'creations',
      orderBy: 'created_at_us DESC, id DESC',
    );
    final parts = await txn.query('creation_parts', orderBy: 'position ASC');
    final byCreation = <String, Map<String, int>>{};
    for (final part in parts) {
      (byCreation[part['creation_id']! as String] ??= {})[part['category']!
              as String] =
          part['selected_index']! as int;
    }
    return [
      for (final row in rows)
        CreationRecord.fromJson({
          'id': row['id'],
          'createdAt': DateTime.fromMicrosecondsSinceEpoch(
            row['created_at_us']! as int,
            isUtc: true,
          ).toIso8601String(),
          'kind': row['kind'],
          'originalImagePath': row['original_image_path'],
          'input': <String, dynamic>{
            'type': row['request_type'],
            'vehicleId': row['vehicle_id'],
            for (final key in _directFields) key: row[key],
            'optionId': row['option_id'],
            'referenceId': row['reference_id'],
            'parts': byCreation[row['id']] ?? <String, int>{},
          },
        }, validateCatalog: false),
    ];
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    final opening = _opening;
    if (opening != null) await (await opening).close();
  }
}
