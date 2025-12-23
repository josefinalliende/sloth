import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

final routeObserver = RouteObserver<ModalRoute<void>>();

void useRouteRefresh(BuildContext context, VoidCallback onRefresh) {
  final route = ModalRoute.of(context);

  useEffect(() {
    if (route == null) return null;

    final subscriber = _RouteAwareSubscriber(onRefresh);
    routeObserver.subscribe(subscriber, route);

    return () => routeObserver.unsubscribe(subscriber);
  }, [route]);
}

class _RouteAwareSubscriber extends RouteAware {
  _RouteAwareSubscriber(this._onRefresh);

  final VoidCallback _onRefresh;

  @override
  void didPopNext() {
    _onRefresh();
  }
}
