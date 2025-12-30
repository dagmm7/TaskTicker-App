import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_ticker_app/services/hive_service.dart';
import 'package:task_ticker_app/models/task_model.dart';
import 'package:task_ticker_app/models/category_model.dart';

class CompletedTasksScreen extends StatefulWidget {
  const CompletedTasksScreen({super.key});

  @override
  State<CompletedTasksScreen> createState() => _CompletedTasksScreenState();
}

class _CompletedTasksScreenState extends State<CompletedTasksScreen> {
  List<TaskModel> _completedTasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadTasks();
  }

  void _loadTasks() {
    setState(() {
      _completedTasks = HiveService.getCompletedTasks();
      // Sort by completion date (most recent first)
      _completedTasks.sort((a, b) {
        if (a.completedDate == null && b.completedDate == null) return 0;
        if (a.completedDate == null) return 1;
        if (b.completedDate == null) return -1;
        return b.completedDate!.compareTo(a.completedDate!);
      });
    });
  }

  Future<void> _clearAllCompleted() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Completed Tasks'),
        content: const Text(
          'Are you sure you want to delete all completed tasks? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      for (var task in _completedTasks) {
        await HiveService.deleteTask(task.id);
      }
      _loadTasks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All completed tasks cleared'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Map<String, List<TaskModel>> _groupTasksByDate() {
    final Map<String, List<TaskModel>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (var task in _completedTasks) {
      if (task.completedDate == null) continue;

      final taskDate = DateTime(
        task.completedDate!.year,
        task.completedDate!.month,
        task.completedDate!.day,
      );

      String groupKey;
      if (taskDate.isAtSameMomentAs(today)) {
        groupKey = 'Today';
      } else if (taskDate.isAtSameMomentAs(yesterday)) {
        groupKey = 'Yesterday';
      } else {
        final daysDiff = today.difference(taskDate).inDays;
        if (daysDiff <= 7) {
          groupKey = 'Last Week';
        } else if (daysDiff <= 30) {
          groupKey = 'Last Month';
        } else {
          groupKey = DateFormat('MMMM yyyy').format(task.completedDate!);
        }
      }

      if (!grouped.containsKey(groupKey)) {
        grouped[groupKey] = [];
      }
      grouped[groupKey]!.add(task);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final groupedTasks = _groupTasksByDate();

    return Container(
      color: Colors.grey.shade50,
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Completed Tasks",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                if (_completedTasks.isNotEmpty)
                  TextButton(
                    onPressed: _clearAllCompleted,
                    child: const Text(
                      "Clear All",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),

          // Tasks List
          Expanded(
            child: _completedTasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No completed tasks",
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
                    itemCount: groupedTasks.length,
                    itemBuilder: (context, index) {
                      final groupKey = groupedTasks.keys.elementAt(index);
                      final tasks = groupedTasks[groupKey]!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle(groupKey, tasks.length),
                          const SizedBox(height: 8),
                          ...tasks.map((task) {
                            final category = HiveService.getCategory(
                              task.categoryId,
                            );
                            return _taskTile(task, category);
                          }),
                          if (index < groupedTasks.length - 1)
                            const SizedBox(height: 15),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        "$title   $count ${count == 1 ? 'task' : 'tasks'}",
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _taskTile(TaskModel task, CategoryModel? category) {
    final taskColor = category?.color ?? Colors.grey;
    final completionDate = task.completedDate != null
        ? DateFormat('MMM d, yyyy h:mm a').format(task.completedDate!)
        : 'Completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ),
              if (category != null)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: taskColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.check_circle, size: 18, color: Colors.green),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  completionDate,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
              ),
              if (category != null)
                Text(
                  category.name,
                  style: TextStyle(
                    fontSize: 12,
                    color: taskColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
