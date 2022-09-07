import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lumberdash/lumberdash.dart';

import 'database_user.dart';
import 'login_state.dart';
import 'result.dart';

const String loggedInKey = 'LoggedIn';
const String userKey = 'user';
const String sessionKey = 'sessionKey';

class SupaAuthManager {
  final String apiKey;
  final String apiSecret;

  SupabaseClient client;
  final SharedPreferences prefs;
  final LoginStateNotifier loginStateNotifier;

  SupaAuthManager(
      {required this.client,
      required this.prefs,
      // required this.ref,
      required this.apiKey,
      required this.apiSecret,
      required this.loginStateNotifier});

  Future loadUser() async {
    if (client.auth.currentUser != null) {
      loginStateNotifier.loggedIn(true);
      logMessage('Logged in');
      return;
    }
    final recovered = await recoverSession();
    if (!recovered) {
      final user = _getUser();
      if (user != null &&
          user.email.isNotEmpty &&
          true == user.password?.isNotEmpty) {
        await login(user.email, user.password!);
        logMessage('Logging in');
      } else {
        logMessage('Not Logged in');
        loginStateNotifier.loggedIn(false);
      }
    }
  }

  bool isLoggedIn() {
    return prefs.getBool(loggedInKey) ?? false;
  }

  DatabaseUser? _getUser() {
    final userString = prefs.getString(userKey);
    if (userString != null) {
      logMessage('Found user string');
      return DatabaseUser.fromJson(jsonDecode(userString));
    }
    logMessage('Did not find user string in prefs');
    return null;
  }

  String? getUserName() {
    final user = _getUser();
    return user?.email;
  }

  DatabaseUser? getUserFromAuth() {
    final user = client.auth.currentUser;
    if (user == null) {
      return null;
    }
    return DatabaseUser(email: user.email!, userId: user.id);
  }

  void authChanged(AuthChangeEvent event, Session? session) {
    logMessage('authChanged: event: $event session: $session');
    switch (event) {
      case AuthChangeEvent.passwordRecovery:
        // TODO: Handle this case.
        break;
      case AuthChangeEvent.signedIn:
        loginStateNotifier.loggedIn(true);
        if (session != null) {
          saveUserSession(session);
        }
        break;
      case AuthChangeEvent.signedOut:
        _logoutState();
        break;
      case AuthChangeEvent.tokenRefreshed:
        if (session != null) {
          saveUserSession(session);
        }
        break;
      case AuthChangeEvent.userUpdated:
        if (session != null) {
          saveUserSession(session);
        }
        break;
      case AuthChangeEvent.userDeleted:
        _logoutState();
        break;
    }
  }

  void saveUserData(DatabaseUser? user, bool loggedIn) {
    if (user != null) {
      prefs.setString(userKey, jsonEncode(user));
    } else {
      prefs.remove(userKey);
    }
    logMessage('saveUserData: Logged In: $loggedIn user: $user');
    prefs.setBool(loggedInKey, loggedIn);
  }

  Future<Result<bool>> createUser(String email, String password) async {
    try {
      final response = await client.auth.signUp(email, password);
      if (response.session != null) {
        saveUserSession(response.session!);
        final user = DatabaseUser(email: email, password: password);
        loginStateNotifier.update(true, user);
        saveUserData(user, true);
        registerAuthListener();
        return const Result.success(true);
      }
    } on Exception catch (error) {
      logError(error);
      return Result.failure(error);
    }
    return const Result.success(false);
  }

  Future<Result<DatabaseUser>> login(String email, String password) async {
    try {
      final response =
          await client.auth.signIn(email: email, password: password);
      if (response.session != null) {
        logMessage('login: response.data = ${response.session}');
        final user = DatabaseUser(
            email: email, password: password, userId: response.user?.id);
        logMessage('login: user = $user');
        loginStateNotifier.update(true, user);
        saveUserSession(response.session!);
        saveUserData(user, true);
        registerAuthListener();
        return Result.success(user);
      }
    } catch (e) {
      logError(e);
      loginStateNotifier.loggedIn(false);
      return Result.errorMessage(99, e.toString());
    }
    return const Result.errorMessage(99, 'Problems logging in');
  }

  void registerAuthListener() {
    client.auth.onAuthStateChange((event, session) {
      authChanged(event, session);
    });
  }

  void logout() async {
    _logoutState();
    try {
      await client.auth.signOut();
    } catch (e) {
      logError(e);
    }
  }

  void _logoutState() {
    prefs.setBool(loggedInKey, false);
    prefs.remove(sessionKey);
    loginStateNotifier.update(false, null);
  }

  void saveUserSession(Session session) async {
    await prefs.setString(sessionKey, session.persistSessionString);
  }

  void clearUserSession() async {
    await prefs.remove(sessionKey);
  }

  Future<bool> recoverSession() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(sessionKey)) {
      logMessage(
          'Found persisted session string, attempting to recover session');
      try {
        final jsonStr = prefs.getString(sessionKey)!;
        final session = await client.auth.recoverSession(jsonStr);
        logMessage(
            'Session successfully recovered for user ID: ${session.user!.id}');
        final builder = DatabaseUserBuilder()
          ..email(session.user?.email)
          ..userId(session.user?.id);
        final user = builder.build();
        logMessage('login: user = $user');
        loginStateNotifier.update(true, user);
        saveUserSession(session.session!);
        saveUserData(user, true);
        return true;
      } catch (error) {
        logError('Problems recovering session $error');
      }
    }
    return false;
  }

  Future<bool> refreshSession() async {
    try {
      final response = await client.auth.refreshSession();
      logMessage('$response');
      return true;
    } catch (e) {
      logFatal('Problems refreshing session: $e');
    }
    return false;
  }

  void resetPassword(String email) async {
    logMessage('Sending email to $email');
    try {
      await client.auth.api.resetPasswordForEmail(
        email,
        options: const AuthOptions(
            redirectTo:
                kIsWeb ? null : 'io.supabase.flutter://reset-callback/'),
      );
    } catch (error) {
      logFatal('Problems resetting password: $error');
    }
  }
}
