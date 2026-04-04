import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  UserModel? _user;
  String? _token;
  bool _isLoading = false;

  // ==================== GETTERS ====================

  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _token != null;

  // ==================== CONSTRUCTOR ====================

  AuthService() {
    _initializeAuth();
  }

  // ==================== INITIALIZATION ====================

  Future<void> _initializeAuth() async {
    await _loadUserFromPrefs();
  }

  // ==================== PUBLIC METHODS ====================

  Future<Map<String, dynamic>> login(String email, String password) async {
    return _handleAuth(() => ApiService.login(email, password));
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    return _handleAuth(() => ApiService.register(name, email, password));
  }

  Future<void> logout() async {
    _clearUserData();
    await _clearPrefs();
    notifyListeners();
  }

  // ==================== CORE AUTH HANDLER ====================

  Future<Map<String, dynamic>> _handleAuth(
    Future<Map<String, dynamic>> Function() apiCall,
  ) async {
    _setLoading(true);

    try {
      final response = await apiCall();

      if (response.containsKey('token')) {
        await _persistAuth(response);
        return {'success': true};
      }

      return {
        'success': false,
        'error': response['error'] ?? 'Operation failed'
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error. Please try again.'
      };
    } finally {
      _setLoading(false);
    }
  }

  // ==================== STATE HELPERS ====================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearUserData() {
    _user = null;
    _token = null;
  }

  // ==================== STORAGE HELPERS ====================

  Future<void> _loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString('auth_token');
    final name = prefs.getString('user_name');
    final email = prefs.getString('user_email');
    final userId = prefs.getString('user_id');

    if (token != null && name != null && email != null && userId != null) {
      _token = token;
      _user = UserModel(userId: userId, name: name, email: email);
      notifyListeners();
    }
  }

  Future<void> _persistAuth(Map<String, dynamic> response) async {
    final prefs = await SharedPreferences.getInstance();

    _token = response['token'];
    _user = UserModel.fromJson(response['user']);

    await prefs.setString('auth_token', _token!);
    await prefs.setString('user_name', _user!.name);
    await prefs.setString('user_email', _user!.email);
    await prefs.setString('user_id', _user!.userId);
  }

  Future<void> _clearPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
