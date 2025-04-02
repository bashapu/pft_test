import 'package:flutter/material.dart';
import 'package:pft_test/services/database_helper.dart';
import 'dashboard_screen.dart';
import '../services/session_manager.dart';
import '../models/user.dart';
import 'package:uuid/uuid.dart';

class RegisterScreen extends StatelessWidget {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _register(BuildContext context) async {
    final user = AppUser(
      id: Uuid().v4(),
      name: _nameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );
    final db = await DatabaseHelper.instance.database;
    await db.insert('users', user.toMap());
    SessionManager().loginUser(user);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => DashboardScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Full Name')),
            TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: _passwordController, decoration: InputDecoration(labelText: 'Password',), obscureText: true,),
            SizedBox(height: 20),
            ElevatedButton(onPressed: () => _register(context), child: Text('Register')),
          ],
        ),
      ),
    );
  }
}