import 'package:flutter/material.dart';
import 'package:house_rent_app/core/constants.dart';

class FilterPill extends StatelessWidget {
  const FilterPill(
      {super.key,
      required this.label,
      required this.selected,
      required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color border = selected ? kPrimaryColor : kDividerColor;
    final Color bg = selected ? kPrimaryColor.withOpacity(0.10) : kWhite;
    final Color text = selected ? kPrimaryColor : kTitleColor;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Text(label,
            style: TextStyle(color: text, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
