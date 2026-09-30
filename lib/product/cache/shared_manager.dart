import 'package:shared_preferences/shared_preferences.dart';

enum SharedKeys { selections }

// Eğitmenin SharedManager örneği: cihazdaki kayıt işlemleri tek yerde.
class SharedManager {
  late final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  String _key(SharedKeys key) => 'modyai.v1.${key.name}';

  Future<String?> getString(SharedKeys key) =>
      _preferences.getString(_key(key));

  Future<void> saveString(SharedKeys key, String value) =>
      _preferences.setString(_key(key), value);
}
