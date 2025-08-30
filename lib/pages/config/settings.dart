import 'package:flutter/material.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Color(0xFFA67B00),
      ),
      body: Center(
       child: Container(
        alignment: Alignment.center,
        child: Text("Settings Page"),
      ),
      ),
    );
  }
}