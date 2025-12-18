import 'dart:async' show Completer;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/hooks/use_user_metadata.dart';
import 'package:sloth/src/rust/api/metadata.dart';
import 'package:sloth/src/rust/frb_generated.dart';
import '../test_helpers.dart';

const _slothMetadata = FlutterMetadata(
  name: 'Sloth',
  displayName: 'sloth',
  about: 'I live in costa rica',
  picture: 'https://example.com/sloth.jpg',
  banner: 'https://example.com/sloth-banner.jpg',
  website: 'https://sloth.com',
  nip05: 'sloth@example.com',
  custom: {},
);

late AsyncSnapshot<FlutterMetadata> Function() getResult;

Future<void> _pump(WidgetTester tester, String pubkey) async {
  getResult = await mountHook(tester, () => useUserMetadata(pubkey));
}

enum _MockMode { loading, success, error }

class _MockApi implements RustLibApi {
  _MockMode mode = _MockMode.success;
  final calls = <String>[];

  @override
  Future<FlutterMetadata> crateApiUsersUserMetadata({
    required bool blockingDataSync,
    required String pubkey,
  }) {
    calls.add(pubkey);
    switch (mode) {
      case _MockMode.loading:
        return Completer<FlutterMetadata>().future;
      case _MockMode.success:
        return Future.value(_slothMetadata);
      case _MockMode.error:
        return Future.error(Exception('fail'));
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

final _api = _MockApi();

void main() {
  setUpAll(() => RustLib.initMock(api: _api));

  setUp(() => _api.calls.clear());

  group('useUserMetadata', () {
    group('loading', () {
      setUp(() => _api.mode = _MockMode.loading);

      testWidgets('is loading while waiting', (tester) async {
        await _pump(tester, 'pk1');

        expect(getResult().connectionState, equals(ConnectionState.waiting));
      });
    });

    group('success', () {
      setUp(() => _api.mode = _MockMode.success);

      testWidgets('returns data on success', (tester) async {
        await _pump(tester, 'pk1');
        await tester.pump();

        expect(getResult().data, isA<FlutterMetadata>());
        expect(getResult().data, equals(_slothMetadata));
      });

      testWidgets('does not refetch when rebuilt with same pubkey', (tester) async {
        await _pump(tester, 'pk1');
        await _pump(tester, 'pk1');

        expect(_api.calls, ['pk1']);
      });

      testWidgets('refetches when pubkey changes', (tester) async {
        await _pump(tester, 'pk1');
        await _pump(tester, 'pk2');

        expect(_api.calls, ['pk1', 'pk2']);
      });
    });

    group('error', () {
      setUp(() => _api.mode = _MockMode.error);

      testWidgets('returns error on failure', (tester) async {
        await _pump(tester, 'pk1');
        await tester.pump();

        expect(getResult().hasError, isTrue);
      });
    });
  });
}
