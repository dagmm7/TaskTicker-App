import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// --- Replicating Models for Self-Containment (Task and Category) ---

// Model for the task categories
class TaskCategory {
  final String name;
  final int taskCount;
  final Color color;
  final IconData icon;
  const TaskCategory(this.name, this.taskCount, this.color, this.icon);
}

// Model for a single task
class Task {
  final String title;
  final String time;
  final TaskCategory category;
  const Task(this.title, this.time, this.category);
}

// Simulated data (must match the structure used in the dashboard)
const List<TaskCategory> categories = [
  const TaskCategory('Work', 4, Colors.blue, Icons.work),
  const TaskCategory('Family', 5, Colors.orange, Icons.family_restroom),
  const TaskCategory('School', 6, Colors.green, Icons.school),
];

// Simulated daily tasks for March 2025 (to match calendar aesthetic)
// Keys must be normalized to date-only (year, month, day)
final Map<DateTime, List<Task>> mockTasks = {
  DateTime(2025, 3, 5): [Task('Design meeting', '1:00 PM', categories[2])],
  DateTime(2025, 3, 8): [Task('Client Call', '10:00 AM', categories[1])],
  DateTime(2025, 3, 14): [Task('Presentation Prep', '11:00 AM', categories[0])],
  DateTime(2025, 3, 19): [Task('Project Check', '9:00 AM', categories[0])],
  DateTime(2025, 3, 20): [Task('Review Draft', '4:00 PM', categories[2])],
  DateTime(2025, 3, 23): [Task('Gym Session', '6:00 PM', categories[1])],
  DateTime(2025, 3, 27): [Task('Code Review', '2:00 PM', categories[0])],
  DateTime(2025, 3, 30): [Task('Grocery Run', '7:00 PM', categories[1])],
  // Tasks for the selected day in the screenshot (March 15th)
  DateTime(2025, 3, 15): [
    Task('Team meeting', '10:00 AM', categories[0]), // Blue dot
    Task('Submit quarterly report', '2:30 PM', categories[1]), // Orange dot
    Task('Review project timeline', '5:00 PM', categories[2]), // Green dot
  ],
};

// --- Calendar View Screen (Stateful Widget) ---

class CalendarViewScreen extends StatefulWidget {
  final DateTime selectedDay;
  final Function(DateTime) onDaySelected;

  const CalendarViewScreen({
    super.key,
    required this.selectedDay,
    required this.onDaySelected,
  });

  @override
  State<CalendarViewScreen> createState() => _CalendarViewScreenState();
}

class _CalendarViewScreenState extends State<CalendarViewScreen> {
  // State for the calendar
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  // Use a fixed month (March 2025) to visually match the screenshot aesthetic
  final int _fixedYear = 2025;
  final int _fixedMonth = 3;

  @override
  void initState() {
    super.initState();
    // Normalize the passed date to match the screenshot's data structure
    _selectedDay = DateTime(_fixedYear, _fixedMonth, widget.selectedDay.day);
    _focusedDay = DateTime(_fixedYear, _fixedMonth, 1);
  }

  // --- Utility Functions ---

  // Fetches tasks for a specific date (normalized to date-only)
  List<Task> _getEventsForDay(DateTime day) {
    // Normalize the day to match the keys in mockTasks
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return mockTasks[normalizedDay] ?? [];
  }

  // Generates the list of days for the fixed month grid (March 2025)
  List<DateTime> _getDaysInMonth(int year, int month) {
    // March 2025 starts on a Saturday.
    // The calendar view typically shows the last few days of the previous month
    // to complete the first week. March 1st is Sat (index 6, where Sun=0).
    // The previous month (Feb 2025) ends on day 28, which is a Friday.
    // We need the 5 preceding days: Sun 23rd to Fri 28th.
    final List<DateTime> days = [];
    final DateTime firstDayOfMonth = DateTime(year, month, 1);
    final int firstDayWeekday =
        firstDayOfMonth.weekday % 7; // Convert to 0 (Sun) - 6 (Sat)
    final DateTime lastDayOfPrevMonth = DateTime(
      year,
      month,
      0,
    ); // Last day of Feb

    // Add days from the previous month
    for (int i = firstDayWeekday; i > 0; i--) {
      days.add(lastDayOfPrevMonth.subtract(Duration(days: i - 1)));
    }

    // Add days of the current month (up to 31)
    DateTime currentDay = firstDayOfMonth;
    while (currentDay.month == month) {
      days.add(currentDay);
      currentDay = currentDay.add(const Duration(days: 1));
    }

    // Add days from the next month to fill the grid (up to 6 rows * 7 columns = 42 cells)
    int daysInGrid = days.length;
    while (daysInGrid < 42) {
      days.add(currentDay);
      currentDay = currentDay.add(const Duration(days: 1));
      daysInGrid++;
    }

    return days;
  }

