import 'package:flutter/material.dart';

class ButtonIcon extends StatelessWidget {
  final String title;
  final String icon;
  final String from;
  final double? width;
  final VoidCallback? onPressed;

  const ButtonIcon({
    super.key,
    required this.title,
    required this.icon,
    required this.from,
    this.width,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(13.0),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: from == 'asset'
                ? (width != null
                    ? Image.asset(
                        icon,
                        width: width,
                      )
                    : Image.asset(icon))
                : Image.network(icon),
          ),
          const SizedBox(height: 8.0),
          Text(
            title,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
