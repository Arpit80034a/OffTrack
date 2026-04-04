import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Auto-detect API service
  // Android emulator needs 10.0.2.2, everything else uses localhost
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:5000';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:5000';
    } catch (_) {}
    return 'http://localhost:5000';
  }

  static Future<String?> _getToken() async 
  {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) 
    {
      final token = await _getToken();
      if (token != null) 
      {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // ─── Auth ────
  static Future<Map<String, dynamic>> register(String name, String email, String password) async 
  {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: await _headers(auth: false),
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> login(String email, String password) async 
  {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: await _headers(auth: false),
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  // ─── Tasks ───
  static Future<Map<String, dynamic>> getTasks() async {
    final response = await http.get(
      Uri.parse('$baseUrl/tasks'),
      headers: await _headers(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createTask(Map<String, dynamic> taskData) async 
  {
    final response = await http.post(
      Uri.parse('$baseUrl/tasks'),
      headers: await _headers(),
      body: jsonEncode(taskData),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateTask(String taskId, Map<String, dynamic> data) async 
  {
    final response = await http.put(
      Uri.parse('$baseUrl/tasks/$taskId'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteTask(String taskId) async 
  {
    final response = await http.delete(
      Uri.parse('$baseUrl/tasks/$taskId'),
      headers: await _headers(),
    );
    return jsonDecode(response.body);
  }

  // ─── Schedule ────
  static Future<Map<String, dynamic>> generateSchedule() async 
  {
    final response = await http.post(
      Uri.parse('$baseUrl/schedule/generate'),
      headers: await _headers(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getSchedule({String? date}) async 
  {
    String url = '$baseUrl/schedule';
    if (date != null) url += '?date=$date';
    final response = await http.get(
      Uri.parse(url),
      headers: await _headers(),
    );
    return jsonDecode(response.body);
  }

  // ─── Habits ────
  static Future<Map<String, dynamic>> getHabits() async
  {
    final response = await http.get(
      Uri.parse('$baseUrl/habits'),
      headers: await _headers(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createHabit(Map<String, dynamic> data) async
  {
    final response = await http.post(
      Uri.parse('$baseUrl/habits'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateHabit(String habitId, Map<String, dynamic> data) async 
  {
    final response = await http.put(
      Uri.parse('$baseUrl/habits/$habitId'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  // ─── Notifications ────
  static Future<Map<String, dynamic>> getNotifications() async 
  {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications'),
      headers: await _headers(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> createNotification(Map<String, dynamic> data) async 
  {
    final response = await http.post(
      Uri.parse('$baseUrl/notifications'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  // ─── Calendar ────
  static Future<Map<String, dynamic>> syncCalendar(Map<String, dynamic> data) async
  {
    final response = await http.post(
      Uri.parse('$baseUrl/calendar/sync'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  // ─── Preferences ───
  static Future<Map<String, dynamic>> getPreferences() async 
  {
    final response = await http.get(
      Uri.parse('$baseUrl/preferences'),
      headers: await _headers(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updatePreferences(Map<String, dynamic> data) async
  {
    final response = await http.put(
      Uri.parse('$baseUrl/preferences'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }

  // ─── Additional CRUD ────
  static Future<Map<String, dynamic>> deleteHabit(String habitId) async 
  {
    final response = await http.delete(
      Uri.parse('$baseUrl/habits/$habitId'),
      headers: await _headers(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> markNotificationRead(String notificationId) async
  {
    final response = await http.put(
      Uri.parse('$baseUrl/notifications/$notificationId/mark-read'),
      headers: await _headers(),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteNotification(String notificationId) async
  {
    final response = await http.delete(
      Uri.parse('$baseUrl/notifications/$notificationId'),
      headers: await _headers(),
    );
    return jsonDecode(response.body);
  }
}
