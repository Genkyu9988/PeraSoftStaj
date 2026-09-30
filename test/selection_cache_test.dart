import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/main.dart';
import 'package:perasoft_staj/demos/selection_loader.dart';
import 'package:perasoft_staj/demos/main_tabs_view.dart';
import 'package:perasoft_staj/product/cache/app_selections.dart';
import 'package:perasoft_staj/product/cache/generate_selection.dart';
import 'package:perasoft_staj/product/cache/selection_cache_manager.dart';
import 'package:perasoft_staj/product/cache/shared_manager.dart';
import 'package:perasoft_staj/product/explore_selection.dart';

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
  test('Yeni yönetici bütün onaylanan seçimleri JSON kaydından okur', () async {
    final storage = MemorySharedManager();
    final data = AppSelections(
      generate: const GenerateSelection(
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
          image: 'Mock Araç 2',
          option: 'Rim 3',
        ),
      },
      aiVideo: {
        'Apex Transform': const ExploreSelection(image: 'Mock Üretim 1'),
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
          image: 'Mock Araç 2',
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
        expect(find.text('Mock Araç 2'), findsOneWidget);
        await tester.tap(find.text('Resim Seçin'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Mock Araç 3'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Uygula'));
        await tester.pumpAndSettle();
        final restored = await SelectionCacheManager(storage).load();
        expect(
          (video ? restored.aiVideo : restored.explore)[title]?.image,
          'Mock Araç 3',
        );
      },
    );
  }
}
