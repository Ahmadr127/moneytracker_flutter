import 'package:flutter/foundation.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';

class AuthState extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  
  // Constructor
  AuthState() {
    _initializeAuth();
  }
  
  // Initialize auth state
  void _initializeAuth() {
    _currentUser = _authRepository.currentUser;
    notifyListeners();
  }
  
  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  // Set error message
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  // Sign in
  Future<bool> signIn(String email, String password) async {
    try {
      _setLoading(true);
      _setError(null);
      
      final result = await _authRepository.signIn(email, password);
      
      if (result.isSuccess) {
        _currentUser = result.user;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError(result.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Terjadi kesalahan yang tidak diketahui.');
      _setLoading(false);
      return false;
    }
  }
  
  // Sign up
  Future<bool> signUp(String email, String password, String fullName) async {
    try {
      _setLoading(true);
      _setError(null);
      
      final result = await _authRepository.signUp(email, password, fullName);
      
      if (result.isSuccess) {
        _setLoading(false);
        return true;
      } else {
        _setError(result.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Terjadi kesalahan yang tidak diketahui.');
      _setLoading(false);
      return false;
    }
  }
  
  // Sign out
  Future<bool> signOut() async {
    try {
      _setLoading(true);
      _setError(null);
      
      final result = await _authRepository.signOut();
      
      if (result.isSuccess) {
        _currentUser = null;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError(result.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Terjadi kesalahan yang tidak diketahui.');
      _setLoading(false);
      return false;
    }
  }
  
  // Update profile
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      _setLoading(true);
      _setError(null);
      
      if (_currentUser == null) {
        _setError('User tidak ditemukan.');
        _setLoading(false);
        return false;
      }
      
      final result = await _authRepository.updateProfile(_currentUser!.id, data);
      
      if (result.isSuccess) {
        _currentUser = result.user;
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError(result.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Terjadi kesalahan yang tidak diketahui.');
      _setLoading(false);
      return false;
    }
  }
  
  // Refresh user data
  Future<void> refreshUserData() async {
    if (_currentUser != null) {
      final updatedUser = await _authRepository.getUserProfile(_currentUser!.id);
      if (updatedUser != null) {
        _currentUser = updatedUser;
        notifyListeners();
      }
    }
  }
  
  // Set user manually (for testing or external auth)
  void setUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }
  
  // Clear user (for logout or session expiry)
  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }
}
