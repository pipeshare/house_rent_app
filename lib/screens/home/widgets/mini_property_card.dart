import 'package:flutter/material.dart';
import 'package:house_rent_app/core/routes/routes.dart';

class MiniPropertyCard extends StatelessWidget {
  final Map<String, dynamic> property;
  final VoidCallback onClose;

  const MiniPropertyCard({
    super.key,
    required this.property,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrls =
        (property['photos'] as List<dynamic>? ?? []).cast<String>();
    final firstImage = imageUrls.isNotEmpty ? imageUrls[0] : null;

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          RouteNames.propertyDetails,
          arguments: property,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.15),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Property Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 70,
                width: 80,
                color: Colors.grey[200],
                child: firstImage != null
                    ? Image.network(
                        firstImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.home, color: Colors.grey),
                          );
                        },
                      )
                    : const Icon(Icons.home, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 12),

            // Property Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property['title'] ?? 'No Title',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    property['location'] ?? 'No Location',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${property['currency'] ?? 'K'}${property['price'] ?? 'N/A'}",
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            // Close Button
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close, size: 20),
              splashRadius: 20,
            ),
          ],
        ),
      ),
    );
  }
}
