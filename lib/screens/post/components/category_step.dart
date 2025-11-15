
// Extracted Category Step
import 'package:flutter/material.dart';
import 'package:house_rent_app/screens/post/components/post_option.dart';
import 'package:house_rent_app/screens/post/components/step_title.dart';

import 'category_option.dart';

class CategoryStep extends StatelessWidget {
  final List<PostOption> options;
  final int? selectedIndex;
  final ValueChanged<int> onSelect;

  const CategoryStep({super.key,
    required this.options,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: StepTitle(
            title: 'What are you posting?',
            theme: theme,
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
                  (context, index) => CategoryOption(
                option: options[index],
                isSelected: selectedIndex == index,
                onTap: () => onSelect(index),
              ),
              childCount: options.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.05,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 96)),
      ],
    );
  }
}
