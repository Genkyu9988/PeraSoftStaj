/// Synchronous, immutable catalog snapshot shared by screens and validation.
/// Production installs SQLite data BEFORE constructing any feature or cubit.
/// Seed fallback is only for isolated widget tests / previews, never DB errors.
class CatalogStore {
  CatalogStore._();
  static Map<String, Object>? _values;
  static bool requireDatabase = false;

  static T read<T>(String key, T seed) {
    final values = _values;
    if (values != null) {
      if (!values.containsKey(key)) throw StateError('Missing catalog: $key');
      return values[key] as T;
    }
    if (requireDatabase) throw StateError('SQLite catalog is not loaded');
    return seed;
  }

  static void install(Map<String, Object> values) {
    _values = Map.unmodifiable(values);
  }

  static void resetForTests() {
    _values = null;
    requireDatabase = false;
  }
}
