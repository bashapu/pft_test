import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/database_helper.dart';

class ReportsScreen extends StatefulWidget {
  @override
  _ReportsScreenState createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  double income = 0;
  double expenses = 0;

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    final transactions = await DatabaseHelper.instance.fetchTransactions();
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