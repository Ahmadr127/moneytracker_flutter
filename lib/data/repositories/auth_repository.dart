import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../../core/network/supabase_client.dart';
import '../../core/error/auth_error.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final AuthService _authService = AuthService();
  
  // Get current user
  UserModel? get currentUser => _authService.currentUser;
  
  // Check if user is authenticated
  bool get isAuthenticated => SupabaseClientWrapper.isAuthenticated;
  
  // Get user ID
  String? get userId => SupabaseClientWrapper.userId;
  
  // Sign up with email and password
  Future<AuthResult> signUp(String email, String password, String fullName) async {
    try {
      print('🚀 [REPO] Starting sign up process...');
      print('📝 [REPO] Input data: {email: $email, fullName: $fullName}');
      
      final response = await _authService.signUp(email, password, fullName);
      
      print('✅ [REPO] Auth service response received');
      
      if (response.user != null) {
        print('👤 [REPO] Creating UserModel from response');
        
        final userModel = UserModel(
          id: response.user!.id,
          email: email,
          fullName: fullName,
          createdAt: DateTime.now(),
        );
        
        print('✅ [REPO] UserModel created: ${userModel.toJson()}');
        
        return AuthResult.success(
          user: userModel,
          message: 'Registrasi berhasil! Silakan cek email Anda untuk verifikasi.',
        );
      } else {
        print('❌ [REPO] No user in response');
        return AuthResult.failure('Gagal membuat akun. Silakan coba lagi.');
      }
    } catch (e) {
      print('❌ [REPO] Error in sign up: $e');
      final errorMessage = AuthError.getSupabaseErrorMessage(e);
      print('📝 [REPO] User-friendly error: $errorMessage');
      return AuthResult.failure(errorMessage);
    }
  }
  
  // Sign in with email and password
  Future<AuthResult> signIn(String email, String password) async {
    try {
      print('🚀 [REPO] Starting sign in process...');
      print('📝 [REPO] Input data: {email: $email}');
      
      final response = await _authService.signIn(email, password);
      
      print('✅ [REPO] Auth service sign in response received');
      
      if (response.user != null) {
        print('👤 [REPO] User authenticated, fetching profile...');
        
        // Get user profile from database
        final userProfile = await _authService.getUserProfile(response.user!.id);
        
        if (userProfile != null) {
          print('✅ [REPO] User profile fetched successfully: ${userProfile.toJson()}');
          return AuthResult.success(
            user: userProfile,
            message: 'Login berhasil!',
          );
        } else {
          print('❌ [REPO] User profile not found in database');
          return AuthResult.failure('Profil user tidak ditemukan.');
        }
      } else {
        print('❌ [REPO] No user in sign in response');
        return AuthResult.failure('Gagal login. Silakan cek email dan password.');
      }
    } catch (e) {
      print('❌ [REPO] Error in sign in: $e');
      final errorMessage = AuthError.getSupabaseErrorMessage(e);
      print('📝 [REPO] User-friendly error: $errorMessage');
      return AuthResult.failure(errorMessage);
    }
  }
  
  // Sign out
  Future<AuthResult> signOut() async {
    try {
      await _authService.signOut();
      return AuthResult.success(
        user: null,
        message: 'Logout berhasil!',
      );
    } catch (e) {
      final errorMessage = AuthError.getSupabaseErrorMessage(e);
      return AuthResult.failure(errorMessage);
    }
  }
  
  // Update user profile
  Future<AuthResult> updateProfile(String userId, Map<String, dynamic> data) async {
    try {
      await _authService.updateUserProfile(userId, data);
      
      // Get updated user profile
      final updatedProfile = await _authService.getUserProfile(userId);
      
      if (updatedProfile != null) {
        return AuthResult.success(
          user: updatedProfile,
          message: 'Profil berhasil diperbarui!',
        );
      } else {
        return AuthResult.failure('Gagal mengambil profil yang diperbarui.');
      }
    } catch (e) {
      final errorMessage = AuthError.getSupabaseErrorMessage(e);
      return AuthResult.failure(errorMessage);
    }
  }
  
  // Get user profile
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      return await _authService.getUserProfile(userId);
    } catch (e) {
      return null;
    }
  }
  
  // Listen to auth state changes
  Stream<AuthState> get authStateChanges => SupabaseClientWrapper.authStateChanges;
}

// Result class for auth operations
class AuthResult {
  final bool isSuccess;
  final UserModel? user;
  final String message;
  
  AuthResult._({
    required this.isSuccess,
    this.user,
    required this.message,
  });
  
  factory AuthResult.success({UserModel? user, String message = 'Berhasil!'}) {
    return AuthResult._(
      isSuccess: true,
      user: user,
      message: message,
    );
  }
  
  factory AuthResult.failure(String message) {
    return AuthResult._(
      isSuccess: false,
      message: message,
    );
  }
}
