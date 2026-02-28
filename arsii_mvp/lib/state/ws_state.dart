import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arsii_mvp/core/websocket_service.dart';
import 'package:arsii_mvp/state/auth_state.dart';

final wsServiceProvider = Provider<WebSocketService>((ref) {
  final service = WebSocketService();
  ref.onDispose(service.dispose);
  return service;
});

final wsEventsProvider = StreamProvider<WsEvent>((ref) {
  final auth = ref.watch(authProvider);
  final service = ref.watch(wsServiceProvider);

  if (auth.isAuthenticated && auth.token != null) {
    service.connect(auth.token!);
  } else {
    service.disconnect();
  }

  return service.stream;
});
