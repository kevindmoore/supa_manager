import 'package:example/ui/dialog/new_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('New item dialog returns entered text', (tester) async {
    String? addedName;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (_) => NewItemDialog(
                    title: 'New Task',
                    callBack: (name) => addedName = name,
                  ),
                );
              },
              child: const Text('Open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Buy milk');
    await tester.tap(find.text('New'));
    await tester.pumpAndSettle();

    expect(addedName, 'Buy milk');
  });
}
