// =====================
// SAVED TAB (production)
// =====================
import 'package:flutter/material.dart';
import 'package:house_rent_app/core/constants.dart';
import 'package:house_rent_app/models/Property.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});
  @override
  State<SavedScreen> createState() => SavedScreenState();
}

class SavedScreenState extends State<SavedScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  final List<Property> _savedRent =
      List.generate(4, (i) => Property.mock(i, rent: true));
  final List<Property> _savedSale =
      List.generate(2, (i) => Property.mock(i + 10, rent: false));

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kWhite,
        surfaceTintColor: kWhite,
        title: const Text('Saved',
            style: TextStyle(color: kTitleColor, fontWeight: FontWeight.w700)),
        bottom: TabBar(
          controller: _tab,
          labelColor: kPrimaryColor,
          unselectedLabelColor: kBodyTextColor,
          indicatorColor: kPrimaryColor,
          tabs: const [
            Tab(text: 'For Rent'),
            Tab(text: 'For Sale'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _SavedGrid(
            items: _savedRent,
            empty: const _EmptyState(
              icon: Icons.bookmark_outline_rounded,
              title: 'No saved rentals yet',
              subtitle: 'Save homes to compare and get alerts.',
            ),
          ),
          _SavedGrid(
            items: _savedSale,
            empty: const _EmptyState(
              icon: Icons.bookmark_outline_rounded,
              title: 'No saved properties for sale',
              subtitle: 'Save listings to watch price changes.',
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedGrid extends StatelessWidget {
  const _SavedGrid({required this.items, required this.empty});
  final List<Property> items;
  final Widget empty;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return empty;
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.72,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => _SavedTile(property: items[i]),
    );
  }
}

class _SavedTile extends StatelessWidget {
  const _SavedTile({required this.property});
  final Property property;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kCardColor,
      elevation: 0,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 12,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(property.images.first, fit: BoxFit.cover),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Badge(
                        label: Text(property.rent ? 'For Rent' : 'For Sale')),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
              child: Text(
                property.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: kTitleColor, fontWeight: FontWeight.w700),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
              child: Text(
                property.location,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: kBodyTextColor, fontSize: 12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Text(
                property.rent
                    ? 'ZMW ${property.price.toStringAsFixed(0)}/mo'
                    : 'ZMW ${property.price.toStringAsFixed(0)}',
                style: const TextStyle(
                    color: kPrimaryColor, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 45, color: kPrimaryColor),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: kTitleColor,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: kBodyTextColor,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
