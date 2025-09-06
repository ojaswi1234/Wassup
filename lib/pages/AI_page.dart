import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

class AI_Page extends StatefulWidget {
  const AI_Page({super.key});

  @override
  State<AI_Page> createState() => _AI_PageState();
}

class _AI_PageState extends State<AI_Page> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ConnectiFy'),
        centerTitle: true,
        backgroundColor: Color(0xFFA67B00), // Primary: Dark Yellow
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
     
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFF1E1E1E), // Background: Dark Gray-Black
            
          ),
          alignment: Alignment.center,
          
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Icon( Icons.smart_toy, size: 100, color: Colors.amberAccent),
            SizedBox(height: 20),
            AnimatedTextKit(
              animatedTexts: [
      TyperAnimatedText('AI Feature Coming Soon.......', textStyle: TextStyle(
        color: Color(0xFFFFD54F), // Text: Warm Yellow
        fontSize: 24,
        fontWeight: FontWeight.bold
      ), speed: Duration(milliseconds: 100)),
     
    ],
    onTap: () {
      print("Tap Event");
    },
  ),
          ],)
        ),
      ),
    );
  }
}