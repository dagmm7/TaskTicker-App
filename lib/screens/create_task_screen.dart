import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_ticker_app/services/hive_service.dart';
import 'package:task_ticker_app/models/task_model.dart';
import 'package:task_ticker_app/models/category_model.dart';

class CreateTaskScreen extends StatefulWidget {
  final bool showCategoryCreation;
  final VoidCallback? onTaskSaved;

  const CreateTaskScreen({
    super.key,
    this.showCategoryCreation = false,
    this.onTaskSaved,
  });

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryNameController = TextEditingController();

  String? _selectedCategoryId;
  DateTime? _selectedDate;
  bool _pushNotification = false;
  bool _emailAlert = false;
  bool _isCreatingCategory = false;
  Color _selectedCategoryColor = Colors.blue;
  List<CategoryModel> _categories = [];

  final List<Color> _colorOptions = [
    Colors.blue,
    Colors.orange,
    Colors.green,
    Colors.purple,
    Colors.red,
    Colors.pink,
    Colors.teal,
    Colors.amber,
  ];

  @override
  void initState() {
    super.initState();
    _isCreatingCategory = widget.showCategoryCreation;
    _loadCategories();
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryNameController.dispose();
    super.dispose();
  }

  void _loadCategories() {
    setState(() {
      _categories = HiveService.getAllCategories();
    });
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate ?? DateTime.now()),
      );
      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _createCategory() async {
    if (_categoryNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a category name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final categoryId = DateTime.now().millisecondsSinceEpoch.toString();
    final category = CategoryModel(
      id: categoryId,
      name: _categoryNameController.text.trim(),
      colorValue: _selectedCategoryColor.value,
      iconName: 'category',
    );

    await HiveService.saveCategory(category);
    _loadCategories();
    setState(() {
      _selectedCategoryId = categoryId;
      _isCreatingCategory = false;
      _categoryNameController.clear();
    });

    // Notify parent screens to refresh
    if (mounted) {
      // This will trigger a refresh in dashboard and other screens
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Category created successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a due date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final taskId = DateTime.now().millisecondsSinceEpoch.toString();
    final task = TaskModel(
      id: taskId,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      categoryId: _selectedCategoryId!,
      dueDate: _selectedDate!,
      reminderType: _getReminderType(),
      isCompleted: false,
    );

    await HiveService.saveTask(task);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task created successfully'),
          backgroundColor: Colors.green,
        ),
      );
      // Call callback to switch to Tasks tab
      if (widget.onTaskSaved != null) {
        widget.onTaskSaved!();
      }
    }
  }

  String _getReminderType() {
    // Build reminder type string
    List<String> types = [];
    if (_pushNotification) types.add('push');
    if (_emailAlert) types.add('email');
    if (types.isEmpty) return 'none';
    return types.join(',');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade50,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Create New Task",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              const Text("Fill in the details below to add a new task"),
              const SizedBox(height: 25),

              // TITLE FIELD
              const Text(
                "Task Title*",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: "Enter task title",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Task title is required";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 15),

              // DESCRIPTION FIELD
              const Text("Description"),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  hintText: "Enter task description (optional)",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 15),

              // CATEGORY SECTION
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Category*",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isCreatingCategory = !_isCreatingCategory;
                      });
                    },
                    child: Text(
                      _isCreatingCategory ? "Select Existing" : "Create New",
                      style: const TextStyle(color: Color(0xFF4A90E2)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (_isCreatingCategory) ...[
                // Category Creation UI
                TextField(
                  controller: _categoryNameController,
                  decoration: const InputDecoration(
                    hintText: "Category name",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text("Select Color:"),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _colorOptions.map((color) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategoryColor = color;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _selectedCategoryColor == color
                                ? Colors.black
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _createCategory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90E2),
                  ),
                  child: const Text("Create Category"),
                ),
                const SizedBox(height: 15),
              ] else ...[
                // Category Selector
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCategoryId,
                    isExpanded: true,
                    decoration: const InputDecoration(border: InputBorder.none),
                    hint: const Text("Select category"),
                    items: [
                      // Add "Create New Category" option
                      const DropdownMenuItem<String>(
                        value: '__create_new__',
                        child: Row(
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              size: 16,
                              color: Color(0xFF4A90E2),
                            ),
                            SizedBox(width: 8),
                            Text(
                              "Create New Category",
                              style: TextStyle(color: Color(0xFF4A90E2)),
                            ),
                          ],
                        ),
                      ),
                      // Existing categories
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
                      if (value == '__create_new__') {
                        setState(() {
                          _isCreatingCategory = true;
                          _selectedCategoryId = null;
                        });
                      } else if (value != null) {
                        setState(() {
                          _selectedCategoryId = value;
                          _isCreatingCategory = false;
                        });
                      }
                    },
                  ),
                ),
              ],

              const SizedBox(height: 15),

              // DATE PICKER FIELD
              const Text(
                "Due Date*",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedDate != null
                            ? DateFormat(
                                'MM/dd/yyyy h:mm a',
                              ).format(_selectedDate!)
                            : "MM/DD/YYYY",
                        style: TextStyle(
                          color: _selectedDate != null
                              ? Colors.black87
                              : Colors.grey,
                        ),
                      ),
                      const Icon(
                        Icons.calendar_today,
                        color: Color(0xFF4A90E2),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // REMINDER OPTIONS
              const Text(
                "Reminder Options",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              _reminderSwitch(
                "Push Notification",
                _pushNotification,
                (v) => setState(() => _pushNotification = v),
              ),
              _reminderSwitch(
                "Email Alert",
                _emailAlert,
                (v) => setState(() => _emailAlert = v),
              ),

              const SizedBox(height: 25),

              // ACTION BUTTONS
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4A90E2),
                        side: const BorderSide(color: Color(0xFF4A90E2)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A90E2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _saveTask,
                      child: const Text("Save Task"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _reminderSwitch(String label, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(label),
      value: value,
      activeThumbColor: const Color(0xFF4A90E2),
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }
}
