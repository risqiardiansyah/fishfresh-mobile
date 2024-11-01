import 'package:fishfreshapp/src/model/data_provider.dart';
import 'package:fishfreshapp/src/model/session_manager.dart';
import 'package:fishfreshapp/src/pages/chat.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatList extends StatefulWidget {
  const ChatList({super.key});

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  final SessionManager sessionManager = SessionManager();

  List<dynamic> chats = [];

  @override
  void initState() {
    super.initState();

    initSession(context);
  }

  void initSession(BuildContext context) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    var token = await sessionManager.getSession('token');

    try {
      await dataProvider.fetchData('shop/messages/list', token: token);

      if (dataProvider.data['success']) {
        setState(() {
          chats = dataProvider.data['data'];
        });
      } else {
        print(" failed: ${dataProvider.data['message']}");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(" failed: ${dataProvider.data['message']}")));
      }
    } catch (error) {
      print("Error during : $error");
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(" failed, please try again.")));
    } finally {
      setState(() {
        // _isLoading = false;
      });
    }
  }

  Future<void> _onRefresh() async {
    initSession(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pesan"),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: chats.isEmpty
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
                          Icons.bubble_chart_outlined,
                          size: 100,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Belum ada pesan',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : ListView.builder(
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final dat = chats[index];
                  return ListItem(
                    icon: Icons.location_on_outlined,
                    user: dat['user']['name'] ?? '-',
                    messages: dat['messages'] ?? '-',
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            idTo: dat['user']['id'],
                            nameTo: dat['user']['name'],
                            isShop: true,
                          ),
                        ),
                      );

                      setState(() {
                        initSession(context);
                      });
                    },
                  );
                },
              ),
      ),
    );
  }
}

class ListItem extends StatelessWidget {
  final IconData icon;
  final String? user;
  final String? messages;
  final VoidCallback onTap;

  const ListItem({
    super.key,
    required this.icon,
    this.user,
    this.messages,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipOval(
        child: Image.asset(
          'assets/images/profile.png',
          width: 40.0,
          height: 40.0,
          fit: BoxFit.cover,
        ),
      ),
      title: Text(
        user ?? '-',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        messages ?? '',
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onTap,
    );
  }
}
