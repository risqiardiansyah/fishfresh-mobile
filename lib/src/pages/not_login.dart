import 'package:fishfreshapp/src/pages/auth/login.dart';
import 'package:flutter/material.dart';

class NotLogin extends StatefulWidget {
  const NotLogin({super.key});

  @override
  State<NotLogin> createState() => _NotLoginState();
}

class _NotLoginState extends State<NotLogin> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints.tightFor(
              height: MediaQuery.of(context).size.height - 500,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.block_flipped,
                    size: 100,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Silahkan login untuk mengakses halaman ini',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: const Color(0xFFff9000),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
