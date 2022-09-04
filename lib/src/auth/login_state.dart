import 'package:flutter/material.dart';

import 'database_user.dart';


class LoginStateNotifier extends ChangeNotifier {
  var state = LoginState(loggedIn: false, user: null);

  bool isLoggedIn() {
    return state.loggedIn;
  }
  void loggedIn(bool value) {
    state = LoginState(loggedIn: value, user: state.user);
    notifyListeners();
  }

  void user(DatabaseUser? newUser) {
    state = LoginState(loggedIn: state.loggedIn, user: newUser);
    notifyListeners();
  }

  void update(bool loggedIn, DatabaseUser? user) {
    state = LoginState(loggedIn: loggedIn, user: user);
    notifyListeners();
  }
}

class LoginState {
  final bool loggedIn;
  final DatabaseUser? user;

  LoginState({required this.loggedIn, this.user});
}
