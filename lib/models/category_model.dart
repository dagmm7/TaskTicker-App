import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class CategoryModel extends HiveObject {
  String id;
  String name;
  int colorValue; // Store color as int value
  String iconName; // Store icon name as string

  CategoryModel({
    required this.id,
    required this.name,
    required this.colorValue,
    this.iconName = 'work',
  });

  Color get color => Color(colorValue);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'colorValue': colorValue,
      'iconName': iconName,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      colorValue: map['colorValue'] ?? Colors.blue.value,
      iconName: map['iconName'] ?? 'work',
    );
  }
}