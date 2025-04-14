import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';

class AddTaskDialog extends StatefulWidget {
  final VoidCallback onTaskCreated;
  const AddTaskDialog({super.key, required this.onTaskCreated});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  List users = [];
  List<String> selectedUserIds = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final url = Uri.parse('${AppConfig.baseUrl}/users');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      setState(() {
        users = jsonDecode(response.body);
      });
    }
  }

  void toggleUserSelection(String userId) {
    setState(() {
      if (selectedUserIds.contains(userId)) {
        selectedUserIds.remove(userId);
      } else {
        selectedUserIds.add(userId);
      }
    });
  }

  Future<void> createTask() async {
    final url = Uri.parse('${AppConfig.baseUrl}/tasks');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': nameController.text,
        'description': descriptionController.text,
        'assignedTo': selectedUserIds,
      }),
    );

    if (response.statusCode == 201) {
      widget.onTaskCreated();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Task"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Task Name')),
            TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description')),
            const SizedBox(height: 10),
            const Text("Assign To:"),
            Column(
              children: users.map<Widget>((user) {
                return CheckboxListTile(
                  title: Text(user['name']),
                  value: selectedUserIds.contains(user['userId']),
                  onChanged: (_) => toggleUserSelection(user['userId']),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel')),
        ElevatedButton(onPressed: createTask, child: const Text('Add')),
      ],
    );
  }
}
