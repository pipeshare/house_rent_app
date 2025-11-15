import 'package:flutter/material.dart';

class Hint extends StatelessWidget {
  final String text;

  const Hint({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.info_outline_rounded, size: 18),
        const SizedBox(width: 6),
        Expanded(child: Text(text)),
      ],
    );
  }
}
