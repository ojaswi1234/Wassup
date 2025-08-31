import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

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

class _ContactsPageState extends State<ContactsPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Contact> _filteredRegistered = [];
  List<Contact> _filteredNonRegistered = [];

  @override
  void initState() {
    super.initState();
    _filteredRegistered = widget.registeredContacts;
    _filteredNonRegistered = widget.nonRegisteredContacts;
  }

  void _filterContacts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredRegistered = widget.registeredContacts;
        _filteredNonRegistered = widget.nonRegisteredContacts;
      } else {
        _filteredRegistered = widget.registeredContacts
            .where((contact) => contact.displayName.toLowerCase().contains(query.toLowerCase()))
            .toList();
        _filteredNonRegistered = widget.nonRegisteredContacts
            .where((contact) => contact.displayName.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      appBar: AppBar(
        title: Text('Select Contact', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFFA67B00),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: widget.isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFFFFC107)),
                  SizedBox(height: 16),
                  Text('Loading contacts...', style: TextStyle(color: Colors.white)),
                ],
              ),
            )
          : Column(
              children: [
                // Search Bar
                Padding(
                  padding: EdgeInsets.all(16),
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
                    ),
                    onChanged: _filterContacts,
                  ),
                ),
                
                // Contact List
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // Registered Contacts Section
                      if (_filteredRegistered.isNotEmpty) ...[
                        Container(
                          padding: EdgeInsets.all(12),
                          margin: EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.green.shade400, Colors.green.shade600],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'On ConnectUs (${_filteredRegistered.length})',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _filteredRegistered.length,
                          itemBuilder: (context, index) {
                            final contact = _filteredRegistered[index];
                            return Card(
                              margin: EdgeInsets.only(bottom: 8),
                              color: Colors.green.withOpacity(0.1),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.green,
                                  child: Icon(Icons.person, color: Colors.white),
                                ),
                                title: Text(
                                  contact.displayName,
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                ),
                                subtitle: contact.phones.isNotEmpty
                                    ? Text(
                                        contact.phones.first.number,
                                        style: TextStyle(color: Colors.white70),
                                      )
                                    : null,
                                trailing: Icon(Icons.chat_bubble, color: Colors.green),
                                onTap: () {
                                  Navigator.pop(context);
                                  widget.onContactTap(contact);
                                },
                              ),
                            );
                          },
                        ),
                        
                        SizedBox(height: 20),
                      ],
                      
                      // Non-Registered Contacts Section
                      if (_filteredNonRegistered.isNotEmpty) ...[
                        Container(
                          padding: EdgeInsets.all(12),
                          margin: EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.orange.shade400, Colors.orange.shade600],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Invite to ConnectUs (${_filteredNonRegistered.length})',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _filteredNonRegistered.length,
                          itemBuilder: (context, index) {
                            final contact = _filteredNonRegistered[index];
                            return Card(
                              margin: EdgeInsets.only(bottom: 8),
                              color: Colors.orange.withOpacity(0.1),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.orange,
                                  child: Icon(Icons.person_outline, color: Colors.white),
                                ),
                                title: Text(
                                  contact.displayName,
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                ),
                                subtitle: contact.phones.isNotEmpty
                                    ? Text(
                                        contact.phones.first.number,
                                        style: TextStyle(color: Colors.white70),
                                      )
                                    : null,
                                trailing: Icon(Icons.share, color: Colors.orange),
                                onTap: () {
                                  Navigator.pop(context);
                                  widget.onInviteContact(contact);
                                },
                              ),
                            );
                          },
                        ),
                      ],
                      
                      // Empty State
                      if (_filteredRegistered.isEmpty && _filteredNonRegistered.isEmpty) ...[
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.contacts_outlined,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No contacts found',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  _searchController.text.isNotEmpty
                                      ? 'Try a different search term'
                                      : 'Make sure you have contacts saved on your device',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade400,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
