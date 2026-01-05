import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:house_rent_app/models/Professional.dart';
import 'package:house_rent_app/screens/home/components/professionals_section.dart';
import 'package:house_rent_app/screens/home/components/property_list.dart';

class DraggableSheet extends StatefulWidget {
  final DraggableScrollableController sheetController;
  final bool isMapMode;
  final bool showSearchBar;
  final VoidCallback onToggleSheet;
  final List<Professional> professionals;
  final String selectedCategory;
  final Stream<QuerySnapshot>? currentPropertiesStream;

  const DraggableSheet({
    super.key,
    required this.sheetController,
    required this.isMapMode,
    required this.showSearchBar,
    required this.onToggleSheet,
    required this.professionals,
    required this.selectedCategory,
    required this.currentPropertiesStream,
  });

  @override
  State<DraggableSheet> createState() => _DraggableSheetState();
}

class _DraggableSheetState extends State<DraggableSheet> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!widget.showSearchBar) {
        if (mounted) {
          setState(() {});
        }
      }
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (widget.showSearchBar) {
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: widget.sheetController,
      initialChildSize: 1,
      minChildSize: 0.04,
      maxChildSize: 1,
      snap: true,
      builder: (context, scrollController) {
        return NotificationListener<DraggableScrollableNotification>(
          onNotification: _handleSheetNotification,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
            ),
            child: Column(
              children: [
                // Grab Handle
                _buildGrabHandle(),

                // Content
                Expanded(
                  child: CustomScrollView(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // Find Professionals Section
                      SliverToBoxAdapter(
                        child: ProfessionalsSection(
                          professionals: widget.professionals,
                        ),
                      ),

                      // Featured Properties Header
                      SliverToBoxAdapter(
                        child: _buildFeaturedHeader(),
                      ),

                      // Properties List
                      PropertyList(
                        propertiesStream: widget.currentPropertiesStream,
                        selectedCategory: widget.selectedCategory,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGrabHandle() {
    return GestureDetector(
      onTap: widget.onToggleSheet,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40,
        height: 5,
        margin: const EdgeInsets.only(top: 12, bottom: 8),
        decoration: BoxDecoration(
          color: Colors.grey[400],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildFeaturedHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Text(
            'Featured Properties',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const Spacer(),
          Text(
            'Explore more',
            style: TextStyle(
              color: Colors.blue[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  bool _handleSheetNotification(DraggableScrollableNotification notification) {
    final isMapMode = notification.extent < 0.5;
    if (widget.isMapMode != isMapMode) {
      if (mounted) {
        setState(() {});
      }
    }
    return true;
  }
}
