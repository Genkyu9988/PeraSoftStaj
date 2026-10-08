import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/main.dart';
import 'package:perasoft_staj/feature/ai_video/view/ai_video_view.dart';
import 'package:perasoft_staj/feature/editor/view/explore_detail_view.dart';
import 'package:perasoft_staj/feature/generation/view/generation_result_view.dart';
import 'package:perasoft_staj/feature/generation/view/widget/generation_panel.dart';
import 'package:perasoft_staj/feature/generation/view_model/generation_activity.dart';
import 'package:perasoft_staj/product/catalog/vehicle_catalog.dart';
import 'package:perasoft_staj/product/constants/image_items.dart';
import 'package:perasoft_staj/product/model/ai_video_template.dart';
import 'package:perasoft_staj/product/model/explore_selection.dart';
import 'package:perasoft_staj/product/model/generation_request.dart';
import 'package:perasoft_staj/product/model/generation_result.dart';
import 'package:perasoft_staj/product/service/generation/generation_service.dart';
import 'package:perasoft_staj/product/validation/explore_validation_messages.dart';
import 'package:perasoft_staj/product/widget/mody_action_button.dart';
import 'package:perasoft_staj/product/widget/mody_asset_image.dart';
import 'helpers/controlled_generation_service.dart';

const videoDemoExplanation =
    'Aşağıdaki fotoğraf seçtiğiniz orijinal araçtır. Seçilen şablon uygulanmadı; gerçek video üretilmedi.';

