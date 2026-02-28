import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:arsii_mvp/screens/login_screen.dart';
import 'package:arsii_mvp/screens/home_screen.dart';
import 'package:arsii_mvp/state/auth_state.dart';
import 'package:arsii_mvp/core/theme.dart';

void main() {
  runApp(const ProviderScope(child: ArsiiApp()));
}

class ArsiiApp extends ConsumerWidget {
  const ArsiiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return MaterialApp(
      title: 'ARSII MVP',
      theme: buildTheme(),
      home: auth.isLoading
          ? const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            )
          : auth.isAuthenticated
              ? const HomeScreen()
              : const LoginScreen(),
    );
  }
}
