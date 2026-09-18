import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perasoft_staj/main.dart';

void main() {
  testWidgets('Mody ana ekrani gorunur', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());

    expect(find.text('Mody AI'), findsOneWidget);
    expect(find.text('Örnek Arabalar'), findsOneWidget);
    expect(find.text('Arabamı Modifiye Et'), findsOneWidget);
  });
}
