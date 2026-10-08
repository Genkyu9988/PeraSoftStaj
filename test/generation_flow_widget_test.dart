import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/feature/generate/logic/generate_suggestions.dart';
import 'package:perasoft_staj/feature/generate/view/widget/generation_overlay.dart';
import 'package:perasoft_staj/feature/generate/view/generation_result_view.dart';
import 'package:perasoft_staj/feature/generate/view/mody_home_view.dart';
import 'package:perasoft_staj/feature/generate/view_model/generate_cubit.dart';
import 'package:perasoft_staj/feature/generate/view_model/state/generate_state.dart';
import 'package:perasoft_staj/feature/generate/view_model/state/generation_activity.dart';
import 'package:perasoft_staj/feature/shell/view/main_tabs_view.dart';
import 'package:perasoft_staj/main.dart';
import 'package:perasoft_staj/product/catalog/vehicle_catalog.dart';
import 'package:perasoft_staj/product/model/generate_selection.dart';
import 'package:perasoft_staj/product/widget/mody_action_button.dart';
import 'package:perasoft_staj/product/widget/mody_asset_image.dart';
import 'package:perasoft_staj/product/widget/mody_bottom_bar.dart';
import 'package:perasoft_staj/product/widget/vehicle_image_input.dart';

import 'helpers/controlled_generation_service.dart';

const _selection = GenerateSelection(
  vehicleId: 'mustang_classic',
  style: 'Sportif',
  extra: 'Jant',
  color: 'Mavi',
  angle: 'Rear',
  parts: {'Spoiler': 2},
  detailColor: 'Mor',
);

GenerateCubit _cubit(WidgetTester tester) => tester
    .element(find.byType(VehicleImageInput, skipOffstage: false))
    .read<GenerateCubit>();

