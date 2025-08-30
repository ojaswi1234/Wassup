 import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ConnectUs/components/contactTile.dart';


// 1. Convert to a StatefulWidget to manage the state of the contacts list

class Home_Page extends StatefulWidget {
  const Home_Page({super.key});

  @override
  State<Home_Page> createState() => _Home_PageState();
}







class _Home_PageState extends State<Home_Page> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _searchController = TextEditingController();
  
  // 2. Create a list to hold the contacts in the state
  List<Contact> _contacts = [];
  final List<Chats> _chats = [ ];
 
  bool _isLoading = false; // To show a loading indicator
  List<Contact> _registeredContacts = [];
  List<Contact> _nonRegisteredContacts = [];

  // 3. Create a method within the state to fetch contacts
 Future<List<String>> _fetchRegisteredPhoneNumbers() async {
  try {
    print('Fetching registered phone numbers from Supabase...');
    final response = await Supabase.instance.client
        .from('users')
        .select('phone_number');

    print('Supabase response Success!!');

    final phoneNumbers = (response as List)
        .map((row) => row['phone_number'] as String)
        .where((number) => number.isNotEmpty)
        .toList();

   
    return phoneNumbers;
  } catch (e) {
    print('Error fetching registered phone numbers: $e');
    return [];
  }
}

Future<void> _categorizeContacts() async {
  final registeredNumbers = await _fetchRegisteredPhoneNumbers();
  final allContacts = await FlutterContacts.getContacts(withProperties: true);

  // Normalize all contacts for better matching
  final normalizedAllContacts = allContacts.map((contact) {
    return contact.phones.map((phone) => _normalizePhoneNumber(phone.number)).toList();
  }).toList();

  // Normalize registered numbers for better matching (remove all non-digits and handle country codes)
  final normalizedRegisteredNumbers = registeredNumbers
      .map((number) => _normalizePhoneNumber(number))
      .where((number) => number.isNotEmpty)
      .toSet();



  _registeredContacts = [];
  _nonRegisteredContacts = [];

  for (final contact in allContacts) {
    bool isRegistered = false;
    
    for (final phone in contact.phones) {
      final normalizedContactPhone = _normalizePhoneNumber(phone.number);
      
     
      
      // Check multiple variations of the phone number
      if (normalizedRegisteredNumbers.contains(normalizedContactPhone) ||
          normalizedRegisteredNumbers.contains('91$normalizedContactPhone') ||
          normalizedRegisteredNumbers.contains(normalizedContactPhone.substring(2))) {
        isRegistered = true;
      
        break;
      }
    }
    
    if (isRegistered) {
      _registeredContacts.add(contact);
    } else {
      _nonRegisteredContacts.add(contact);
    }
  }


}

