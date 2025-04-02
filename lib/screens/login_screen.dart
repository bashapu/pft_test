import 'package:flutter/material.dart';
import 'package:pft_test/services/database_helper.dart';
import 'register_screen.dart';
import 'dashboard_screen.dart';
import '../models/user.dart';
import '../services/session_manager.dart';
import 'package:uuid/uuid.dart';

class LoginScreen extends StatelessWidget {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _continueAsGuest(BuildContext context) {
    final guestUser = AppUser(id: Uuid().v4(), name: "Guest", email: "", password: "");
    SessionManager().loginUser(guestUser);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => DashboardScreen()),
    );
  }

  void _login(BuildContext context) async {
    final db = await DatabaseHelper.instance.database;
    final users = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [_emailController.text, _passwordController.text],
    );
    if (users.isNotEmpty) {
      final user = AppUser.fromMap(users.first);
      SessionManager().loginUser(user);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DashboardScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid credentials")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: () => _login(context), child: Text('Login')),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterScreen())),
              child: Text('Register'),
            ),
            TextButton(
              onPressed: () => _continueAsGuest(context),
              child: Text('Continue as Guest'),
            ),
          ],
        ),
      ),
    );
  }
}
