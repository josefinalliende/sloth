import 'dart:async' show Completer;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/hooks/use_welcomes.dart';
import 'package:sloth/src/rust/api/welcomes.dart';
import 'package:sloth/src/rust/frb_generated.dart';
import '../test_helpers.dart';

Welcome _welcome(String id, BigInt createdAt) => Welcome(
  id: id,
  mlsGroupId: 'mls_$id',
  nostrGroupId: 'nostr_$id',
  groupName: 'Group $id',
  groupDescription: '',
  groupAdminPubkeys: const [],
  groupRelays: const [],
  welcomer: 'welcomer',
  memberCount: 1,
  state: WelcomeState.pending,
  createdAt: createdAt,
);

class _MockApi implements RustLibApi {
  List<Welcome> welcomes = [];
  Completer<List<Welcome>>? completer;
  final calls = <String>[];

  @override
  Future<List<Welcome>> crateApiWelcomesPendingWelcomes({
    required String pubkey,
  }) {
    calls.add(pubkey);
    if (completer != null) return completer!.future;
    return Future.value(welcomes);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

final _api = _MockApi();

late WelcomesResult Function() getResult;

Future<void> _pump(WidgetTester tester, String pubkey) async {
  getResult = await mountHook(tester, () => useWelcomes(pubkey));
}

void main() {
  setUpAll(() => RustLib.initMock(api: _api));

  setUp(() {
    _api.welcomes = [];
    _api.completer = null;
    _api.calls.clear();
  });

  group('useWelcomes', () {
    group('loading', () {
      setUp(() => _api.completer = Completer());

      testWidgets('is waiting while loading', (tester) async {
        await _pump(tester, 'pk1');

        expect(getResult().snapshot.connectionState, ConnectionState.waiting);
      });
    });

    group('success', () {
      testWidgets('returns welcomes on success', (tester) async {
        _api.welcomes = [_welcome('w1', BigInt.one)];
        await _pump(tester, 'pk1');
        await tester.pump();

        expect(getResult().snapshot.data?.length, 1);
      });

      testWidgets('sorts by createdAt descending', (tester) async {
        _api.welcomes = [
          _welcome('old', BigInt.from(100)),
          _welcome('new', BigInt.from(200)),
        ];
        await _pump(tester, 'pk1');
        await tester.pump();

        expect(getResult().snapshot.data?.first.id, 'new');
        expect(getResult().snapshot.data?.last.id, 'old');
      });
    });

    group('refresh', () {
      testWidgets('triggers refetch', (tester) async {
        await _pump(tester, 'pk1');
        await tester.pump();
        getResult().refresh();
        await tester.pump();

        expect(_api.calls.length, 2);
      });
    });

    group('pubkey change', () {
      testWidgets('refetches with new pubkey', (tester) async {
        await _pump(tester, 'pk1');
        await _pump(tester, 'pk2');

        expect(_api.calls, ['pk1', 'pk2']);
      });
    });
  });
}
