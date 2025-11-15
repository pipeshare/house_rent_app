
// Extracted Category Option
import 'package:flutter/material.dart';
import 'package:house_rent_app/screens/post/components/post_option.dart';

class CategoryOption extends StatelessWidget {
  final PostOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryOption({super.key,
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primary.withOpacity(0.65) : Colors.black12,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: isSelected ? 10 : 6,
              offset: const Offset(0, 3),
              color: Colors.black.withOpacity(isSelected ? 0.08 : 0.05),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? primary.withOpacity(0.10)
                      : Colors.black.withOpacity(0.04),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  option.icon,
                  size: 36,
                  color: isSelected ? primary : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                option.label,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.9),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
