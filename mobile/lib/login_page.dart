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
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task['name'],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                task['description'],
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              const Text(
                'Assigned To:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...assignedNames.map((name) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline, size: 16),
                        const SizedBox(width: 8),
                        Text(name),
                      ],
                    ),
                  )),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
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
      appBar: AppBar(
        title: const Text(
          'Login',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              if (!isLoggedIn) ...[
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loginUser,
                    child: const Text('Login'),
                  ),
                ),
                const SizedBox(height: 16),
                if (status.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: status.contains('successful')
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: status.contains('successful')
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ),
              ],
              if (isLoggedIn) ...[
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Tasks",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: openTaskDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('New Task'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () => showTaskDetails(task),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        task['name'],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '${task['assignedTo'].length} assigned',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimaryContainer,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  task['description'],
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
