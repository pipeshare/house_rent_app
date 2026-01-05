import 'package:flutter/material.dart';
import '../utils/home_constants.dart';

class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;

  const SearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 0,
      ),
      child: Container(
        height: HomeConstants.searchBarHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 16),
            Icon(Icons.search, color: Colors.grey[500], size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search properties, locations, professionals...',
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                    height: 1.2,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                onChanged: onChanged,
                onSubmitted: (value) => onSubmitted?.call(),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
