import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('snackbar with undo action auto-dismisses after 4 seconds',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: _ShowSnackbarButton(),
      ),
    ));

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsOneWidget);

    // Auto-dismisses at the 4s mark.
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsNothing);
  });
}

class _ShowSnackbarButton extends StatelessWidget {
  const _ShowSnackbarButton();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          ScaffoldMessenger.of(context)
            ..clearSnackBars()
            ..showSnackBar(
              SnackBar(
                content: const Text('game'),
                duration: const Duration(seconds: 4),
                persist: false,
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {},
                ),
              ),
            );
        },
        child: const Text('show'),
      ),
    );
  }
}
