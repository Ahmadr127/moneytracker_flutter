import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/constants.dart';

class SupabaseClientWrapper {
  static SupabaseClient get client => Supabase.instance.client;
  
  // Auth methods
  static Session? get currentSession {
    final session = client.auth.currentSession;
    print('🔐 [CLIENT] Current session: ${session != null ? 'Active' : 'None'}');
    if (session != null) {
      print('   - User ID: ${session.user.id}');
      print('   - Expires: ${session.expiresAt}');
    }
    return session;
  }
  
  static User? get currentUser {
    final user = client.auth.currentUser;
    print('👤 [CLIENT] Current user: ${user != null ? 'Logged in' : 'None'}');
    if (user != null) {
      print('   - ID: ${user.id}');
      print('   - Email: ${user.email}');
      print('   - Email confirmed: ${user.emailConfirmedAt}');
    }
    return user;
  }
  
  // Check if user is authenticated
  static bool get isAuthenticated {
    final authenticated = currentUser != null;
    print('🔒 [CLIENT] Authentication status: $authenticated');
    return authenticated;
  }
  
  // Get user ID
  static String? get userId {
    final id = currentUser?.id;
    print('🆔 [CLIENT] User ID: $id');
    return id;
  }
  
  // Listen to auth state changes
  static Stream<AuthState> get authStateChanges {
    print('👂 [CLIENT] Setting up auth state listener');
    return client.auth.onAuthStateChange;
  }
  
  // Database operations
  static SupabaseQueryBuilder from(String table) {
    print('📊 [CLIENT] Database query to table: $table');
    return client.from(table);
  }
  
  // Storage operations
  static SupabaseStorageClient get storage {
    print('💾 [CLIENT] Accessing storage');
    return client.storage;
  }
  
  // Real-time operations
  static RealtimeChannel channel(String name) {
    print('📡 [CLIENT] Creating realtime channel: $name');
    return client.channel(name);
  }
  
  // RPC (Remote Procedure Call)
  static PostgrestTransformBuilder rpc(
    String function, {
    Map<String, dynamic>? params,
  }) {
    print('🔄 [CLIENT] RPC call to function: $function');
    if (params != null) {
      print('   - Params: $params');
    }
    return client.rpc(function, params: params);
  }
}

// Extension methods for easier database operations
extension SupabaseClientExtension on SupabaseClient {
  // Get profiles table
  SupabaseQueryBuilder get profiles => 
      from(AppConstants.profilesTable);
  
  // Get users table
  SupabaseQueryBuilder get users => 
      from(AppConstants.usersTable);
  
  // Get transactions table
  SupabaseQueryBuilder get transactions => 
      from(AppConstants.transactionsTable);
  
  // Get categories table
  SupabaseQueryBuilder get categories => 
      from(AppConstants.categoriesTable);
  
  // Get wallets table
  SupabaseQueryBuilder get wallets => 
      from(AppConstants.walletsTable);
}
