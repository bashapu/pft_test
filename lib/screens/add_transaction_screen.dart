import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../services/session_manager.dart';

class AddTransactionScreen extends StatefulWidget {
  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final List<String> allCategories = [
    'Salary', 'Freelance', 'Investments', // income
    'Food', 'Rent', 'Entertainment', 'Transport', // expenses
  ];

  String _category = 'Food';
  String _type = 'Expense';

  final userId = SessionManager().currentUser!.id;
  void _saveTransaction() async {
    await DatabaseHelper.instance.insertTransaction({
      'title': _titleController.text,
      'amount': double.parse(_amountController.text),
      'category': _category,
      'type': _type,
      'date': _selectedDate.toIso8601String(),
      'userId': userId,
    });
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Transaction')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            DropdownButton<String>(
              value: _category,
              items: allCategories.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newVal) => setState(() => _category = newVal!),
            ),
            DropdownButton<String>(
              value: _type,
              items: ['Income', 'Expense'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newVal) => setState(() => _type = newVal!),
            ),
            SizedBox(height: 20),
            TextButton(
              onPressed: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() => _selectedDate = picked);
                }
              },
              child: Text(
                "Date: ${_selectedDate.toLocal().toString().split(' ')[0]}",
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveTransaction,
              child: Text('Save'),
            )
          ],
        ),
      ),
    );
  }
}