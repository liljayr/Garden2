import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String baseUrl = 'https://garden2-je8f.onrender.com'; // ← same as ApiService

  static const _keyUsername = 'username';
  static const _keyToken = 'auth_token';
  static const _keyLoggedIn = 'is_logged_in';

  // ── Session helpers ────────────────────────────────────

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_keyLoggedIn) != true) return null;
    return prefs.getString(_keyToken);
  }

  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoggedIn) == true;
  }

  static Future<void> _saveSession(String username, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUsername, username);
    await prefs.setString(_keyToken, token);
    await prefs.setBool(_keyLoggedIn, true);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUsername);
    await prefs.remove(_keyToken);
    await prefs.setBool(_keyLoggedIn, false);
  }

  // ── API calls ──────────────────────────────────────────

  static Future<AuthResult> register(String username, String password) async {
    return _authRequest('/auth/register', username, password);
  }

  static Future<AuthResult> login(String username, String password) async {
    return _authRequest('/auth/login', username, password);
  }

  static Future<AuthResult> _authRequest(
      String path, String username, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl$path'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      final body = jsonDecode(res.body);

      if (res.statusCode == 200) {
        final token = body['token'] as String;
        await _saveSession(username, token);
        return AuthResult(success: true, token: token, username: username);
      } else {
        return AuthResult(
            success: false, error: body['detail'] ?? 'Something went wrong');
      }
    } catch (e) {
      return AuthResult(success: false, error: 'Network error: $e');
    }
  }
}

class AuthResult {
  final bool success;
  final String? error;
  final String? token;
  final String? username;

  AuthResult({required this.success, this.error, this.token, this.username});
}
