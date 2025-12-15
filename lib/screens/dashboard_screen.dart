import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'calandar_view_screen.dart';

// Model for the task categories
class TaskCategory {
  final String name;
  final int taskCount;
  final Color color;
  final IconData icon;

  TaskCategory(this.name, this.taskCount, this.color, this.icon);
}

// Model for a single task
class Task {
  final String title;
  final String time;
  final TaskCategory category;

  Task(this.title, this.time, this.category);
}

// Simulated data
final List<TaskCategory> categories = [
  TaskCategory('Work', 4, Colors.blue, Icons.work),
  TaskCategory('Family', 5, Colors.orange, Icons.family_restroom),
  TaskCategory('School', 6, Colors.green, Icons.school),
  TaskCategory('Personal', 3, Colors.purple, Icons.person),
  TaskCategory('Add', 2, Colors.red, Icons.add),
];

// data model(simulated)....

// Simulated daily tasks
final Map<DateTime, List<Task>> mockTasks = {
  // Today's tasks (normalized to just date, ignoring time)
  DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day): [
    Task('Project proposal review', '10:00 AM', categories[0]),
    Task('Math assignment', '2:30 PM', categories[2]),
    Task('Grocery shopping', '5:00 PM', categories[4]),
  ],
  // Tomorrow's tasks
  DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day + 1): [
    Task('Team Meeting Prep', '9:00 AM', categories[0]),
    Task('Client Follow-up', '1:00 PM', categories[0]),
    Task('Call Mom', '7:00 PM', categories[1]),
  ],
};

