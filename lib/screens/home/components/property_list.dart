import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:house_rent_app/screens/home/widgets/loading_states.dart';
import '../widgets/property_card.dart';

class PropertyList extends StatelessWidget {
  final Stream<QuerySnapshot>? propertiesStream;
  final String selectedCategory;

  const PropertyList({
    super.key,
    required this.propertiesStream,
    required this.selectedCategory,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: propertiesStream,
      builder: (context, snapshot) {
        // Handle loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SliverToBoxAdapter(
            child: LoadingStates.loadingList(),
          );
        }

        // Handle error state
        if (snapshot.hasError) {
          return SliverToBoxAdapter(
            child: LoadingStates.errorState(
              error: snapshot.error.toString(),
              onRetry: () {},
            ),
          );
        }

        // Handle empty state
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return SliverToBoxAdapter(
            child: LoadingStates.emptyState(
              icon: Icons.home_work_outlined,
              title: 'No properties found',
              message: selectedCategory == 'All'
                  ? 'Check back later for new listings'
                  : 'No properties in $selectedCategory category',
            ),
          );
        }

        final properties = snapshot.data!.docs;

        // Sort properties by date if needed
        final sortedProperties = _sortProperties(properties);

        // Return list of properties
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final property =
                  sortedProperties[index].data() as Map<String, dynamic>;
              return PropertyCard(
                property: property,
                onTap: () {
                  Navigator.of(context).pushNamed(
                    '/property-details',
                    arguments: property,
                  );
                },
              );
            },
            childCount: sortedProperties.length,
          ),
        );
      },
    );
  }

  List<QueryDocumentSnapshot> _sortProperties(
      List<QueryDocumentSnapshot> properties) {
    if (selectedCategory == 'All') {
      // Properties already sorted by createdAt in query
      return properties;
    }

    // Manual sorting for filtered categories
    return List.from(properties)
      ..sort((a, b) {
        final aData = a.data() as Map<String, dynamic>;
        final bData = b.data() as Map<String, dynamic>;
        final aDate = aData['createdAt'] as Timestamp?;
        final bDate = bData['createdAt'] as Timestamp?;

        if (aDate == null || bDate == null) return 0;
        return bDate.compareTo(aDate); // Descending order
      });
  }
}
