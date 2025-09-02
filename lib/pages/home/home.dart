import 'status.dart';
import 'package:flutter/material.dart';
import 'package:ConnectUs/pages/home/home_page.dart';
import 'package:ConnectUs/pages/home/community.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  int _selectedSection = 0;
  late PageController _pageController;
  
  // Cache widgets to prevent unnecessary rebuilds
  late final List<Widget> _pages = [
    const Home_Page(),
    const Status(),
    const Community(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'ConnectUs',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'EduNSWACTCursive',
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFFA67B00),
        elevation: 2,
        actions: [
          PopupMenuButton(
            color: Colors.black,
            icon: const Icon(Icons.settings, color: Colors.white),
            itemBuilder: (context) => [
               PopupMenuItem(
                value: 'new_group',
                child: Text('New Group', style: TextStyle(color: Color(0xFFFFD54F))),
              ),
               PopupMenuItem(
                value: 'settings',
                child: Text('Settings', style: TextStyle(color: Color(0xFFFFD54F))),
                onTap: () {
                  // Navigate to the settings page
                  Navigator.pushNamed(context, '/settings');
                },
              ),
               PopupMenuItem(
                value: 'logout',
                child: Text('Logout', style: TextStyle(color: Color(0xFFFFD54F))),
                onTap: () async {
    try {
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: $e'), backgroundColor: Colors.red),
      );
    }
  },
               ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF1E1E1E),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.chat, color: Color(0xFFFFC107)),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications, color: Color(0xFFFFC107)),
            label: 'Status',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group, color: Color(0xFFFFC107)),
            label: 'Communities',
          ),
        ],
        currentIndex: _selectedSection,
        unselectedItemColor: Color(0xFFFFD54F),
        selectedItemColor: Color(0xFFA67B00),
        onTap: (index) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
          );
        },
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedSection = index;
          });
        },
        children: _pages,
      ),
    );
  }
}