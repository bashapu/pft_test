import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pft_test/services/session_manager.dart';
import '../services/database_helper.dart';

class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  double income = 0;
  double expenses = 0;
  final userId = SessionManager().currentUser?.id;
  DateTime _startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime _endDate = DateTime.now();
  int flag = 0;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    final transactions = await DatabaseHelper.instance.fetchTransactions(userId);
    double totalIncome = 0;
    double totalExpense = 0;

    for (var t in transactions) {
      if (t['type'] == 'Income') {
        totalIncome += t['amount'];
      } else {
        totalExpense += t['amount'];
      }
    }

    setState(() {
      income = totalIncome;
      expenses = totalExpense;
    });
  }

  Future<void> _loadReportData() async {
    final db = await DatabaseHelper.instance.database;

    final result = await db.query(
      'transactions',
      where: 'userId = ? AND date BETWEEN ? AND ?',
      whereArgs: [
        userId,
        _startDate.toIso8601String(),
        _endDate.toIso8601String(),
      ],
    );

    double totalIncome = 0;
    double totalExpense = 0;

    for (var t in result) {
      if (t['type'] == 'Income') {
        totalIncome += t['amount'] as num;
      } else {
        totalExpense += t['amount'] as num;
      }
    }

    setState(() {
      income = totalIncome;
      expenses = totalExpense;
    });
  }

  Future<void> _showDateRangeDialog() async {
    DateTime tempStart = _startDate;
    DateTime tempEnd = _endDate;

    await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Select Date Range'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: tempStart,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) tempStart = picked;
                  },
                  child: Text(
                    "Start: ${tempStart.toLocal().toString().split(' ')[0]}",
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: tempEnd,
                      firstDate: tempStart,
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) tempEnd = picked;
                  },
                  child: Text(
                    "End: ${tempEnd.toLocal().toString().split(' ')[0]}",
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _startDate = tempStart;
                    _endDate = tempEnd;
                    flag = 1;
                  });
                  Navigator.pop(context);
                  _loadReportData(); // Refresh the chart
                },
                child: Text('Apply'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reports')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Income vs. Expenses', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                flag == 0 ? 'No period selected' : 'Period : ${_startDate.toLocal().toString().split(' ')[0]} → ${_endDate.toLocal().toString().split(' ')[0]}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: ElevatedButton.icon(
                onPressed: _showDateRangeDialog,
                icon: Icon(Icons.date_range),
                label: Text('Select Period'),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      color: Colors.blue,
                      value: income,
                      title: 'Income\n\$${income.toStringAsFixed(0)}',
                      radius: 100,
                      titleStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    PieChartSectionData(
                      color: Colors.orange,
                      value: expenses,
                      title: 'Expenses\n\$${expenses.toStringAsFixed(0)}',
                      radius: 100,
                      titleStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ]
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}