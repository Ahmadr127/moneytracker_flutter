import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'data/services/auth_service.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/home_page.dart';
import 'config/routes.dart';
import 'config/constants.dart';
import 'config/theme/app_theme.dart';

void main() async {
  print('🚀 [APP] Starting Money Tracker App...');
  
  WidgetsFlutterBinding.ensureInitialized();
  
  print('🔧 [APP] Initializing Supabase...');
  print('   - URL: ${AppConstants.baseUrl}');
  print('   - Anon Key: ${AppConstants.anonKey.substring(0, 20)}...');
  
  await Supabase.initialize(
    url: AppConstants.baseUrl,
    anonKey: AppConstants.anonKey,
  );
  
  print('✅ [APP] Supabase initialized successfully');
  print('🚀 [APP] Running app...');
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Money Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const AuthWrapper(),
      routes: AppRoutes.getRoutes(),
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    print('🔍 [AUTH_WRAPPER] Checking authentication state...');
    
    // Listen to auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      print('👂 [AUTH_WRAPPER] Auth state change detected:');
      print('   - Event: ${data.event}');
      print('   - Session: ${data.session != null ? 'Active' : 'None'}');
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        print('✅ [AUTH_WRAPPER] State updated, loading set to false');
      }
    });

    // Check initial auth state
    print('⏳ [AUTH_WRAPPER] Waiting for initial auth check...');
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      print('✅ [AUTH_WRAPPER] Initial auth check completed');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Check if user is authenticated
    final currentUser = _authService.currentUser;
    
    if (currentUser != null) {
      return const HomePage();
    } else {
      return const LoginPage();
    }
  }
}
