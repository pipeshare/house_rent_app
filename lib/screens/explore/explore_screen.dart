import 'dart:async';
import 'package:flutter/material.dart';
import 'package:house_rent_app/constants/constants.dart';
import 'package:house_rent_app/models/Professional.dart';
import 'package:house_rent_app/models/Property.dart';
import 'package:house_rent_app/screens/explore/components/professional_grid_card.dart';
import 'package:house_rent_app/screens/explore/components/property_grid_card.dart';

enum ExploreTab { properties, professionals }

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with AutomaticKeepAliveClientMixin<ExploreScreen> {
  ExploreTab activeTab = ExploreTab.properties;
  List<Property> properties = [];
  List<Professional> professionals = [];

  // Paging
  bool isLoadingMore = false;
  bool hasMore = true;

  // Search & filters
  String searchQuery = '';
  Set<String> activeFilterPills = {};
  Map<ProfessionalSpecialty, bool> professionalFilterSelection = {};

  // Scroll controller with proper disposal
  final ScrollController _scrollController = ScrollController();

  // Cache for filtered results
  int _propertiesCacheKey = 0;
  late List<Property> _cachedFilteredProperties = [];
  int _professionalsCacheKey = 0;
  late List<Professional> _cachedFilteredProfessionals = [];

  @override
  void initState() {
    super.initState();
    _seedInitial();
    // Initialize professional filter map efficiently
    professionalFilterSelection = {
      for (var s in ProfessionalSpecialty.values) s: false
    };

    // Add scroll listener instead of NotificationListener for better control
    _scrollController.addListener(_onScroll);
  }

  void _seedInitial() {
    properties = Property.generate(12);
    professionals = Professional.generate(10);
  }

  Future<void> _refresh() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    setState(() {
      properties = Property.generate(12);
      professionals = Professional.generate(10);
      hasMore = true;
      // Clear cache on refresh
      _propertiesCacheKey = 0;
      _professionalsCacheKey = 0;
    });
  }

  Future<void> _loadMore() async {
    if (isLoadingMore || !hasMore || !mounted) return;

    setState(() => isLoadingMore = true);

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    setState(() {
      if (activeTab == ExploreTab.properties) {
        final next = Property.generate(8);
        properties.addAll(next);
        if (properties.length > 60) hasMore = false;
        // Invalidate cache
        _propertiesCacheKey = 0;
      } else {
        final next = Professional.generate(6);
        professionals.addAll(next);
        if (professionals.length > 60) hasMore = false;
        // Invalidate cache
        _professionalsCacheKey = 0;
      }
      isLoadingMore = false;
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 350) {
      _loadMore();
    }
  }

  void _onSearchChanged(String q) {
    setState(() {
      searchQuery = q;
      // Invalidate cache on search change
      _propertiesCacheKey = 0;
      _professionalsCacheKey = 0;
    });
  }

  // Memoized filtered properties with caching
  List<Property> get _filteredProperties {
    final cacheKey = Object.hash(
      properties.length,
      searchQuery,
      Object.hashAll(activeFilterPills),
    );

    if (_propertiesCacheKey == cacheKey) {
      return _cachedFilteredProperties;
    }

    final filtered = properties.where((p) {
      final q = searchQuery.toLowerCase();
      if (q.isNotEmpty &&
          !(p.title.toLowerCase().contains(q) ||
              p.address.toLowerCase().contains(q))) {
        return false;
      }
      if (activeFilterPills.contains('Featured') && !p.featured) return false;
      if (activeFilterPills.contains('Available') && !p.available) return false;
      return true;
    }).toList();

    _propertiesCacheKey = cacheKey;
    _cachedFilteredProperties = filtered;
    return filtered;
  }

  // Memoized filtered professionals with caching
  List<Professional> get _filteredProfessionals {
    final cacheKey = Object.hash(
      professionals.length,
      searchQuery,
      Object.hashAll(professionalFilterSelection.entries
          .where((e) => e.value)
          .map((e) => e.key)),
    );

    if (_professionalsCacheKey == cacheKey) {
      return _cachedFilteredProfessionals;
    }

    final filtered = professionals.where((pr) {
      final q = searchQuery.toLowerCase();
      if (q.isNotEmpty &&
          !(pr.name.toLowerCase().contains(q) ||
              pr.company.toLowerCase().contains(q))) {
        return false;
      }
      final activeSpecs = professionalFilterSelection.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toSet();
      if (activeSpecs.isNotEmpty && !activeSpecs.contains(pr.specialty)) {
        return false;
      }
      return true;
    }).toList();

    _professionalsCacheKey = cacheKey;
    _cachedFilteredProfessionals = filtered;
    return filtered;
  }

  void _onCardTap(String id, {required bool isProperty}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text(isProperty ? 'Open Property $id' : 'Open Professional $id')),
    );
  }

  void _openProfessionalFilterModal() async {
    final result = await showModalBottomSheet<Map<ProfessionalSpecialty, bool>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _FilterBottomSheet(
        initialSelection: professionalFilterSelection,
      ),
    );

    if (result != null && mounted) {
      setState(() {
        professionalFilterSelection = result;
        // Invalidate cache on filter change
        _professionalsCacheKey = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Top tabs
            const SliverToBoxAdapter(
              child: _TabSection(),
            ),

            // Grid content based on active tab
            _buildContentGrid(),

            // Loading indicator or end marker
            _buildLoadingIndicator(),

            // Bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }

  // Extracted AppBar widget
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Row(
          children: [
            const SizedBox(width: 4),
            Expanded(
              child: _SearchBar(
                searchQuery: searchQuery,
                onSearchChanged: _onSearchChanged,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.tune),
              onPressed: _openProfessionalFilterModal,
              tooltip: 'Open filter modal',
            ),
          ],
        ),
      ),
    );
  }

  // Extracted content grid
  Widget _buildContentGrid() {
    if (activeTab == ExploreTab.properties) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: kHorizontalPadding),
        sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final items = _filteredProperties;
              if (index >= items.length) return null;
              final p = items[index];
              return PropertyGridCard(
                property: p,
                onTap: () => _onCardTap(p.id, isProperty: true),
              );
            },
            childCount: _filteredProperties.length,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: kSpacing,
            mainAxisSpacing: kSpacing,
            childAspectRatio: 0.75,
          ),
        ),
      );
    } else {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: kHorizontalPadding),
        sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final items = _filteredProfessionals;
              if (index >= items.length) return null;
              final pr = items[index];
              return ProfessionalGridCard(
                pro: pr,
                onTap: () => _onCardTap(pr.id, isProperty: false),
              );
            },
            childCount: _filteredProfessionals.length,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: kSpacing,
            mainAxisSpacing: kSpacing,
            childAspectRatio: 0.7,
          ),
        ),
      );
    }
  }

  // Extracted loading indicator
  Widget _buildLoadingIndicator() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: isLoadingMore
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : (!hasMore
                  ? const Text('No more results', style: kCaptionStyle)
                  : const SizedBox.shrink()),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Critical: prevent memory leaks
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}

