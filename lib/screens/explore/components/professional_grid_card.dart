import 'package:flutter/material.dart';
import 'package:house_rent_app/constants/constants.dart';
import 'package:house_rent_app/models/Property.dart';

class PropertyGridCard extends StatelessWidget {
  final Property property;
  final VoidCallback onTap;
  const PropertyGridCard({
    super.key,
    required this.property,
    required this.onTap,
  });

  Widget _buildBadge(String text, {Color? background}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background ?? Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(.15)),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image + Badges row
              AspectRatio(
                aspectRatio: 1.6,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        property.images[0],
                        fit: BoxFit.cover,
                        loadingBuilder: (c, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                              child: CircularProgressIndicator(strokeWidth: 2));
                        },
                        errorBuilder: (c, o, s) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(Icons.broken_image,
                                  size: 36, color: Colors.grey),
                            ),
                          );
                        },
                      ),
                      Positioned(
                        top: 8,
                        left: 8,
                        child: _buildBadge(
                            '\$${property.price.toStringAsFixed(0)}',
                            background: Colors.white),
                      ),
                      if (property.featured)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: _buildBadge('FEATURED',
                              background: kPrimaryColor.withOpacity(.95)),
                        ),
                      if (!property.available)
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: _buildBadge('UNAVAILABLE',
                              background: Colors.black.withOpacity(.6)),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(property.title,
                  style: kBodyStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(property.address,
                  style: kCaptionStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.bed, size: 14),
                  const SizedBox(width: 6),
                  Text('${property.beds}'),
                  const SizedBox(width: 12),
                  const Icon(Icons.bathtub, size: 14),
                  const SizedBox(width: 6),
                  Text('${property.baths}'),
                  const SizedBox(width: 12),
                  const Icon(Icons.square_foot, size: 14),
                  const SizedBox(width: 6),
                  Text('${property.area.toStringAsFixed(0)} m²'),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
