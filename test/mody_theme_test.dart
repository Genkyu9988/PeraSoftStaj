import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/main.dart';
import 'package:perasoft_staj/product/init/theme/mody_theme.dart';

// Intentionally independent of ModyTheme/ColorItems: freeze the pre-refactor
// configuration, including the original labelLarge <- bodyMedium mapping.
ThemeData _originalTheme() {
  final darkTheme = ThemeData.dark();
  final textTheme = darkTheme.textTheme.apply(
    bodyColor: const Color(0xffF5F5F7),
    displayColor: const Color(0xffF5F5F7),
  );
  return darkTheme.copyWith(
    scaffoldBackgroundColor: Colors.black,
    textTheme: textTheme.copyWith(
      titleLarge: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      titleMedium: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      labelLarge: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
    ),
  );
}

void main() {
  test('Extracted theme equals the complete original ThemeData', () {
    expect(ModyTheme.dark(), _originalTheme());
  });

  testWidgets('MyApp applies the same theme and preserves injected home', (
    tester,
  ) async {
    const probeKey = Key('themeProbe');
    await tester.pumpWidget(
      const MyApp(
        home: Scaffold(body: SizedBox(key: probeKey)),
      ),
    );
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme, _originalTheme());
    expect(app.title, 'Mody AI');
    expect(app.debugShowCheckedModeBanner, isFalse);
    expect(find.byKey(probeKey), findsOneWidget);
    final actualInheritedTheme = Theme.of(tester.element(find.byKey(probeKey)));

    // MaterialApp localizes typography for the active locale. Compare against
    // the original theme through the same widget boundary, not the raw data.
    await tester.pumpWidget(
      MaterialApp(
        theme: _originalTheme(),
        home: const Scaffold(body: SizedBox(key: probeKey)),
      ),
    );
    expect(
      actualInheritedTheme,
      Theme.of(tester.element(find.byKey(probeKey))),
    );
  });
}
