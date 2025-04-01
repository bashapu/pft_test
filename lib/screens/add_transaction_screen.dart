import 'package:flutter/material.dart';
import '../services/database_helper.dart';

class AddTransactionScreen extends StatefulWidget {
  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _amountController = TextEditingController();
  String _category = 'Food';
  String _type = 'Expense';

  void _saveTransaction() async {
    await DatabaseHelper.instance.insertTransaction({
      'amount': double.parse(_amountController.text),
      'category': _category,
      'type': _type,
      'date': DateTime.now().toIso8601String(),
    });
    Navigator.pop(context);
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
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            DropdownButton<String>(
              value: _category,
              items: ['Food', 'Rent', 'Entertainment', 'Transport'].map((String value) {
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