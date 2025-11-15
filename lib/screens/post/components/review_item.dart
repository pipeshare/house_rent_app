// Extracted Review Item
import 'package:flutter/material.dart';

class ReviewItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isMultiline;

  const ReviewItem({super.key,
    required this.label,
    required this.value,
    this.isMultiline = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.bodySmall?.copyWith(color: Colors.grey[700]);
    final valueStyle = theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: isMultiline
          ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: labelStyle),
          const SizedBox(height: 4),
          Text(value.isEmpty ? '—' : value, style: valueStyle),
        ],
      )
          : Row(
        children: [
          SizedBox(width: 110, child: Text(label, style: labelStyle)),
          const SizedBox(width: 8),
          Expanded(child: Text(value.isEmpty ? '—' : value, style: valueStyle)),
        ],
      ),
    );
  }
}