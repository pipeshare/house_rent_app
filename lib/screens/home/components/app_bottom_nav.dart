import 'package:flutter/material.dart';
import 'package:house_rent_app/screens/main.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return SafeArea(
      top: false,
      child: Material(
        color: Colors.white,
        elevation: 8,
        child: SizedBox(
          height: 64, // a touch taller avoids vertical overflow on large text
          child: Row(
            children: List.generate(items.length, (i) {
              final it = items[i];
              final active = i == currentIndex;
              final color = active ? primary : Colors.black54;

              return Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(it.icon, color: color, size: 24),
                      const SizedBox(height: 2),
                      // FittedBox prevents label overflow on narrow screens / large text scale
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          it.label,
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight:
                                active ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
