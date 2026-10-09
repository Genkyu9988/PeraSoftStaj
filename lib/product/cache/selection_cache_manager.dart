import 'dart:convert';
import 'package:perasoft_staj/product/model/app_selections.dart';
import 'shared_manager.dart';
import 'selection_repository.dart';

class SelectionCacheManager implements SelectionRepository {
  SelectionCacheManager(this.sharedManager);
  final SharedManager sharedManager;
  Future<void> _pendingSave = Future.value();

  @override
  Future<AppSelections> load() async {
    final text = await sharedManager.getString(SharedKeys.selections);
    if (text == null) return AppSelections();
    final data = jsonDecode(text);
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Geçersiz seçim kaydı');
    }
    return AppSelections.fromJson(data);
  }

  @override
  Future<bool> save(AppSelections selections) {
    // Onay anındaki veriyi al; hızlı ardışık kayıtlar birbirini geçmesin.
    final text = jsonEncode(selections.toJson());
    final operation = _pendingSave.then((_) async {
      try {
        await sharedManager.saveString(SharedKeys.selections, text);
        return true;
      } catch (_) {
        return false;
      }
    });
    _pendingSave = operation.then((_) {});
    return operation;
  }
}
