import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_ticker_app/services/hive_service.dart';
import 'package:task_ticker_app/models/task_model.dart';
import 'package:task_ticker_app/models/category_model.dart';

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
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime(
      widget.selectedDay.year,
      widget.selectedDay.month,
      widget.selectedDay.day,
    );
    _focusedDay = DateTime(
      widget.selectedDay.year,
      widget.selectedDay.month,
      1,
    );
  }

  List<TaskModel> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return HiveService.getTasksByDate(normalizedDay);
  }

  List<Color> _getEventColorsForDay(DateTime day) {
    final tasks = _getEventsForDay(day);
    return tasks.map((task) {
      final category = HiveService.getCategory(task.categoryId);
      return category?.color ?? Colors.grey;
    }).toList();
  }

  List<DateTime> _getDaysInMonth(int year, int month) {
    final List<DateTime> days = [];
    final DateTime firstDayOfMonth = DateTime(year, month, 1);
    final int firstDayWeekday = firstDayOfMonth.weekday % 7;
    final DateTime lastDayOfPrevMonth = DateTime(year, month, 0);

    for (int i = firstDayWeekday; i > 0; i--) {
      days.add(lastDayOfPrevMonth.subtract(Duration(days: i - 1)));
    }

    DateTime currentDay = firstDayOfMonth;
    while (currentDay.month == month) {
      days.add(currentDay);
      currentDay = currentDay.add(const Duration(days: 1));
    }

    int daysInGrid = days.length;
    while (daysInGrid < 42) {
      days.add(currentDay);
      currentDay = currentDay.add(const Duration(days: 1));
      daysInGrid++;
    }

    return days;
  }

  void _onDayTap(DateTime day) {
    if (day.month == _focusedDay.month) {
      setState(() {
        _selectedDay = day;
      });
    }
  }

  void _previousMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
    });
  }

  Future<void> _toggleTaskCompletion(TaskModel task) async {
    await HiveService.updateTaskCompletion(task.id, !task.isCompleted);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final selectedTasks = _getEventsForDay(_selectedDay);
    final daysInGrid = _getDaysInMonth(_focusedDay.year, _focusedDay.month);
    final dateString = DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Full Calendar View",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4A90E2),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4A90E2),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Tasks'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 30),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Completed',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) {
          } else {
            Navigator.pop(context);
          }
        },
      ),

      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

                const Divider(
                  height: 1,
                  thickness: 1,
                  indent: 20,
                  endIndent: 20,
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 15.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: _previousMonth,
                      ),
                      Text(
                        DateFormat('MMMM yyyy').format(_focusedDay),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: _nextMonth,
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Table(
                    children: [
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

                      for (int i = 0; i < 6; i++)
                        TableRow(
                          children: daysInGrid.skip(i * 7).take(7).map((day) {
                            final bool isCurrentMonth =
                                day.month == _focusedDay.month;
                            final bool isSelected = day.isAtSameMomentAs(
                              _selectedDay,
                            );
                            final eventColors = _getEventColorsForDay(day);

                            return GestureDetector(
                              onTap: () => _onDayTap(day),
                              child: CalendarCell(
                                day: day.day,
                                isCurrentMonth: isCurrentMonth,
                                isSelected: isSelected,
                                eventColors: eventColors,
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

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
                        ...selectedTasks.map((task) {
                          final category = HiveService.getCategory(
                            task.categoryId,
                          );
                          return TaskItem(
                            task: task,
                            category: category,
                            onToggle: () => _toggleTaskCompletion(task),
                          );
                        }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 70,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  widget.onDaySelected(_selectedDay);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
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
              color: const Color(0xFF4A90E2),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF4A90E2), width: 1.5),
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

class TaskItem extends StatelessWidget {
  final TaskModel task;
  final CategoryModel? category;
  final VoidCallback onToggle;

  const TaskItem({
    super.key,
    required this.task,
    this.category,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final taskColor = category?.color ?? Colors.grey;
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: task.isCompleted,
            onChanged: (bool? newValue) {
              onToggle();
            },
            activeColor: const Color(0xFF4A90E2),
            checkColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: BorderSide(
              color: task.isCompleted
                  ? const Color(0xFF4A90E2)
                  : Colors.grey.shade400,
              width: 2,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Text(
                task.title,
                style: TextStyle(
                  fontSize: 17,
                  decoration: task.isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  color: task.isCompleted ? Colors.grey : Colors.black87,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: taskColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
