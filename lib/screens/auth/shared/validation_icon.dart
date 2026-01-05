import 'package:flutter/material.dart';

class ValidationIcon extends StatelessWidget {
  final bool isValid;

  const ValidationIcon({
    super.key,
    required this.isValid,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: isValid
          ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
          : const SizedBox(width: 20),
    );
  }
}
