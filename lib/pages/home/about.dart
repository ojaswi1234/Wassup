import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class About extends StatelessWidget {
   About({super.key});
final Uri _url = Uri.parse('mailto:Ojaswideep2020@Outlook.com');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
      title: const Text('About'),
      centerTitle: true,
      backgroundColor: Color(0xFFA67B00), // Primary: Dark Yellow
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: 
      Container(
        decoration: BoxDecoration(
          color: Color( 0xFF1E1E1E), // Background: Dark Gray-Black
        ),
        child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
          Icons.info_outline,
          size: 64,
          color: Colors.amber,
          ),
          const SizedBox(height: 24),
          Text(
          'ConnectUs',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFD54F), // Text: Warm Yellow
          ),
          ),
          const SizedBox(height: 12),
          Text(
          'A modern app built with Flutter.\nStay connected and enjoy a seamless experience.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFFFFD54F).withOpacity(0.9), // Text: Warm Yellow
          ),
          ),
          const SizedBox(height: 24),
          const Text("Developer: Ojaswi Bhardwaj",
          style: TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
          ),
          const SizedBox(height: 8),
          MaterialButton(
            onPressed: () {
              // Handle email action
              launchUrl(_url);
            },
            color: Color(0xFFA67B00), // Button: Dark Yellow
            textColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('Ojaswideep2020@Outlook.com)'),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              launchUrl(Uri.parse('https://github.com/ojaswi1234'));
            },
            child: Text("ojaswi1234 (GitHub)", style: TextStyle(
              color: Color(0xFFFFD54F), // Text: Warm Yellow
              decoration: TextDecoration.underline,
            )),
          )
        ],
      ),
      ),
      ),
      ),
    );
  }
  
  
}