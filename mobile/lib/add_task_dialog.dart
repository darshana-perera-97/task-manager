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
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Create New Task",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Task Name',
                prefixIcon: Icon(Icons.task_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description_outlined),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            const Text(
              "Assign To",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.3,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: CheckboxListTile(
                      title: Text(user['name']),
                      subtitle: Text(user['designation'] ?? ''),
                      value: selectedUserIds.contains(user['userId']),
                      onChanged: (_) => toggleUserSelection(user['userId']),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: createTask,
                  child: const Text('Create Task'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
