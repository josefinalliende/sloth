import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sloth/src/rust/api/accounts.dart' as accounts_api;
import 'package:sloth/src/rust/api/users.dart' as users_api;

const _storageKey = 'active_account_pubkey';

final secureStorageProvider = Provider<FlutterSecureStorage>(
  (_) => const FlutterSecureStorage(),
);

class AuthNotifier extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    final storage = ref.read(secureStorageProvider);
    final pubkey = await storage.read(key: _storageKey);
    return (pubkey != null && pubkey.isNotEmpty) ? pubkey : null;
  }

  Future<void> login(String nsec) async {
    final storage = ref.read(secureStorageProvider);
    final account = await accounts_api.login(nsecOrHexPrivkey: nsec);
    users_api.userMetadata(pubkey: account.pubkey, blockingDataSync: false);
    await storage.write(key: _storageKey, value: account.pubkey);
    state = AsyncData(account.pubkey);
  }

  Future<String> signup() async {
    final storage = ref.read(secureStorageProvider);
    final account = await accounts_api.createIdentity();
    await storage.write(key: _storageKey, value: account.pubkey);
    state = AsyncData(account.pubkey);
    return account.pubkey;
  }

  Future<void> logout() async {
    final pubkey = state.value;
    if (pubkey == null) return;

    final storage = ref.read(secureStorageProvider);
    await accounts_api.logout(pubkey: pubkey);
    await storage.delete(key: _storageKey);
    state = const AsyncData(null);
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, String?>(AuthNotifier.new);
