import 'package:flutter/foundation.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

class AuthState extends ChangeNotifier {
  AuthState(this._api);

  final ApiClient _api;
  String? _token;
  Future<void>? _loggingOut;
  String? get token => _token;
  bool get isLoggedIn => _token != null;

  Future<void> login(String username, String password) async {
    _token = await _api.obtainToken(username, password);
    notifyListeners();
  }

  void invalidate(String token) {
    if (_token != token) return;
    _token = null;
    notifyListeners();
  }

  Future<void> logout() {
    final pending = _loggingOut;
    if (pending != null) return pending;
    final token = _token;
    if (token == null) return Future.value();
    final future = () async {
      try {
        await _api.logout(token);
      } finally {
        invalidate(token);
        _loggingOut = null;
      }
    }();
    _loggingOut = future;
    return future;
  }
}
