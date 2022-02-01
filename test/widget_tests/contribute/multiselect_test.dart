
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hunt_app/contribute/multiselect.dart';


Future<void> main() async {
  List<String> selectedList = [];

  testWidgets('MultiSelectChip Widget', (tester) async {
    Widget testWidget = MediaQuery(
        data: MediaQueryData(size: Size(1000, 1000)),
        child: MaterialApp(
            home: Material(
              child: MultiSelectChip(
                ['art', 'culture', 'food', 'nature'],
                onSelectionChanged: (list) {selectedList = list;},
              )
            )
        )
    );

    await tester.pumpWidget(testWidget);

    final finder = find.byType(Wrap);
    expect(finder, findsOneWidget);

    final chipFinder = find.descendant(of: finder, matching: find.byType(ChoiceChip));
    expect(chipFinder, findsNWidgets(4));
  });

  testWidgets('Choose one category', (tester) async {
    Widget testWidget = MediaQuery(
        data: MediaQueryData(size: Size(1000, 1000)),
        child: MaterialApp(
            home: Material(
                child: MultiSelectChip(
                  ['art', 'culture', 'food', 'nature'],
                  onSelectionChanged: (list) {selectedList = list;},
                )
            )
        )
    );

    await tester.pumpWidget(testWidget);

    final finder = find.byType(Wrap);
    expect(finder, findsOneWidget);

    await tester.tap(find.descendant(of: finder, matching: find.byType(ChoiceChip).first));
    await tester.pumpAndSettle();

    expect(selectedList.contains('art'), true);
  });

  testWidgets('Choose two categories', (tester) async {
    Widget testWidget = MediaQuery(
        data: MediaQueryData(size: Size(1000, 1000)),
        child: MaterialApp(
            home: Material(
                child: MultiSelectChip(
                  ['art', 'culture', 'food', 'nature'],
                  onSelectionChanged: (list) {selectedList = list;},
                )
            )
        )
    );

    await tester.pumpWidget(testWidget);

    final finder = find.byType(Wrap);
    expect(finder, findsOneWidget);

    await tester.tap(find.descendant(of: finder, matching: find.byType(ChoiceChip).first));
    await tester.tap(find.descendant(of: finder, matching: find.byType(ChoiceChip).last));
    await tester.pumpAndSettle();

    expect(selectedList.contains('art') && selectedList.contains('nature'), true);
  });
  
}