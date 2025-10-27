import 'package:flutter/material.dart';
import 'package:house_rent_app/screens/post/post_screen.dart';

class ListingsScreen extends StatelessWidget {
  const ListingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const items = <_Listing>[
      _Listing(
        id: '1',
        title: '2-bed Apartment • Salama Park',
        location: 'Lusaka, Salama Park',
        image:
            'https://images.unsplash.com/photo-1505692794403-34d4982d1e9d?w=1200',
        price: 'ZMW 9,500/mo',
        active: true,
      ),
      _Listing(
        id: '2',
        title: 'Family House • Ibex Hill',
        location: 'Lusaka, Ibex Hill',
        image:
            'https://images.unsplash.com/photo-1499914485622-a88fac536970?w=1200',
        price: 'ZMW 2,400,000',
        active: true,
      ),
      _Listing(
        id: '3',
        title: 'Office Space • Cairo Rd',
        location: 'Lusaka CBD',
        image:
            'https://images.unsplash.com/photo-1479839672679-a46483c0e7c8?w=1200',
        price: 'ZMW 25,000/mo',
        active: false,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your listings'),
        actions: [
          IconButton(
            tooltip: 'Add listing',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PostScreen()),
              );
            },
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PostScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add listing'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) => _ListingCard(item: items[i]),
      ),
    );
  }
}

class _Listing {
  final String id;
  final String title;
  final String location;
  final String image;
  final String price;
  final bool active;
  const _Listing({
    required this.id,
    required this.title,
    required this.location,
    required this.image,
    required this.price,
    required this.active,
  });
}

class _ListingCard extends StatelessWidget {
  const _ListingCard({required this.item});
  final _Listing item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // TODO: push to details screen if available
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Open details for ${item.title}')),
          );
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            SizedBox(
              width: 120,
              height: 120,
              child: Ink.image(
                image: NetworkImage(item.image),
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.place_outlined,
                            size: 14, color: scheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            item.location,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Chip(
                          label: Text(item.active ? 'Active' : 'Inactive'),
                          visualDensity: VisualDensity.compact,
                          side: BorderSide(
                              color: item.active
                                  ? scheme.primary
                                  : scheme.outline),
                          labelStyle: TextStyle(
                            color: item.active
                                ? scheme.primary
                                : scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                          backgroundColor: item.active
                              ? scheme.primaryContainer.withOpacity(0.25)
                              : scheme.surfaceContainerHigh,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item.price,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const PostScreen()),
                        );
                      },
                      icon: const Icon(Icons.post_add_outlined),
                      label: const Text('Add another'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}
