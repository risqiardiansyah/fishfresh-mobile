import 'dart:convert';

import 'package:fishfreshapp/src/app.dart';
import 'package:fishfreshapp/src/pages/address/address_list.dart';
import 'package:fishfreshapp/src/pages/auth/login.dart';
import 'package:fishfreshapp/src/model/session_manager.dart';
import 'package:fishfreshapp/src/pages/shop/main_shop.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final SessionManager sessionManager = SessionManager();
  dynamic users;

  _launchURL() async {
    final Uri url = Uri.parse('https://fishfresh.id');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  void initState() {
    super.initState();

    initSession();
  }

  initSession() async {
    var token = await sessionManager.getSession('token');
    var user = await sessionManager.getSession('user');

    if (user != null) {
      setState(() {
        users = jsonDecode(user);
      });
      print(users['id']);
    }

    if (token == null) {
      _redirectLogin();
    }
  }

  _redirectLogin() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );

    setState(() {
      initSession();
    });
  }

  Future<void> _onRefresh() async {
    initSession();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Profile Picture
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/images/profile.png'),
              ),
              const SizedBox(height: 10),
              // Name
              Text(
                users?['name'] ?? '-',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                users?['phone'] ?? '-',
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 30),
              // ProfileMenuItem(
              //   icon: Icons.person_outline,
              //   text: 'Edit Profile',
              //   onTap: () {
              //     // Aksi jika menu Edit Profile ditekan
              //   },
              // ),
              ProfileMenuItem(
                icon: Icons.store,
                text: 'Toko Saya',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MainShop()),
                  );
                },
              ),
              ProfileMenuItem(
                icon: Icons.location_on_outlined,
                text: 'Alamat',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AddressList()),
                  );
                },
              ),
              ProfileMenuItem(
                icon: Icons.call,
                text: 'Hubungi Kami',
                onTap: () {
                  _launchURL();
                },
              ),
              ProfileMenuItem(
                icon: Icons.logout,
                text: 'Keluar',
                onTap: () {
                  sessionManager.clearSession();

                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const HomeScreen()),
                      (route) => false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
