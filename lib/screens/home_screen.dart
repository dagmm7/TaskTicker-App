import 'package:flutter/material.dart';
import 'dashboard_screen.dart'; // Dashboard content
import 'tasks_screen.dart';     // Tasks List content

// Placeholder screen for the full Calendar View (Index 0 in BNV if Dashboard wasn't here)
class CalendarScreenPlaceholder extends StatelessWidget {
  const CalendarScreenPlaceholder({super.key});
  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.calendar_month, size: 50, color: Colors.grey),
        Text('Calendar View (Placeholder)'),
      ],
    ),
  );
}

class AddScreenPlaceholder extends StatelessWidget {
  const AddScreenPlaceholder({super.key});
  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_circle, size: 50, color: Colors.grey),
        Text('Add New Task (Action)'),
      ],
    ),
  );
}

class CompletedScreenPlaceholder extends StatelessWidget {
  const CompletedScreenPlaceholder({super.key});
  @override
  Widget build(BuildContext context) => const Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.check_circle_outline, size: 50, color: Colors.grey),
        Text('Completed Tasks View (Placeholder)'),
      ],
    ),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 1. Current index state variable.
  int _selectedIndex = 0; 

  // 2. List of screens corresponding to the navigation bar items (BNV).
  final List<Widget> _screens = [
    // Index 0: Calendar -> Mapped to Dashboard Screen (App Start)
    const DashboardScreen(), 
    // Index 1: Tasks -> Mapped correctly to Tasks Screen
    const TasksScreen(), 
    // Index 2: Add (Placeholder)
    const AddScreenPlaceholder(), 
    // Index 3: Completed (Placeholder)
    const CompletedScreenPlaceholder(),
  ];

  // 3. Helper to get the AppBar Title based on the current index
  String _getAppTitle(int index) {
    switch (index) {
      case 0:
        return 'My Dashboard'; // Matching the Dashboard screen title
      case 1:
        return 'Tasks List'; // Matching the Tasks screen title
      case 2:
        return 'Add New Task';
      case 3:
        return 'Completed';
      default:
        return 'TaskTicker';
    }
  }

  // 4. Function to update the selected index
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // The main Scaffold now contains the common AppBar
    return Scaffold(
      appBar: AppBar(
        // The three-line menu icon for opening the Drawer
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                // We'll use this later for the Drawer/Side Menu
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        // Title: Dynamically display the current page title
        title: Text("TaskTicker",
          //_getAppTitle(_selectedIndex),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: false, // Title aligned to the left (common in Flutter)
        backgroundColor: Colors.blue, // Blue background as per the proposal
        foregroundColor: Colors.white, // White icons/text on blue background
      ),
      
      // Placeholder for the navigation Drawer (Side Menu)
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'TaskTicker Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: const Text('Categories (TODO)'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
              },
            ),
          ],
        ),
      ),

      // The body displays the currently selected screen
      // Padding is NOT required here as the screen widgets are now full-page content
      body: _screens[_selectedIndex],
      
      // The fixed navigation bar at the bottom
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          // Item 0: Calendar (Dashboard entry)
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          // Item 1: Tasks 
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Tasks',
          ),
          // Item 2: Add 
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Add',
          ),
          // Item 3: Completed 
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Completed',
          ),
        ],
        currentIndex: _selectedIndex, 
        selectedItemColor: Colors.blue, 
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped, 
      ),
    );
  }
}