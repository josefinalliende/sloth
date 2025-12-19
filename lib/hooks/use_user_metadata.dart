import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:sloth/hooks/use_route_refresh.dart';
import 'package:sloth/src/rust/api/metadata.dart';
import 'package:sloth/src/rust/api/users.dart' as users_api;

AsyncSnapshot<FlutterMetadata> useUserMetadata(
  BuildContext context,
  String pubkey,
) {
  final refreshKey = useState(0);

  useRouteRefresh(context, () => refreshKey.value++);

  final future = useMemoized(
    () async {
      final storedUserMetadata = await users_api.userMetadata(
        pubkey: pubkey,
        blockingDataSync: false,
      );

      if (storedUserMetadata.name != null ||
          storedUserMetadata.displayName != null ||
          storedUserMetadata.picture != null) {
        return storedUserMetadata;
      }

      return users_api.userMetadata(
        pubkey: pubkey,
        blockingDataSync: true,
      );
    },
    [pubkey, refreshKey.value],
  );
  return useFuture(future);
}