void main() {
  late ControlledGenerationService service;
  late List<GenerateSelection> writes;
  setUp(() {
    service = ControlledGenerationService();
    writes = [];
  });

  Future<void> render(
    WidgetTester tester, {
    ValueGetter<bool>? isActive,
    double width = 390,
    Widget? home,
  }) async {
    tester.view.physicalSize = Size(width, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MyApp(
        home:
            home ??
            ModyHomeView(
              generationService: service,
              initialSelection: _selection,
              onApplied: writes.add,
              isActive: isActive,
            ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapAction(
    WidgetTester tester, [
    String title = 'Arabamı Modifiye Et',
  ]) async {
    final button = find.widgetWithText(ModyActionButton, title);
    await tester.ensureVisible(button);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pump();
  }

  for (final mode in GenerateMode.values) {
    testWidgets(
      '$mode: original photo, correct request summary, return preserves form',
      (tester) async {
        await render(tester);
        final cubit = _cubit(tester);
        final modeTitle = switch (mode) {
          GenerateMode.styleBuilder => 'Style Builder',
          GenerateMode.customEdit => 'Custom Edit',
          GenerateMode.detailEdit => 'Detail Edit',
        };
        await tester.tap(find.text(modeTitle));
        await tester.pumpAndSettle();
        if (mode == GenerateMode.customEdit) {
          await tester.enterText(
            find.byKey(const Key('customEditDescriptionField')),
            '  Altın jant  ',
          );
          await tester.pumpAndSettle();
        }
        await tapAction(
          tester,
          mode == GenerateMode.detailEdit
              ? 'Modifiye Et'
              : 'Arabamı Modifiye Et',
        );
        expect(find.text('Demo hazırlanıyor…'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        service.succeed();
        await tester.pumpAndSettle();
        expect(find.byType(GenerationResultView), findsOneWidget);
        expect(find.text('Demo sonuç — AI ile üretilmedi'), findsOneWidget);
        expect(find.text(modeTitle), findsOneWidget);
        final photo = tester.widget<ModyAssetImage>(
          find.descendant(
            of: find.byType(GenerationResultView),
            matching: find.byType(ModyAssetImage),
          ),
        );
        expect(
          photo.path,
          VehicleCatalog.find(_selection.vehicleId)!.imagePath,
        );
        final result = tester
            .widget<GenerationResultView>(find.byType(GenerationResultView))
            .result;
        expect(result.request, same(service.requests.single));
        if (mode == GenerateMode.detailEdit) {
          expect(find.text('Rear'), findsOneWidget);
          expect(find.text('Spoiler 3'), findsOneWidget);
          expect(find.text('Mor'), findsOneWidget);
          expect(find.text('Mavi'), findsNothing);
        }
        if (mode == GenerateMode.customEdit) {
          expect(find.text('Altın jant'), findsOneWidget);
        }
        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(cubit.state.generation.status, GenerationStatus.idle);
        expect(cubit.state.toSelection().toJson(), _selection.toJson());
        expect(writes, isEmpty);
        if (mode == GenerateMode.customEdit) {
          expect(find.text('  Altın jant  '), findsOneWidget);
        }
        // Same input can produce another demo and exactly one new route.
        await tapAction(
          tester,
          mode == GenerateMode.detailEdit
              ? 'Modifiye Et'
              : 'Arabamı Modifiye Et',
        );
        service.succeed(1);
        await tester.pumpAndSettle();
        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(find.byType(GenerationResultView), findsNothing);
        expect(find.byType(ModyHomeView), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'Loading disables action, absorbs taps; stale callback cannot double-submit',
    (tester) async {
      await render(tester);
      final staleButton = tester.widget<ModyActionButton>(
        find.widgetWithText(ModyActionButton, 'Arabamı Modifiye Et'),
      );
      for (var i = 0; i < 5; i++) {
        staleButton.onPressed!();
      }
      await tester.pump();
      await tester.pump();
      expect(service.requests, hasLength(1));
      expect(
        tester
            .widget<ModyActionButton>(
              find.widgetWithText(ModyActionButton, 'Arabamı Modifiye Et'),
            )
            .onPressed,
        isNull,
      );
      await tester.tap(find.text('Custom Edit'), warnIfMissed: false);
      await tester.pump();
      expect(find.byKey(const Key('customEditDescriptionField')), findsNothing);
      await tester.tap(find.byKey(const Key('dismissGeneration')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('generationOverlay')), findsNothing);
      service.succeed();
      await tester.pumpAndSettle();
      expect(find.byType(GenerationResultView), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Safe failure -> retry -> success keeps selections and no cache writes',
    (tester) async {
      await render(tester);
      await tapAction(tester);
      service.fail(0, Exception('private token'));
      await tester.pumpAndSettle();
      expect(find.text('İşlem tamamlanamadı'), findsOneWidget);
      expect(find.textContaining('private token'), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      await tester.tap(find.byKey(const Key('retryGeneration')));
      await tester.pump();
      expect(service.requests[1], same(service.requests[0]));
      service.succeed(1);
      await tester.pumpAndSettle();
      expect(find.byType(GenerationResultView), findsOneWidget);
      expect(writes, isEmpty);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(_cubit(tester).state.toSelection().toJson(), _selection.toJson());
    },
  );

  testWidgets('Dismiss failure unlocks form without resetting selected parts', (
    tester,
  ) async {
    await render(tester);
    await tapAction(tester);
    service.fail();
    await tester.pumpAndSettle();
    expect(find.textContaining('Demo hata senaryosu'), findsOneWidget);
    await tester.tap(find.byKey(const Key('dismissGeneration')));
    await tester.pumpAndSettle();
    expect(_cubit(tester).state.parts, _selection.parts);
    expect(
      tester
          .widget<ModyActionButton>(
            find.widgetWithText(ModyActionButton, 'Arabamı Modifiye Et'),
          )
          .onPressed,
      isNotNull,
    );
    expect(writes, isEmpty);
  });

  testWidgets(
    'Hidden Generate does not navigate; pending success can be opened on return',
    (tester) async {
      var active = true;
      await render(tester, isActive: () => active);
      await tapAction(tester);
      active = false;
      service.succeed();
      await tester.pumpAndSettle();
      expect(find.byType(GenerationResultView), findsNothing);
      expect(find.text('Demo sonucu hazır'), findsOneWidget);
      active = true;
      await tester.tap(find.byKey(const Key('showGenerationResult')));
      await tester.pumpAndSettle();
      expect(find.byType(GenerationResultView), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('generationOverlay')), findsNothing);
    },
  );

  testWidgets('Real main-tab switch does not steal navigation from Explore', (
    tester,
  ) async {
    await render(tester, home: const MainTabsView());
    final cubit = _cubit(tester);
    cubit.selectVehicle('mustang_classic');
    cubit.selectStyle('Sportif');
    cubit.submit(GenerateMode.styleBuilder);
    tester.widget<ModyBottomBar>(find.byType(ModyBottomBar)).onSelected!(1);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.byType(GenerationResultView), findsNothing);
    expect(find.byType(SnackBar), findsNothing);
    tester.widget<ModyBottomBar>(find.byType(ModyBottomBar)).onSelected!(0);
    await tester.pumpAndSettle();
    expect(identical(_cubit(tester), cubit), isTrue);
    expect(find.text('Demo sonucu hazır'), findsOneWidget);
    await tester.tap(find.byKey(const Key('showGenerationResult')));
    await tester.pumpAndSettle();
    expect(find.byType(GenerationResultView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Disposed view ignores late success without a navigation or emit',
    (tester) async {
      await render(tester);
      final cubit = _cubit(tester);
      await tapAction(tester);
      await tester.pumpWidget(const SizedBox());
      expect(cubit.isClosed, isTrue);
      service.succeed();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Failure and result remain scrollable at 320px and large text', (
    tester,
  ) async {
    // Isolate panel/result styling here. Full forms at 2x are covered in
    // responsive_verification_test.dart alongside selections and navigation.
    await render(
      tester,
      width: 320,
      home: BlocProvider(
        create: (_) => GenerateCubit(
          generationService: service,
          suggestions: GenerateSuggestions(),
          initialSelection: _selection,
        ),
        child: Scaffold(body: GenerationOverlay(onShowResult: (_) {})),
      ),
    );
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpAndSettle();
    final cubit = tester
        .element(find.byType(GenerationOverlay))
        .read<GenerateCubit>();
    cubit.submit(GenerateMode.styleBuilder);
    await tester.pump();
    service.fail();
    await tester.pumpAndSettle();
    final retry = find.byKey(const Key('retryGeneration'));
    await tester.ensureVisible(retry);
    await tester.tap(retry);
    await tester.pump();
    service.succeed(1);
    await tester.pumpAndSettle();
    expect(find.text('Demo sonucu hazır'), findsOneWidget);
    final result = cubit.state.generation.result!;
    await tester.pumpWidget(MyApp(home: GenerationResultView(result: result)));
    await tester.pumpAndSettle();
    expect(find.text('Demo sonuç — AI ile üretilmedi'), findsOneWidget);
    await tester.ensureVisible(find.text('Seçimlere Dön'));
    await tester.pumpAndSettle();
    expect(find.text('Seçimlere Dön').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
