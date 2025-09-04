import 'dart:io';

import 'package:flutter/material.dart';

class ContactSelectionPage extends StatefulWidget {
   final File? imageFile;
   const ContactSelectionPage({super.key, required this.imageFile});

  @override
  State<ContactSelectionPage> createState() => _ContactSelectionPageState();
}

class _ContactSelectionPageState extends State<ContactSelectionPage> {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text("Still In Development plz wait for this feature"),);
  }
}