import 'package:flutter/material.dart';

class Status extends StatelessWidget {
  const Status({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      body: Container(
          decoration: BoxDecoration(
            color: Color(0xFF1E1E1E),
          
          ),
        child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(

          children: [
            ListTile(
              leading: CircleAvatar(
                // Replace with your asset
              ),
              title: const Text('My Status', style: TextStyle(color: Colors.white),),
              subtitle: const Text('Tap to add status update', style: TextStyle(color: Colors.white70),),
              trailing: Icon(Icons.add_circle, color: Colors.yellow),
            ),
            const Divider(),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recent Updates',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                     
                    ),
                    title: const Text('Alice', style: TextStyle(color: Colors.white),),
                    subtitle: const Text('10 minutes ago', style: TextStyle(color: Colors.white70),),
                  ),
                  ListTile(
                    leading: CircleAvatar(
                     
                    ),
                    title: const Text('Bob', style: TextStyle(color: Colors.white),),
                    subtitle: const Text('30 minutes ago', style: TextStyle(color: Colors.white70), ),
                  ),
                  // Add more ListTiles for other statuses
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}