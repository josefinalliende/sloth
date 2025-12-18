import 'package:flutter/material.dart' show Key;
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/widgets/wn_copyable_field.dart' show WnCopyableField;
import '../mocks/mock_clipboard.dart' show mockClipboard;
import '../test_helpers.dart' show mountWidget;

void main() {
  group('WnCopyableField', () {
    testWidgets('displays label', (tester) async {
      await mountWidget(
        const WnCopyableField(label: 'My Label', value: 'content'),
        tester,
      );
      expect(find.text('My Label'), findsOneWidget);
    });

    testWidgets('displays value', (tester) async {
      await mountWidget(
        const WnCopyableField(label: 'Label', value: 'my-value'),
        tester,
      );
      expect(find.text('my-value'), findsOneWidget);
    });

    testWidgets('displays copy icon', (tester) async {
      await mountWidget(
        const WnCopyableField(label: 'Label', value: 'value'),
        tester,
      );
      expect(find.byKey(const Key('copy_button')), findsOneWidget);
    });

    group('on tap', () {
      late String? Function() getClipboard;

      setUp(() {
        getClipboard = mockClipboard();
      });

      testWidgets('copies value to clipboard', (tester) async {
        await mountWidget(
          const WnCopyableField(label: 'Label', value: 'my-text'),
          tester,
        );
        await tester.tap(find.byKey(const Key('copy_button')));
        expect(getClipboard(), 'my-text');
      });

      testWidgets('shows snackbar when copiedMessage is provided', (tester) async {
        await mountWidget(
          const WnCopyableField(
            label: 'Label',
            value: 'value',
            copiedMessage: 'Copied!',
          ),
          tester,
        );
        await tester.tap(find.byKey(const Key('copy_button')));
        await tester.pump();
        expect(find.text('Copied!'), findsOneWidget);
      });
    });
  });
}
