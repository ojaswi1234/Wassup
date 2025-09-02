import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'dart:async';

class ContactsPage extends StatefulWidget {
  final List<Contact> registeredContacts;
  final List<Contact> nonRegisteredContacts;
  final Function(Contact) onContactTap;
  final Function(Contact) onInviteContact;
  final bool isLoading;

  const ContactsPage({
    super.key,
    this.registeredContacts = const [],
    this.nonRegisteredContacts = const [],
    required this.onContactTap,
    required this.onInviteContact,
    this.isLoading = false,
  });

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  List<Contact> _filteredRegistered = [];
  List<Contact> _filteredNonRegistered = [];
  Timer? _debounceTimer;
  
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _filteredRegistered = widget.registeredContacts;
    _filteredNonRegistered = widget.nonRegisteredContacts;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _filterContacts(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          if (query.isEmpty) {
            _filteredRegistered = widget.registeredContacts;
            _filteredNonRegistered = widget.nonRegisteredContacts;
          } else {
            final lowerQuery = query.toLowerCase();
            _filteredRegistered = widget.registeredContacts
                .where((contact) => contact.displayName.toLowerCase().contains(lowerQuery))
                .toList();
            _filteredNonRegistered = widget.nonRegisteredContacts
                .where((contact) => contact.displayName.toLowerCase().contains(lowerQuery))
                .toList();
          }
        });
      }
    });
  }

  Widget _buildContactTile(Contact contact, bool isRegistered) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isRegistered ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isRegistered ? Colors.green : Colors.orange,
          child: Text(
            contact.displayName.isNotEmpty ? contact.displayName[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          contact.displayName,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        subtitle: contact.phones.isNotEmpty
            ? Text(
                contact.phones.first.number,
                style: const TextStyle(color: Colors.white70),
              )
            : null,
        trailing: Icon(
          isRegistered ? Icons.chat_bubble : Icons.person_add,
          color: isRegistered ? Colors.green : Colors.orange,
        ),
        onTap: () {
          if (isRegistered) {
            Navigator.pop(context);
            widget.onContactTap(contact);
          } else {
            widget.onInviteContact(contact);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    if (widget.isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF1E1E1E),
        appBar: AppBar(
          title: const Text('Select Contact', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFFA67B00),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFFFFC107)),
              SizedBox(height: 16),
              Text('Loading contacts...', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text('Select Contact', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFFA67B00),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
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
              ),
              onChanged: _filterContacts,
            ),
          ),
          
          // Contact List
          Expanded(
            child: CustomScrollView(
              cacheExtent: 1000.0, // Performance optimization
              slivers: [
                // Registered Contacts Section
                if (_filteredRegistered.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green.shade400, Colors.green.shade600],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'On ConnectUs (${_filteredRegistered.length})',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildContactTile(_filteredRegistered[index], true),
                        childCount: _filteredRegistered.length,
                      ),
                    ),
                  ),
                ],
                
                // Non-Registered Contacts Section
                if (_filteredNonRegistered.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.orange.shade400, Colors.orange.shade600],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Invite to ConnectUs (${_filteredNonRegistered.length})',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildContactTile(_filteredNonRegistered[index], false),
                        childCount: _filteredNonRegistered.length,
                      ),
                    ),
                  ),
                ],
                
                // Empty state
                if (_filteredRegistered.isEmpty && _filteredNonRegistered.isEmpty)
                  const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'No contacts found',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