// Extracted Tab Section as const widget
class _TabSection extends StatelessWidget {
  const _TabSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: kHorizontalPadding, vertical: 12),
      child: Row(
        children: [
          _TabButton(label: 'Properties', tab: ExploreTab.properties),
          const SizedBox(width: 8),
          _TabButton(label: 'Professionals', tab: ExploreTab.professionals),
        ],
      ),
    );
  }
}

// Extracted Tab Button with state management
class _TabButton extends StatelessWidget {
  final String label;
  final ExploreTab tab;

  const _TabButton({required this.label, required this.tab});

  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_ExploreScreenState>();
    final selected = state?.activeTab == tab;

    return Expanded(
      child: GestureDetector(
        onTap: () => state?.setState(() => state.activeTab = tab),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? kPrimaryColor.withOpacity(.12) : Colors.white,
            border: Border.all(
                color: selected ? kPrimaryColor : Colors.grey.shade200),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                color: selected ? kPrimaryColor : kBodyTextColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Extracted Search Bar as const widget
class _SearchBar extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChanged;

  const _SearchBar({
    required this.searchQuery,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.search,
            size: 20,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Search properties or professionals',
                hintStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          if (searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () => onSearchChanged(''),
              child: const Icon(Icons.close, size: 18),
            ),
        ],
      ),
    );
  }
}

// Extracted Filter Bottom Sheet
class _FilterBottomSheet extends StatefulWidget {
  final Map<ProfessionalSpecialty, bool> initialSelection;

  const _FilterBottomSheet({required this.initialSelection});

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late Map<ProfessionalSpecialty, bool> tempSelection;

  @override
  void initState() {
    super.initState();
    tempSelection =
        Map<ProfessionalSpecialty, bool>.from(widget.initialSelection);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding:
              MediaQuery.of(context).viewInsets.add(const EdgeInsets.all(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(height: 6, width: 40, color: Colors.grey.shade200),
              const SizedBox(height: 12),
              const Text('Filter Professionals', style: kTitleStyle),
              const SizedBox(height: 8),
              const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Specialties', style: kCaptionStyle)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ProfessionalSpecialty.values.map((s) {
                  final label = s.name[0].toUpperCase() + s.name.substring(1);
                  return FilterChip(
                    label: Text(label),
                    selected: tempSelection[s] ?? false,
                    onSelected: (v) {
                      setState(() {
                        tempSelection[s] = v;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(null),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(tempSelection),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }
}
