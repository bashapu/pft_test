import 'package:flutter/material.dart';

class GoalsScreen extends StatefulWidget {
  @override
  _GoalsScreenState createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  List<Map<String, dynamic>> goals = [];

  void _addGoal() {
    if (_goalController.text.isEmpty || _amountController.text.isEmpty) return;
    setState(() {
      goals.add({
        'goal': _goalController.text,
        'target': double.tryParse(_amountController.text) ?? 0,
        'saved': 0.0,
      });
      _goalController.clear();
      _amountController.clear();
    });
  }

  void _updateSavedAmount(int index) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Amount to Goal'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'Amount to add'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value != null) {
                setState(() {
                  goals[index]['saved'] += value;
                  if (goals[index]['saved'] > goals[index]['target']) {
                    goals[index]['saved'] = goals[index]['target'];
                  }
                });
              }
              Navigator.pop(context);
            },
            child: Text('Add'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text('Savings Goals')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _goalController,
              decoration: InputDecoration(labelText: 'Goal Name'),
            ),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Target Amount'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addGoal,
              child: Text('Add Goal'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: goals.length,
                itemBuilder: (context, index) {
                  final goal = goals[index];
                  double progress = goal['saved'] / goal['target'];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text(goal['goal']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LinearProgressIndicator(value: progress),
                          SizedBox(height: 4),
                          Text('Saved: \$${goal['saved'].toStringAsFixed(2)} / \$${goal['target'].toStringAsFixed(2)}')
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () => _updateSavedAmount(index),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
