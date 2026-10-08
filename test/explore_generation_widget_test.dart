import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/main.dart';
import 'package:perasoft_staj/feature/editor/view/explore_detail_view.dart';
import 'package:perasoft_staj/feature/explore/view/explore_view.dart';
import 'package:perasoft_staj/feature/generation/view/generation_result_view.dart';
import 'package:perasoft_staj/feature/generation/view/widget/generation_panel.dart';
import 'package:perasoft_staj/feature/generation/view_model/generation_activity.dart';
import 'package:perasoft_staj/product/catalog/car_mod_option.dart';
import 'package:perasoft_staj/product/catalog/reference_car_catalog.dart';
import 'package:perasoft_staj/product/catalog/vehicle_catalog.dart';
import 'package:perasoft_staj/product/model/explore_selection.dart';
import 'package:perasoft_staj/product/model/explore_operation.dart';
import 'package:perasoft_staj/product/model/generation_request.dart';
import 'package:perasoft_staj/product/model/generation_result.dart';
import 'package:perasoft_staj/product/service/generation/generation_service.dart';
import 'helpers/controlled_generation_service.dart';

void main() {
  late ControlledGenerationService service;
  late List<ExploreSelection> writes;
  final selection = ExploreSelection(
    image: 'mustang_classic',
    option: CarModCatalog.groups['Customize Rims']!.first.id,
  );
  setUp(() {
    service = ControlledGenerationService();
    writes = [];
  });

  Future<void> render(
    WidgetTester tester, {
    String title = 'Customize Rims',
    ExploreSelection? initial,
    bool video = false,
    Widget? home,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MyApp(
        home:
            home ??
            ExploreDetailView(
              title: title,
              isCarMod: title == 'Customize Rims' || title == 'Change Color',
              initialSelection: initial ?? selection,
              generationService: service,
              onApplied: writes.add,
              isVideo: video,
            ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(
    WidgetTester tester,
    Finder target, {
    bool settle = true,
  }) async {
    await tester.ensureVisible(target);
    await tester.tap(target.hitTestable());
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
  }

  Future<void> submit(WidgetTester tester) =>
      tap(tester, find.text('Arabamı Modifiye Et'), settle: false);

  for (final title in [
    'Customize Rims',
    'Japanese',
    'Change Color',
    'Clone Car Style',
  ]) {
    testWidgets(
      '$title: correct result summary, original photo, unchanged choices after return',
      (tester) async {
        final initial = ExploreSelection(
          image: selection.image,
          option: title == 'Change Color' ? 'Özel Mor' : selection.option,
          referenceImage: ReferenceCarCatalog.items.first.id,
        );
        await render(tester, title: title, initial: initial);
        await submit(tester);
        expect(find.text('Demo hazırlanıyor…'), findsOneWidget);
        expect(service.requests, hasLength(1));
        service.succeed();
        await tester.pumpAndSettle();
        expect(find.byType(GenerationResultView), findsOneWidget);
        final result = tester
            .widget<GenerationResultView>(find.byType(GenerationResultView))
            .result;
        expect(result.request, same(service.requests.single));
        expect(
          (result as DemoGenerationResult).originalImagePath,
          VehicleCatalog.find(initial.image)!.imagePath,
        );
        expect(find.text('Demo sonuç — AI ile üretilmedi'), findsOneWidget);
        expect(find.text(title), findsOneWidget);
        expect(find.text('Style Builder'), findsNothing);
        if (title == 'Customize Rims') {
          expect(
            find.text(CarModCatalog.groups[title]!.first.label),
            findsOneWidget,
          );
        }
        if (title == 'Change Color') {
          expect(find.text('Özel Mor'), findsOneWidget);
        }
        if (title == 'Clone Car Style') {
          expect(
            find.text(ReferenceCarCatalog.items.first.label),
            findsOneWidget,
          );
        }
        await tap(tester, find.text('Seçimlere Dön'));
        expect(find.byType(GenerationResultView), findsNothing);
        expect(find.byKey(const Key('generationOverlay')), findsNothing);
        expect(find.byKey(const Key('selectedVehicleImage')), findsOneWidget);
        expect(writes, isEmpty);
        await submit(tester);
        expect(service.requests.last, service.requests.first);
        await tap(tester, find.text('Vazgeç'));
        service.succeed(1);
        await tester.pumpAndSettle();
        expect(find.byType(GenerationResultView), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'Loading blocks duplicate taps; failure, retry and result keep same request',
    (tester) async {
      await render(tester);
      final actionPosition = tester.getCenter(find.text('Arabamı Modifiye Et'));
      await submit(tester);
      await tester.tapAt(actionPosition);
      await tester.pump();
      expect(service.requests, hasLength(1));
      service.fail();
      await tester.pumpAndSettle();
      expect(find.text('İşlem tamamlanamadı'), findsOneWidget);
      await tap(tester, find.text('Tekrar Dene'), settle: false);
      expect(service.requests[1], same(service.requests[0]));
      service.succeed(1);
      await tester.pumpAndSettle();
      await tap(tester, find.text('Seçimlere Dön'));
      expect(find.text('İşlem tamamlanamadı'), findsNothing);
      expect(writes, isEmpty);
    },
  );

  for (final lateError in [false, true]) {
    testWidgets(
      'Cancel ignores late response (error=$lateError), allows selection changes',
      (tester) async {
        await render(tester);
        await submit(tester);
        await tap(tester, find.text('Vazgeç'));
        lateError ? service.fail() : service.succeed();
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 3));
        expect(find.byType(GenerationResultView), findsNothing);
        expect(find.byKey(const Key('generationOverlay')), findsNothing);
        expect(writes, isEmpty);
        await tap(tester, find.byTooltip('Örnek Araç 2'));
        expect(writes, hasLength(1));
        expect(writes.single.option, selection.option);
      },
    );
  }

  testWidgets(
    'Failure dismissal preserves form and permits a new edited request',
    (tester) async {
      await render(tester);
      await submit(tester);
      service.fail();
      await tester.pumpAndSettle();
      await tap(tester, find.text('Seçimlere Dön'));
      expect(writes, isEmpty);
      await tap(tester, find.byTooltip('Örnek Araç 2'));
      await submit(tester);
      expect(service.requests.last.vehicleId, VehicleCatalog.samples[1].id);
      expect(
        (service.requests.last as ExploreGenerationRequest).optionId,
        selection.option,
      );
      service.succeed(1);
      await tester.pumpAndSettle();
      expect(find.byType(GenerationResultView), findsOneWidget);
    },
  );

  testWidgets(
    'Actual Explore navigation injects service; system back invalidates pending work',
    (tester) async {
      await render(
        tester,
        home: ExploreView(
          generationService: service,
          initialSelections: {'Customize Rims': selection},
        ),
      );
      await tap(tester, find.text('Customize Rims'));
      await submit(tester);
      expect(service.requests, hasLength(1));
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      service.succeed();
      await tester.pumpAndSettle();
      expect(find.text('Car Mods'), findsOneWidget);
      expect(find.byType(GenerationResultView), findsNothing);
      await tap(tester, find.text('Customize Rims'));
      expect(find.byKey(const Key('selectedVehicleImage')), findsOneWidget);
      expect(find.byKey(const Key('generationOverlay')), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Covered editor does not steal navigation; result can be opened once on return',
    (tester) async {
      await render(tester);
      await submit(tester);
      final navigator = Navigator.of(
        tester.element(find.byType(ExploreDetailView)),
      );
      navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => const Scaffold(body: Text('Other page')),
        ),
      );
      await tester.pumpAndSettle();
      service.succeed();
      await tester.pumpAndSettle();
      expect(find.text('Other page'), findsOneWidget);
      expect(find.byType(GenerationResultView), findsNothing);
      navigator.pop();
      await tester.pumpAndSettle();
      await tap(tester, find.text('Demo Sonucunu Gör'));
      expect(find.byType(GenerationResultView), findsOneWidget);
      await tap(tester, find.text('Seçimlere Dön'));
      expect(find.text('Demo Sonucunu Gör'), findsNothing);
    },
  );

  testWidgets(
    'AI Video submits its own request type without Explore option fields',
    (tester) async {
      await render(tester, title: 'Race Video', video: true);
      await tap(tester, find.text('Video Oluştur'), settle: false);
      expect(
        find.text('Bu bir akış denemesidir. Gerçek video üretilmiyor.'),
        findsOneWidget,
      );
      expect(service.requests.single, isA<AiVideoGenerationRequest>());
      service.succeed();
      await tester.pumpAndSettle();
      expect(find.text('AI Video'), findsOneWidget);
      expect(find.text('Hedef'), findsNothing);
      expect(find.byType(GenerationPanel), findsNothing);
    },
  );

  testWidgets(
    'Shared panel and Explore result remain usable at 320px and 2x text',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      const request = ExploreGenerationRequest(
        operation: ExploreOperation.cloneCarStyle,
        vehicleId: 'mustang_classic',
        referenceId: 'reference.wide_body',
      );
      Future<void> show(Widget child) => tester.pumpWidget(
        MyApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: child,
          ),
        ),
      );
      await show(
        Scaffold(
          body: GenerationPanel(
            activity: const GenerationActivity.failure(
              1,
              request,
              GenerationFailureKind.demo,
            ),
            onRetry: () {},
            onDismiss: () {},
            onShowResult: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Tekrar Dene'));
      expect(tester.takeException(), isNull);
      await show(
        GenerationResultView(
          result: DemoGenerationResult(
            request: request,
            originalImagePath: VehicleCatalog.find(
              request.vehicleId,
            )!.imagePath,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Seçimlere Dön'));
      expect(tester.takeException(), isNull);
    },
  );
}
