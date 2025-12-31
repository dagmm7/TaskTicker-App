import 'package:flutter/material.dart';
import 'package:task_ticker_app/services/hive_service.dart';
import 'package:task_ticker_app/models/task_model.dart';
import 'package:task_ticker_app/models/category_model.dart';
import 'create_task_screen.dart';
import 'calandar_view_screen.dart';
import 'category_edit_screen.dart';

class TasksScreen extends StatefulWidget {
  final String? selectedCategoryId;
  final bool showAllTasks; // If true, show all tasks including completed

  const TasksScreen({
    super.key,
    this.selectedCategoryId,
    this.showAllTasks = false,
  });

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String? _selectedCategoryId;
  List<TaskModel> _tasks = [];
  List<CategoryModel> _categories = [];

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.selectedCategoryId;
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _categories = HiveService.getAllCategories();
      if (widget.showAllTasks) {
        // Show all tasks (including completed)
        _tasks = HiveService.getAllTasksCreated();
      } else if (_selectedCategoryId != null) {
        _tasks = HiveService.getTasksByCategory(_selectedCategoryId!);
      } else {
        _tasks = HiveService.getIncompleteTasks();
      }
    });
  }

  Future<void> _toggleTaskCompletion(TaskModel task) async {
    await HiveService.updateTaskCompletion(task.id, !task.isCompleted);
    _loadData();
  }

  void _navigateToCalendar() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CalendarViewScreen(
          selectedDay: DateTime.now(),
          onDaySelected: (day) {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAllTasks
          ? AppBar(
              title: const Text('All Tasks Created'),
              backgroundColor: const Color(0xFF4A90E2),
              foregroundColor: Colors.white,
            )
          : null,
      backgroundColor: Colors.grey.shade50,
      body: Column(
        children: [
          // Category Selector (only show if not showing all tasks)
          if (!widget.showAllTasks)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Category",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    hint: const Text("All Categories"),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text("All Categories"),
                      ),
                      ..._categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category.id,
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: category.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(category.name),
                            ],
                          ),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                      _loadData();
                    },
                  ),
                ],
              ),
            ),

          // Action Buttons (only show if not showing all tasks)
          if (!widget.showAllTasks)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        final selectedCategory = _selectedCategoryId != null
                            ? HiveService.getCategory(_selectedCategoryId!)
                            : null;
                        Navigator.of(context)
                            .push(
                              MaterialPageRoute(
                                builder: (context) => CategoryEditScreen(
                                  category: selectedCategory,
                                ),
                              ),
                            )
                            .then((_) => _loadData());
                      },
                      icon: const Icon(Icons.add),
                      label: const Text("Customize Category"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4A90E2),
                        side: const BorderSide(color: Color(0xFF4A90E2)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _navigateToCalendar,
                      icon: const Icon(Icons.calendar_month),
                      label: const Text("Calendar View"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4A90E2),
                        side: const BorderSide(color: Color(0xFF4A90E2)),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Tasks List
          Expanded(
            child: _tasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.task_alt,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No tasks found",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _tasks.length,
                    itemBuilder: (context, index) {
                      final task = _tasks[index];
                      final category = HiveService.getCategory(task.categoryId);
                      return _TaskCard(
                        task: task,
                        category: category,
                        onToggle: () => _toggleTaskCompletion(task),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final TaskModel task;
  final CategoryModel? category;
  final VoidCallback onToggle;

  const _TaskCard({required this.task, this.category, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final taskColor = category?.color ?? Colors.grey;
    final timeString = task.dueDate.toString().substring(0, 16);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: taskColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: task.isCompleted ? Colors.grey : Colors.black87,
                  ),
                ),
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    task.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      timeString,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (category != null) ...[
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: taskColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context)
                              .push(
                                MaterialPageRoute(
                                  builder: (ctx) =>
                                      CategoryEditScreen(category: category),
                                ),
                              )
                              .then(
                                (_) => context
                                    .findAncestorStateOfType<
                                      _TasksScreenState
                                    >()
                                    ?._loadData(),
                              );
                        },
                        child: Text(
                          category!.name,
                          style: TextStyle(
                            fontSize: 12,
                            color: taskColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
