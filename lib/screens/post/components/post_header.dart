// Extracted Post Header
import 'package:flutter/material.dart';
import 'package:house_rent_app/screens/post/components/step_dots.dart';

class PostHeader extends StatelessWidget {
  final int currentStep;
  final VoidCallback onBack;
  final Color primaryColor;

  const PostHeader({
    required this.currentStep,
    required this.onBack,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: currentStep == 0 ? null : onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: StepDots(
              current: currentStep,
              total: 5,
              color: primaryColor,
            ),
          ),
          const SizedBox(width: 48), // Balance FAB space
        ],
      ),
    );
  }
}