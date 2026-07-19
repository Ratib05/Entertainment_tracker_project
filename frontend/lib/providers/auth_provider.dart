import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService apiService;
  final SupabaseClient supabaseClient;

  User? _currentUser;
  String? _accessToken;
  bool _isLoading = false;
  String? _error;

  AuthProvider({
    required this.apiService,
    required this.supabaseClient,
  }) {
    _checkAuthStatus();
  }

  User? get currentUser => _currentUser;
  String? get accessToken => _accessToken;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  void _checkAuthStatus() {
    final session = supabaseClient.auth.currentSession;
    if (session != null) {
      _currentUser = session.user;
      _accessToken = session.accessToken;
      apiService.setAuthToken(session.accessToken);
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    String? username,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final Map<String, dynamic> metadata = {};
      if (username != null && username.isNotEmpty) {
        metadata['username'] = username;
      }

      final AuthResponse response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: metadata.isNotEmpty ? metadata : null,
      );

      _currentUser = response.user;
      _accessToken = response.session?.accessToken;

      if (_accessToken != null) {
        apiService.setAuthToken(_accessToken!);
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final AuthResponse response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      _currentUser = response.user;
      _accessToken = response.session?.accessToken;

      if (_accessToken != null) {
        apiService.setAuthToken(_accessToken!);
        // Verify token works with backend
        await apiService.getMe();
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await supabaseClient.auth.signOut();
      _currentUser = null;
      _accessToken = null;
      apiService.clearAuthToken();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshToken() async {
    try {
      final session = supabaseClient.auth.currentSession;
      if (session != null) {
        _accessToken = session.accessToken;
        apiService.setAuthToken(_accessToken!);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
