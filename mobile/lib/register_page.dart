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
          status = "Registered successfully!";
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
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name')),
            TextField(
                controller: designationController,
                decoration: const InputDecoration(labelText: 'Designation')),
            TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: registerUser, child: const Text('Register')),
            const SizedBox(height: 20),
            Text(status),
            if (userId.isNotEmpty) Text('Your user ID: $userId'),
          ],
        ),
      ),
    );
  }
}
