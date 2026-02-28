# ARSII MVP Flutter Client

## Run (Android)

```bash
flutter pub get
flutter run
```

## Backend URL

Android emulator cannot reach `localhost` on the host machine. The app defaults to:

- `http://10.0.2.2:8000`

Override at build time if needed:

```bash
flutter run --dart-define=BASE_URL=http://10.0.2.2:8000 --dart-define=WS_URL=ws://10.0.2.2:8000/ws/updates
```
