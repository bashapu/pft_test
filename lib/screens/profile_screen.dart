import 'package:flutter/material.dart';
import '../services/session_manager.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = SessionManager().currentUser;
    return Scaffold(
      appBar: AppBar(title: Text('Profile & Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${user?.name ?? "Guest"}'),
            SizedBox(height: 8),
            Text('Email: ${user?.email ?? "Not logged in"}'),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                SessionManager().logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false,
                );
              },
              icon: Icon(Icons.logout),
              label: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
