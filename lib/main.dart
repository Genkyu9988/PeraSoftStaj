import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:perasoft_staj/feature/creations/view_model/creation_history_cubit.dart';
import 'package:perasoft_staj/product/cache/creation_cache_manager.dart';
import 'package:perasoft_staj/product/cache/creation_repository.dart';
import 'package:perasoft_staj/product/cache/sqlite_creation_repository.dart';
import 'package:perasoft_staj/feature/shell/view/main_tabs_view.dart';
import 'package:perasoft_staj/product/init/theme/mody_theme.dart';
import 'package:perasoft_staj/product/cache/shared_manager.dart';
import 'package:perasoft_staj/product/cache/sqlite_selection_repository.dart';
import 'package:perasoft_staj/product/catalog/catalog_store.dart';
import 'package:perasoft_staj/product/model/app_selections.dart';
import 'package:perasoft_staj/product/cache/api_repositories.dart';
import 'package:perasoft_staj/product/catalog/catalog_codec.dart';
import 'package:perasoft_staj/product/service/backend/mody_api_client.dart';

void main() {
  runModyApp();
}

void runModyApp({MainTab initialTab = MainTab.generate}) {
  WidgetsFlutterBinding.ensureInitialized();
  CatalogStore.requireDatabase = true;
  const source = String.fromEnvironment(
    'MODY_DATA_SOURCE',
    defaultValue: 'django',
  );
  runApp(
    source == 'sqlite'
        ? SqliteAppLoader(initialTab: initialTab)
        : DjangoAppLoader(initialTab: initialTab),
  );
}

class DjangoAppLoader extends StatefulWidget {
  const DjangoAppLoader({
    super.key,
    this.initialTab = MainTab.generate,
    this.client,
  });
  final MainTab initialTab;
  final ModyApiClient? client;
  @override
  State<DjangoAppLoader> createState() => _DjangoAppLoaderState();
}

class _DjangoAppLoaderState extends State<DjangoAppLoader> {
  late final ModyApiClient _client;
  late final ApiCreationRepository _history;
  late final ApiSelectionRepository _settings;
  late Future<AppSelections> _loading;
  @override
  void initState() {
    super.initState();
    _client =
        widget.client ??
        ModyApiClient(
          baseUrl: const String.fromEnvironment(
            'MODY_API_URL',
            defaultValue: 'http://10.0.2.2:8765',
          ),
          token: const String.fromEnvironment('MODY_API_TOKEN'),
        );
    _history = ApiCreationRepository(_client);
    _settings = ApiSelectionRepository(_client);
    _loading = _load();
  }

  Future<AppSelections> _load() async {
    final response = await _client.request('GET', 'catalog');
    CatalogStore.install(CatalogCodec.decode(response.data));
    return _settings.load();
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<AppSelections>(
    future: _loading,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done &&
          snapshot.hasData) {
        return MyApp(
          historyRepository: _history,
          home: MainTabsView(
            initialTab: widget.initialTab,
            initialSelections: snapshot.data,
            cacheManager: _settings,
          ),
        );
      }
      final error = snapshot.error;
      return MaterialApp(
        theme: ModyTheme.dark(),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: snapshot.hasError
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Backend bağlantısı kurulamadı'),
                          const SizedBox(height: 12),
                          Text(
                            error is BackendException
                                ? error.message
                                : 'Katalog veya seçimler yüklenemedi. Kayıtlar silinmedi.',
                            textAlign: TextAlign.center,
                          ),
                          TextButton(
                            onPressed: () => setState(() {
                              _loading = _load();
                            }),
                            child: const Text('Tekrar Dene'),
                          ),
                        ],
                      )
                    : const CircularProgressIndicator(),
              ),
            ),
          ),
        ),
      );
    },
  );
}

/// No screen, history validation or selection restoration runs with seed data
/// while SQLite is opening. Failures stay retryable without clearing anything.
class SqliteAppLoader extends StatefulWidget {
  const SqliteAppLoader({super.key, this.initialTab = MainTab.generate});
  final MainTab initialTab;
  @override
  State<SqliteAppLoader> createState() => _SqliteAppLoaderState();
}

class _SqliteAppLoaderState extends State<SqliteAppLoader> {
  late final SqliteCreationRepository _store;
  late final SqliteSelectionRepository _settings;
  late Future<AppSelections> _loading;

  @override
  void initState() {
    super.initState();
    final legacy = SharedManager();
    _store = SqliteCreationRepository(
      legacyRepository: CreationCacheManager(legacy),
    );
    _settings = SqliteSelectionRepository(_store, legacy);
    _loading = _settings.load();
  }

  @override
  void dispose() {
    _store.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<AppSelections>(
    future: _loading,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.done &&
          snapshot.hasData) {
        return MyApp(
          historyRepository: _store,
          home: MainTabsView(
            initialTab: widget.initialTab,
            initialSelections: snapshot.data,
            cacheManager: _settings,
          ),
        );
      }
      return MaterialApp(
        theme: ModyTheme.dark(),
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: SafeArea(
            child: Center(
              child: snapshot.hasError
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Yerel veriler yüklenemedi. Kayıtlarınız silinmedi.',
                        ),
                        TextButton(
                          onPressed: () => setState(() {
                            _loading = _settings.load();
                          }),
                          child: const Text('Tekrar Dene'),
                        ),
                      ],
                    )
                  : const CircularProgressIndicator(),
            ),
          ),
        ),
      );
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    this.home = const MainTabsView(),
    this.historyRepository,
  });

  final Widget home;
  final CreationRepository? historyRepository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CreationHistoryCubit(
        repository: historyRepository ?? MemoryCreationRepository(),
      )..load(),
      lazy: false,
      child: MaterialApp(
        title: 'Mody AI',
        debugShowCheckedModeBanner: false,
        theme: ModyTheme.dark(),
        home: home,
      ),
    );
  }
}

// .\backend\stop_local.ps1
// .\backend\.venv\Scripts\python.exe backend/manage.py runserver 127.0.0.1:8765 --noreload
// flutter run -d emulator-5554 --dart-define-from-file=backend/flutter.local.json --dart-define=MODY_REAL_AI=true
