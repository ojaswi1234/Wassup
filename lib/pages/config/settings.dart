import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {



  @override
  Widget build(BuildContext context) {
    // Define color scheme
    const primaryColor = Color(0xFFA67B00);
    const accentColor = Color(0xFFF5E6C0);
    const tileColor = Color(0xFF1E1E1E);


  

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 45, 45, 45),
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Card(
          color: tileColor,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListView(
            children: [
              _buildTile(
                icon: Icons.person,
                title: 'Account',
                onTap: () {},
                primaryColor: primaryColor,
              ),
             
            
              _buildTile(
                icon: Icons.notifications,
                title: 'Notifications',
                onTap: () {},
                primaryColor: primaryColor,
              ),
             
              _buildTile(
                icon: Icons.lock,
                title: 'Privacy',
                onTap: () {},
                primaryColor: primaryColor,
              ),
              
              _buildTile(
                icon: Icons.info,
                title: 'About',
                onTap: () {
                  Navigator.pushNamed(context, '/about');
                },
                primaryColor: primaryColor,
              ),
            
             
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color primaryColor,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: primaryColor.withOpacity(0.15),
        child: Icon(icon, color: primaryColor),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, color: primaryColor, size: 18),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Divider(thickness: 1, height: 0),
    );
  }
}