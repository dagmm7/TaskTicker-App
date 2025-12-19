import 'package:flutter/material.dart';
//import 'package:intl/intl.dart';
//import 'completed_tasks_screen.dart';
// Assuming TaskCategory and Task models are defined or imported from dashboard_screen.dart
// For a standalone file, we must redefine them here.

// Enum to define the current view state of the TasksScreen
// category: Viewing incomplete tasks filtered by the selected category.
// completedCategory: Viewing completed tasks filtered by the selected category (New).
enum _ViewMode { category, completedCategory }

// --- DATA MODELS (Redefined for clarity and completeness) ---
class TaskCategory {
  final String name;
  final int taskCount;
  final Color color;
  final IconData icon;

  TaskCategory(this.name, this.taskCount, this.color, this.icon);
}

class Task {
  final String title;
  final String description;
  final TaskCategory category;
  final bool isCompleted;

  Task(this.title, this.description, this.category, {this.isCompleted = false});
}

// Simulated data
final List<TaskCategory> categories = [
  TaskCategory('Work', 5, Colors.blue, Icons.work),
  TaskCategory('Family', 3, Colors.orange, Icons.family_restroom),
  TaskCategory('School', 6, Colors.green, Icons.school),
  TaskCategory('Personal', 3, Colors.purple, Icons.person),
  TaskCategory(
    'Add New',
    0,
    Colors.red,
    Icons.add,
  ), // For the 'Add' button placeholder
];

final List<Task> allTasks = [
  // Work tasks
  Task(
    'Quarterly Report Draft',
    'Prepare initial draft for Q3 financial performance review',
    categories[0],
  ),
  Task(
    'Client Presentation',
    'Finalize slides for the Johnson & Co. proposal',
    categories[0],
  ),
  Task(
    'Team Meeting Agenda',
    'Prepare discussion points for weekly team sync',
    categories[0],
  ),
  Task(
    'Budget Review',
    'Analyze Q4 department spending and prepare adjustments',
    categories[0],
    isCompleted: true,
  ),
  Task(
    'Project Timeline Update',
    'Revise milestone dates for the Henderson project',
    categories[0],
  ),

  // Family tasks
  Task('Grocery Shopping', 'Buy groceries for dinner', categories[1]),
  Task(
    'Plan Weekend Trip',
    'Book cabin and activities for weekend getaway',
    categories[1],
    isCompleted: true,
  ),

  // School tasks
  Task(
    'Read Chapter 5',
    'Complete reading assignment for Literature class',
    categories[2],
  ),
  Task(
    'Submit Homework',
    'Upload Math 101 assignment to portal',
    categories[2],
  ),

  // Completed tasks (used for the total count)
  Task('Old Task 1', 'Already finished', categories[3], isCompleted: true),
  Task('Old Task 2', 'Already finished', categories[3], isCompleted: true),
];

