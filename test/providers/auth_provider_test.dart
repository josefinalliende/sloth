import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/src/rust/api/accounts.dart';
import 'package:sloth/src/rust/api/metadata.dart';
import 'package:sloth/src/rust/frb_generated.dart';

import '../mocks/mock_secure_storage.dart';

class _MockRustLibApi implements RustLibApi {
  var metadataCompleter = Completer<FlutterMetadata>();
  String? metadataCalledWithPubkey;
  String? logoutCalledWithPubkey;

  @override
  Future<Account> crateApiAccountsCreateIdentity() async => Account(
    pubkey: 'created_pubkey',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  @override
  Future<Account> crateApiAccountsLogin({required String nsecOrHexPrivkey}) async => Account(
    pubkey: 'logged_in_pubkey',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  @override
  Future<void> crateApiAccountsLogout({required String pubkey}) async {
    logoutCalledWithPubkey = pubkey;
  }

  @override
  Future<FlutterMetadata> crateApiUsersUserMetadata({
    required bool blockingDataSync,
    required String pubkey,
  }) {
    metadataCalledWithPubkey = pubkey;
    return metadataCompleter.future;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  late ProviderContainer container;
  late _MockRustLibApi mockApi;
  late MockSecureStorage mockStorage;

  setUpAll(() {
    mockApi = _MockRustLibApi();
    RustLib.initMock(api: mockApi);
  });

  setUp(() {
    mockApi.metadataCompleter = Completer<FlutterMetadata>();
    mockApi.metadataCalledWithPubkey = null;
    mockApi.logoutCalledWithPubkey = null;
    mockStorage = MockSecureStorage();
    container = ProviderContainer(
      overrides: [secureStorageProvider.overrideWithValue(mockStorage)],
    );
  });

  tearDown(() => container.dispose());

  group('AuthNotifier', () {
    group('build', () {
      test('returns null when storage is empty', () async {
        await container.read(authProvider.future);
        expect(container.read(authProvider).value, isNull);
      });

      test('returns stored pubkey when present', () async {
        await mockStorage.write(key: 'active_account_pubkey', value: 'stored_pubkey');
        final pubkey = await container.read(authProvider.future);
        expect(pubkey, 'stored_pubkey');
      });
    });

    group('login', () {
      test('sets state to pubkey', () async {
        await container.read(authProvider.notifier).login('nsec123');
        expect(container.read(authProvider).value, 'logged_in_pubkey');
      });

      test('fetches account metadata without awaiting', () async {
        await container.read(authProvider.notifier).login('nsec123');
        expect(mockApi.metadataCalledWithPubkey, 'logged_in_pubkey');
        expect(mockApi.metadataCompleter.isCompleted, isFalse);
      });
    });

    group('signup', () {
      test('returns created pubkey', () async {
        final pubkey = await container.read(authProvider.notifier).signup();
        expect(pubkey, 'created_pubkey');
      });
    });

    group('logout', () {
      test('clears state', () async {
        await container.read(authProvider.notifier).login('nsec123');
        await container.read(authProvider.notifier).logout();
        expect(container.read(authProvider).value, isNull);
      });

      test('clears storage', () async {
        await container.read(authProvider.notifier).login('nsec123');
        await container.read(authProvider.notifier).logout();
        expect(await mockStorage.read(key: 'active_account_pubkey'), isNull);
      });

      test('calls Rust API logout', () async {
        await container.read(authProvider.notifier).login('nsec123');
        await container.read(authProvider.notifier).logout();
        expect(mockApi.logoutCalledWithPubkey, 'logged_in_pubkey');
      });

      test('does nothing when not authenticated', () async {
        await container.read(authProvider.future);
        await container.read(authProvider.notifier).logout();
        expect(mockApi.logoutCalledWithPubkey, isNull);
        expect(container.read(authProvider).value, isNull);
      });
    });
  });
}
