import 'package:perasoft_staj/product/model/creation_record.dart';

/// Storage is injected; the history state has no preference/plugin dependency.
abstract interface class CreationRepository {
  Future<List<CreationRecord>> load();
  Future<void> save(List<CreationRecord> records);
}

/// Isolated previews/tests; the production entry point supplies device storage.
final class MemoryCreationRepository implements CreationRepository {
  List<CreationRecord> _records = const [];
  @override
  Future<List<CreationRecord>> load() async => _records;
  @override
  Future<void> save(List<CreationRecord> records) async {
    _records = List.unmodifiable(records);
  }
}
