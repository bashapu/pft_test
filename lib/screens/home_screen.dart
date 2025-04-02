import 'package:flutter/material.dart';
import '../services/database_helper.dart';
import '../services/session_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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

  Future<void> _editTransaction(
    BuildContext context,
    Map<String, dynamic> t,
  ) async {
    final titleController = TextEditingController(text: t['title']);
    final amountController = TextEditingController(
      text: t['amount'].toString(),
    );
    String selectedCategory = t['category'];
    String selectedType = t['type'];
    DateTime selectedDate = DateTime.tryParse(t['date']) ?? DateTime.now();

    await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Edit Transaction'),
            content: StatefulBuilder(
              builder:
                  (context, setState) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(labelText: 'Title'),
                      ),
                      TextField(
                        controller: amountController,
                        decoration: InputDecoration(labelText: 'Amount'),
                        keyboardType: TextInputType.number,
                      ),
                      DropdownButton<String>(
                        value: selectedType,
                        items:
                            ['Income', 'Expense']
                                .map(
                                  (type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) => setState(() => selectedType = val!),
                      ),
                      DropdownButton<String>(
                        value: selectedCategory,
                        items:
                            [
                                  'Food',
                                  'Rent',
                                  'Entertainment',
                                  'Salary',
                                  'Freelance',
                                  'Investments',
                                ]
                                .map(
                                  (cat) => DropdownMenuItem(
                                    value: cat,
                                    child: Text(cat),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (val) => setState(() => selectedCategory = val!),
                      ),
                      TextButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            setState(() => selectedDate = picked);
                          }
                        },
                        child: Text(
                          "Date: ${selectedDate.toLocal().toString().split(' ')[0]}",
                        ),
                      ),
                    ],
                  ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  final db = await DatabaseHelper.instance.database;
                  await db.update(
                    'transactions',
                    {
                      'title': titleController.text,
                      'amount': double.tryParse(amountController.text) ?? 0.0,
                      'type': selectedType,
                      'category': selectedCategory,
                      'date': selectedDate.toIso8601String(),
                    },
                    where: 'id = ?',
                    whereArgs: [t['id']],
                  );
                  Navigator.pop(context);
                  refreshData();
                },
                child: Text('Save'),
              ),
            ],
          ),
    );
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
                        return InkWell(
                          onTap: () => _editTransaction(context, t),
                          child: Card(
                            child: ListTile(
                                leading: Icon(
                                  t['type'] == 'Income'
                                      ? Icons.arrow_downward
                                      : Icons.arrow_upward,
                                  color:
                                      t['type'] == 'Income'
                                          ? Colors.green
                                          : Colors.red,
                                ),
                                title: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      t['title'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      '\$${(t['amount'] as double).toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            t['type'] == 'Income'
                                                ? Colors.green
                                                : Colors.red,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          '${t['category']}',
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 14,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          '${t['date'].toString().split('T')[0]}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                          ),
                        );
                      }
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
