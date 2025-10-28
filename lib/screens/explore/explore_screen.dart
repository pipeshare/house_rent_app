import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:house_rent_app/constants/constants.dart';
import 'package:house_rent_app/models/DataModels.dart';
import 'package:house_rent_app/models/Professional.dart';
import 'package:house_rent_app/models/Property.dart';
import 'package:house_rent_app/screens/explore/components/filter_pill.dart';
import 'package:house_rent_app/screens/explore/components/professional_grid_card.dart';

enum ExploreTab { properties, professionals }

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
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

  // Scroll controller isn't necessary for NotificationListener but keep reference for convenience
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _seedInitial();
    // initialize professional filter map
    for (var s in ProfessionalSpecialty.values) {
      professionalFilterSelection[s] = false;
    }
  }

  void _seedInitial() {
    properties = Property.generate(12);
    professionals = Professional.generate(10);
  }

  Future<void> _refresh() async {
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      // Reset lists - in real app you'd fetch fresh data
      properties = Property.generate(12);
      professionals = Professional.generate(10);
      hasMore = true;
    });
  }

  Future<void> _loadMore() async {
    if (isLoadingMore || !hasMore) return;
    setState(() => isLoadingMore = true);
    await Future.delayed(const Duration(milliseconds: 900));
    setState(() {
      if (activeTab == ExploreTab.properties) {
        final next = Property.generate(8);
        properties.addAll(next);
        if (properties.length > 60) hasMore = false;
      } else {
        final next = Professional.generate(6);
        professionals.addAll(next);
        if (professionals.length > 60) hasMore = false;
      }
      isLoadingMore = false;
    });
  }

  void _onScrollNotification(ScrollNotification notification) {
    if (notification.metrics.pixels >=
        notification.metrics.maxScrollExtent - 350) {
      _loadMore();
    }
  }

  void _onSearchChanged(String q) {
    setState(() => searchQuery = q);
    // placeholder: you'd normally trigger a filtered fetch; here we just update UI
  }

  void _toggleFilterPill(String label) {
    setState(() {
      if (activeFilterPills.contains(label))
        activeFilterPills.remove(label);
      else
        activeFilterPills.add(label);
    });
  }

  void _openProfessionalFilterModal() async {
    final result = await showModalBottomSheet<Map<ProfessionalSpecialty, bool>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final tempSelection =
            Map<ProfessionalSpecialty, bool>.from(professionalFilterSelection);
        return Padding(
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
                      onPressed: () {
                        Navigator.of(context).pop(null); // cancel -> no change
                      },
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(tempSelection);
                      },
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        professionalFilterSelection = result;
      });
    }
  }

  List<Property> get _filteredProperties {
    var list = properties.where((p) {
      final q = searchQuery.toLowerCase();
      if (q.isNotEmpty &&
          !(p.title.toLowerCase().contains(q) ||
              p.address.toLowerCase().contains(q))) {
        return false;
      }
      // Further pill-based filter logic (placeholder)
      if (activeFilterPills.contains('Featured') && !p.featured) return false;
      if (activeFilterPills.contains('Available') && !p.available) return false;
      return true;
    }).toList();
    return list;
  }

  List<Professional> get _filteredProfessionals {
    var list = professionals.where((pr) {
      final q = searchQuery.toLowerCase();
      if (q.isNotEmpty &&
          !(pr.name.toLowerCase().contains(q) ||
              pr.company.toLowerCase().contains(q))) {
        return false;
      }
      // specialty filters
      final activeSpecs = professionalFilterSelection.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toSet();
      if (activeSpecs.isNotEmpty && !activeSpecs.contains(pr.specialty)) {
        return false;
      }
      return true;
    }).toList();
    return list;
  }

  void _onCardTap(String id, {required bool isProperty}) {
    // Placeholder navigation handler
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content:
              Text(isProperty ? 'Open Property $id' : 'Open Professional $id')),
    );
    // Example actual navigation:
    // Navigator.of(context).push(MaterialPageRoute(builder: (_) => DetailsScreen(...)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 4),
            Expanded(
              child: _buildSearchBar(),
            ),
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _openProfessionalFilterModal,
              tooltip: 'Open filter modal',
            ),
          ],
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          _onScrollNotification(notification);
          return false;
        },
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Top tabs: properties / professionals
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: kHorizontalPadding, vertical: 12),
                  child: Row(
                    children: [
                      _buildTabButton('Properties', ExploreTab.properties),
                      const SizedBox(width: 8),
                      _buildTabButton(
                          'Professionals', ExploreTab.professionals),
                    ],
                  ),
                ),
              ),

              // Filter pills
              SliverToBoxAdapter(
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.only(left: kHorizontalPadding),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      FilterPill(
                        label: 'Featured',
                        selected: activeFilterPills.contains('Featured'),
                        onTap: () => _toggleFilterPill('Featured'),
                      ),
                      FilterPill(
                        label: 'Available',
                        selected: activeFilterPills.contains('Available'),
                        onTap: () => _toggleFilterPill('Available'),
                      ),
                      FilterPill(
                        label: '3+ beds',
                        selected: activeFilterPills.contains('3+ beds'),
                        onTap: () => _toggleFilterPill('3+ beds'),
                      ),
                      FilterPill(
                        label: 'Verified',
                        selected: activeFilterPills.contains('Verified'),
                        onTap: () => _toggleFilterPill('Verified'),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                ),
              ),

              // Section title
              const SliverToBoxAdapter(
                child: SizedBox(height: 8),
              ),

              // Grid
              if (activeTab == ExploreTab.properties)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: kHorizontalPadding),
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
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: kSpacing,
                      mainAxisSpacing: kSpacing,
                      childAspectRatio: 0.75, // requirement
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: kHorizontalPadding),
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
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: kSpacing,
                      mainAxisSpacing: kSpacing,
                      childAspectRatio: 0.7, // requirement
                    ),
                  ),
                ),

              // If loading more show a loader
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: isLoadingMore
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : (!hasMore
                            ? const Text('No more results',
                                style: kCaptionStyle)
                            : const SizedBox.shrink()),
                  ),
                ),
              ),
              // bottom padding
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String label, ExploreTab tab) {
    final selected = activeTab == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => activeTab = tab),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
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

  Widget _buildSearchBar() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Search properties or professionals',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          if (searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                setState(() => searchQuery = '');
              },
              child: const Icon(Icons.close, size: 18),
            ),
        ],
      ),
    );
  }
}

