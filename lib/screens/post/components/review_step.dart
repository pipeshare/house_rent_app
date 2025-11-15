// Extracted Review Step
import 'package:flutter/material.dart';
import 'package:house_rent_app/screens/post/components/review_item.dart';
import 'package:house_rent_app/screens/post/components/step_title.dart';

import 'hint.dart';

class ReviewStep extends StatelessWidget {
  final String category;
  final String title;
  final String description;
  final String location;
  final String price;
  final int photosCount;

  const ReviewStep({
    super.key,
    required this.category,
    required this.title,
    required this.description,
    required this.location,
    required this.price,
    required this.photosCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StepTitle(title: 'Review & post', theme: theme),
          const SizedBox(height: 16),
          ReviewItem(label: 'Category', value: category),
          ReviewItem(label: 'Title', value: title),
          ReviewItem(label: 'Location', value: location),
          ReviewItem(label: 'Price', value: 'ZMW $price'),
          const SizedBox(height: 8),
          ReviewItem(
            label: 'Description',
            value: description,
            isMultiline: true,
          ),
          const SizedBox(height: 12),
          ReviewItem(label: 'Photos', value: '$photosCount selected'),
          const SizedBox(height: 12),
          const Hint(
              text: 'If everything looks good, tap the check button to post.'),
        ],
      ),
    );
  }
}
