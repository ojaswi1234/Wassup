import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ConnectUs/components/contactTile.dart';
import 'package:ConnectUs/pages/contacts_page.dart';

class Home_Page extends StatefulWidget {
  const Home_Page({super.key});

  @override
  State<Home_Page> createState() => _Home_PageState();
}

class _Home_PageState extends State<Home_Page> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _searchController = TextEditingController();
  
  List<Contact> _contacts = [];
  final List<Chats> _chats = [];
 
  bool _isLoading = false;
  List<Contact> _registeredContacts = [];
  List<Contact> _nonRegisteredContacts = [];

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

  String _normalizePhoneNumber(String phoneNumber) {
    String normalized = phoneNumber.replaceAll(RegExp(r'\D'), '');
    
    if (normalized.startsWith('0')) {
      normalized = normalized.substring(1);
    }
    
    if (normalized.startsWith('91') && normalized.length == 12) {
      return normalized.substring(2);
    }
    
    return normalized;
  }

  Future<void> _fetchContacts() async {
    if (!await FlutterContacts.requestPermission()) {
      print("Permission Denied");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission denied to access contacts.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _registeredContacts = [];
    });

    try {
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false, // Avoid photos for performance
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
    setState(() {
      _chats.add(Chats(contactName: contact.displayName, lastMessage: 'Click here to start chatting'));
    });
    Navigator.pushNamed(context, '/chat');
  }

  void _inviteContact(Contact contact) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Invite ${contact.displayName} to ConnectUs'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showContactFlowDialog() {
    if (_contacts.isEmpty && !_isLoading) {
      _fetchContacts().then((_) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ContactsPage(
              registeredContacts: _registeredContacts,
              nonRegisteredContacts: _nonRegisteredContacts,
              onContactTap: _createChatWithContact,
              onInviteContact: _inviteContact,
              isLoading: false,
            ),
          ),
        );
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ContactsPage(
            registeredContacts: _registeredContacts,
            nonRegisteredContacts: _nonRegisteredContacts,
            onContactTap: _createChatWithContact,
            onInviteContact: _inviteContact,
            isLoading: _isLoading,
          ),
        ),
      );
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1E1E1E),
      child: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Form(
                  key: _formKey,
                  child: TextFormField(
                    style: const TextStyle(color: Color(0xFFFFD54F)),
                    cursorColor: const Color(0xFFFFD54F),
                    decoration: InputDecoration(
                      hintText: 'Search Name/Number.....',
                      hintStyle: const TextStyle(color: Color(0xFFFFCA28)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFFA67B00),
                      ),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 41, 41, 41),
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
                  child: ListView(
                    children: _chats.isNotEmpty 
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
              shape: const CircleBorder(
                side: BorderSide(
                  color: Color(0xFFFFD54F),
                ),
              ),
              onPressed: _showContactFlowDialog,
              backgroundColor: const Color(0xFFFFC107),
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