// Helper method to normalize phone numbers
String _normalizePhoneNumber(String phoneNumber) {
  // Remove all non-digit characters
  String normalized = phoneNumber.replaceAll(RegExp(r'\D'), '');
  
  // Handle different country code formats
  if (normalized.startsWith('0')) {
    normalized = normalized.substring(1); // Remove leading 0
  }
  
  // If number starts with country code +91, keep it
  if (normalized.startsWith('91') && normalized.length == 12) {
    return normalized.substring(2); // Remove country code for comparison
  }
  
  return normalized;
}



  Future<void> _fetchContacts() async {
    // Request permission first
    if (!await FlutterContacts.requestPermission()) {
      print("Permission Denied");
      // Optionally, show a snackbar to the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission denied to access contacts.')),
      );
      return;
    }

    // Set loading state and fetch contacts
    setState(() {
      _isLoading = true;
      _registeredContacts = [];
    });

    try {
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: true,
      );
      _contacts = contacts;
      await _categorizeContacts();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _createChatWithContact(Contact contact) {
    // Add the contact to chats list
    setState(() {
      _chats.add(Chats(contactName: contact.displayName, lastMessage: 'Click here to start chatting'));
    });
    
    // Navigate to chat screen
    Navigator.pushNamed(context, '/chat');
  }

  void _inviteContact(Contact contact) {
    // Implement invite functionality here
    // For example, you could open a share dialog or send an SMS
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invite ${contact.displayName} to WassUp'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // 4. Show the bottom sheet with the fetched contacts
  void _showContactFlowDialog() {
    showModalBottomSheet( 
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        // Use StatefulBuilder to allow the bottom sheet's content to be updated.
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade600,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  
                  // Header
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 8, 20, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _contacts.isEmpty && !_isLoading 
                                ? "Contacts Permission" 
                                : 'Select Contact',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(Icons.close, color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                  ),
                  
                  // Search bar
                  if (_contacts.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search contacts...',
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                          filled: true,
                          fillColor: Colors.grey.shade800,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onChanged: (value) {
                          // Implement search functionality if needed
                        },
                      ),
                    ),
                  
                  // Content
                  Expanded(
                    child: _isLoading
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(color: Colors.orange),
                                SizedBox(height: 16),
                                Text(
                                  'Loading contacts...',
                                  style: TextStyle(color: Colors.grey.shade400),
                                ),
                              ],
                            ),
                          )
                        : _contacts.isNotEmpty
                           ? SingleChildScrollView(
                               padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                               child: Column(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                // Registered Contacts Section
                                if (_registeredContacts.isNotEmpty) ...[
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Colors.green.shade400, Colors.green.shade600],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.green.withOpacity(0.3),
                                          blurRadius: 8.0,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Icon(Icons.verified, color: Colors.white, size: 20),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'On WassUp',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Text(
                                                '${_registeredContacts.length} contacts ready to chat',
                                                style: TextStyle(
                                                  color: Colors.white.withOpacity(0.9),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '${_registeredContacts.length}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ...List.generate(_registeredContacts.length, (index) {
                                    final contact = _registeredContacts[index];
                                    return Container(
                                      margin: EdgeInsets.only(bottom: 8),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(12),
                                          onTap: () {
                                            Navigator.of(context).pop();
                                            _createChatWithContact(contact);
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.green.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.green.withOpacity(0.3),
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 50,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [Colors.green.shade400, Colors.green.shade600],
                                                      begin: Alignment.topLeft,
                                                      end: Alignment.bottomRight,
                                                    ),
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.green.withOpacity(0.3),
                                                        blurRadius: 6,
                                                        offset: Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Icon(Icons.person, color: Colors.white, size: 24),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        contact.displayName,
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.w600,
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        contact.phones.isNotEmpty
                                                            ? contact.phones.first.number
                                                            : 'No phone number',
                                                        style: TextStyle(
                                                          color: Colors.white70,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green.withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Icon(Icons.chat_bubble, color: Colors.green, size: 20),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                  const SizedBox(height: 20),
                                ],
                                
                                // Divider
                                if (_registeredContacts.isNotEmpty && _nonRegisteredContacts.isNotEmpty)
                                  Container(
                                    margin: EdgeInsets.symmetric(vertical: 16),
                                    child: Row(
                                      children: [
                                        Expanded(child: Divider(color: Colors.grey.shade600, thickness: 1)),
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 16),
                                          child: Text(
                                            'INVITE FRIENDS',
                                            style: TextStyle(
                                              color: Colors.grey.shade400,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ),
                                        Expanded(child: Divider(color: Colors.grey.shade600, thickness: 1)),
                                      ],
                                    ),
                                  ),
                                
                                // Non-Registered Contacts Section
                                if (_nonRegisteredContacts.isNotEmpty) ...[
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Colors.orange.shade400, Colors.orange.shade600],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.orange.withOpacity(0.3),
                                          blurRadius: 8.0,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Icon(Icons.person_add_alt_1, color: Colors.white, size: 20),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Invite to WassUp',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              Text(
                                                '${_nonRegisteredContacts.length} friends not on WassUp yet',
                                                style: TextStyle(
                                                  color: Colors.white.withOpacity(0.9),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            '${_nonRegisteredContacts.length}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ...List.generate(_nonRegisteredContacts.length, (index) {
                                    final contact = _nonRegisteredContacts[index];
                                    return Container(
                                      margin: EdgeInsets.only(bottom: 8),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(12),
                                          onTap: () {
                                            Navigator.of(context).pop();
                                            _inviteContact(contact);
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.orange.withOpacity(0.3),
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 50,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [Colors.orange.shade400, Colors.orange.shade600],
                                                      begin: Alignment.topLeft,
                                                      end: Alignment.bottomRight,
                                                    ),
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.orange.withOpacity(0.3),
                                                        blurRadius: 6,
                                                        offset: Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Icon(Icons.person_outline, color: Colors.white, size: 24),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        contact.displayName,
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.w600,
                                                          color: Colors.white,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 2),
                                                      Text(
                                                        contact.phones.isNotEmpty
                                                            ? contact.phones.first.number
                                                            : 'No phone number',
                                                        style: TextStyle(
                                                          color: Colors.white70,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  padding: EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: Colors.orange.withOpacity(0.2),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Icon(Icons.share, color: Colors.orange, size: 20),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ],
                                
                                if (_registeredContacts.isEmpty && _nonRegisteredContacts.isEmpty)
                                  Container(
                                    padding: EdgeInsets.all(32),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.contacts_outlined,
                                          size: 64,
                                          color: Colors.grey.shade400,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No contacts found',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Make sure you have contacts saved on your device',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade400,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                           )
                           : Padding(
                               padding: EdgeInsets.all(32),
                               child: Column(
                                 mainAxisAlignment: MainAxisAlignment.center,
                                 children: [
                                   Icon(
                                     Icons.contacts,
                                     size: 80,
                                     color: Colors.grey.shade500,
                                   ),
                                   SizedBox(height: 24),
                                   Text(
                                     'Access Your Contacts',
                                     style: TextStyle(
                                       fontSize: 20,
                                       fontWeight: FontWeight.bold,
                                       color: Colors.white,
                                     ),
                                   ),
                                   SizedBox(height: 12),
                                   Text(
                                     'To find friends to chat with, this app needs access to your contacts.',
                                     style: TextStyle(
                                       fontSize: 16,
                                       color: Colors.grey.shade400,
                                     ),
                                     textAlign: TextAlign.center,
                                   ),
                                   SizedBox(height: 32),
                                   ElevatedButton(
                                     onPressed: () async {
                                       setState(() {
                                         _isLoading = true;
                                       });
                                       await _fetchContacts();
                                       setState(() {
                                         _isLoading = false;
                                       });
                                     },
                                     style: ElevatedButton.styleFrom(
                                       backgroundColor: Colors.orange,
                                       foregroundColor: Colors.white,
                                       padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                       shape: RoundedRectangleBorder(
                                         borderRadius: BorderRadius.circular(12),
                                       ),
                                     ),
                                     child: Text(
                                       'Grant Access',
                                       style: TextStyle(
                                         fontSize: 16,
                                         fontWeight: FontWeight.w600,
                                       ),
                                     ),
                                   ),
                                 ],
                               ),
                             ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) {
      // Reset state when the bottom sheet is closed
      setState(() {
        _contacts = [];
        _isLoading = false;
        _searchController.clear();
      });
    });
  }

  void _showPermissionExplanationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Contacts Permission"),
          content: const Text(
              "To find friends to chat with, this app needs access to your contacts."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close the explanation dialog
                // Now, proceed with fetching contacts, which will trigger the system permission prompt
                await _fetchContacts();
                if (mounted) {
                  _showContactFlowDialog();
                }
              },
              child: const Text("Continue"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
      return Container(
          color: Color(0xFF1E1E1E), // Background: Dark Gray-Black
          child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      style: const TextStyle(color: Color(0xFFFFD54F)), // Text: Warm Yellow
                      cursorColor: Color(0xFFFFD54F),
                      decoration: InputDecoration(
                        
                        hintText: 'Search Name/Number.....',
                        hintStyle: const TextStyle(color: Color(0xFFFFCA28)), // Accent: Light Amber
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFFA67B00), // Primary: Dark Yellow
                        ),
                        filled: true,
                        fillColor: Color.fromARGB(255, 41, 41, 41), // Background: Dark Gray-Black
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                      ),
                      controller: _searchController,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child:  ListView(
                      
                      children:  _chats.isNotEmpty 
                      ? _chats.map((chat) {
                          return ContactTile(
                            contactName: chat.contactName,
                            lastMessage: chat.lastMessage,
                          );
                        }).toList()
                      : [
                          Center(
                            heightFactor: 20,
                            child: Text(
                              'No chats available. Start a new chat!',
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          ),
                        ],
                      ),
                    ),
                
                     
                  ),
            
              ],
            ),
            Positioned(
              bottom: 10,
              right: 30,
              child: FloatingActionButton(
                shape: CircleBorder(
                  side: BorderSide(
                    color: Color(0xFFFFD54F), // Border: Warm Yellow
                  
                  ),
                ),
                onPressed: _showPermissionExplanationDialog,
                backgroundColor: Color(0xFFFFC107), // Secondary: Amber
                child: const Icon(Icons.chat_bubble_outline_rounded,
                    color: Color(0xFF1E1E1E), size: 24),
              ),
            ),
          ],
        ),
      );
  }
}

class Chats {
  final String contactName;
  final String lastMessage;

  Chats({required this.contactName, required this.lastMessage});
}