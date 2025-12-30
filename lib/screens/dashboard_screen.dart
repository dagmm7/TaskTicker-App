import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_ticker_app/services/hive_service.dart';
import 'package:task_ticker_app/models/task_model.dart';
import 'package:task_ticker_app/models/category_model.dart';
import 'calandar_view_screen.dart';
import 'tasks_screen.dart';
import 'create_task_screen.dart';
import 'category_edit_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime _selectedDay = DateTime.now();
  final DateTime _today = DateTime.now();
  List<TaskModel> _todayTasks = [];
  List<CategoryModel> _categories = [];

  @override
  void initState() {
    super.initState();

    _selectedDay = DateTime(_today.year, _today.month, _today.day);
    _loadData();
  }

  void _loadData() {
    setState(() {
      _categories = HiveService.getAllCategories();
      _todayTasks = HiveService.getTasksByDate(_selectedDay);
    });
  }

  void _onDaySelected(DateTime day) {
    setState(() {
      _selectedDay = DateTime(day.year, day.month, day.day);
      _loadData();
    });
  }

  List<DateTime> _getSevenDays() {
    final start = DateTime(_today.year, _today.month, _today.day);
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }

  void _navigateToCalendarView() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => CalendarViewScreen(
              selectedDay: _selectedDay,
              onDaySelected: _onDaySelected,
            ),
          ),
        )
        .then((_) => _loadData());
  }

  void _navigateToCategoryTasks(String categoryId) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => TasksScreen(selectedCategoryId: categoryId),
          ),
        )
        .then((_) => _loadData());
  }

  void _toggleTaskCompletion(TaskModel task) {
    task.isCompleted = !task.isCompleted;
    HiveService.saveTask(task);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final normalizedToday = DateTime(_today.year, _today.month, _today.day);
    final _currentDateText = DateFormat('MMMM d, y').format(_today);

    final selectedNormalized = DateTime(
      _selectedDay.year,
      _selectedDay.month,
      _selectedDay.day,
    );
    final taskSectionTitle =
        selectedNormalized.isAtSameMomentAs(normalizedToday)
        ? "Today's Tasks"
        : "${DateFormat('EEEE').format(_selectedDay)}'s Tasks";

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      children: [
                        Text(
                          'View All',
                          style: TextStyle(
                            color: Color(0xFF4A90E2),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Color(0xFF4A90E2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.white,
              height: 100,
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 7,
                itemBuilder: (context, index) {
                  final day = _getSevenDays()[index];
                  final normalizedDay = DateTime(day.year, day.month, day.day);
                  final isSelected = normalizedDay.isAtSameMomentAs(
                    _selectedDay,
                  );
                  final isToday = normalizedDay.isAtSameMomentAs(
                    normalizedToday,
                  );

                  return DayTile(
                    day: day,
                    isSelected: isSelected,
                    isToday: isToday,
                    onTap: () {
                      _onDaySelected(day);
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

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
                  SizedBox(
                    height: 170,
                    child: GridView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _categories.length + 1,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10.0,
                            mainAxisSpacing: 10.0,

                            childAspectRatio: 0.45,
                          ),
                      itemBuilder: (context, index) {
                        if (index == _categories.length) {
                          return CategoryCard(
                            category: null,
                            onTap: () {
                              Navigator.of(context)
                                  .push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CategoryEditScreen(),
                                    ),
                                  )
                                  .then((result) {
                                    _loadData();
                                    if (result == true) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Deleted successfully'),
                                        ),
                                      );
                                    }
                                  });
                            },
                          );
                        }
                        final category = _categories[index];
                        final taskCount = HiveService.getTasksByCategory(
                          category.id,
                        ).length;
                        return CategoryCard(
                          category: category,
                          taskCount: taskCount,
                          onTap: () {
                            _navigateToCategoryTasks(category.id);
                          },
                        );
                      },
                    ),
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
                  Text(
                    taskSectionTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 15),
                  ..._todayTasks.map((task) {
                    final category = HiveService.getCategory(task.categoryId);
                    return TaskListItem(
                      task: task,
                      category: category,
                      onToggle: () => _toggleTaskCompletion(task),
                    );
                  }),
                  if (_todayTasks.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          "Hooray! No tasks scheduled for today.",
                          style: TextStyle(
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

class CategoryCard extends StatelessWidget {
  final CategoryModel? category;
  final int? taskCount;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    this.category,
    this.taskCount,
    required this.onTap,
  });

  bool get isAddButton => category == null;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isAddButton
              ? Colors.red.shade100
              : category!.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isAddButton ? Colors.red : category!.color.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isAddButton ? Icons.add : _getIconData(category!.iconName),
              color: isAddButton ? Colors.red : category!.color,
              size: 24,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isAddButton ? 'Add New' : category!.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isAddButton ? Colors.red : category!.color,
                    ),
                  ),
                  if (!isAddButton && taskCount != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      "$taskCount tasks",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'work':
        return Icons.work;
      case 'family_restroom':
        return Icons.family_restroom;
      case 'school':
        return Icons.school;
      case 'person':
        return Icons.person;
      default:
        return Icons.category;
    }
  }
}

class TaskListItem extends StatelessWidget {
  final TaskModel task;
  final CategoryModel? category;
  final VoidCallback onToggle;

  const TaskListItem({
    super.key,
    required this.task,
    this.category,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final taskColor = category?.color ?? Colors.grey;
    final timeString = DateFormat('h:mm a').format(task.dueDate);

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
            Container(
              width: 5,
              height: 50,
              decoration: BoxDecoration(
                color: taskColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 15),
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
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.black45,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        timeString,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const Spacer(),
                      if (category != null)
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context)
                                .push(
                                  MaterialPageRoute(
                                    builder: (ctx) =>
                                        CategoryEditScreen(category: category),
                                  ),
                                )
                                .then((result) {
                                  final parent = context
                                      .findAncestorStateOfType<
                                        _DashboardScreenState
                                      >();
                                  parent?._loadData();
                                  if (result == true) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Deleted successfully'),
                                      ),
                                    );
                                  }
                                });
                          },
                          child: Text(
                            category!.name,
                            style: TextStyle(
                              fontSize: 12,
                              color: taskColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Checkbox(
              value: task.isCompleted,
              onChanged: (bool? newValue) {
                onToggle();
              },
              activeColor: taskColor,
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
      child: Container(
        width: 70,
        margin: const EdgeInsets.symmetric(horizontal: 5.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4A90E2) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? const Color(0xFF4A90E2) : Colors.grey.shade300,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF4A90E2).withOpacity(0.3),
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
              isToday ? 'TODAY' : DateFormat('EEE').format(day).toUpperCase(),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black54,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              day.day.toString(),
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
