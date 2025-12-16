import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sloth/src/rust/api/metadata.dart';
import 'package:sloth/src/rust/api/users.dart' as users_api;

AsyncSnapshot<FlutterMetadata> useUserMetadata(String pubkey) {
  final future = useMemoized(
    () => users_api.userMetadata(pubkey: pubkey, blockingDataSync: false),
    [pubkey],
  );
  return useFuture(future);
}
