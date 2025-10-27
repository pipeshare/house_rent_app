// =======================
// Reusable UI helpers
// =======================
import 'package:flutter/material.dart';
import 'package:house_rent_app/core/constants.dart';

class SearchField extends StatelessWidget {
  const SearchField(
      {super.key,
      required this.controller,
      required this.hint,
      this.onSubmitted});
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: kHintTextColor),
        filled: true,
        fillColor: kInputFieldColor,
        prefixIcon: const Icon(Icons.search_rounded, color: kBodyTextColor),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear_rounded, color: kBodyTextColor),
          onPressed: () => controller.clear(),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: kDividerColor),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: kPrimaryColor, width: 1.2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
