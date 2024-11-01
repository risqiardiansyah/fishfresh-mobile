import 'dart:convert';

import 'package:fishfreshapp/src/app.dart';
import 'package:fishfreshapp/src/model/data_provider.dart';
import 'package:fishfreshapp/src/model/session_manager.dart';
import 'package:fishfreshapp/src/pages/auth/register.dart';
import 'package:fishfreshapp/src/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final SessionManager sessionManager = SessionManager();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    checkSession();
  }

  checkSession() async {
    var token = await sessionManager.getSession('token');

    if (token != null) {
      _redirectLogin();
    }
  }

  _redirectLogin() async {
    await Navigator.maybePop(
      context,
      MaterialPageRoute(builder: (context) => const Home()),
    );

    setState(() {
      checkSession();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login(BuildContext context) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    setState(() {
      _isLoading = true;
    });

    try {
      await dataProvider.postData(
        'login',
        {
          'email': _emailController.text,
          'password': _passwordController.text,
        },
      );

      if (dataProvider.data['success']) {
        final user = dataProvider.data['data'];
        final token = user['token'];
        print("Login successful, token: $user['token']");
        sessionManager.saveSession('user', jsonEncode(user));
        sessionManager.saveSession('token', token);

        dataProvider.resetData();

        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false);
      } else {
        print("Login failed: ${dataProvider.data['message']}");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Login failed: ${dataProvider.data['message']}")));
      }
    } catch (error) {
      print("Error during login: $error");
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login failed, please try again.")));
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
        title: const Text("Login"),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/images/logo-blue.png',
                    height: 180,
                    width: 300,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
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
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _login(context);
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
                      child: _isLoading
                          ? const Text('Loading...')
                          : const Text(
                              'Login',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Belum Punya Akun?',
                        ),
                        InkWell(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const RegisterPage()),
                            );

                            checkSession();
                          },
                          child: const Text(
                            ' Register',
                            style: TextStyle(color: Color(0xFFff9000)),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