// --- WIDGETS ---

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  // State to hold the currently selected category for filtering.
  TaskCategory _selectedCategory = categories.first;

  // State to manage the view mode (Category filter vs. Completed tasks list)
  _ViewMode _currentViewMode = _ViewMode.category;

  // Calculates the number of remaining (uncompleted) tasks.
  int get _tasksRemainingCount {
    return allTasks.where((task) => !task.isCompleted).length;
  }

  // Filters tasks based on the current view mode and selected category.
  List<Task> get _filteredTasks {
    if (_selectedCategory.name == 'Add New')
      return []; // Should not happen in completed view
      if (_currentViewMode == _ViewMode.completedCategory) {
      // Return COMPLETED tasks filtered by the currently selected category
      return allTasks
          .where(
            (task) =>
                task.isCompleted &&
                task.category.name == _selectedCategory.name,
          )
          .toList();
    } else {
      // Viewing standard INCOMPLETE Category Tasks:
      return allTasks
          .where(
            (task) =>
                !task.isCompleted &&
                task.category.name == _selectedCategory.name,
          )
          .toList();
    }
  }

  // Handles Category selection tap
  void _onCategorySelected(TaskCategory category) {
    if (category.name == 'Add New') {
      // TODO: Implement navigation to Create New Task Screen
      print("Navigate to Create New Task Screen from Tasks Screen");
    } else {
      setState(() {
        _selectedCategory = category;
        // Keep the current view mode (category/completedCategory) when changing categories
      });
    }
  }

  // Handles switching between Category Tasks View and Completed Tasks View
  void _toggleCompletedTasksView() {
    setState(() {
      // If currently viewing incomplete tasks, switch to completed category view
      if (_currentViewMode == _ViewMode.category) {
        _currentViewMode = _ViewMode.completedCategory;
        // Reset selected category to the first one when switching to completed view
        _selectedCategory = categories.first;
      } else {
        // If currently viewing completed tasks, switch back to incomplete category view
        _currentViewMode = _ViewMode.category;
      }
    });
  }

  // Helper to calculate the total number of completed tasks across all categories
  int get _totalCompletedCount {
    return allTasks.where((task) => task.isCompleted).length;
  }

  // Helper to calculate the number of completed tasks for the currently selected category
  int get _categoryCompletedCount {
    return allTasks
        .where(
          (task) =>
              task.isCompleted && task.category.name == _selectedCategory.name,
        )
        .length;
  }

  

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _filteredTasks;
    final isViewingCompleted = _currentViewMode == _ViewMode.completedCategory;

    // Determine the header and count text based on the view mode
    final headerTitle = isViewingCompleted ? "Completed Tasks" : "Tasks";

    // Adjust count text based on view mode and category selection
    final countText = isViewingCompleted
        ? "${_categoryCompletedCount} tasks completed in ${_selectedCategory.name}"
        : "${_tasksRemainingCount} tasks remaining";

    final actionButtonText = isViewingCompleted
        ? "Back to Incomplete Tasks"
        : "View Completed Tasks (${_totalCompletedCount})";
        return Scaffold(
      appBar: AppBar(
        title: Text(
          headerTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.black87),
            onPressed: () {
              // TODO: Implement task editing/reordering mode
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline,
              color: Colors.blueAccent,
            ),
            onPressed: () {
              // TODO: Implement navigation to Task Creation Screen
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Horizontal Category Filter (Visible in BOTH modes)
          SizedBox(
            // Removed if (!isViewingCompleted) wrapper
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = category.name == _selectedCategory.name;

                // Skip the "Add New" button in the filter list if it's not the last item
                if (category.name == 'Add New') return const SizedBox.shrink();

                return GestureDetector(
                  onTap: () => _onCategorySelected(category),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 6.0,
                      vertical: 8.0,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: isSelected ? category.color : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: category.color.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        category.name,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Divider Line (Present in both modes)
          const Divider(height: 1, thickness: 1, color: Colors.black12),
          const SizedBox(height: 16),

          // Tasks Remaining/Completed Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              countText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Task List (Filtered by Category / Completed)
          Expanded(
            child: filteredTasks.isEmpty
                ? Center(
                    child: Text(
                      isViewingCompleted
                          ? "No completed tasks found in the ${_selectedCategory.name} category."
                          : "No tasks found in the ${_selectedCategory.name} category.",
                      style: const TextStyle(
                        color: Colors.black45,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = filteredTasks[index];
                      return TaskDetailItem(task: task);
                    },
                  ),
          ),

          // View Completed Tasks Button (Now a toggle)
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TaskActionButton(
              text: actionButtonText,
              color: isViewingCompleted
                  ? Colors.orange
                  : Colors
                        .blueAccent, // Use different color to show toggle state
              onPressed: _toggleCompletedTasksView, // Call the toggle function
            ),
          ),

          // Switch to Calendar View Button (Placeholder)
          Padding(
            padding: const EdgeInsets.only(
              left: 20.0,
              right: 20.0,
              bottom: 20.0,
            ),
            child: TaskActionButton(
              text: "Switch to Calendar View",
              color: Colors.grey.shade200,
              textColor: Colors.black87,
              onPressed: () {
                // TODO: Implement navigation back to DashboardScreen or Calendar View
                print("Switch to Calendar View Tapped (No action yet)");
              },
            ),
          ),
        ],
      ),
    );
  }
}



// Custom Widget for the detailed task item in the list
class TaskDetailItem extends StatelessWidget {
  final Task task;
  const TaskDetailItem({super.key, required this.task});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Checkbox/Completion Indicator
              Icon(
                task.isCompleted
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: task.isCompleted ? Colors.green : task.category.color,
                size: 20,
              ),
              const SizedBox(width: 10),
              // Task Title
              Expanded(
                child: Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
              ),
              // Category Name Chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: task.category.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  task.category.name,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: task.category.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Task Description
          Padding(
            padding: const EdgeInsets.only(
              left: 30.0,
            ), // Align description under the title
            child: Text(
              task.description,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Widget for the action buttons at the bottom
class TaskActionButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final VoidCallback onPressed;

  const TaskActionButton({
    super.key,
    required this.text,
    required this.color,
    required this.onPressed,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: color == Colors.blueAccent || color == Colors.orange
            ? [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}