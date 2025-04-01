import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'reports_screen.dart';
import 'goals_screen.dart';
import 'profile_screen.dart';
import 'add_transaction_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  late List<Widget> _screens;
  final GlobalKey<HomeScreenState> _homeKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(key: _homeKey),
      ReportsScreen(),
      Container(),
      GoalsScreen(),
      ProfileScreen(),
    ];
  }

  void _onAddTransaction() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddTransactionScreen()),
    );
    if (_currentIndex == 0 && result == true) {
      _homeKey.currentState?.refreshData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddTransaction,
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Wrap(
          children: [
            BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex:
                  _currentIndex >= 2 ? _currentIndex - 1 : _currentIndex,
              onTap:
                  (index) => setState(
                    () => _currentIndex = index >= 2 ? index + 1 : index,
                  ),
              unselectedItemColor: Colors.grey,
              selectedItemColor: Colors.blue,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart),
                  label: 'Reports',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.savings),
                  label: 'Goals',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ],
        )
      ),
    );
  }
}