import 'package:flutter/material.dart';
import '../services/database_helper.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  late Future<List<Map<String, dynamic>>> _transactions;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadTransactions();
  }

  void _loadTransactions() {
    setState(() {
      _transactions = DatabaseHelper.instance.fetchTransactions();
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text('Transactions')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _transactions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No transactions yet.'));
          } else {
            return RefreshIndicator(
              onRefresh: () async => _loadTransactions(),
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final transaction = snapshot.data![index];
                  return ListTile(
                    leading: Icon(
                      transaction['type'] == 'Income' ? Icons.arrow_downward : Icons.arrow_upward,
                      color: transaction['type'] == 'Income' ? Colors.green : Colors.red,
                    ),
                    title: Text(
                      '${transaction['category']} - \$${transaction['amount'].toStringAsFixed(2)}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(transaction['date'].toString().split('T')[0]),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}