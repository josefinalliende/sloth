import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sloth/src/rust/api/welcomes.dart' as welcomes_api;

typedef WelcomesResult = ({
  AsyncSnapshot<List<welcomes_api.Welcome>> snapshot,
  VoidCallback refresh,
});

WelcomesResult useWelcomes(String pubkey) {
  final refreshKey = useState(0);
  final future = useMemoized(
    () async {
      final welcomes = await welcomes_api.pendingWelcomes(pubkey: pubkey);
      return welcomes.reversed.toList();
    },
    [pubkey, refreshKey.value],
  );
  final snapshot = useFuture(future);

  return (
    snapshot: snapshot,
    refresh: () => refreshKey.value++,
  );
}
