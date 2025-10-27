import 'package:flutter/material.dart';
import 'package:house_rent_app/screens/home/components/quick_filter_strip.dart';

class PropertyCategoriesStrip extends StatelessWidget {
  const PropertyCategoriesStrip({
    super.key,
    required this.items,
    this.selectedIndex,
    this.onSelect,
  });

  final List<CategoryItem> items;
  final int? selectedIndex;
  final ValueChanged<int>? onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return SizedBox(
      height: 35,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(right: 3),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 5),
        itemBuilder: (context, i) {
          final it = items[i];
          final selected = selectedIndex == i;
          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onSelect == null ? null : () => onSelect!(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? primary.withOpacity(0.65) : Colors.black12,
                  width: selected ? 2 : 1,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    it.icon,
                    size: 20,
                    color: selected ? primary : Colors.grey[700],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    it.label,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: selected ? primary : const Color(0xFF111827),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
