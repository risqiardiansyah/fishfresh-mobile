import 'dart:convert';

import 'package:fishfreshapp/src/model/data_provider.dart';
import 'package:fishfreshapp/src/model/session_manager.dart';
import 'package:fishfreshapp/src/pages/education/education_add.dart';
import 'package:fishfreshapp/src/pages/education/education_item.dart';
import 'package:fishfreshapp/src/pages/not_login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Education extends StatefulWidget {
  const Education({super.key});

  @override
  State<Education> createState() => _EducationState();
}

class _EducationState extends State<Education> {
  final SessionManager sessionManager = SessionManager();
  List<dynamic> educationItems = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  final int _limit = 10;
  int _offset = 0;

  String? token;
  dynamic users;

  @override
  void initState() {
    super.initState();
    checkToken();
    initData(context);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          _offset += _limit;
        });

        initData(context);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void initData(BuildContext context) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    var token = await sessionManager.getSession('token');

    try {
      await dataProvider.fetchData('education?limit=$_limit&offset=$_offset',
          token: token);

      if (dataProvider.data['success']) {
        setState(() {
          educationItems = dataProvider.data['data'];
        });
      } else {
        print("failed: ${dataProvider.data['message']}");
      }
    } catch (error) {
      print("Error during  $error");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _offset = 0;
      educationItems = [];
    });
    initData(context);
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
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: educationItems.isEmpty
            ? SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints.tightFor(
                    height: MediaQuery.of(context).size.height - 200,
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.book,
                          size: 100,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Belum ada Education',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : ListView.builder(
                controller: _scrollController,
                itemCount: educationItems.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == educationItems.length) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  var item = educationItems[index];
                  return EducationItem(
                    title: item['title'],
                    image: item['image'],
                    date: item['created_at'],
                    author: item['name'],
                    link: item['link'],
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => token!.isEmpty
                      ? const NotLogin()
                      : const EducationAddPage()),
            );

            initData(context);
          },
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF08244d),
          shape: const CircleBorder(),
          child: const Icon(Icons.edit),
        ),
      ),
    );
  }
}
