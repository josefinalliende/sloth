import 'package:flutter/material.dart' show Text, Hero;
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/widgets/wn_slate_container.dart' show WnSlateContainer;
import '../test_helpers.dart' show mountWidget;

void main() {
  group('WnSlateContainer tests', () {
    testWidgets('renders child', (WidgetTester tester) async {
      final widget = const WnSlateContainer(
        child: Text('Hi I am a child!'),
      );
      await mountWidget(widget, tester);
      expect(find.text('Hi I am a child!'), findsOneWidget);
    });

    group('without tag', () {
      testWidgets('renders hero with default tag', (WidgetTester tester) async {
        final widget = const WnSlateContainer(
          child: Text('Hi I am a child!'),
        );
        await mountWidget(widget, tester);
        expect(find.byType(Hero), findsOneWidget);
        final hero = tester.widget<Hero>(find.byType(Hero));
        expect(hero.tag, 'wn-slate-container');
      });
    });

    group('with tag', () {
      testWidgets('renders hero with custom tag', (WidgetTester tester) async {
        final widget = const WnSlateContainer(
          tag: 'custom-tag',
          child: Text('Hi I am a child!'),
        );
        await mountWidget(widget, tester);
        expect(find.byType(Hero), findsOneWidget);
        final hero = tester.widget<Hero>(find.byType(Hero));
        expect(hero.tag, 'custom-tag');
      });
    });
  });
}
