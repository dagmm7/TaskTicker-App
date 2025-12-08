import 'package:flutter/material.dart';

class CompletedTasksScreen extends StatelessWidget {
  const CompletedTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Completed Tasks",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  "Clear All",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ---- TODAY ----
          _sectionTitle("Today", 3),
          _taskTile("Submit quarterly report"),
          _taskTile("Call client about project timeline"),
          _taskTile("Buy groceries for dinner"),

          const SizedBox(height: 15),

          // ---- YESTERDAY ----
          _sectionTitle("Yesterday", 2),
          _taskTile("Schedule team meeting"),
          _taskTile("Review presentation slides"),

          const SizedBox(height: 15),

          // ---- LAST WEEK ----
          _sectionTitle("Last Week", 4),
          _taskTile("Finish monthly report analysis", subtitle: "Completed on Friday"),
          _taskTile("Send invoice to client", subtitle: "Completed on Thursday"),
          _taskTile("Update website content", subtitle: "Completed on Wednesday"),
          _taskTile("Prepare agenda for team meeting", subtitle: "Completed on Monday"),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        "$title   $count tasks",
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _taskTile(String title, {String? subtitle}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.check_circle, size: 18, color: Colors.green),
              const SizedBox(width: 6),
              Text(
                subtitle ?? "Completed",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
