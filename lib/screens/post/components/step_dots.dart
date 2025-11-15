import 'package:flutter/material.dart';

class StepDots extends StatelessWidget {
  final int current, total;
  final Color color;

  const StepDots({super.key,
    required this.current,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        total,
            (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          height: 8,
          width: i == current ? 22 : 8,
          decoration: BoxDecoration(
            color: i == current ? color : Colors.black12,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
      ),
    );
  }
}
