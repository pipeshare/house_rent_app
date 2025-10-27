import 'package:flutter/material.dart';
import 'package:house_rent_app/core/constants.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: const TextStyle(
            color: kTitleColor, fontWeight: FontWeight.w800, fontSize: 16));
  }
}
