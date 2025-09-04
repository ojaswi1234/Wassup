import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ConnectUs/pages/landing.dart';
import 'session_manager.dart';

class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  bool _isLoading = true;
  final _supabase = Supabase.instance.client;
  final _sessionManager = SessionManager();

  @override
  void initState() {
    super.initState();
    _initializeSession();
  }

  void _initializeSession() async {
    // Initialize session manager first
    await _sessionManager.initialize();
    
    // Try auto-login first if remember me is enabled
    final autoLoginSuccess = await _sessionManager.tryAutoLogin();
    if (autoLoginSuccess && mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
      return;
    }
    
    // If auto-login fails, check current session
    _checkSession();
    _listenToAuthChanges();
  }

  void _checkSession() async {
    try {
      // Check if user has valid session
      final session = _supabase.auth.currentSession;
      
      if (session != null) {
        // Verify session is still valid
        final user = await _supabase.auth.getUser();
        if (user.user != null) {
          print('✅ Valid session found for: ${user.user!.email}');
          // Session is valid, go to home
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
          return;
        }
      }
      
      print('❌ No valid session found');
      // No valid session, stay on landing/login
      setState(() => _isLoading = false);
      
    } catch (e) {
      print('Session check error: $e');
      setState(() => _isLoading = false);
    }
  }

  void _listenToAuthChanges() {
    _supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      print('Auth state changed: $event');

      switch (event) {
        case AuthChangeEvent.signedIn:
          print('✅ User signed in: ${session?.user.email}');
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
          break;
        case AuthChangeEvent.signedOut:
          print('❌ User signed out');
          if (mounted) {
            Navigator.of(context).pushReplacementNamed('/landing');
          }
          break;
        case AuthChangeEvent.tokenRefreshed:
          print('🔄 Token refreshed');
          break;
        default:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
         backgroundColor: Color(0xFF1E1E1E),
      body: Center(
        
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children:[
            Image(image: AssetImage('assets/images/logo.png'), height: 250, width: 250,),
             SizedBox(height: 32,),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
            ),
            SizedBox(height: 32,),
        Text("Checking Authentication Please Wait.....", style: TextStyle(color: Colors.yellow)),
        ]

      ),
      ),
      );
    }

    // No session found, show landing page
    return const Landing();
  }
}