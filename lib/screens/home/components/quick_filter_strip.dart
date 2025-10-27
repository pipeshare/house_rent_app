import 'package:flutter/material.dart';

class QuickFiltersStrip extends StatelessWidget {
  const QuickFiltersStrip({
    super.key,
    required this.items,
    this.onTap,
  });

  final List<FilterItem> items;
  final void Function(int index)? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(right: 4),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final m = items[i];
          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap == null ? null : () => onTap!(i),
            child: Container(
              constraints: const BoxConstraints(minWidth: 120, maxHeight: 100),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x0F000000),
                      blurRadius: 10,
                      offset: Offset(0, 6)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(m.label,
                      style: const TextStyle(fontWeight: FontWeight.w300)),
                  const SizedBox(width: 8),
                  Text(m.value, style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class FilterItem {
  final String label;
  final String value;
  const FilterItem(this.label, this.value);
}

class CategoryItem {
  final String label;
  final IconData icon;
  const CategoryItem(this.label, this.icon);
}
