import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sloth/hooks/use_signup.dart';
import 'package:sloth/providers/auth_provider.dart';
import 'package:sloth/src/rust/api/accounts.dart';
import 'package:sloth/src/rust/api/metadata.dart';
import 'package:sloth/src/rust/frb_generated.dart';

import '../mocks/mock_secure_storage.dart';

class MockApi implements RustLibApi {
  bool identityCreated = false;
  bool imageUploaded = false;
  FlutterMetadata? updatedMetadata;
  bool shouldThrowOnCreateIdentity = false;

  @override
  Future<Account> crateApiAccountsCreateIdentity() async {
    if (shouldThrowOnCreateIdentity) {
      throw Exception('Network error');
    }
    identityCreated = true;
    return Account(
      pubkey: 'test_pubkey',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<String> crateApiUtilsGetDefaultBlossomServerUrl() async {
    return 'https://blossom.example.com';
  }

  @override
  Future<String> crateApiAccountsUploadAccountProfilePicture({
    required String pubkey,
    required String serverUrl,
    required String filePath,
    required String imageType,
  }) async {
    imageUploaded = true;
    return 'https://example.com/uploaded.jpg';
  }

  @override
  Future<void> crateApiAccountsUpdateAccountMetadata({
    required String pubkey,
    required FlutterMetadata metadata,
  }) async {
    updatedMetadata = metadata;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _MockFile extends Fake implements File {
  _MockFile(this.path);

  @override
  final String path;

  @override
  bool existsSync() => true;

  @override
  Stream<List<int>> openRead([int? start, int? end]) {
    // JPEG magic bytes
    return Stream.value([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01]);
  }
}

late ({
  SignupState state,
  SignupCallback submit,
  OnImageSelectedCallback onImageSelected,
  ClearErrorsCallback clearErrors,
})
result;

Future<void> _pump(WidgetTester tester, List overrides) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [...overrides],
      child: MaterialApp(
        home: HookConsumer(
          builder: (context, ref, _) {
            result = useSignup(ref);
            return const SizedBox();
          },
        ),
      ),
    ),
  );
}

late MockApi mockApi;

void main() {
  late List overrides;

  setUpAll(() {
    mockApi = MockApi();
    RustLib.initMock(api: mockApi);
  });

  setUp(() {
    mockApi.identityCreated = false;
    mockApi.imageUploaded = false;
    mockApi.updatedMetadata = null;
    mockApi.shouldThrowOnCreateIdentity = false;
    overrides = [secureStorageProvider.overrideWithValue(MockSecureStorage())];
  });

  group('submit', () {
    testWidgets('sets error when displayName is empty', (tester) async {
      await _pump(tester, overrides);
      await result.submit(displayName: '');
      await tester.pump();

      expect(result.state.displayNameError, isNotNull);
    });

    testWidgets('creates identity', (tester) async {
      await _pump(tester, overrides);
      await result.submit(displayName: 'Test');

      expect(mockApi.identityCreated, isTrue);
    });

    testWidgets('updates metadata', (tester) async {
      await _pump(tester, overrides);
      await result.submit(displayName: 'Test');

      expect(mockApi.updatedMetadata, isNotNull);
    });

    testWidgets('with image uploads to blossom', (tester) async {
      await IOOverrides.runZoned(
        () async {
          await _pump(tester, overrides);
          result.onImageSelected('/fake/image.jpg');
          await result.submit(displayName: 'Test');

          expect(mockApi.imageUploaded, isTrue);
        },
        createFile: (path) => _MockFile(path),
      );
    });

    testWidgets('with image includes url in metadata', (tester) async {
      await IOOverrides.runZoned(
        () async {
          await _pump(tester, overrides);
          result.onImageSelected('/fake/image.jpg');
          await result.submit(displayName: 'Test');

          expect(mockApi.updatedMetadata?.picture, 'https://example.com/uploaded.jpg');
        },
        createFile: (path) => _MockFile(path),
      );
    });

    testWidgets('sets friendly error message on failure', (tester) async {
      mockApi.shouldThrowOnCreateIdentity = true;
      await _pump(tester, overrides);
      await result.submit(displayName: 'Test');
      await tester.pump();

      expect(result.state.error, 'Oh no! An error occurred, please try again.');
    });
  });

  group('clearErrors', () {
    testWidgets('clears error', (tester) async {
      mockApi.shouldThrowOnCreateIdentity = true;
      await _pump(tester, overrides);
      await result.submit(displayName: 'Test');
      await tester.pump();

      expect(result.state.error, isNotNull);

      result.clearErrors();
      await tester.pump();

      expect(result.state.error, isNull);
    });

    testWidgets('clears displayNameError', (tester) async {
      await _pump(tester, overrides);
      await result.submit(displayName: '');
      await tester.pump();

      expect(result.state.displayNameError, isNotNull);

      result.clearErrors();
      await tester.pump();

      expect(result.state.displayNameError, isNull);
    });
  });
}
