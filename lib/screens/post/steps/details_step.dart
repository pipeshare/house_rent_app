// Extracted Details Step
import 'package:flutter/material.dart';

import 'form_step.dart';

class DetailsStep extends StatelessWidget {
  final TextEditingController titleCtrl;
  final TextEditingController descCtrl;

  const DetailsStep({
    super.key,
    required this.titleCtrl,
    required this.descCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return FormStep(
      title: 'Basic details',
      subtitle: 'Provide a title and description for your listing',
      children: [
        TextField(
          controller: titleCtrl,
          decoration: const InputDecoration(
            labelText: 'Listing title',
            hintText: 'e.g., 2-Bedroom Apartment in Salama Park',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: descCtrl,
          maxLines: 6,
          decoration: const InputDecoration(
            labelText: 'Description',
            hintText: 'Describe the property, amenities, nearby places…',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
