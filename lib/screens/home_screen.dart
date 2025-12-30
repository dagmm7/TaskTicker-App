import 'dart:io';
import 'package:flutter/material.dart';
import 'package:task_ticker_app/services/hive_service.dart';
import 'package:task_ticker_app/models/user_model.dart';
import 'dashboard_screen.dart';
import 'tasks_screen.dart';
import 'create_task_screen.dart';
import 'completed_tasks_screen.dart';
import 'profile.dart';
import 'settings_screen.dart';
import 'help_screen.dart';
import 'welcome_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  UserModel? _currentUser;

  List<Widget> get _screens => [
    const DashboardScreen(),
    const TasksScreen(),
    CreateTaskScreen(onTaskSaved: _onTaskSaved),
    const CompletedTasksScreen(),
  ];

  void _onTaskSaved() {
    setState(() {
      _selectedIndex = 1;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() {
    final email = HiveService.getCurrentUserEmail();
    if (email != null) {
      setState(() {
        _currentUser = HiveService.getUser(email);
      });
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              HiveService.setCurrentUserEmail(null);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                (route) => false,
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

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

    if (index == 0 || index == 1 || index == 3) {
      setState(() {});
    }
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
        backgroundColor: const Color(0xFF4A90E2),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              ).then((_) => _loadUser());
            },
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.white,
              backgroundImage:
                  _currentUser?.profilePicturePath != null &&
                      File(_currentUser!.profilePicturePath!).existsSync()
                  ? FileImage(File(_currentUser!.profilePicturePath!))
                  : null,
              child:
                  _currentUser?.profilePicturePath == null ||
                      !(_currentUser?.profilePicturePath != null &&
                          File(_currentUser!.profilePicturePath!).existsSync())
                  ? const Icon(Icons.person, color: Color(0xFF4A90E2))
                  : null,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF4A90E2)),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileScreen(),
                    ),
                  ).then((_) => _loadUser());
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white,
                      backgroundImage:
                          _currentUser?.profilePicturePath != null &&
                              File(
                                _currentUser!.profilePicturePath!,
                              ).existsSync()
                          ? FileImage(File(_currentUser!.profilePicturePath!))
                          : null,
                      child:
                          _currentUser?.profilePicturePath == null ||
                              !File(
                                _currentUser!.profilePicturePath!,
                              ).existsSync()
                          ? const Icon(
                              Icons.person,
                              size: 40,
                              color: Color(0xFF4A90E2),
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _currentUser?.fullName ?? 'User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentUser?.email ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.dashboard, color: Color(0xFF4A90E2)),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedIndex = 0;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.today, color: Color(0xFF4A90E2)),
              title: const Text("Today's Tasks"),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedIndex = 0;
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.list, color: Color(0xFF4A90E2)),
              title: const Text('All Tasks Created'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TasksScreen(showAllTasks: true),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Color(0xFF4A90E2)),
              title: const Text('Completed Tasks'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _selectedIndex = 3;
                });
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF4A90E2)),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                ).then((_) => _loadUser());
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Color(0xFF4A90E2)),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline, color: Color(0xFF4A90E2)),
              title: const Text('Help / User Guide'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HelpScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: _logout,
            ),
          ],
        ),
      ),

      body: _screens[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF4A90E2),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Tasks'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_task),
            label: 'Create Task',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Completed',
          ),
        ],
      ),
    );
  }
}
