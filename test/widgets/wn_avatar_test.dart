import 'dart:io';
import 'package:flutter/material.dart' show Key;
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/widgets/wn_avatar.dart' show WnAvatar;
import '../test_helpers.dart' show mountWidget;

class _MockFailingHttpClient extends Fake implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    throw const SocketException('Simulated network error');
  }
}

void main() {
  group('WnAvatar', () {
    group('without pictureUrl', () {
      testWidgets('shows user icon when displayName is null', (tester) async {
        await mountWidget(const WnAvatar(), tester);
        expect(find.byKey(const Key('avatar_fallback_icon')), findsOneWidget);
      });

      testWidgets('shows user icon when displayName is empty', (tester) async {
        await mountWidget(const WnAvatar(displayName: ''), tester);
        expect(find.byKey(const Key('avatar_fallback_icon')), findsOneWidget);
      });

      testWidgets('shows first letter for single word', (tester) async {
        await mountWidget(const WnAvatar(displayName: 'alice'), tester);
        expect(find.text('A'), findsOneWidget);
      });

      testWidgets('shows two initials for two words', (tester) async {
        await mountWidget(const WnAvatar(displayName: 'alice bob'), tester);
        expect(find.text('AB'), findsOneWidget);
      });
    });

    group('with empty pictureUrl', () {
      testWidgets('shows initials', (tester) async {
        await mountWidget(const WnAvatar(pictureUrl: '', displayName: 'test'), tester);
        expect(find.text('T'), findsOneWidget);
      });
    });

    group('with pictureUrl', () {
      testWidgets('shows image', (tester) async {
        await mountWidget(
          const WnAvatar(pictureUrl: 'https://example.com/image.jpg', displayName: 'test'),
          tester,
        );
        expect(find.byKey(const Key('avatar_image')), findsOneWidget);
      });

      testWidgets('shows initials on image load error', (tester) async {
        await HttpOverrides.runZoned(
          () async {
            await mountWidget(
              const WnAvatar(
                pictureUrl: 'https://example.com/image.jpg',
                displayName: 'test widget',
              ),
              tester,
            );
            await tester.pumpAndSettle();

            expect(find.text('TW'), findsOneWidget);
          },
          createHttpClient: (_) => _MockFailingHttpClient(),
        );
      });
    });
  });
}
