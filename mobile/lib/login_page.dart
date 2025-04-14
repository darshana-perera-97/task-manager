import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';
import 'add_task_dialog.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String status = '';
  String userId = '';
  List tasks = [];
  List users = [];

  Future<void> loginUser() async {
    final url = Uri.parse('${AppConfig.baseUrl}/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': nameController.text,
          'password': passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          userId = data['userId'];
          status = "Login successful!";
        });
        await fetchUsers();
        await fetchTasks();
      } else {
        setState(() {
          status = "Login failed: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        status = "Error: $e";
      });
    }
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

  Future<void> fetchTasks() async {
    final url = Uri.parse('${AppConfig.baseUrl}/tasks');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      setState(() {
        tasks = jsonDecode(response.body);
      });
    }
  }

  void showTaskDetails(Map<String, dynamic> task) {
    List<String> assignedNames = [];

    for (var id in task['assignedTo']) {
      final matchingUser = users.firstWhere(
        (u) => u['userId'] == id,
        orElse: () => null,
      );

      if (matchingUser != null &&
          matchingUser is Map &&
          matchingUser['name'] != null) {
        assignedNames.add(matchingUser['name']);
      } else {
        assignedNames.add('Unknown');
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(task['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description: ${task['description']}'),
            const SizedBox(height: 10),
            const Text('Assigned To:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...assignedNames.map((name) => Text('- $name')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void openTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AddTaskDialog(onTaskCreated: fetchTasks),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = userId.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (!isLoggedIn) ...[
              TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name')),
              TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: loginUser, child: const Text('Login')),
            ],
            const SizedBox(height: 20),
            Text(status),
            if (isLoggedIn) ...[
              const SizedBox(height: 20),
              const Text("Tasks:",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Card(
                      child: ListTile(
                        title: Text(task['name']),
                        subtitle: Text(task['description']),
                        trailing:
                            Text('Assigned: ${task['assignedTo'].length}'),
                        onTap: () => showTaskDetails(task),
                      ),
                    );
                  },
                ),
              ),
            ]
          ],
        ),
      ),
      floatingActionButton: isLoggedIn
          ? FloatingActionButton(
              onPressed: openTaskDialog,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
