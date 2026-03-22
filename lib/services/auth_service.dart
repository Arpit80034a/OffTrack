import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  UserModel? _user;
  String? _token;
  bool _isLoading = false;

  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _token != null;

  AuthService() {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    final name = prefs.getString('user_name');
    final email = prefs.getString('user_email');
    final userId = prefs.getString('user_id');

    if (_token != null && name != null && email != null && userId != null) {
      _user = UserModel(userId: userId, name: name, email: email);
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.login(email, password);
      if (response.containsKey('token')) {
        await _saveAuth(response);
        return {'success': true};
      }
      return {'success': false, 'error': response['error'] ?? 'Login failed'};
    } catch (e) {
      return {'success': false, 'error': 'Connection error. Please try again.'};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.register(name, email, password);
      if (response.containsKey('token')) {
        await _saveAuth(response);
        return {'success': true};
      }
      return {'success': false, 'error': response['error'] ?? 'Registration failed'};
    } catch (e) {
      return {'success': false, 'error': 'Connection error. Please try again.'};
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveAuth(Map<String, dynamic> response) async {
    _token = response['token'];
    final userData = response['user'];
    _user = UserModel.fromJson(userData);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', _token!);
    await prefs.setString('user_name', _user!.name);
    await prefs.setString('user_email', _user!.email);
    await prefs.setString('user_id', _user!.userId);
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}
