import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../../core/network/supabase_client.dart';
import '../../core/error/auth_error.dart';

class AuthService {
  final SupabaseClient supabase = SupabaseClientWrapper.client;

  /// Get current user
  UserModel? get currentUser {
    final user = supabase.auth.currentUser;
    if (user != null) {
      return UserModel(
        id: user.id,
        email: user.email ?? '',
        fullName: user.userMetadata?['full_name'],
        createdAt: user.createdAt != null ? DateTime.parse(user.createdAt!) : null,
      );
    }
    return null;
  }

  /// Sign up with email and password
  Future<AuthResponse> signUp(String email, String password, String fullName) async {
    try {
      print('🔐 [AUTH] Attempting sign up for: $email');
      print('📝 [AUTH] User data: {full_name: $fullName}');
      
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
        },
      );
      
      print('✅ [AUTH] Sign up response:');
      print('   - User ID: ${response.user?.id}');
      print('   - Email: ${response.user?.email}');
      print('   - Email confirmed: ${response.user?.emailConfirmedAt}');
      print('   - Session: ${response.session != null ? 'Created' : 'None'}');
      
      // Safe substring untuk access token jika ada
      final accessToken = response.session?.accessToken;
      if (accessToken != null && accessToken.isNotEmpty) {
        final tokenLength = accessToken.length;
        final displayLength = tokenLength > 20 ? 20 : tokenLength;
        print('   - Session ID: ${accessToken.substring(0, displayLength)}...');
      }
      
      if (response.user != null) {
        print('📊 [DB] Inserting user profile to profiles table...');
        
        try {
          final profileData = {
            'id': response.user!.id,
            'email': email,
            'full_name': fullName,
            'created_at': DateTime.now().toIso8601String(),
          };
          
          print('📝 [DB] Profile data: $profileData');
          
          await supabase.from('profiles').insert(profileData);
          print('✅ [DB] Profile inserted successfully');
        } catch (dbError) {
          print('⚠️ [DB] Profile insertion failed: $dbError');
          print('⚠️ [DB] This might be due to missing table or permissions');
          print('⚠️ [DB] User account created but profile not saved');
          
          // Try to create profile again after a delay
          await Future.delayed(Duration(seconds: 2));
          try {
            print('🔄 [DB] Retrying profile creation...');
            await supabase.from('profiles').insert({
              'id': response.user!.id,
              'email': email,
              'full_name': fullName,
              'created_at': DateTime.now().toIso8601String(),
            });
            print('✅ [DB] Profile created on retry');
          } catch (retryError) {
            print('❌ [DB] Profile creation retry failed: $retryError');
          }
        }
      }
      
      return response;
    } catch (e) {
      print('❌ [AUTH] Sign up error: $e');
      print('❌ [AUTH] Error type: ${e.runtimeType}');
      
      // Handle specific Supabase errors
      if (e.toString().contains('profiles')) {
        throw Exception('Akun berhasil dibuat, tetapi ada masalah dengan database. Silakan hubungi admin.');
      } else if (e.toString().contains('already registered')) {
        throw Exception('Email sudah terdaftar. Silakan gunakan email lain atau login.');
      } else if (e.toString().contains('password')) {
        throw Exception('Password terlalu lemah. Minimal 6 karakter.');
      } else if (e.toString().contains('email')) {
        throw Exception('Format email tidak valid.');
      } else {
        throw Exception('Gagal mendaftar: ${e.toString()}');
      }
    }
  }

  /// Sign in with email and password
  Future<AuthResponse> signIn(String email, String password) async {
    try {
      print('🔐 [AUTH] Attempting sign in for: $email');
      
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      // Log response dengan aman
      _logAuthResponse(response);
      
      // Check if user has profile, if not create one
      if (response.user != null) {
        try {
          final existingProfile = await supabase
              .from('profiles')
              .select()
              .eq('id', response.user!.id)
              .maybeSingle();
          
          if (existingProfile == null) {
            print('⚠️ [AUTH] User profile not found, creating one...');
            
            // Try to get user metadata for full_name
            String fullName = response.user!.userMetadata?['full_name'] ?? 'User';
            
            await supabase.from('profiles').insert({
              'id': response.user!.id,
              'email': email,
              'full_name': fullName,
              'created_at': DateTime.now().toIso8601String(),
            });
            
            print('✅ [AUTH] Profile created during login');
          } else {
            print('✅ [AUTH] User profile found: ${existingProfile['full_name']}');
          }
        } catch (profileError) {
          print('⚠️ [AUTH] Profile check/creation failed: $profileError');
          // Don't fail login if profile creation fails
        }
      }
      
      return response;
    } catch (e) {
      print('❌ [AUTH] Sign in error: $e');
      print('❌ [AUTH] Error type: ${e.runtimeType}');
      
      // Handle specific auth errors
      if (e.toString().contains('invalid_credentials')) {
        throw Exception('Email atau password salah. Silakan cek kembali.');
      } else if (e.toString().contains('email not confirmed') || e.toString().contains('email_not_confirmed')) {
        throw Exception('Email belum diverifikasi. Silakan cek email Anda dan klik link verifikasi.');
      } else if (e.toString().contains('too many requests')) {
        throw Exception('Terlalu banyak percobaan. Silakan tunggu beberapa saat.');
      } else if (e.toString().contains('RangeError') || e.toString().contains('Invalid value')) {
        // RangeError biasanya terjadi setelah login berhasil, jadi kita anggap sukses
        print('⚠️ [AUTH] RangeError detected but login was successful');
        // Karena login sebenarnya berhasil, kita throw exception yang friendly
        throw Exception('Login berhasil, tetapi ada masalah teknis. Silakan coba lagi.');
      } else {
        throw Exception('Gagal login: ${e.toString()}');
      }
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      print('🚪 [AUTH] Attempting sign out...');
      
      await supabase.auth.signOut();
      
      print('✅ [AUTH] Sign out successful');
    } catch (e) {
      print('❌ [AUTH] Sign out error: $e');
      print('❌ [AUTH] Error type: ${e.runtimeType}');
      throw Exception('Gagal logout: ${e.toString()}');
    }
  }

  /// Get user profile from database
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      print('📊 [DB] Fetching user profile for ID: $userId');
      
      final response = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      
      print('✅ [DB] Profile data received: $response');
      
      final userModel = UserModel.fromJson(response);
      print('✅ [DB] UserModel created: ${userModel.toJson()}');
      
      return userModel;
    } catch (e) {
      print('❌ [DB] Error fetching profile: $e');
      print('❌ [DB] Error type: ${e.runtimeType}');
      return null;
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    try {
      await supabase
          .from('profiles')
          .update(data)
          .eq('id', userId);
    } catch (e) {
      throw Exception('Gagal update profile: ${e.toString()}');
    }
  }

  /// Safe logging untuk auth response
  void _logAuthResponse(AuthResponse response) {
    try {
      print('✅ [AUTH] Sign in response:');
      print('   - User ID: ${response.user?.id}');
      print('   - Email: ${response.user?.email}');
      print('   - Session: ${response.session != null ? 'Active' : 'None'}');
      print('   - Access Token Length: ${response.session?.accessToken?.length ?? 0}');
      print('   - Refresh Token Length: ${response.session?.refreshToken?.length ?? 0}');
    } catch (e) {
      print('⚠️ [AUTH] Error logging response: $e');
      print('✅ [AUTH] Sign in successful but logging failed');
    }
  }
}
