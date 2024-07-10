import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'screens/_screens.dart';

class AppRouter {
  late final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          return MainScreen();
        },
      ),
    ],
    debugLogDiagnostics: true,
  );
}
