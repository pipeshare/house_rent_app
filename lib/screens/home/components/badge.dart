import 'package:flutter/material.dart';
import 'package:house_rent_app/core/constants.dart';

class Badge extends StatelessWidget {
  const Badge({super.key, required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: kBlack.withOpacity(0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: const TextStyle(
              color: kWhite, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}
