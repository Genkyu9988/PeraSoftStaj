import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<Finder> revealDetailPart(
  WidgetTester tester,
  String category,
  int index,
) async {
  await tester.scrollUntilVisible(
    find.byKey(Key('partCategory$category')),
    120,
    scrollable: find
        .descendant(
          of: find.byKey(const Key('detailPartCategories')),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  final card = find.byKey(Key('part$category$index'));
  await tester.ensureVisible(card);
  await tester.pumpAndSettle();
  return card;
}
