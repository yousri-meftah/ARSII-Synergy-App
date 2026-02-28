const String kBaseUrl = String.fromEnvironment(
  'BASE_URL',
  defaultValue: 'http://localhost:9000',
);

const String kWsUrl = String.fromEnvironment(
  'WS_URL',
  defaultValue: 'ws://localhost:9000/ws/updates',
);
