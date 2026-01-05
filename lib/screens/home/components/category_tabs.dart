import 'package:flutter/material.dart';
import 'package:house_rent_app/models/DataModels.dart';

class CategoryTabs extends StatelessWidget {
  final List<Category> categories;
  final int selectedIndex;
  final Function(int) onCategorySelected;
  final Map<int, Widget> categoryCache;

  const CategoryTabs({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onCategorySelected,
    required this.categoryCache,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: MediaQuery.of(context).size.height * 0.088,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return _buildCategoryItem(index);
        },
      ),
    );
  }

  Widget _buildCategoryItem(int index) {
    final category = categories[index];
    final isSelected = selectedIndex == index;
    final cacheKey = index * 10 + (isSelected ? 1 : 0);

    // Return cached widget if exists
    if (categoryCache.containsKey(cacheKey)) {
      return categoryCache[cacheKey]!;
    }

    // Build the widget if not cached
    final widget = Padding(
      padding: EdgeInsets.only(
        left: index == 0 ? 20 : 12,
        right: index == categories.length - 1 ? 20 : 12,
      ),
      child: GestureDetector(
        onTap: () => onCategorySelected(index),
        child: _buildCategoryTab(category, isSelected),
      ),
    );

    // Store it in cache
    categoryCache[cacheKey] = widget;
    return widget;
  }

  Widget _buildCategoryTab(Category category, bool isSelected) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 55,
          height: 48,
          child: Icon(
            category.icon,
            color: isSelected ? Colors.grey[600] : Colors.grey[600],
            size: 50,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            border: isSelected
                ? const Border(
                    bottom: BorderSide(
                      color: Colors.black,
                      width: 3.0,
                    ),
                  )
                : null,
          ),
          child: Text(
            category.name,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.grey[600],
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
