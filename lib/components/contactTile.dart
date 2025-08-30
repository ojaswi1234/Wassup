import 'package:flutter/material.dart';

class ContactTile extends StatelessWidget {
  final String contactName;
  final String lastMessage;
  const ContactTile({super.key, required this.contactName, required this.lastMessage});


  

  @override
  Widget build(BuildContext context) {
    return  GestureDetector(
      onLongPressStart: (details){
        showMenu(
          context: context,
          position: RelativeRect.fromLTRB(details.globalPosition.dx, details.globalPosition.dy, details.globalPosition.dx, details.globalPosition.dy),
          items: [
            PopupMenuItem(
              value: 'delete',
              child: Text('Delete Chat', style: TextStyle(color: Color(0xFFFFD54F))), // Text: Warm Yellow
            ),
            PopupMenuItem(
              value: 'mute',
              child: Text('Mute Notifications', style: TextStyle(color: Color(0xFFFFD54F))), // Text: Warm Yellow
            ),
          ],
          color: Color(0xFF1E1E1E), // Background: Dark Gray-Black
        ).then((value) {
          if (value == 'delete') {
            // Handle delete action
          } else if (value == 'mute') {
            // Handle mute action
          }
        });
      },
                           child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFA67B00).withOpacity(0.08), // Primary: Dark Yellow
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            title: Text(contactName,
                                style: TextStyle(
                                    color: Color(0xFFFFD54F), // Text: Warm Yellow
                                    fontWeight: FontWeight.bold)),
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFFFFC107), // Secondary: Amber
                              child: Text(
                                'A',
                                style: TextStyle(
                                    color: Color(0xFF1E1E1E), // Background: Dark Gray-Black
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            trailing: const CircleAvatar(
                              backgroundColor: Colors.transparent, //Colors.cyanAccent, // Primary: Dark Yellow
                              radius: 12,
                              child: Center(
                                  child: Text(
                                '1',
                                style: TextStyle(
                                    color: Colors.black, // Accent: Light Amber
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              )),
                            ),
                            subtitle: const Text('Hey There',
                                style: TextStyle(color: Color(0xFFFFCA28))), // Accent: Light Amber
                            onTap: () {
                              Navigator.pushNamed(context, '/chat');
                            },
                          ),
                        )

                        
    );                
  }
}