void main() {
  late ControlledGenerationService service;
  late List<ExploreSelection> writes;
  const initial = ExploreSelection(image: 'bmw_ix5');
  setUp(() {
    service = ControlledGenerationService();
    writes = [];
  });

  Future<void> render(
    WidgetTester tester, {
    String title = 'Cliff Drive',
    ExploreSelection selection = initial,
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
              isCarMod: false,
              isVideo: true,
              coverImagePath: ImageItems.aiVideoCovers[title],
              initialSelection: selection,
              generationService: service,
              onApplied: writes.add,
            ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tap(
    WidgetTester tester,
    Finder finder, {
    bool settle = true,
  }) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder.hitTestable());
    if (settle) {
      await tester.pumpAndSettle();
    } else {
      await tester.pump();
    }
  }

  Future<void> submit(WidgetTester tester) =>
      tap(tester, find.text('Video Oluştur'), settle: false);

  for (final template in AiVideoTemplate.values) {
    testWidgets(
      '${template.name}: static cover, video request, truthful result and return',
      (tester) async {
        await render(tester, title: template.title);
        expect(
          tester
              .widget<ModyAssetImage>(find.byKey(const Key('detailCover')))
              .path,
          ImageItems.aiVideoCovers[template.title],
        );
        expect(find.text('Renk'), findsNothing);
        await submit(tester);
        expect(find.text('Demo hazırlanıyor…'), findsOneWidget);
        expect(
          find.text('Bu bir akış denemesidir. Gerçek video üretilmiyor.'),
          findsOneWidget,
        );
        final action = find.widgetWithText(ModyActionButton, 'Video Oluştur');
        expect(tester.widget<ModyActionButton>(action).onPressed, isNull);
        expect(
          service.requests.single,
          AiVideoGenerationRequest(
            template: template,
            vehicleId: initial.image,
          ),
        );
        service.succeed();
        await tester.pumpAndSettle();
        expect(find.byType(GenerationResultView), findsOneWidget);
        expect(find.text('AI Video'), findsOneWidget);
        expect(find.text('Şablon'), findsOneWidget);
        expect(find.text(template.title), findsOneWidget);
        expect(find.text('BMW iX5'), findsOneWidget);
        expect(find.text(videoDemoExplanation), findsOneWidget);
        expect(find.text('Hedef'), findsNothing);
        final result = tester
            .widget<GenerationResultView>(find.byType(GenerationResultView))
            .result;
        expect(result.request, same(service.requests.single));
        expect(
          (result as DemoGenerationResult).originalImagePath,
          VehicleCatalog.find(initial.image)!.imagePath,
        );
        await tap(tester, find.text('Seçimlere Dön'));
        expect(find.byKey(const Key('selectedVehicleImage')), findsOneWidget);
        expect(tester.widget<ModyActionButton>(action).onPressed, isNotNull);
        expect(find.byType(GenerationPanel), findsNothing);
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

  testWidgets('Missing/invalid vehicle warns without calling service', (
    tester,
  ) async {
    await render(tester, selection: const ExploreSelection(image: 'invalid'));
    await submit(tester);
    await tester.pumpAndSettle();
    expect(find.text(ExploreValidationMessages.image), findsOneWidget);
    expect(service.requests, isEmpty);
    expect(find.byType(GenerationPanel), findsNothing);
  });

  testWidgets(
    'Error, same-request retry, result and return never write selections',
    (tester) async {
      await render(tester);
      await submit(tester);
      service.fail();
      await tester.pumpAndSettle();
      expect(find.text('İşlem tamamlanamadı'), findsOneWidget);
      await tap(tester, find.text('Tekrar Dene'), settle: false);
      expect(service.requests.last, same(service.requests.first));
      service.succeed(1);
      await tester.pumpAndSettle();
      await tap(tester, find.text('Seçimlere Dön'));
      expect(find.byType(GenerationPanel), findsNothing);
      expect(writes, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  for (final error in [false, true]) {
    testWidgets(
      'Cancel ignores late response (error=$error), form remains editable',
      (tester) async {
        await render(tester);
        await submit(tester);
        await tap(tester, find.text('Vazgeç'));
        error ? service.fail() : service.succeed();
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 3));
        expect(find.byType(GenerationResultView), findsNothing);
        expect(find.byType(GenerationPanel), findsNothing);
        expect(writes, isEmpty);
        await tap(tester, find.byTooltip('Örnek Araç 1'));
        expect(writes.single.image, VehicleCatalog.samples.first.id);
        await submit(tester);
        expect(
          service.requests.last.vehicleId,
          VehicleCatalog.samples.first.id,
        );
        service.succeed(1);
        await tester.pumpAndSettle();
        expect(find.byType(GenerationResultView), findsOneWidget);
      },
    );
  }

  testWidgets(
    'Error dismissal preserves vehicle; new request can use a different vehicle',
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
      service.succeed(1);
      await tester.pumpAndSettle();
      expect(find.text('Porsche 911'), findsOneWidget);
    },
  );

  for (final error in [false, true]) {
    testWidgets(
      'Actual AI Video route injects service; back ignores late response (error=$error)',
      (tester) async {
        await render(
          tester,
          home: AiVideoView(
            generationService: service,
            onApplied: (_, selection) => writes.add(selection),
          ),
        );
        await tap(tester, find.text('Apex Transform'));
        await tap(tester, find.byTooltip('Örnek Araç 2'));
        await submit(tester);
        await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();
        error ? service.fail() : service.succeed();
        await tester.pumpAndSettle();
        expect(find.byType(ExploreDetailView), findsNothing);
        expect(find.byType(GenerationResultView), findsNothing);
        await tap(tester, find.text('Apex Transform'));
        expect(find.byKey(const Key('selectedVehicleImage')), findsOneWidget);
        await submit(tester);
        expect(service.requests.last.vehicleId, VehicleCatalog.samples[1].id);
        service.succeed(1);
        await tester.pumpAndSettle();
        expect(writes, hasLength(1));
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'Covered route keeps result pending; explicit open consumes it once',
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
      expect(find.byType(GenerationPanel), findsNothing);
    },
  );

  testWidgets(
    'Video explanation, error actions and result fit narrow screen with large text',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      const request = AiVideoGenerationRequest(
        template: AiVideoTemplate.pitStopTransformation,
        vehicleId: 'bmw_ix5',
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
