import 'dart:convert';
import 'dart:io' show Platform, SocketException;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Auto-detect: Android emulator needs 10.0.2.2, everything else uses localhost
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:5000';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:5000';
    } catch (_) {}
    return 'http://localhost:5000';
  }

  static const Duration _timeout = Duration(seconds: 10);

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  /// Wrapper that handles timeouts and socket errors with clear messages
  static Future<Map<String, dynamic>> _safeRequest(
      Future<http.Response> Function() requestFn) async {
    try {
      final response = await requestFn().timeout(_timeout);
      return jsonDecode(response.body);
    } on SocketException {
      throw Exception(
          'Cannot connect to server. Please make sure the backend is running.');
    } on http.ClientException {
      throw Exception(
          'Cannot connect to server. Please make sure the backend is running.');
    }
  }

  // ─── Auth ──────────────────────────────────────────
  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    return _safeRequest(() async => await http.post(
          Uri.parse('$baseUrl/auth/register'),
          headers: await _headers(auth: false),
          body: jsonEncode({'name': name, 'email': email, 'password': password}),
        ));
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    return _safeRequest(() async => await http.post(
          Uri.parse('$baseUrl/auth/login'),
          headers: await _headers(auth: false),
          body: jsonEncode({'email': email, 'password': password}),
        ));
  }

  // ─── Tasks ─────────────────────────────────────────
  static Future<Map<String, dynamic>> getTasks() async {
    return _safeRequest(() async => await http.get(
          Uri.parse('$baseUrl/tasks'),
          headers: await _headers(),
        ));
  }

  static Future<Map<String, dynamic>> createTask(
      Map<String, dynamic> taskData) async {
    return _safeRequest(() async => await http.post(
          Uri.parse('$baseUrl/tasks'),
          headers: await _headers(),
          body: jsonEncode(taskData),
        ));
  }

  static Future<Map<String, dynamic>> updateTask(
      String taskId, Map<String, dynamic> data) async {
    return _safeRequest(() async => await http.put(
          Uri.parse('$baseUrl/tasks/$taskId'),
          headers: await _headers(),
          body: jsonEncode(data),
        ));
  }

  static Future<Map<String, dynamic>> deleteTask(String taskId) async {
    return _safeRequest(() async => await http.delete(
          Uri.parse('$baseUrl/tasks/$taskId'),
          headers: await _headers(),
        ));
  }

  // ─── Schedule ──────────────────────────────────────
  static Future<Map<String, dynamic>> generateSchedule() async {
    return _safeRequest(() async => await http.post(
          Uri.parse('$baseUrl/schedule/generate'),
          headers: await _headers(),
        ));
  }

  static Future<Map<String, dynamic>> getSchedule({String? date}) async {
    String url = '$baseUrl/schedule';
    if (date != null) url += '?date=$date';
    return _safeRequest(() async => await http.get(
          Uri.parse(url),
          headers: await _headers(),
        ));
  }

  // ─── Habits ────────────────────────────────────────
  static Future<Map<String, dynamic>> getHabits() async {
    return _safeRequest(() async => await http.get(
          Uri.parse('$baseUrl/habits'),
          headers: await _headers(),
        ));
  }

  static Future<Map<String, dynamic>> createHabit(
      Map<String, dynamic> data) async {
    return _safeRequest(() async => await http.post(
          Uri.parse('$baseUrl/habits'),
          headers: await _headers(),
          body: jsonEncode(data),
        ));
  }

  static Future<Map<String, dynamic>> updateHabit(
      String habitId, Map<String, dynamic> data) async {
    return _safeRequest(() async => await http.put(
          Uri.parse('$baseUrl/habits/$habitId'),
          headers: await _headers(),
          body: jsonEncode(data),
        ));
  }

  // ─── Notifications ─────────────────────────────────
  static Future<Map<String, dynamic>> getNotifications() async {
    return _safeRequest(() async => await http.get(
          Uri.parse('$baseUrl/notifications'),
          headers: await _headers(),
        ));
  }

  static Future<Map<String, dynamic>> createNotification(
      Map<String, dynamic> data) async {
    return _safeRequest(() async => await http.post(
          Uri.parse('$baseUrl/notifications'),
          headers: await _headers(),
          body: jsonEncode(data),
        ));
  }

  // ─── Calendar ──────────────────────────────────────
  static Future<Map<String, dynamic>> syncCalendar(
      Map<String, dynamic> data) async {
    return _safeRequest(() async => await http.post(
          Uri.parse('$baseUrl/calendar/sync'),
          headers: await _headers(),
          body: jsonEncode(data),
        ));
  }

  // ─── Preferences ──────────────────────────────────
  static Future<Map<String, dynamic>> getPreferences() async {
    return _safeRequest(() async => await http.get(
          Uri.parse('$baseUrl/preferences'),
          headers: await _headers(),
        ));
  }

  static Future<Map<String, dynamic>> updatePreferences(
      Map<String, dynamic> data) async {
    return _safeRequest(() async => await http.put(
          Uri.parse('$baseUrl/preferences'),
          headers: await _headers(),
          body: jsonEncode(data),
        ));
  }

  // ─── Additional CRUD ──────────────────────────────
  static Future<Map<String, dynamic>> deleteHabit(String habitId) async {
    return _safeRequest(() async => await http.delete(
          Uri.parse('$baseUrl/habits/$habitId'),
          headers: await _headers(),
        ));
  }

  static Future<Map<String, dynamic>> markNotificationRead(
      String notificationId) async {
    return _safeRequest(() async => await http.put(
          Uri.parse('$baseUrl/notifications/$notificationId/mark-read'),
          headers: await _headers(),
        ));
  }

  static Future<Map<String, dynamic>> deleteNotification(
      String notificationId) async {
    return _safeRequest(() async => await http.delete(
          Uri.parse('$baseUrl/notifications/$notificationId'),
          headers: await _headers(),
        ));
  }
}
