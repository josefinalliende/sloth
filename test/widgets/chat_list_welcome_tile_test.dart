import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/src/rust/api/metadata.dart';
import 'package:sloth/src/rust/api/welcomes.dart';
import 'package:sloth/src/rust/frb_generated.dart';
import 'package:sloth/widgets/chat_list_welcome_tile.dart';
import '../test_helpers.dart';

const _welcomerPubkey = 'welcomer_pubkey';

Welcome _welcomeFactory({String groupName = ''}) => Welcome(
  id: 'id',
  mlsGroupId: 'mls',
  nostrGroupId: 'nostr',
  groupName: groupName,
  groupDescription: '',
  groupAdminPubkeys: const [],
  groupRelays: const [],
  welcomer: _welcomerPubkey,
  memberCount: 2,
  state: WelcomeState.pending,
  createdAt: BigInt.zero,
);

enum _MockMode { loading, loaded }

class _MockApi implements RustLibApi {
  _MockMode mode = _MockMode.loaded;
  String? displayName;

  @override
  Future<FlutterMetadata> crateApiUsersUserMetadata({
    required bool blockingDataSync,
    required String pubkey,
  }) {
    if (mode == _MockMode.loading) return Completer<FlutterMetadata>().future;
    return Future.value(
      FlutterMetadata(
        displayName: displayName,
        custom: const {},
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

final _api = _MockApi();

void main() {
  setUpAll(() => RustLib.initMock(api: _api));

  setUp(() {
    _api.mode = _MockMode.loaded;
    _api.displayName = null;
  });

  group('ChatListWelcomeTile', () {
    group('while loading', () {
      setUp(() => _api.mode = _MockMode.loading);

      testWidgets('shows nothing', (tester) async {
        await mountWidget(ChatListWelcomeTile(welcome: _welcomeFactory()), tester);

        expect(find.byType(ListTile), findsNothing);
      });
    });

    group('with group name', () {
      testWidgets('shows group name as title', (tester) async {
        await mountWidget(
          ChatListWelcomeTile(welcome: _welcomeFactory(groupName: 'Team Chat')),
          tester,
        );
        await tester.pumpAndSettle();

        expect(find.text('Team Chat'), findsOneWidget);
      });

      testWidgets('shows welcomer name in subtitle', (tester) async {
        _api.displayName = 'Alice';
        await mountWidget(
          ChatListWelcomeTile(welcome: _welcomeFactory(groupName: 'Team Chat')),
          tester,
        );
        await tester.pumpAndSettle();

        expect(find.text('Alice invited you to a secure chat'), findsOneWidget);
      });

      testWidgets('shows fallback subtitle when welcomer is unknown', (tester) async {
        await mountWidget(
          ChatListWelcomeTile(welcome: _welcomeFactory(groupName: 'Team Chat')),
          tester,
        );
        await tester.pumpAndSettle();

        expect(find.text('Someone invited you to a secure chat'), findsOneWidget);
      });
    });

    group('without group name', () {
      testWidgets('shows welcomer name as title', (tester) async {
        _api.displayName = 'Bob';
        await mountWidget(ChatListWelcomeTile(welcome: _welcomeFactory()), tester);
        await tester.pumpAndSettle();

        expect(find.text('Bob'), findsOneWidget);
      });

      testWidgets('shows Unknown User when welcomer is unknown', (tester) async {
        await mountWidget(ChatListWelcomeTile(welcome: _welcomeFactory()), tester);
        await tester.pumpAndSettle();

        expect(find.text('Unknown User'), findsOneWidget);
      });

      testWidgets('shows invite subtitle', (tester) async {
        _api.displayName = 'Bob';
        await mountWidget(ChatListWelcomeTile(welcome: _welcomeFactory()), tester);
        await tester.pumpAndSettle();

        expect(find.text('Invited you to a secure chat'), findsOneWidget);
      });
    });

    group('on tap', () {
      testWidgets('calls onTap when tapped', (tester) async {
        var tapped = false;
        await mountWidget(
          ChatListWelcomeTile(welcome: _welcomeFactory(), onTap: () => tapped = true),
          tester,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byType(ListTile));

        expect(tapped, isTrue);
      });
    });
  });
}
