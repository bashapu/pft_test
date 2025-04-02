import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../services/database_helper.dart';
import '../services/session_manager.dart';

class GoalsScreen extends StatefulWidget {
  @override
  _GoalsScreenState createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  List<Goal> goals = [];

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    final userId = SessionManager().currentUser?.id ?? '';
    final result = await DatabaseHelper.instance.getGoalsByUser(userId);
    setState(() => goals = result);
  }

  Future<void> _addGoal() async {
    final titleController = TextEditingController();
    final targetController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('New Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: InputDecoration(labelText: 'Title')),
            TextField(controller: targetController, decoration: InputDecoration(labelText: 'Target Amount'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final goal = Goal(
                title: titleController.text,
                targetAmount: double.tryParse(targetController.text) ?? 0.0,
                savedAmount: 0.0,
                userId: SessionManager().currentUser!.id,
              );
              await DatabaseHelper.instance.insertGoal(goal);
              Navigator.pop(context);
              _loadGoals();
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateSavedAmount(Goal goal) async {
    final amountController = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Add Saved Amount'),
        content: TextField(
          controller: amountController,
          decoration: InputDecoration(labelText: 'Amount'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final addAmount = double.tryParse(amountController.text) ?? 0.0;
              final newAmount = (goal.savedAmount + addAmount).clamp(0.0, goal.targetAmount);
              await DatabaseHelper.instance.updateGoalSavedAmount(goal.id!, newAmount);
              Navigator.pop(context);
              _loadGoals();
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _editGoal(Goal goal) async {
    final titleController = TextEditingController(text: goal.title);
    final targetController = TextEditingController(
      text: goal.targetAmount.toString(),
    );

    await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Edit Goal'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: targetController,
                  decoration: InputDecoration(labelText: 'Target Amount'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  final db = await DatabaseHelper.instance.database;
                  await db.update(
                    'goals',
                    {
                      'title': titleController.text,
                      'targetAmount':
                          double.tryParse(targetController.text) ??
                          goal.targetAmount,
                    },
                    where: 'id = ?',
                    whereArgs: [goal.id],
                  );
                  Navigator.pop(context);
                  _loadGoals();
                },
                child: Text('Update'),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteGoal(int id) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete('goals', where: 'id = ?', whereArgs: [id]);
    _loadGoals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Savings Goals')),
      body:
          goals.isEmpty
              ? Center(child: Text("No goals yet 😔"))
              : ListView.builder(
                itemCount: goals.length,
                itemBuilder: (_, index) {
                  final goal = goals[index];
                  final percent = goal.savedAmount / goal.targetAmount;
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(goal.title),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${goal.savedAmount.toStringAsFixed(2)} / ${goal.targetAmount}',
                          ),
                          LinearProgressIndicator(value: percent),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') _editGoal(goal);
                          if (value == 'delete') _deleteGoal(goal.id!);
                          if (value == 'save') _updateSavedAmount(goal);
                        },
                        itemBuilder:
                            (context) => [
                              PopupMenuItem(value: 'edit', child: Text('Edit')),
                              PopupMenuItem(
                                value: 'save',
                                child: Text('Add Saved Amount'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete'),
                              ),
                            ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: ElevatedButton(
        onPressed: _addGoal,
        child: Text('Add Saving Goal'), // changed from add to pencil/edit style
      ),
    );
  }

}
