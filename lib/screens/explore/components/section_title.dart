import 'package:flutter/material.dart';
import 'package:house_rent_app/constants/constants.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onTapAction;
  const SectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.onTapAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kHorizontalPadding),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: kTitleStyle),
                if (subtitle != null) SizedBox(height: 4),
                if (subtitle != null) Text(subtitle!, style: kCaptionStyle),
              ],
            ),
          ),
          if (onTapAction != null)
            IconButton(
              icon: const Icon(Icons.tune, size: 20),
              onPressed: onTapAction,
              tooltip: 'Filters',
            ),
        ],
      ),
    );
  }
}
