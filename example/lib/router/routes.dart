import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supa_manager/supa_manager.dart';

import '../main.dart';
import '../ui/error_page.dart';
import '../ui/login/login.dart';
import '../ui/main_screen.dart';
import 'route_names.dart';

final routeProvider = Provider<MyRouter>((ref) {
  return MyRouter(getLoginStateNotifier(ref));
});

class MyRouter {
  final LoginStateNotifier loginState;

  MyRouter(this.loginState);

  late final router = GoRouter(
    refreshListenable: loginState,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        name: rootRouteName,
        path: '/',
        redirect: (_, state) => state.namedLocation(homeRouteName),
      ),
      GoRoute(
        name: loginRouteName,
        path: '/login',
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: const LoginDialog(),
        ),
      ),
      GoRoute(
        name: homeRouteName,
        path: '/home',
        pageBuilder: (context, state) {
          return MaterialPage<void>(
              key: state.pageKey, child: const MainScreen());
        },
      ),
    ],

    errorPageBuilder: (context, state) => MaterialPage<void>(
      key: state.pageKey,
      child: ErrorPage(error: state.error),
    ),

    // redirect to the login page if the user is not logged in
    redirect: (_, state) {
      final loginLoc = state.namedLocation(loginRouteName);
      final loggingIn = state.path == loginLoc;
      final loggedIn = loginState.isLoggedIn();
      final rootLoc = state.namedLocation(rootRouteName);

      if (!loggedIn && !loggingIn) return loginLoc;
      if (loggedIn && (loggingIn)) return rootLoc;
      return null;
    },
  );
}
