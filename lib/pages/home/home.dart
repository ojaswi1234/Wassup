import 'package:ConnectUs/pages/chat/contactSelectionPage.dart';
import 'package:image_picker/image_picker.dart';

import 'status.dart';
import 'package:flutter/material.dart';
import 'package:ConnectUs/pages/home/home_page.dart';
import 'package:ConnectUs/pages/home/community.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

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

  final ImagePicker _picker = ImagePicker();
  File? _imageFile;

  Future<void> _openingCamera() async {
    if(Platform.isAndroid || Platform.isIOS){
    if (!mounted) return;
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
     
    }
      showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Display the captured image
              if (_imageFile != null)
                Image.file(
                  _imageFile!,
                  height: 200,
                ),
              // Buttons for Retake and Use Photo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    child: const Text('Retake'),
                    onPressed: () {
                      // Close the current dialog
                      Navigator.of(context).pop();
                      // Re-open the camera
                      _openingCamera();
                    },
                  ),
                  TextButton(
                    child: const Text('Use Photo'),
                    onPressed: () {
                      // Close the dialog before navigating
                      Navigator.of(context).pop();

                      // Navigate to the contact selection page, passing the image file
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ContactSelectionPage(
                            imageFile: _imageFile!,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
    } else {
      // Handle non-mobile platforms if necessary
     AlertDialog(
        title: const Text('Camera Not Supported'),
        content: const Text('Camera functionality is only available on mobile devices.'),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
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
          MaterialButton(
            minWidth: 52,
            height: 52,
            padding: const EdgeInsets.all(0),
            shape: const CircleBorder(),
            onPressed: () {
              // Implement search functionality
            },
            child: const Icon(Icons.dark_mode, color: Colors.white),
          ),
          MaterialButton(
            minWidth: 52,
            height: 52,
            padding: const EdgeInsets.all(0),
            shape: const CircleBorder(),
            onPressed: _openingCamera,
            child: const Icon(Icons.camera_alt_outlined, color: Colors.white),
          ),
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