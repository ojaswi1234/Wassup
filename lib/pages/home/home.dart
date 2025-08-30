import 'package:ConnectUs/pages/home/status.dart';
import 'package:flutter/material.dart';
import 'package:ConnectUs/pages/home/home_page.dart';
import 'package:ConnectUs/pages/home/community.dart';
class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedSection = 0;

  Widget _getBody() {
    switch (_selectedSection) {
      case 1:
        return const Status();
      case 2:
        return const Community();
      default:
        return const Home_Page(); // Use your chat/contact page here
    }
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
                onTap: () {
                  // Add your logout logic here
                  // For example, navigate to the login screen
                  Navigator.pushReplacementNamed(context, '/login');
                }
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
          setState(() {
            _selectedSection = index;
          });
        },
      ),
      body: _getBody(),
    );
  }
}