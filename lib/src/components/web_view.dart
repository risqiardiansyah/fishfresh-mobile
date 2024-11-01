import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebView extends StatefulWidget {
  final String title;
  final String initialUrl;
  final VoidCallback onPressed;

  const WebView({
    super.key,
    required this.title,
    required this.initialUrl,
    required this.onPressed,
  });

  @override
  State<WebView> createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context); // Menutup WebView
            widget.onPressed(); // Aksi setelah menutup
          },
        ),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
