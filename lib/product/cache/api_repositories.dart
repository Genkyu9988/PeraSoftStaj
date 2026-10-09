import 'dart:convert';
import 'package:perasoft_staj/product/service/backend/mody_api_client.dart';
import 'package:perasoft_staj/product/model/creation_record.dart';
import 'package:perasoft_staj/product/model/app_selections.dart';
import 'creation_repository.dart';
import 'selection_repository.dart';

class ApiCreationRepository implements CreationRepository {
  ApiCreationRepository(this.client);
  final ModyApiClient client;
  @override
  Future<List<CreationRecord>> load() async {
    final response = await client.request('GET', 'creations');
    final rows = response.data['records'];
    if (rows is! List) throw const FormatException('Missing history');
    final records = [
      for (final row in rows)
        CreationRecord.fromJson(
          Map<String, dynamic>.from(row as Map),
          validateCatalog: false,
        ),
    ];
    if (records.map((r) => r.id).toSet().length != records.length) {
      throw const FormatException('Duplicate history ID');
    }
    return List.unmodifiable(records);
  }

  @override
  Future<void> save(List<CreationRecord> records) async {
    await client.request(
      'POST',
      'creations',
      body: {
        'records': [for (final r in records) r.toJson()],
      },
    );
  }
}

class ApiSelectionRepository implements SelectionRepository {
  ApiSelectionRepository(this.client);
  final ModyApiClient client;
  String? _etag;
  Future<void> _pending = Future.value();
  @override
  Future<AppSelections> load() async {
    final response = await client.request('GET', 'selections');
    final data = response.data['selections'];
    if (data is! Map<String, dynamic> || response.etag == null) {
      throw const FormatException('Missing selections or revision');
    }
    final selections = AppSelections.fromJson(data);
    _etag = response.etag;
    return selections;
  }

  @override
  Future<bool> save(AppSelections selections) {
    // Freeze at Apply time, and preserve ordering across fast UI interactions.
    final frozen =
        jsonDecode(jsonEncode(selections.toJson())) as Map<String, dynamic>;
    final operation = _pending.then((_) async {
      try {
        if (_etag == null) return false; // Never overwrite unread data.
        final response = await client.request(
          'PUT',
          'selections',
          body: {'selections': frozen},
          etag: _etag,
        );
        if (response.etag == null || response.data['saved'] != true) {
          return false;
        }
        _etag = response.etag;
        return true;
      } catch (_) {
        return false;
      }
    });
    _pending = operation.then((_) {});
    return operation;
  }
}
