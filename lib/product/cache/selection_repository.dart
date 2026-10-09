import 'package:perasoft_staj/product/model/app_selections.dart';

abstract interface class SelectionRepository {
  Future<AppSelections> load();
  Future<bool> save(AppSelections selections);
}
