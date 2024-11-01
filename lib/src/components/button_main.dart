import 'package:flutter/material.dart';

class ButtonMain extends StatelessWidget {
  final String title;
  final String icon;
  final String from;
  final VoidCallback? onPressed;

  const ButtonMain({
    super.key,
    required this.title,
    required this.icon,
    required this.from,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(13.0),
          decoration: BoxDecoration(
            color: const Color(0xFFE0E0E0),
            borderRadius: BorderRadius.circular(10),
          ),
          child: from == 'asset' ? Image.asset(icon) : Image.network(icon),
        ),
        const SizedBox(height: 8.0),
        Text(title, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
