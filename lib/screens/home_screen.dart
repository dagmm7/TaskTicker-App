import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'tasks_screen.dart';
import 'create_task_screen.dart';
import 'completed_tasks_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(), // Calendar / Dashboard
    const TasksScreen(), // Tasks List
    const CreateTaskScreen(), // <-- REAL ADD TASK UI
    const CompletedTasksScreen(), // Completed Tasks UI
  ];

  String _getAppTitle(int index) {
    switch (index) {
      case 0:
        return "My Dashboard";
      case 1:
        return "Tasks List";
      case 2:
        return "Create Task";
      case 3:
        return "Completed Tasks";
      default:
        return "TaskTicker";
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          _getAppTitle(_selectedIndex),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: const [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'TaskTicker Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(title: Text('Categories (Coming Soon)')),
          ],
        ),
      ),

      body: _screens[_selectedIndex], // <-- Shows correct screen

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Add'),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Completed',
          ),
        ],
      ),
    );
  }
}
