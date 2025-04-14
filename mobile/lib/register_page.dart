import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController designationController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String userId = '';
  String status = '';

  Future<void> registerUser() async {
    final url = Uri.parse('${AppConfig.baseUrl}/register');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': nameController.text,
          'designation': designationController.text,
          'password': passwordController.text,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        setState(() {
          userId = data['userId'];
          status = "Registration successful!";
        });
      } else {
        setState(() {
          status = "Registration failed: ${response.body}";
        });
      }
    } catch (e) {
      setState(() {
        status = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Register',
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Join our task management system',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: designationController,
                  decoration: const InputDecoration(
                    labelText: 'Designation',
                    prefixIcon: Icon(Icons.work_outline),
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
                    onPressed: registerUser,
                    child: const Text('Create Account'),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          status,
                          style: TextStyle(
                            color: status.contains('successful')
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        if (userId.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Your user ID: $userId',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
