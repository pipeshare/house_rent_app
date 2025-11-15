// Extracted Floating Action Button
import 'package:flutter/material.dart';

class PostFAB extends StatelessWidget {
  final int currentStep;
  final bool isPosting;
  final VoidCallback onPressed;

  const PostFAB({super.key,
    required this.currentStep,
    required this.isPosting,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: isPosting ? null : onPressed,
      shape: const CircleBorder(),
      child: isPosting
          ? const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(Colors.white),
        ),
      )
          : Icon(
        currentStep == 4 ? Icons.check_rounded : Icons.arrow_forward_rounded,
        size: 24,
      ),
    );
  }
}