  // Handles when a day is tapped
  void _onDayTap(DateTime day) {
    if (day.month == _fixedMonth) {
      setState(() {
        _selectedDay = day;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Re-select the key tasks based on the current state of _selectedDay
    final List<Task> selectedTasks = _getEventsForDay(_selectedDay);
    final List<DateTime> daysInGrid = _getDaysInMonth(_fixedYear, _fixedMonth);

    // This is the date/time string for display below the AppBar
    final String dateString = DateFormat(
      'EEEE, MMMM d, yyyy',
    ).format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        // Retaining the user-requested AppBar style
        title: const Text(
          "Full Calendar View",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // --- Bottom Navigation Bar (Added) ---
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Tasks'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 30), // Larger Add icon
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Completed',
          ),
        ],
        currentIndex: 0, // Calendar is the current view
        onTap: (index) {
          // In a real app, this would navigate to the respective screen
          if (index == 0) {
            // Already on Calendar view
          } else {
            // Pop back to dashboard if navigating to a different main screen
            Navigator.pop(context);
          }
        },
      ),
      // --- Body Content ---
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(
              bottom: 100,
            ), // Reserve space for the button
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Current Date Display
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 15.0,
                  ),
                  child: Text(
                    dateString,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),

                // 2. Divider
                const Divider(
                  height: 1,
                  thickness: 1,
                  indent: 20,
                  endIndent: 20,
                ),

                // 3. Calendar Month Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 15.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(
                        Icons.chevron_left,
                        color: Colors.grey,
                      ), // Mock navigation
                      Text(
                        DateFormat('MMMM yyyy').format(_focusedDay),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                      ), // Mock navigation
                    ],
                  ),
                ),

                // 4. Calendar Grid (Static Month View)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Table(
                    children: [
                      // Weekday Headers
                      TableRow(
                        children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                            .map(
                              (day) => Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    day,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: day == 'S'
                                          ? Colors.red.shade300
                                          : Colors.black54,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      // Day Cells (6 rows)
                      for (int i = 0; i < 6; i++)
                        TableRow(
                          children: daysInGrid.skip(i * 7).take(7).map((day) {
                            final bool isCurrentMonth =
                                day.month == _fixedMonth;
                            final bool isSelected = day.isAtSameMomentAs(
                              _selectedDay,
                            );
                            final List<Task> events = _getEventsForDay(day);

                            return GestureDetector(
                              onTap: () => _onDayTap(day),
                              child: CalendarCell(
                                day: day.day,
                                isCurrentMonth: isCurrentMonth,
                                isSelected: isSelected,
                                eventColors: events
                                    .map((e) => e.category.color)
                                    .toList(),
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // 5. Tasks for Selected Day
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Tasks for ${DateFormat('MMMM d').format(_selectedDay)}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${selectedTasks.length} tasks",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // Task List
                      if (selectedTasks.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(30.0),
                            child: Text(
                              "No tasks scheduled for this day.",
                              style: TextStyle(
                                color: Colors.black54,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        )
                      else
                        ...selectedTasks
                            .map((task) => TaskItem(task: task))
                            .toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 6. "Return to Dashboard" Button (Fixed at the bottom)
          Positioned(
            bottom: 70, // Positioned above the BottomNavigationBar
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  // Call the original callback with the last selected day
                  widget.onDaySelected(_selectedDay);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  "Return to Dashboard",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Widget for a single calendar grid cell
class CalendarCell extends StatelessWidget {
  final int day;
  final bool isSelected;
  final bool isCurrentMonth;
  final List<Color> eventColors;

  const CalendarCell({
    super.key,
    required this.day,
    required this.isSelected,
    required this.isCurrentMonth,
    required this.eventColors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(2),
      alignment: Alignment.center,
      decoration: isSelected
          ? BoxDecoration(
              color: Colors.blueAccent,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blueAccent.shade700, width: 1.5),
            )
          : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$day',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : isCurrentMonth
                  ? Colors.black
                  : Colors.grey.shade400,
            ),
          ),
          if (eventColors.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: eventColors
                    .take(3) // Show up to 3 dots
                    .map(
                      (color) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1.0),
                        child: Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

// Custom Widget for Task List Item in Calendar View
class TaskItem extends StatefulWidget {
  final Task task;
  const TaskItem({super.key, required this.task});

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  bool isCompleted = false;

  @override
  void initState() {
    super.initState();
    // Pre-check the third task in the March 15 list to match the screenshot
    if (widget.task.title == 'Review project timeline') {
      isCompleted = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Custom Checkbox that resembles the screenshot style
          Checkbox(
            value: isCompleted,
            onChanged: (bool? newValue) {
              setState(() {
                isCompleted = newValue!;
              });
            },
            activeColor: Colors.blueAccent,
            checkColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: BorderSide(
              color: isCompleted ? Colors.blueAccent : Colors.grey.shade400,
              width: 2,
            ),
          ),
          const SizedBox(width: 10),
          // Task Title
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text(
                widget.task.title,
                style: TextStyle(
                  fontSize: 17,
                  decoration: isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  color: isCompleted ? Colors.grey : Colors.black87,
                ),
              ),
            ),
          ),
          // Category Dot
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: widget.task.category.color,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
