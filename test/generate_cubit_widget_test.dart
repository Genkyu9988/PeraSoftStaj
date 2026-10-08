import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/feature/generate/view/mody_home_view.dart';
import 'package:perasoft_staj/feature/generate/view/widget/style_builder_content.dart';
import 'package:perasoft_staj/feature/generate/view_model/generate_cubit.dart';
import 'package:perasoft_staj/feature/generate/view_model/state/generate_state.dart';
import 'package:perasoft_staj/feature/shell/view/main_tabs_view.dart';
import 'package:perasoft_staj/main.dart';
import 'package:perasoft_staj/product/model/generate_selection.dart';
import 'package:perasoft_staj/product/utility/mody_feedback.dart';
import 'package:perasoft_staj/product/validation/generate_validation_messages.dart';
import 'package:perasoft_staj/product/widget/mody_bottom_bar.dart';
import 'package:perasoft_staj/product/widget/vehicle_image_input.dart';

GenerateCubit _cubit(WidgetTester tester) =>
    tester.element(find.byType(VehicleImageInput)).read<GenerateCubit>();

void main() {
  Future<void> render(WidgetTester tester, {Widget? home}) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MyApp(home: home ?? const ModyHomeView()));
    await tester.pumpAndSettle();
  }

  testWidgets('Selectors rebuild only the choices used by their view', (
    tester,
  ) async {
    await render(tester);
    final cubit = _cubit(tester);
    final vehicleBefore = tester.widget<VehicleImageInput>(
      find.byType(VehicleImageInput),
    );
    final styleBefore = tester.widget<StyleBuilderContent>(
      find.byType(StyleBuilderContent),
    );
    cubit.selectStyleColor('Mor');
    await tester.pumpAndSettle();
    final styleAfter = tester.widget<StyleBuilderContent>(
      find.byType(StyleBuilderContent),
    );
    expect(styleAfter.selectedColor, 'Mor');
    expect(identical(styleBefore, styleAfter), isFalse);
    expect(
      identical(vehicleBefore, tester.widget(find.byType(VehicleImageInput))),
      isTrue,
    );

    cubit.selectDetailColor('Mavi');
    await tester.pumpAndSettle();
    expect(
      identical(styleAfter, tester.widget(find.byType(StyleBuilderContent))),
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Repeated equal warnings display again without a queue', (
    tester,
  ) async {
    await render(tester);
    final cubit = _cubit(tester);
    cubit.submit(GenerateMode.styleBuilder);
    await tester.pumpAndSettle();
    expect(find.text(GenerateValidationMessages.vehicle), findsOneWidget);
    ModyFeedback.dismiss(tester.element(find.byType(ModyHomeView)));
    await tester.pumpAndSettle();
    cubit.submit(GenerateMode.styleBuilder);
    await tester.pumpAndSettle();
    expect(find.text(GenerateValidationMessages.vehicle), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('A confirmed choice invalidates queued missing-car feedback', (
    tester,
  ) async {
    await render(tester);
    final cubit = _cubit(tester);
    cubit.submit(GenerateMode.styleBuilder);
    cubit.selectVehicle('mustang_classic');
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsNothing);
    cubit.submit(GenerateMode.styleBuilder);
    await tester.pumpAndSettle();
    expect(find.text(GenerateValidationMessages.styleChoice), findsOneWidget);
  });

  testWidgets(
    'Main tab switch keeps Cubit and drops pending Generate warning',
    (tester) async {
      await render(tester, home: const MainTabsView());
      final cubit = _cubit(tester);
      cubit.selectStyle('Klasik');
      await tester.pumpAndSettle();
      cubit.submit(GenerateMode.styleBuilder);
      tester.widget<ModyBottomBar>(find.byType(ModyBottomBar)).onSelected!(1);
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
      expect(cubit.isClosed, isFalse);
      tester.widget<ModyBottomBar>(find.byType(ModyBottomBar)).onSelected!(0);
      await tester.pumpAndSettle();
      expect(identical(_cubit(tester), cubit), isTrue);
      expect(cubit.state.style, 'Klasik');
      expect(find.byType(SnackBar), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Owner closes Cubit and a reopened screen restores selections', (
    tester,
  ) async {
    var saved = const GenerateSelection();
    await render(tester, home: ModyHomeView(onApplied: (s) => saved = s));
    final previous = _cubit(tester);
    previous.selectVehicle('mustang_classic');
    previous.selectAngle('Rear');
    previous.selectParts({'Spoiler': 2});
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    expect(previous.isClosed, isTrue);
    await tester.pumpWidget(MyApp(home: ModyHomeView(initialSelection: saved)));
    await tester.pumpAndSettle();
    final next = _cubit(tester);
    expect(identical(previous, next), isFalse);
    expect(next.isClosed, isFalse);
    expect(next.state.toSelection().toJson(), saved.toJson());
    expect(tester.takeException(), isNull);
  });

  testWidgets('Removing owner while a draft sheet is open never commits it', (
    tester,
  ) async {
    final saved = <GenerateSelection>[];
    await render(tester, home: ModyHomeView(onApplied: saved.add));
    final cubit = _cubit(tester);
    await tester.tap(find.text('Stil'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Klasik'));
    await tester.pumpAndSettle();
    expect(cubit.state.style, '');
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    expect(cubit.isClosed, isTrue);
    expect(saved, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