//.....widgets....
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // State to track the currently selected date
  DateTime _selectedDay = DateTime.now();
  final DateTime _today = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Normalize the initial selected day to avoid time component issues
    _selectedDay = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
    );
  }

  void _navigateToCalendarView() {
    // Navigates to the full calendar view screen, passing the selected date
    // and the callback function for when a new day is selected in the full view.
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CalendarViewScreen(
          selectedDay: _selectedDay, // Now passing the required argument
          onDaySelected: _onDaySelected, // Now passing the required argument
        ),
      ),
    );
  }

  List<DateTime> _getSevenDays() {
    // Assuming _today is defined as DateTime.now() in the state init
    return List.generate(7, (index) => _today.add(Duration(days: index)));
  }

  // Helper to format the date display for the header
  String get _currentDateText {
    return DateFormat('MMMM d').format(DateTime.now());
  }

  // Gets tasks for the selected day by normalizing the map keys
  List<Task> get _tasksForSelectedDay {
    // Normalize selected day to match keys in mockTasks
    DateTime normalizedSelected = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
    );

    // Look up tasks for the normalized date
    return mockTasks[normalizedSelected] ?? [];
  }

  // This handles the user selecting a new day from the calendar strip
  void _onDaySelected(DateTime day) {
    setState(() {
      _selectedDay = DateTime(day.year, day.month, day.day);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Normalize today's date once for comparison in the builder
    final DateTime normalizedToday = DateTime(
      _today.year,
      _today.month,
      _today.day,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "TaskTicker",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            onPressed: () {
              // TODO: Navigate to Task Creation Screen
            },
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // TODO: Open Search
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Dashboard Header
            Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 20.0,
                top: 10.0,
                bottom: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "My Dashboard",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // This text is placed above the calendar view as requested
                  Text(
                    "Today, $_currentDateText",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // 2. Horizontal Calendar View Strip
            Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                bottom: 8.0,
                right: 20.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Calendar",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  GestureDetector(
                    onTap: _navigateToCalendarView,
                    child: const Row(
                      children: const [
                        Text(
                          'View All',
                          style: TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Colors.blueAccent,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Tap anywhere in this area navigates
            Container(
              color: Colors
                  .white, // Necessary for the gesture detector to register taps outside the list items
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 7, // Show 7 days starting from today
                itemBuilder: (context, index) {
                  final day = _getSevenDays()[index];
                  // Normalize both to compare only date parts (year, month, day)
                  final normalizedDay = DateTime(day.year, day.month, day.day);
                  final isSelected = normalizedDay.isAtSameMomentAs(
                    _selectedDay,
                  );
                  final isToday = normalizedDay.isAtSameMomentAs(
                    normalizedToday,
                  );

                  // Using DayTile custom widget
                  return DayTile(
                    day: day,
                    isSelected: isSelected,
                    isToday: isToday,
                    onTap: () {
                      // Explicitly call the selection logic when a tile is tapped
                      _onDaySelected(day);
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            // 3. Category GridView (between calendar and tasks list)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Categories",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 15),
                  GridView.builder(
                    physics:
                        const NeverScrollableScrollPhysics(), // Important to scroll with SingleChildScrollView
                    shrinkWrap: true,
                    itemCount: categories.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15.0,
                          mainAxisSpacing: 15.0,
                          childAspectRatio: 2.5, // Make cards wide and short
                        ),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return CategoryCard(category: category);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // 4. Tasks List for the Selected Day
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tasks for ${DateFormat('EEEE, MMMM d').format(_selectedDay)}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 15),
                  ..._tasksForSelectedDay
                      .map((task) => TaskListItem(task: task))
                      .toList(),
                  if (_tasksForSelectedDay.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          "Hooray! No tasks scheduled for ${DateFormat('MMMM d').format(_selectedDay)}.",
                          style: const TextStyle(
                            color: Colors.black54,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// Custom Widget for grid view item
class CategoryCard extends StatelessWidget {
  final TaskCategory category;
  const CategoryCard({super.key, required this.category});

  bool get isAddButton => category.name == 'Add New';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // <--- WRAP IN GESTUREDETECTOR
      onTap: () {
        if (isAddButton) {
          // TODO: Implement navigation to the "Create New Task" screen.
          // For now, we can print a message:
          print('Navigate to Create New Task Screen');
        } else {
          // Normal category selection logic (e.g., filter tasks)
          print('Selected category: ${category.name}');
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        // Use a distinct style for the Add button
        decoration: BoxDecoration(
          color: isAddButton
              ? Colors.red.shade100
              : category.color.withOpacity(0.1), // Light red background for Add
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isAddButton ? Colors.red : category.color.withOpacity(0.3),
          ), // Red border for Add
        ),
        child: Row(
          children: [
            // Use a larger icon for the Add button
            Icon(
              category.icon,
              color: isAddButton ? Colors.red : category.color,
              size: isAddButton ? 36 : 28,
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  category.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isAddButton ? Colors.red : category.color,
                  ),
                ),
                const SizedBox(height: 2),
                // Hide the task count for the 'Add New' button
                if (!isAddButton)
                  Text(
                    "${category.taskCount} tasks",
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Widget for Task List Item
class TaskListItem extends StatelessWidget {
  final Task task;
  const TaskListItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Category Color Indicator
            Container(
              width: 5,
              height: 50,
              decoration: BoxDecoration(
                color: task.category.color,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 15),
            // Task Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.black45),
                      const SizedBox(width: 5),
                      Text(
                        task.time,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const Spacer(),
                      // Optional: Show category name on the right
                      Text(
                        task.category.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: task.category.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Checkbox
            Checkbox(
              value: false, // Always false for active task list
              onChanged: (bool? newValue) {
                // TODO: Implement task completion logic
              },
              activeColor: task.category.color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DayTile extends StatelessWidget {
  final DateTime day;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  const DayTile({
    super.key,
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      // Wrap in Builder to prevent gesture propagation to parent GestureDetector when tapped
      child: Container(
        width: 70,
        margin: const EdgeInsets.symmetric(horizontal: 5.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? Colors.blueAccent : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isToday
                  ? 'TODAY'
                  : DateFormat(
                      'EEE',
                    ).format(day).toUpperCase(), // Day name (MON, TUE, etc.)
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black54,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              day.day.toString(), // Day number (15, 16, etc.)
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
