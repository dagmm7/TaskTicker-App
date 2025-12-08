import 'package:flutter/material.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  String? selectedCategory;
  bool push = false;
  bool email = false;
  bool none = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
            const Text("Task Title*", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: "Enter task title",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 15),

            // DESCRIPTION FIELD
            const Text("Description"),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: "Enter task description",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 15),

            // CATEGORY DROPDOWN
            const Text("Category*", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<String>(
                value: selectedCategory,
                isExpanded: true,
                underline: const SizedBox(),
                hint: const Text("Select category"),
                items: ["Work", "School", "Personal", "Family"]
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => selectedCategory = value);
                },
              ),
            ),

            const SizedBox(height: 15),

            // DATE PICKER FIELD
            const Text("Due Date*", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                hintText: "MM/DD/YYYY",
                suffixIcon: const Icon(Icons.calendar_today),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onTap: () {},
            ),

            const SizedBox(height: 25),

            const Text("Reminder Options",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            _reminderSwitch("Push Notification", push, (v) => setState(() => push = v)),
            _reminderSwitch("Email Alert", email, (v) => setState(() => email = v)),
            _reminderSwitch("None", none, (v) => setState(() => none = v)),

            const SizedBox(height: 25),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {},
                    child: const Text("Save Task"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _reminderSwitch(String label, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(label),
      value: value,
      activeThumbColor: Colors.blue,
      onChanged: onChanged,
    );
  }
}
