import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';

class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  final _supabase = Supabase.instance.client;
  final _logger = Logger();
  SharedPreferences? _prefs;

  // Keys for storing session data
  static const String _keyRememberMe = 'remember_me';
  static const String _keyLastLoginEmail = 'last_login_email';
  static const String _keySessionExpiry = 'session_expiry';

  /// Initialize session manager
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _logger.i('SessionManager initialized');
  }

  /// Check if user wants to stay logged in
  Future<bool> getRememberMe() async {
    await _ensureInitialized();
    return _prefs?.getBool(_keyRememberMe) ?? false;
  }

  /// Set remember me preference
  Future<void> setRememberMe(bool remember) async {
    await _ensureInitialized();
    await _prefs?.setBool(_keyRememberMe, remember);
    _logger.i('Remember me set to: $remember');
  }

  /// Save last login email
  Future<void> saveLastLoginEmail(String email) async {
    await _ensureInitialized();
    await _prefs?.setString(_keyLastLoginEmail, email);
  }

  /// Get last login email
  Future<String?> getLastLoginEmail() async {
    await _ensureInitialized();
    return _prefs?.getString(_keyLastLoginEmail);
  }

  /// Check if current session is valid
  Future<bool> isSessionValid() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) {
        _logger.w('No current session found');
        return false;
      }

      // Check if token is expired
      final expiresAt = session.expiresAt;
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      if (expiresAt != null && now >= expiresAt) {
        _logger.w('Session token expired');
        return false;
      }

      // Try to get user to verify session is still valid
      final user = await _supabase.auth.getUser();
      if (user.user != null) {
        _logger.i('Session is valid for user: ${user.user!.email}');
        return true;
      }

      return false;
    } catch (e) {
      _logger.e('Session validation error: $e');
      return false;
    }
  }

  /// Refresh session token if needed
  Future<bool> refreshSessionIfNeeded() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) return false;

      // Check if token expires within next 5 minutes
      final expiresAt = session.expiresAt;
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      if (expiresAt != null && (expiresAt - now) < 300) { // 5 minutes
        _logger.i('Refreshing session token...');
        final response = await _supabase.auth.refreshSession();
        if (response.session != null) {
          _logger.i('Session refreshed successfully');
          return true;
        }
      }

      return true;
    } catch (e) {
      _logger.e('Session refresh error: $e');
      return false;
    }
  }

  /// Enhanced login with remember me functionality
  Future<AuthResponse> signInWithEmailAndPassword({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null) {
        await setRememberMe(rememberMe);
        await saveLastLoginEmail(email);
        _logger.i('Login successful with remember me: $rememberMe');
      }

      return response;
    } catch (e) {
      _logger.e('Login error: $e');
      rethrow;
    }
  }

  /// Sign out and clear session data
  Future<void> signOut({bool clearRememberMe = false}) async {
    try {
      await _supabase.auth.signOut();
      
      if (clearRememberMe) {
        await setRememberMe(false);
        await _prefs?.remove(_keyLastLoginEmail);
        _logger.i('Signed out and cleared remember me data');
      } else {
        _logger.i('Signed out but kept remember me settings');
      }
    } catch (e) {
      _logger.e('Sign out error: $e');
      rethrow;
    }
  }

  /// Get current user info
  User? get currentUser => _supabase.auth.currentUser;

  /// Check if user is currently logged in
  bool get isLoggedIn => currentUser != null;

  /// Ensure SharedPreferences is initialized
  Future<void> _ensureInitialized() async {
    if (_prefs == null) {
      await initialize();
    }
  }

  /// Auto-login if remember me is enabled and session is valid
  Future<bool> tryAutoLogin() async {
    try {
      final rememberMe = await getRememberMe();
      if (!rememberMe) {
        _logger.i('Remember me is disabled');
        return false;
      }

      final isValid = await isSessionValid();
      if (isValid) {
        await refreshSessionIfNeeded();
        _logger.i('Auto-login successful');
        return true;
      }

      _logger.w('Auto-login failed - invalid session');
      return false;
    } catch (e) {
      _logger.e('Auto-login error: $e');
      return false;
    }
  }

  /// Clear all session data (for debugging)
  Future<void> clearAllSessionData() async {
    await _ensureInitialized();
    await _prefs?.clear();
    await _supabase.auth.signOut();
    _logger.w('All session data cleared');
  }
}
