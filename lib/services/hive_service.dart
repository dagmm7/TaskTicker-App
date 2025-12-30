import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../models/task_model.dart';
import '../models/category_model.dart';
import 'package:flutter/material.dart';

class HiveService {
  static const String usersBoxName = 'users';
  static const String tasksBoxName = 'tasks';
  static const String categoriesBoxName = 'categories';
  static const String appStateBoxName = 'appState';
  static const String settingsBoxName = 'settings';

  static Box? _usersBox;
  static Box? _tasksBox;
  static Box? _categoriesBox;
  static Box? _appStateBox;
  static Box? _settingsBox;
  // Notifier for theme mode changes: 'light' or 'dark'
  static ValueNotifier<String> themeNotifier = ValueNotifier<String>('light');

  // Initialize Hive
  static Future<void> init() async {
    await Hive.initFlutter();

    _usersBox = await Hive.openBox(usersBoxName);
    _tasksBox = await Hive.openBox(tasksBoxName);
    _categoriesBox = await Hive.openBox(categoriesBoxName);
    _appStateBox = await Hive.openBox(appStateBoxName);
    _settingsBox = await Hive.openBox(settingsBoxName);

    // Initialize default categories if none exist
    if (_categoriesBox!.isEmpty) {
      await _initializeDefaultCategories();
    }
  }

  static Future<void> _initializeDefaultCategories() async {
    final defaultCategories = [
      CategoryModel(
        id: 'work',
        name: 'Work',
        colorValue: Colors.blue.value,
        iconName: 'work',
      ),
      CategoryModel(
        id: 'family',
        name: 'Family',
        colorValue: Colors.orange.value,
        iconName: 'family_restroom',
      ),
      CategoryModel(
        id: 'school',
        name: 'School',
        colorValue: Colors.green.value,
        iconName: 'school',
      ),
      CategoryModel(
        id: 'personal',
        name: 'Personal',
        colorValue: Colors.purple.value,
        iconName: 'person',
      ),
    ];

    for (var category in defaultCategories) {
      await _categoriesBox!.put(category.id, category.toMap());
    }
  }

  // User operations
  static Future<void> saveUser(UserModel user) async {
    await _usersBox!.put(user.email, user.toMap());
  }

  static UserModel? getUser(String email) {
    final userData = _usersBox!.get(email);
    if (userData == null) return null;
    return UserModel.fromMap(Map<String, dynamic>.from(userData));
  }
  
  static bool userExists(String email) {
    return _usersBox!.containsKey(email);
  }

  static Future<void> updateUserOnboarding(String email, bool completed) async {
    final user = getUser(email);
    if (user != null) {
      user.hasCompletedOnboarding = completed;
      await saveUser(user);
    }
  }

  // Task operations
  static Future<void> saveTask(TaskModel task) async {
    await _tasksBox!.put(task.id, task.toMap());
  }

  static List<TaskModel> getAllTasks() {
    final tasks = <TaskModel>[];
    for (var key in _tasksBox!.keys) {
      final taskData = _tasksBox!.get(key);
      if (taskData != null) {
        tasks.add(TaskModel.fromMap(Map<String, dynamic>.from(taskData)));
      }
    }
    return tasks;
  }

  static List<TaskModel> getTasksByDate(DateTime date) {
    final allTasks = getAllTasks();
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return allTasks.where((task) {
      final taskDate = DateTime(
        task.dueDate.year,
        task.dueDate.month,
        task.dueDate.day,
      );
      return taskDate.isAtSameMomentAs(normalizedDate) && !task.isCompleted;
    }).toList();
  }

  static List<TaskModel> getTodayTasks() {
    return getTasksByDate(DateTime.now());
  }

  static List<TaskModel> getIncompleteTasks() {
    return getAllTasks().where((task) => !task.isCompleted).toList();
  }

  static List<TaskModel> getCompletedTasks() {
    return getAllTasks().where((task) => task.isCompleted).toList();
  }

  static List<TaskModel> getTasksByCategory(String categoryId) {
    return getAllTasks()
        .where((task) => task.categoryId == categoryId && !task.isCompleted)
        .toList();
  }
