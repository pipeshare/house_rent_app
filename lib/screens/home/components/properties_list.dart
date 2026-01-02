// Create a separate stateful widget for the properties list
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:house_rent_app/screens/home/property_card.dart';

class PostsSection extends StatefulWidget {
  final Stream<QuerySnapshot>? postsStream;

  const PostsSection({
    super.key,
    required this.postsStream,
  });

  @override
  State<PostsSection> createState() => PostsSectionState();
}

class PostsSectionState extends State<PostsSection> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: widget.postsStream,
      builder: (context, snapshot) {
        // Your existing stream builder logic
        if (snapshot.hasError) {
          // Error handling
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return SliverToBoxAdapter(
            child: _buildEmptyState(),
          );
        }

        final properties = snapshot.data!.docs;

        // Manual sorting logic...

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final property = properties[index].data() as Map<String, dynamic>;
              return PropertyCard(
                property: property,
                onTap: () {
                  // Navigate to property details
                },
              );
            },
            childCount: properties.length,
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Text("");
  }
}
