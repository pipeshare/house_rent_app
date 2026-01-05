import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:house_rent_app/core/helpers.dart';

class PropertyCard extends StatefulWidget {
  final Map<String, dynamic> property;
  final VoidCallback onTap;

  const PropertyCard({
    super.key,
    required this.property,
    required this.onTap,
    required Null Function() onClose,
  });

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  final PageController _pageController = PageController();

  // Custom cache manager with longer expiry
  static final CustomCacheManager _cacheManager = CustomCacheManager();

  @override
  Widget build(BuildContext context) {
    final images = widget.property['images'] as List<dynamic>? ?? [];

    return Container(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        child: InkWell(
          onTap: widget.onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Property Images with PageView and Caching
              Stack(
                children: [
                  SizedBox(
                    height: 400,
                    width: double.infinity,
                    child: images.isNotEmpty
                        ? PageView.builder(
                            controller: _pageController,
                            itemCount: images.length,
                            onPageChanged: (int page) {
                              setState(() {});
                            },
                            itemBuilder: (context, index) {
                              return CachedNetworkImage(
                                imageUrl: images[index],
                                fit: BoxFit.cover,
                                cacheManager: _cacheManager,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[200],
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.grey[400]!,
                                      ),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        size: 48,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey[200],
                            child: Center(
                              child: Icon(
                                Icons.home_work_outlined,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                            ),
                          ),
                  ),
                ],
              ),

              // Property Details
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.property['category'] ?? 'Property',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'ZMW ${_formatPrice(widget.property['price'])}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.property['title'] ?? 'No Title',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.property['location'] ??
                                'Location not specified',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '0';
    if (price is int) return price.toString();
    if (price is double) return price.toStringAsFixed(0);
    return price.toString();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
