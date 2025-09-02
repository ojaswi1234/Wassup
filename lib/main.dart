// main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';

import 'package:ConnectUs/services/AuthChecker.dart';
import 'package:ConnectUs/pages/auth/profile.dart';
import 'package:ConnectUs/pages/chat/chatArea.dart';
import 'package:ConnectUs/pages/config/settings.dart';
import 'package:ConnectUs/pages/home/home.dart';
import 'package:ConnectUs/pages/landing.dart';
import 'package:ConnectUs/pages/auth/login.dart';
import 'package:ConnectUs/pages/auth/register.dart';
import 'package:ConnectUs/pages/auth/loginPhone.dart';
import 'package:ConnectUs/pages/auth/registerPhone.dart';
import 'package:ConnectUs/pages/contacts_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ConnectUs/services/socketService.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Performance optimization: Enable GPU rendering
  debugProfileBuildsEnabled = false;
  debugProfilePaintsEnabled = false;
  
  // Initialize Firebase with platform-specific options

  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Supabase.initialize(
    url: 'https://hkxvlihyacqpfdviyycy.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhreHZsaWh5YWNxcGZkdml5eWN5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTU4OTQxMzksImV4cCI6MjA3MTQ3MDEzOX0.vQDz72Zu6IVglI43t2VUTYVxzeMZbBPRki9zm4_VxF8',
    debug: false, // Set to true for debugging auth issues
  );

  // Initialize socket service
  SocketService().initializeSocket();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      // Performance optimizations
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
          child: child!,
        );
      },
      theme: ThemeData(
        // Pre-cache theme data for better performance
        useMaterial3: true,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
      routes: {
        '/': (context) => const AuthChecker(), // Use AuthChecker for session persistence
        '/landing': (context) => const Landing(),
        '/getStarted': (context) => Register(),
        '/login': (context) => Login(),
        '/home': (context) => Home(),
        '/chat': (context) => ChatArea(),
        '/contacts': (context) => ContactsPage(
          registeredContacts: [],
          nonRegisteredContacts: [],
          onContactTap: (contact) {},
          onInviteContact: (contact) {},
          isLoading: false,
        ),
        '/registerPhone': (context) => RegisterPhone(),
        '/loginPhone': (context) => LoginPhone(),
        '/profile': (context) => Profile(),
        '/settings': (context) => Settings(),
      },
    );
  }
}