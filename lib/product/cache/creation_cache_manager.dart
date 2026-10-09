import 'dart:convert';
import 'package:perasoft_staj/product/cache/creation_repository.dart';
import 'package:perasoft_staj/product/cache/shared_manager.dart';
import 'package:perasoft_staj/product/model/creation_record.dart';

/// Lesson #12: model conversion belongs in a dedicated cache manager.
/// Legacy preferences format, retained for one-time SQLite migration/tests.
final class CreationCacheManager implements CreationRepository {
  CreationCacheManager(this.sharedManager);
  final SharedManager sharedManager;

  @override
  Future<List<CreationRecord>> load() async {
    final text = await sharedManager.getString(SharedKeys.creations);
    if (text == null) return [];
    final data = jsonDecode(text);
    if (data is! Map<String, dynamic> ||
        data['version'] != 1 ||
        data['records'] is! List) {
      throw const FormatException('Geçmiş biçimi desteklenmiyor');
    }
    final records = <CreationRecord>[];
    final ids = <String>{};
    for (final item in data['records'] as List) {
      if (item is! Map<String, dynamic>) {
        throw const FormatException('Geçersiz kayıt');
      }
      final record = CreationRecord.fromJson(item);
      if (!ids.add(record.id)) throw const FormatException('Tekrarlanan kayıt');
      records.add(record);
    }
    return records;
  }

  @override
  Future<void> save(List<CreationRecord> records) => sharedManager.saveString(
    SharedKeys.creations,
    jsonEncode({
      'version': 1,
      'records': records.map((r) => r.toJson()).toList(),
    }),
  );
}
