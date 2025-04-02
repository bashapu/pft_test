import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../services/session_manager.dart';
import 'package:sqflite/sqflite.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _transactions = [];
  double _income = 0;
  double _expenses = 0;
  final userId = SessionManager().currentUser?.id;

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  void refreshData() async {
    final data = await DatabaseHelper.instance.fetchTransactions(userId);
    double income = 0;
    double expenses = 0;
    for (var t in data) {
      if (t['type'] == 'Income') {
        income += t['amount'];
      } else {
        expenses += t['amount'];
      }
    }
    setState(() {
      _transactions = data;
      _income = income;
      _expenses = expenses;
    });
  }

  @override
  Widget build(BuildContext context) {
    double balance = _income - _expenses;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text('Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Column(
                children: [
                  Text('Total Balance', style: TextStyle(fontSize: 16)),
                  Text(
                    '\$${balance.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text('Income', style: TextStyle(color: Colors.green)),
                      Text('\$${_income.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text('Expenses', style: TextStyle(color: Colors.orange)),
                      Text('\$${_expenses.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: _transactions.isEmpty
                  ? Center(child: Text('No transactions yet.'))
                  : ListView.builder(
                      itemCount: _transactions.length,
                      itemBuilder: (context, index) {
                        final t = _transactions[index];
                        return ListTile(
                          leading: Icon(
                            t['type'] == 'Income' ? Icons.arrow_downward : Icons.arrow_upward,
                            color: t['type'] == 'Income' ? Colors.green : Colors.red,
                          ),
                          title: Text('${t['category']} - \$${t['amount'].toStringAsFixed(2)}'),
                          subtitle: Text(t['date'].toString().split('T')[0]),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
