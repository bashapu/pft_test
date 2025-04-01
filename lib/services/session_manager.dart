import '../models/user.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  AppUser? currentUser;

  void loginUser(AppUser user) => currentUser = user;
  void logout() => currentUser = null;
  bool get isLoggedIn => currentUser != null;
}