import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:arsii_mvp/core/config.dart';

class WsEvent {
  final String event;
  final Map<String, dynamic> payload;
  WsEvent(this.event, this.payload);

  factory WsEvent.fromJson(Map<String, dynamic> json) {
    return WsEvent(json['event'] as String? ?? '', json);
  }
}

class WebSocketService {
  WebSocketChannel? _channel;
  final _controller = StreamController<WsEvent>.broadcast();

  Stream<WsEvent> get stream => _controller.stream;

  void connect(String token) {
    disconnect();
    final uri = Uri.parse('$kWsUrl?token=$token');
    _channel = WebSocketChannel.connect(uri);
    _channel?.stream.listen(
      (data) {
        try {
          final decoded = json.decode(data as String) as Map<String, dynamic>;
          _controller.add(WsEvent.fromJson(decoded));
        } catch (_) {}
      },
      onDone: () {},
      onError: (_) {},
    );
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }

  void dispose() {
    disconnect();
    _controller.close();
  }
}
