import 'package:flutter/material.dart';
import 'package:house_rent_app/core/constants.dart';

class FilterPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const FilterPill({
    Key? key,
    required this.label,
    required this.selected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        margin: EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: selected ? kPrimaryColor.withOpacity(.12) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? kPrimaryColor : Colors.grey.shade300,
            width: selected ? 1.25 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? kPrimaryColor : kBodyTextColor,
                )),
            if (selected) ...[
              SizedBox(width: 6),
              Icon(Icons.check_circle, size: 16, color: kPrimaryColor),
            ],
          ],
        ),
      ),
    );
  }
}
