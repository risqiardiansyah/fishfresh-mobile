import 'dart:convert';

import 'package:fishfreshapp/src/app.dart';
import 'package:fishfreshapp/src/model/data_provider.dart';
import 'package:fishfreshapp/src/model/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final SessionManager sessionManager = SessionManager();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfController = TextEditingController();
  String _gender = 'l';
  bool _isLoading = false;

  void _register(BuildContext context) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    setState(() {
      _isLoading = true;
    });

    try {
      await dataProvider.postData(
        'register',
        {
          'name': _nameController.text,
          'gender': _gender,
          'email': _emailController.text,
          'phone': _phoneController.text,
          'password': _passwordController.text,
          'password_confirmation': _passwordConfController.text,
        },
      );

      if (dataProvider.data['success']) {
        final user = dataProvider.data['data'];
        final token = user['token'];
        print("Register successful, token: $user['token']");
        sessionManager.saveSession('user', jsonEncode(user));
        sessionManager.saveSession('token', token);

        dataProvider.resetData();

        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false);
      } else {
        print("Register failed: ${dataProvider.data}");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Register failed: ${dataProvider.data['message']}")));
      }
    } catch (error) {
      print("Error during Register: $error");
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Register failed, please try again.")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                'assets/images/logo-blue.png',
                height: 180,
                width: 300,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              // Gender Selection
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text("Gender: "),
                  Radio<String>(
                    value: 'l',
                    groupValue: _gender,
                    onChanged: (value) {
                      setState(() {
                        _gender = value!;
                      });
                    },
                  ),
                  const Text('Laki-laki'),
                  Radio<String>(
                    value: 'p',
                    groupValue: _gender,
                    onChanged: (value) {
                      setState(() {
                        _gender = value!;
                      });
                    },
                  ),
                  const Text('Perempuan'),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                keyboardType: const TextInputType.numberWithOptions(),
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordConfController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Konfirmasi Password",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _isLoading ? print('disabled') : _register(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16), // Tinggi tombol
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: _isLoading
                        ? const Color(0xFFA4A4A4)
                        : const Color(0xFFff9000),
                  ),
                  child: Text(
                    _isLoading ? 'Loading...' : 'Dafter',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
