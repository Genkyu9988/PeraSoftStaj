import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/main.dart';
import 'package:perasoft_staj/product/init/selection_loader.dart';
import 'package:perasoft_staj/feature/shell/view/main_tabs_view.dart';
import 'package:perasoft_staj/product/model/app_selections.dart';
import 'package:perasoft_staj/product/model/generate_selection.dart';
import 'package:perasoft_staj/product/cache/selection_cache_manager.dart';
import 'package:perasoft_staj/product/cache/shared_manager.dart';
import 'package:perasoft_staj/product/model/explore_selection.dart';
import 'package:perasoft_staj/product/catalog/car_mod_option.dart';
import 'package:perasoft_staj/product/catalog/detail_part_catalog.dart';

class MemorySharedManager extends SharedManager {
  String? value;
  bool fail = false;
  int writes = 0;
  @override
  Future<String?> getString(SharedKeys key) async => value;
  @override
  Future<void> saveString(SharedKeys key, String value) async {
    if (fail) throw StateError('disk unavailable');
    writes++;
    this.value = value;
  }
}

void main() {
  for (final angle in DetailPartCatalog.byAngle.keys) {
    test(
      '$angle parts survive a new cache manager, including new categories',
      () async {
        final storage = MemorySharedManager();
        final parts = {
          for (final category in DetailPartCatalog.forAngle(angle))
            category.title: category.images.length - 1,
        };
        final data = AppSelections(
          generate: GenerateSelection(
            angle: angle,
            parts: parts,
            detailColor: 'Mavi',
          ),
        );
        expect(await SelectionCacheManager(storage).save(data), isTrue);
        final restored = await SelectionCacheManager(storage).load();
        expect(restored.generate.toJson(), data.generate.toJson());
      },
    );
  }

  test(
    'Every Car Mod survives manager reload; invalid and foreign IDs do not',
    () async {
      final storage = MemorySharedManager();
      final data = AppSelections(
        explore: {
          for (final entry in CarModCatalog.groups.entries)
            entry.key: ExploreSelection(
              image: 'mustang_classic',
              option: entry.value.last.id,
            ),
        },
      );
      expect(await SelectionCacheManager(storage).save(data), isTrue);
      final restored = await SelectionCacheManager(storage).load();
      expect(restored.toJson(), data.toJson());
      for (final entry in CarModCatalog.groups.entries) {
        expect(CarModCatalog.restoreId(entry.key, ''), '');
        expect(CarModCatalog.restoreId(entry.key, 'deleted.option'), '');
        expect(CarModCatalog.restoreId(entry.key, 12), '');
      }
      expect(CarModCatalog.restoreId('Perspective', 'upholstery.black'), '');
    },
  );
  test('Yeni yönetici bütün onaylanan seçimleri JSON kaydından okur', () async {
    final storage = MemorySharedManager();
    final data = AppSelections(
      generate: const GenerateSelection(
        vehicleId: 'mustang_classic',
        style: 'Klasik',
        extra: 'Jant',
        color: 'Premium Mavi',
        colorCategory: 1,
        angle: 'Rear',
        parts: {'Spoiler': 2},
        detailColor: 'Özel Mor',
        detailColorCategory: 2,
      ),
      explore: {
        'Customize Rims': const ExploreSelection(
          image: 'porsche_911',
          option: 'rim.split_spoke',
        ),
      },
      aiVideo: {
        'Apex Transform': const ExploreSelection(image: 'mustang_classic'),
      },
    );
    expect(await SelectionCacheManager(storage).save(data), isTrue);
    final restored = await SelectionCacheManager(storage).load();
    expect(restored.toJson(), data.toJson());
  });

  test('Eksik kayıt ve geçersiz alanlar güvenli varsayılanlara döner', () async {
    final storage = MemorySharedManager();
    final manager = SelectionCacheManager(storage);
    expect((await manager.load()).generate.style, '');
    storage.value =
        '{"generate":{"style":12,"color":"silinen renk","parts":{"Spoiler":9}},"explore":{"Bilinmeyen":{}}}';
    final restored = await manager.load();
    expect(restored.generate.style, '');
    expect(restored.generate.color, '');
    expect(restored.generate.parts, isEmpty);
    expect(restored.explore, isEmpty);
    storage.value = 'bozuk json';
    await expectLater(manager.load(), throwsFormatException);
    storage.value = '[]';
    await expectLater(manager.load(), throwsFormatException);
  });

  test('Kayıt sırası korunur ve hata sonraki kaydı engellemez', () async {
    final storage = MemorySharedManager();
    final manager = SelectionCacheManager(storage);
    final data = AppSelections(
      generate: const GenerateSelection(style: 'Klasik'),
    );
    final first = manager.save(data);
    data.generate = const GenerateSelection(style: 'Sportif');
    final second = manager.save(data);
    expect(await first, isTrue);
    expect(await second, isTrue);
    expect((await manager.load()).generate.style, 'Sportif');
    storage.fail = true;
    expect(await manager.save(data), isFalse);
    storage.fail = false;
    expect(await manager.save(data), isTrue);
  });

  testWidgets(
    'Uygula kalıcıdır; panel iptali ve yeniden açılış kaydı değiştirmez',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final storage = MemorySharedManager();
      Future<void> start() async {
        await tester.pumpWidget(
          MyApp(home: SelectionLoader(manager: SelectionCacheManager(storage))),
        );
        await tester.pumpAndSettle();
      }

      Future<void> tap(String title) async {
        await tester.tap(find.text(title));
        await tester.pumpAndSettle();
      }

      await start();
      expect(storage.writes, 0);
      await tap('Stil');
      await tap('Klasik');
      await tap('Uygula');
      expect(storage.writes, 1);
      await tap('Stil');
      await tap('Sportif');
      await tester.tap(find.byTooltip('Paneli kapat'));
      await tester.pumpAndSettle();
      expect(storage.writes, 1);
      await tester.pumpWidget(const SizedBox());
      await start();
      expect(
        tester.widget<Text>(find.byKey(const Key('selectionStil'))).data,
        'Klasik',
      );
      expect(storage.writes, 1);
      storage.fail = true;
      await tap('Stil');
      await tap('SUV');
      await tap('Uygula');
      expect(
        find.text('Seçiminiz bu oturumda korundu ancak cihaza kaydedilemedi.'),
        findsOneWidget,
      );
      expect(
        tester.widget<Text>(find.byKey(const Key('selectionStil'))).data,
        'SUV',
      );
    },
  );

  testWidgets('Bozuk kayıt açılışı engellemez ve kullanıcı uyarılır', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final storage = MemorySharedManager()..value = 'bozuk';
    await tester.pumpWidget(
      MyApp(home: SelectionLoader(manager: SelectionCacheManager(storage))),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Kayıtlar okunamadı; varsayılan seçimlerle devam ediliyor.'),
      findsOneWidget,
    );
    expect(find.text('Stil'), findsOneWidget);
    expect(storage.writes, 0);
  });

  for (final tab in [MainTab.explore, MainTab.aiVideo]) {
    testWidgets(
      '${tab.name} kayıtlı kartı yeniden yükler ve yeni seçimi saklar',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final storage = MemorySharedManager();
        final video = tab == MainTab.aiVideo;
        final title = video ? 'Apex Transform' : 'Change Color';
        final data = AppSelections();
        (video ? data.aiVideo : data.explore)[title] = const ExploreSelection(
          image: 'porsche_911',
        );
        await SelectionCacheManager(storage).save(data);
        await tester.pumpWidget(
          MyApp(
            home: SelectionLoader(
              initialTab: tab,
              manager: SelectionCacheManager(storage),
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text(title));
        await tester.pumpAndSettle();
        expect(
          find.bySemanticsLabel('Seçilen araç: Porsche 911'),
          findsOneWidget,
        );
        await tester.tap(find.byKey(const Key('vehicleInput')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Jeep Wrangler'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Uygula'));
        await tester.pumpAndSettle();
        final restored = await SelectionCacheManager(storage).load();
        expect(
          (video ? restored.aiVideo : restored.explore)[title]?.image,
          'jeep_wrangler',
        );
      },
    );
  }
}
