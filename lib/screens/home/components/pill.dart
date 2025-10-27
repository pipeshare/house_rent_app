import 'package:flutter/material.dart';
import 'package:house_rent_app/core/constants.dart';

class Pill extends StatelessWidget {
  const Pill({super.key, required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: kInputFieldColor,
        border: Border.all(color: kDividerColor),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(text,
          style: const TextStyle(
              color: kTitleColor, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}
