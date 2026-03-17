import 'package:flutter/foundation.dart';

String get _host {
  const configuredHost = String.fromEnvironment('API_HOST', defaultValue: '');
  if (configuredHost.isNotEmpty) {
    return configuredHost;
  }
  if (kIsWeb) {
    return 'localhost';
  }
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return '10.0.2.2';
    default:
      return 'localhost';
  }
}

const String _port = String.fromEnvironment('API_PORT', defaultValue: '8000');

String get kBaseUrl => 'http://$_host:$_port';

String get kWsUrl => 'ws://$_host:$_port/ws/updates';
