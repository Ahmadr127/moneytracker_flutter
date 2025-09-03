import 'package:flutter/material.dart';
import '../../data/services/auth_service.dart';
import '../../data/models/user_model.dart';
import 'tabs/dashboard_page.dart';
import 'tabs/add_page.dart';
import 'tabs/history_page.dart';
import 'tabs/profile_page.dart';
import '../widgets/app_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  int _currentIndex = 0;
  // Keys to access child states for refresh
  final GlobalKey<DashboardPageState> _dashboardKey = GlobalKey<DashboardPageState>();
  final GlobalKey<AddPageState> _addKey = GlobalKey<AddPageState>();
  final GlobalKey<HistoryPageState> _historyKey = GlobalKey<HistoryPageState>();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = _authService.currentUser;
    if (user != null) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  Future<void> _logout() async {
    print('🚪 [HOME_PAGE] Logout attempt started');
    
    try {
      print('🚀 [HOME_PAGE] Calling auth service signOut...');
      
      await _authService.signOut();
      
      print('✅ [HOME_PAGE] Logout successful, navigating to login');
      
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      print('❌ [HOME_PAGE] Logout error: $e');
      print('❌ [HOME_PAGE] Error type: ${e.runtimeType}');
      
      if (mounted) {
        final errorMessage = 'Gagal logout: ${e.toString()}';
        print('📝 [HOME_PAGE] Showing error snackbar: $errorMessage');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      endDrawer: AppDrawer(onLogout: _logout),
      appBar: AppBar(
        toolbarHeight: 72,
        automaticallyImplyLeading: false,
        leadingWidth: 64,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: CircleAvatar(
            radius: 22,
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
            child: Text(
              (_currentUser?.fullName?.substring(0, 1) ?? 'U').toUpperCase(),
          style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
              'Money Tracker',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 2),
                      Text(
              'Hai, ${_currentUser?.fullName ?? 'User'}',
              style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
        actions: [
          Builder(builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
              tooltip: 'Menu',
            );
          }),
          const SizedBox(width: 8),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
            children: [
          DashboardPage(key: _dashboardKey, currentUser: _currentUser),
          AddPage(key: _addKey),
          HistoryPage(key: _historyKey),
          ProfilePage(currentUser: _currentUser),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Tambah',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