class ProfessionalGridCard extends StatelessWidget {
  final Professional pro;
  final VoidCallback onTap;
  const ProfessionalGridCard({
    super.key,
    required this.pro,
    required this.onTap,
  });

  Widget _badge(String label, {Color? bg}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg ?? Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(.12)),
      ),
      child: Text(label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      pro.imageUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (c, o, s) {
                        return Container(
                          width: 56,
                          height: 56,
                          color: Colors.grey.shade200,
                          child:
                              Icon(Icons.person, size: 30, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(pro.name,
                            style: kBodyStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        SizedBox(height: 4),
                        Text(
                            '${pro.specialty.name[0].toUpperCase()}${pro.specialty.name.substring(1)} • ${pro.company}',
                            style: kCaptionStyle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                        SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(Icons.star, size: 14),
                            SizedBox(width: 6),
                            Text(pro.rating.toStringAsFixed(1),
                                style: TextStyle(fontSize: 12)),
                            SizedBox(width: 12),
                            Icon(Icons.work_outline, size: 14),
                            SizedBox(width: 6),
                            Text('${pro.yearsExperience}y',
                                style: TextStyle(fontSize: 12)),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  _badge(pro.verified ? 'VERIFIED' : 'UNVERIFIED',
                      bg: pro.verified
                          ? kPrimaryColor.withOpacity(.10)
                          : Colors.white),
                  Spacer(),
                  IconButton(
                    onPressed: () {
                      // quick call handler placeholder
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Call ${pro.phone}')));
                    },
                    icon: Icon(Icons.call, size: 20),
                    tooltip: 'Call',
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
