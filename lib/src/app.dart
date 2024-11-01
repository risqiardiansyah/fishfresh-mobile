import 'dart:convert';

import 'package:fishfreshapp/src/components/slide_right.dart';
import 'package:fishfreshapp/src/model/session_manager.dart';
import 'package:fishfreshapp/src/pages/education/education.dart';
import 'package:fishfreshapp/src/pages/home.dart';
import 'package:fishfreshapp/src/pages/not_login.dart';
import 'package:fishfreshapp/src/pages/product/search.dart';
import 'package:fishfreshapp/src/pages/profile/profile.dart';
import 'package:fishfreshapp/src/pages/transaction/transaksi.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marketplace',
      theme: ThemeData(primarySwatch: Colors.orange, fontFamily: 'Poppins'),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final int? setIndex;
  const HomeScreen({super.key, this.setIndex});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SessionManager sessionManager = SessionManager();
  final FocusNode _focusNode = FocusNode();
  final _keywordController = TextEditingController();
  String? token;
  dynamic users;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    checkToken();

    if (widget.setIndex != null) {
      setState(() {
        _currentIndex = widget.setIndex!;
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  checkToken() async {
    var tses = await sessionManager.getSession('token');
    var user = await sessionManager.getSession('user');

    if (user != null) {
      setState(() {
        users = jsonDecode(user);
      });
    }
    setState(() {
      token = tses;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('tapped');
        _focusNode.unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _currentIndex == 0
            ? AppBar(
                toolbarHeight: 120,
                elevation: 0,
                title: Padding(
                  padding:
                      const EdgeInsets.only(right: 5.0, left: 5.0, top: 16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: users?['name'] == null
                                ? const Text(
                                    'Selamat Datang di FishFresh',
                                    style: TextStyle(color: Colors.white),
                                  )
                                : Text(
                                    'Hi, ${users?['name']}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              focusNode: _focusNode,
                              textInputAction: TextInputAction.search,
                              controller: _keywordController,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                hintText: 'Cari Nila',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6.0),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onSubmitted: (value) async {
                                if (value.isNotEmpty) {
                                  await Navigator.push(
                                      context,
                                      SlideRightRoute(
                                          page: SearchPage(keyword: value)));

                                  setState(() {
                                    _keywordController.text = '';
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                backgroundColor: const Color(0xFFff9000),
              )
            : AppBar(
                elevation: 0,
                title: Padding(
                  padding:
                      const EdgeInsets.only(right: 5.0, left: 5.0, top: 16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _currentIndex == 0
                                  ? 'Home'
                                  : _currentIndex == 1
                                      ? 'Fish Education'
                                      : _currentIndex == 2
                                          ? 'Riwayat Transaksi'
                                          : 'Profile',
                              style: TextStyle(
                                  color: _currentIndex == 3
                                      ? Colors.black
                                      : Colors.white),
                              textAlign: _currentIndex == 1
                                  ? TextAlign.left
                                  : TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                backgroundColor:
                    _currentIndex == 3 ? Colors.white : Colors.orange,
                toolbarHeight: 80.0,
              ),

        body: _currentIndex == 0
            ? const Home()
            : _currentIndex == 1
                ? const Education()
                : _currentIndex == 2
                    ? (token != null ? const Transaksi() : const NotLogin())
                    : _currentIndex == 3
                        ? (token != null ? const Profile() : const NotLogin())
                        : const SizedBox.shrink(),
        // Bottom Navigation Bar
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.orange,
          unselectedItemColor: Colors.grey,
          currentIndex: _currentIndex,
          onTap: (index) async {
            await checkToken();
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Education'),
            BottomNavigationBarItem(
                icon: Icon(Icons.receipt), label: 'Transaksi'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}
