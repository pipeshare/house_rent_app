// Common Components
import 'package:flutter/material.dart';

class StepTitle extends StatelessWidget {
  final String title;
  final ThemeData theme;

  const StepTitle({super.key, required this.title, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 15),
      child: Center(
        child: Text(
          title,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.15,
            fontSize: 30,
          ),
        ),
      ),
    );
  }
}