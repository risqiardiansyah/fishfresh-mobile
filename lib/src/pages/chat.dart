import 'dart:async';

import 'package:fishfreshapp/src/model/data_provider.dart';
import 'package:fishfreshapp/src/model/session_manager.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  final dynamic idTo;
  final dynamic nameTo;
  final bool isShop;
  const ChatPage({super.key, this.idTo, this.nameTo, required this.isShop});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final SessionManager sessionManager = SessionManager();
  List<dynamic> messages = [];

  final TextEditingController _controller = TextEditingController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    getChat(context);

    _startAutoUpdate();
  }

  void _sendMessage() async {
    if (_controller.text.isNotEmpty) {
      final dataProvider = Provider.of<DataProvider>(context, listen: false);

      var token = await sessionManager.getSession('token');
      try {
        var path = widget.isShop ? 'shop/messages/send' : 'messages/send';
        await dataProvider.postData(
          path,
          {
            'to': widget.idTo,
            'messages': _controller.text,
          },
          token: token,
        );
      } catch (error) {
        print("Error during login: $error");
      } finally {
        _controller.text = '';
        getChat(context);
        // setState(() {
        //   _isLoading = false;
        // });
      }
      // setState(() {
      //   messages.insert(0, {"text": _controller.text, "isSentByMe": true});
      //   _controller.clear();
      // });
    }
  }

  void _startAutoUpdate() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      getChat(context);
      // setState(() {
      //   messages.insert(0, {
      //     "text":
      //         "Automatic message at ${DateTime.now().toLocal().toIso8601String()}",
      //     "isSentByMe": false,
      //   });
      // });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void getChat(BuildContext context) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    var token = await sessionManager.getSession('token');
    try {
      var path = widget.isShop ? 'shop/messages' : 'messages';
      await dataProvider.fetchData(
        '$path?to=${widget.idTo}',
        token: token,
      );

      if (dataProvider.data['success']) {
        setState(() {
          messages = dataProvider.data['data'];
        });
      } else {
        print("failed: ${dataProvider.data['message']}");
      }
    } catch (error) {
      print("Error during login: $error");
    } finally {
      // setState(() {
      //   _isLoading = false;
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nameTo),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
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
                              Icons.mark_chat_unread_rounded,
                              size: 100,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Belum ada percakapan',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return Align(
                        alignment: message['me']
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: ChatBubble(
                          text: message['messages'],
                          time: message['created_at'],
                          isSentByMe: message['me'],
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Tulis Pesan",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String text;
  final String time;
  final bool isSentByMe;

  const ChatBubble(
      {super.key,
      required this.text,
      required this.isSentByMe,
      required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.3,
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSentByMe ? const Color(0xFFff9000) : Colors.grey[300],
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(15),
          topRight: const Radius.circular(15),
          bottomLeft:
              isSentByMe ? const Radius.circular(15) : const Radius.circular(0),
          bottomRight:
              isSentByMe ? const Radius.circular(0) : const Radius.circular(15),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isSentByMe ? Colors.white : Colors.black87,
                fontSize: 16,
              ),
            ),
          ),
          Text(
            DateFormat.Hm().format(DateTime.parse(time)),
            style: TextStyle(
              color: isSentByMe ? Colors.white : Colors.black87,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
