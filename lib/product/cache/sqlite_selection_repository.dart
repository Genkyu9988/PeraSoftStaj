import 'dart:convert';
import 'package:perasoft_staj/product/model/app_selections.dart';
import 'selection_repository.dart';
import 'shared_manager.dart';
import 'sqlite_creation_repository.dart';

/// Preferences are a read-only migration source, never a runtime write target.
class SqliteSelectionRepository implements SelectionRepository {
  SqliteSelectionRepository(this.store, this.legacy);
  final SqliteCreationRepository store;
  final SharedManager legacy;
  static const migrationKey = 'shared_preferences_selections_v2';
  Future<void> _pendingSave = Future.value();

  Map<String, dynamic> _decode(String text) {
    final value = jsonDecode(text);
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Invalid selections');
    }
    return value;
  }

  Future<void> _migrate() async {
    final db = await store.database;
    final marker = await db.query(
      'migration_log',
      where: 'migration_key = ?',
      whereArgs: [migrationKey],
    );
    if (marker.isNotEmpty) return;
    final text = await legacy.getString(SharedKeys.selections);
    if (text != null) _decode(text); // Don't mark malformed data as migrated.
    await db.transaction((txn) async {
      final again = await txn.query(
        'migration_log',
        where: 'migration_key = ?',
        whereArgs: [migrationKey],
      );
      if (again.isNotEmpty) return;
      final existing = await txn.query(
        'app_settings',
        where: 'key = ?',
        whereArgs: ['selections'],
      );
      if (existing.isEmpty) {
        await txn.insert('app_settings', {
          'key': 'selections',
          'value_json': text ?? jsonEncode(AppSelections().toJson()),
        });
      }
      await txn.insert('migration_log', {
        'migration_key': migrationKey,
        'completed_at_utc': DateTime.now().toUtc().toIso8601String(),
      });
    });
  }

  @override
  Future<AppSelections> load() async {
    await _migrate();
    final db = await store.database;
    final rows = await db.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: ['selections'],
    );
    if (rows.length != 1) throw const FormatException('Missing selections');
    return AppSelections.fromJson(
      _decode(rows.single['value_json']! as String),
    );
  }

  @override
  Future<bool> save(AppSelections selections) {
    final text = jsonEncode(selections.toJson());
    final operation = _pendingSave.then((_) async {
      try {
        await _migrate();
        final db = await store.database;
        final count = await db.update(
          'app_settings',
          {'value_json': text},
          where: 'key = ?',
          whereArgs: ['selections'],
        );
        return count == 1;
      } catch (_) {
        return false;
      }
    });
    _pendingSave = operation.then((_) {});
    return operation;
  }
}
