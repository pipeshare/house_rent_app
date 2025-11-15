
// Extracted Location & Price Step
import 'package:flutter/material.dart';
import 'package:house_rent_app/screens/post/components/form_step.dart';

import 'hint.dart';

class LocationPriceStep extends StatelessWidget {
  final TextEditingController locationCtrl;
  final TextEditingController priceCtrl;

  const LocationPriceStep({super.key,
    required this.locationCtrl,
    required this.priceCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return FormStep(
      title: 'Location & price',
      children: [
        TextField(
          controller: locationCtrl,
          decoration: const InputDecoration(
            labelText: 'Location',
            hintText: 'e.g., Salama Park, Lusaka',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: priceCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Price',
            hintText: 'e.g., 9,500',
            border: OutlineInputBorder(),
            prefixText: 'ZMW ',
          ),
        ),
        const SizedBox(height: 12),
        const Hint(text: 'Tip: Add a fair price to increase visibility.'),
      ],
    );
  }
}
