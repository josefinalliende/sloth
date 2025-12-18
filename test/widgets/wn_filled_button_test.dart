import 'package:flutter/material.dart' show Key;
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/widgets/wn_filled_button.dart' show WnFilledButton;
import '../test_helpers.dart' show mountWidget;

void main() {
  group('WnFilledButton tests', () {
    testWidgets('displays text', (WidgetTester tester) async {
      final widget = WnFilledButton(
        text: 'Hi I am a button!',
        onPressed: () {},
      );
      await mountWidget(widget, tester);
      expect(find.text('Hi I am a button!'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (WidgetTester tester) async {
      var onPressedCalled = false;
      final widget = WnFilledButton(
        text: 'Hi I am a button!',
        onPressed: () {
          onPressedCalled = true;
        },
      );
      await mountWidget(widget, tester);
      await tester.tap(find.byType(WnFilledButton));
      expect(onPressedCalled, isTrue);
    });

    group('when loading', () {
      testWidgets('displays loading indicator', (WidgetTester tester) async {
        final widget = WnFilledButton(
          text: 'Hi I am a button!',
          onPressed: () {},
          loading: true,
        );
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('loading_indicator')), findsOneWidget);
      });

      testWidgets('hides text', (WidgetTester tester) async {
        final widget = WnFilledButton(
          text: 'Hi I am a button!',
          onPressed: () {},
          loading: true,
        );
        await mountWidget(widget, tester);
        expect(find.text('Hi I am a button!'), findsNothing);
      });

      testWidgets('does not call onPressed', (WidgetTester tester) async {
        var onPressedCalled = false;
        final widget = WnFilledButton(
          text: 'Hi I am a button!',
          onPressed: () {
            onPressedCalled = true;
          },
          loading: true,
        );
        await mountWidget(widget, tester);
        await tester.tap(find.byType(WnFilledButton));
        expect(onPressedCalled, isFalse);
      });
    });

    group('when disabled', () {
      testWidgets('displays text', (WidgetTester tester) async {
        final widget = WnFilledButton(
          text: 'Hi I am a button!',
          onPressed: () {},
          disabled: true,
        );
        await mountWidget(widget, tester);
        expect(find.text('Hi I am a button!'), findsOneWidget);
      });

      testWidgets('does not display loading indicator', (WidgetTester tester) async {
        final widget = WnFilledButton(
          text: 'Hi I am a button!',
          onPressed: () {},
          disabled: true,
        );
        await mountWidget(widget, tester);
        expect(find.byKey(const Key('loading_indicator')), findsNothing);
      });

      testWidgets('does not call onPressed', (WidgetTester tester) async {
        var onPressedCalled = false;
        final widget = WnFilledButton(
          text: 'Hi I am a button!',
          onPressed: () {
            onPressedCalled = true;
          },
          disabled: true,
        );
        await mountWidget(widget, tester);
        await tester.tap(find.byType(WnFilledButton));
        expect(onPressedCalled, isFalse);
      });
    });
  });
}
