import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import "../../data/models/login_model.dart";

class SessionStorage {
  static const _kSession = 'session';

  static Future<void> save(LoginResponse data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSession, jsonEncode(data.toJson()));
  }

  static Future<LoginResponse?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kSession);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return LoginResponse.fromJson(map);
    } catch (_) {
      await clear();
      return null;
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSession);
  }

  static Future<bool> hasSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_kSession);
  }
}
