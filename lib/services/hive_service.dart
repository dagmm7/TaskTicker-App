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
   static Future<void> updateTaskCompletion(
    String taskId,
    bool isCompleted,
  ) async {
    final taskData = _tasksBox!.get(taskId);
    if (taskData != null) {
      final task = TaskModel.fromMap(Map<String, dynamic>.from(taskData));
      task.isCompleted = isCompleted;
      task.completedDate = isCompleted ? DateTime.now() : null;
      await saveTask(task);
    }
  }

  static Future<void> deleteTask(String taskId) async {
    await _tasksBox!.delete(taskId);
  }

  // Category operations
  static Future<void> saveCategory(CategoryModel category) async {
    await _categoriesBox!.put(category.id, category.toMap());
  }

  static List<CategoryModel> getAllCategories() {
    final categories = <CategoryModel>[];
    for (var key in _categoriesBox!.keys) {
      final categoryData = _categoriesBox!.get(key);
      if (categoryData != null) {
        categories.add(
          CategoryModel.fromMap(Map<String, dynamic>.from(categoryData)),
        );
      }
    }
    return categories;
  }

  static CategoryModel? getCategory(String categoryId) {
    final categoryData = _categoriesBox!.get(categoryId);
    if (categoryData == null) return null;
    return CategoryModel.fromMap(Map<String, dynamic>.from(categoryData));
  }

  static Future<void> deleteCategory(String categoryId) async {
    await _categoriesBox!.delete(categoryId);
  }

  // App state operations
  static Future<void> setOnboardingCompleted(bool completed) async {
    await _appStateBox!.put('onboardingCompleted', completed);
  }

  static bool isOnboardingCompleted() {
    return _appStateBox!.get('onboardingCompleted', defaultValue: false);
  }

  static String? getCurrentUserEmail() {
    return _appStateBox!.get('currentUserEmail');
  }

  static Future<void> setCurrentUserEmail(String? email) async {
    if (email == null) {
      await _appStateBox!.delete('currentUserEmail');
    } else {
      await _appStateBox!.put('currentUserEmail', email);
    }
  }

  // Settings operations
  static Future<void> setThemeMode(String themeMode) async {
    await _settingsBox!.put('themeMode', themeMode); // 'light' or 'dark'
    // Notify listeners about theme change
    themeNotifier.value = themeMode;
  }

  static String getThemeMode() {
    return _settingsBox!.get('themeMode', defaultValue: 'light');
  }

  static Future<void> setLanguage(String language) async {
    await _settingsBox!.put('language', language);
  }

  static String getLanguage() {
    return _settingsBox!.get('language', defaultValue: 'en');
  }

  // Profile picture operations
  static Future<void> updateUserProfilePicture(
    String email,
    String? picturePath,
  ) async {
    final user = getUser(email);
    if (user != null) {
      user.profilePicturePath = picturePath;
      await saveUser(user);
    }
  }

  static Future<void> updateUserName(String email, String newName) async {
    final user = getUser(email);
    if (user != null) {
      user.fullName = newName;
      await saveUser(user);
    }
  }

  static Future<void> updateUserEmail(String oldEmail, String newEmail) async {
    final user = getUser(oldEmail);
    if (user != null) {
      // Delete old user entry
      await _usersBox!.delete(oldEmail);
      // Update email and save with new key
      user.email = newEmail;
      await _usersBox!.put(newEmail, user.toMap());
      // Update current user email if it matches
      if (getCurrentUserEmail() == oldEmail) {
        await setCurrentUserEmail(newEmail);
      }
    }
  }

  static Future<bool> updateUserPassword(
    String email,
    String currentPassword,
    String newPassword,
  ) async {
    final user = getUser(email);
    if (user != null && user.password == currentPassword) {
      user.password = newPassword;
      await saveUser(user);
      return true;
    }
    return false;
  }

  // Get all tasks (including completed) for "All Tasks Created"
  static List<TaskModel> getAllTasksCreated() {
    return getAllTasks();
  }

  // Get deleted tasks (soft delete - tasks marked as deleted)
  static List<TaskModel> getDeletedTasks() {
    // For now, we'll use a simple approach - tasks with a special flag
    // In a real app, you'd have a deleted flag in TaskModel
    return []; // Placeholder - can be extended later
  }
}

