import 'package:flutter/material.dart';
import 'package:house_rent_app/core/constants.dart';

class StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isSmall;

  const StatChip({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = isSmall ? 14.0 : 16.0;
    final fontSize = isSmall ? 10.0 : 12.0;
    final padding = isSmall
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 6);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: kPrimaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: kPrimaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: kPrimaryColor,
          ),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: kTitleColor,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: fontSize - 1,
                  color: kBodyTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
