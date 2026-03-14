import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  final _api = ApiService();

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') != null;
  }

  Future<void> login() async {
    await _api.devLogin();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }
}
