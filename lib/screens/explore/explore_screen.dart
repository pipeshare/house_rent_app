// =======================
// EXPLORE TAB (production)
// =======================
import 'package:flutter/material.dart';
import 'package:house_rent_app/core/constants.dart';
import 'package:house_rent_app/models/Property.dart';
import 'package:house_rent_app/screens/explore/components/filer_pill.dart';
import 'package:house_rent_app/screens/explore/search_field.dart';
import 'package:house_rent_app/screens/home/property_card.dart';
import 'package:house_rent_app/screens/profile/section_tiltle.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final List<String> _filters = const [
    'Near me',
    '2+ Beds',
    'Furnished',
    'Pet friendly',
    'Parking',
    'New'
  ];
  final Set<String> _active = {'Near me', '2+ Beds'};
  final List<Property> _properties = List.generate(8, (i) => Property.mock(i));
  bool _loadingMore = false;

  Future<void> _refresh() async {
    await Future.delayed(const Duration(milliseconds: 700));
    setState(() {
      _properties
        ..clear()
        ..addAll(List.generate(8, (i) => Property.mock(i)));
    });
  }

  Future<void> _loadMore() async {
    if (_loadingMore) return;
    setState(() => _loadingMore = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _properties.addAll(
          List.generate(6, (i) => Property.mock(_properties.length + i)));
      _loadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: kWhite,
        backgroundColor: kWhite,
        title: const Text('Explore',
            style: TextStyle(color: kTitleColor, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
              onPressed: () {},
              icon: const Icon(Icons.tune_rounded, color: kTitleColor)),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: kPrimaryColor,
          onRefresh: _refresh,
          child: NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200 &&
                  !_loadingMore) {
                _loadMore();
              }
              return false;
            },
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                // Search
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: SearchField(
                      controller: _searchCtrl,
                      hint: 'Search city, area, landmark…',
                      onSubmitted: (q) {}, // hook into your search flow
                    ),
                  ),
                ),

                // Filter pills
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 44,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: _filters.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (_, i) {
                        final label = _filters[i];
                        final selected = _active.contains(label);
                        return FilterPill(
                          label: label,
                          selected: selected,
                          onTap: () => setState(() {
                            selected
                                ? _active.remove(label)
                                : _active.add(label);
                          }),
                        );
                      },
                    ),
                  ),
                ),

                // Section title
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: SectionTitle(title: 'Recommended for you'),
                  ),
                ),

                // Property list
                // SliverList.builder(
                //   itemCount: _properties.length,
                //   itemBuilder: (_, i) => Padding(
                //     padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                //     child: PropertyCard(property: _properties[i], onTap: () {  },),
                //   ),
                // ),

                // Load more indicator
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: _loadingMore
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const SizedBox.shrink(),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
