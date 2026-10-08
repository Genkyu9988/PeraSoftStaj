import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/feature/generate/view/widget/generate_idea_button.dart';
import 'package:perasoft_staj/feature/generate/view/widget/generate_mode_tabs.dart';
import 'package:perasoft_staj/feature/generate/view/widget/generate_options_panel.dart';

void main() {
  testWidgets('Mode tabs report the choice without owning selected state', (
    tester,
  ) async {
    final choices = <int>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GenerateModeTabs(selectedIndex: 0, onSelected: choices.add),
        ),
      ),
    );
    await tester.tap(find.text('Detail Edit'));
    await tester.pump();
    expect(choices, [2]);
    expect(
      tester
          .widget<GenerateModeTabs>(find.byType(GenerateModeTabs))
          .selectedIndex,
      0,
    );
    await tester.tap(find.text('Custom Edit'));
    expect(choices, [2, 1]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Idea button delegates each tap without requiring app state', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: GenerateIdeaButton(onPressed: () => taps++)),
      ),
    );
    await tester.tap(find.byKey(const Key('suggestIdea')));
    await tester.tap(find.byKey(const Key('suggestIdea')));
    expect(taps, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Options panel reports a draft and keeps apply independent', (
    tester,
  ) async {
    final choices = <String>[];
    var applies = 0;
    const options = ['Front', 'Rear', 'Side'];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GenerateOptionsPanel(
            title: 'Açı seçin',
            options: options,
            selectedTitle: 'Front',
            onSelected: choices.add,
            showApply: true,
            onApply: () => applies++,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Rear'));
    await tester.pump();
    expect(choices, ['Rear']);
    expect(applies, 0);
    expect(
      tester
          .widget<GenerateOptionsPanel>(find.byType(GenerateOptionsPanel))
          .selectedTitle,
      'Front',
    );
    expect(options, ['Front', 'Rear', 'Side']);
    await tester.tap(find.text('Uygula'));
    expect(applies, 1);
    expect(tester.takeException(), isNull);
  });
}
