import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sloth/providers/auth_provider.dart';

final accountPubkeyProvider = Provider<String>((ref) {
  final pubkey = ref.watch(authProvider).value;
  if (pubkey == null) {
    throw StateError('accountPubkeyProvider accessed without authentication');
  }
  return pubkey;
});
