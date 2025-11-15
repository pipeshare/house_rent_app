import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PropertyDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> property;

  const PropertyDetailsScreen({super.key, required this.property});

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  int _currentIndex = 0;
  late final List<String> _photos;
  late final String _title;
  late final double _price;
  late final String _location;
  late final String _description;

  @override
  void initState() {
    super.initState();
    // Cache property data to avoid repeated lookups
    _photos = (widget.property['photos'] as List<dynamic>?)?.cast<String>() ?? [];
    _title = widget.property['title']?.toString() ?? '';
    _price = (widget.property['price'] as num?)?.toDouble() ?? 0.0;
    _location = widget.property['location']?.toString() ?? '';
    _description = widget.property['description']?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Photo Gallery
          _buildPhotoGallery(),

          // Top Navigation Bar
          const _TopNavigationBar(),

          // Page Indicator
          if (_photos.length > 1) _buildPageIndicator(),

          // Bottom Content Sheet
          _buildContentSheet(),

          // Bottom Action Bar
          const _BottomActionBar(),
        ],
      ),
    );
  }

  Widget _buildPhotoGallery() {
    if (_photos.isEmpty) {
      return const _PlaceholderImage();
    }

    return PageView.builder(
      itemCount: _photos.length,
      onPageChanged: (index) => setState(() => _currentIndex = index),
      itemBuilder: (context, index) {
        return _PhotoItem(
          photoUrl: _photos[index],
          onVerticalDragEnd: (details) {
            if (details.primaryVelocity! > 300) Navigator.pop(context);
          },
          heroTag: widget.property,
        );
      },
    );
  }

  Widget _buildPageIndicator() {
    return Positioned(
      bottom: 380,
      left: 0,
      right: 0,
      child: _PageIndicator(
        currentIndex: _currentIndex,
        totalItems: _photos.length,
      ),
    );
  }

  Widget _buildContentSheet() {
    return DraggableScrollableSheet(
      initialChildSize: .40,
      minChildSize: .40,
      maxChildSize: .85,
      builder: (context, scrollController) {
        return _PropertyContent(
          title: _title,
          price: _price,
          location: _location,
          description: _description,
          scrollController: scrollController,
        );
      },
    );
  }
}

// Extracted Photo Item with optimized image loading
class _PhotoItem extends StatelessWidget {
  final String photoUrl;
  final GestureDragEndCallback onVerticalDragEnd;
  final Object heroTag;

  const _PhotoItem({
    required this.photoUrl,
    required this.onVerticalDragEnd,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: onVerticalDragEnd,
      child: Hero(
        tag: heroTag,
        child: Container(
          color: Colors.black,
          child: _buildImageContent(),
        ),
      ),
    );
  }

  Widget _buildImageContent() {
    if (photoUrl.endsWith(".mp4")) {
      return const _VideoPlaceholder();
    }

    return CachedNetworkImage(
      imageUrl: photoUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, url) => const _ImageLoadingPlaceholder(),
      errorWidget: (context, url, error) => const _ImageErrorPlaceholder(),
      fadeInDuration: const Duration(milliseconds: 300),
      fadeOutDuration: const Duration(milliseconds: 300),
    );
  }
}

// Extracted Top Navigation Bar
class _TopNavigationBar extends StatelessWidget {
  const _TopNavigationBar();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _CircleButton(
              icon: Icons.arrow_back,
              onTap: () => Navigator.pop(context),
            ),
            const Row(
              children: [
                _CircleButton(icon: Icons.share, onTap: _handleShare),
                SizedBox(width: 10),
                _CircleButton(icon: Icons.favorite_border, onTap: _handleFavorite),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static void _handleShare() {
    // Implement share functionality
  }

  static void _handleFavorite() {
    // Implement favorite functionality
  }
}

// Extracted Circle Button
class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(.3),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

// Extracted Page Indicator
class _PageIndicator extends StatelessWidget {
  final int currentIndex;
  final int totalItems;

  const _PageIndicator({
    required this.currentIndex,
    required this.totalItems,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalItems,
            (index) => _PageIndicatorDot(
          isActive: currentIndex == index,
        ),
      ),
    );
  }
}

class _PageIndicatorDot extends StatelessWidget {
  final bool isActive;

  const _PageIndicatorDot({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 7,
      width: isActive ? 22 : 7,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(isActive ? 1 : .5),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

// Extracted Property Content Sheet
class _PropertyContent extends StatelessWidget {
  final String title;
  final double price;
  final String location;
  final String description;
  final ScrollController scrollController;

  const _PropertyContent({
    required this.title,
    required this.price,
    required this.location,
    required this.description,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: SingleChildScrollView(
        controller: scrollController,
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PropertyHeader(
              title: title,
              price: price,
              location: location,
            ),
            const SizedBox(height: 30),
            const _SectionTitle(title: 'Description'),
            const SizedBox(height: 10),
            _PropertyDescription(description: description),
            const SizedBox(height: 100), // Bottom padding for action bar
          ],
        ),
      ),
    );
  }
}

// Extracted Property Header
class _PropertyHeader extends StatelessWidget {
  final String title;
  final double price;
  final String location;

  const _PropertyHeader({
    required this.title,
    required this.price,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              "ZMW ${price.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          location,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.grey,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

// Extracted Section Title
class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// Extracted Property Description
class _PropertyDescription extends StatelessWidget {
  final String description;

  const _PropertyDescription({required this.description});

  @override
  Widget build(BuildContext context) {
    return Text(
      description.isEmpty ? 'No description available.' : description,
      style: const TextStyle(
        fontSize: 15,
        color: Colors.black87,
        height: 1.5,
      ),
    );
  }
}

// Extracted Bottom Action Bar
class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.black12),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _handleContactOwner,
                child: const Text(
                  "Contact Owner",
                  style: TextStyle(fontSize: 17, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleContactOwner() {
    // Implement contact owner functionality
  }
}

// Placeholder and Loading Widgets
class _PlaceholderImage extends StatelessWidget {
  const _PlaceholderImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(
          Icons.home_work_outlined,
          size: 64,
          color: Colors.grey,
        ),
      ),
    );
  }
}

class _VideoPlaceholder extends StatelessWidget {
  const _VideoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.videocam_outlined, size: 48, color: Colors.white54),
          SizedBox(height: 8),
          Text(
            "Video support can be added here",
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}

class _ImageLoadingPlaceholder extends StatelessWidget {
  const _ImageLoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Colors.grey,
      child: Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}

class _ImageErrorPlaceholder extends StatelessWidget {
  const _ImageErrorPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Colors.grey,
      child: Center(
        child: Icon(Icons.error_outline, color: Colors.white54, size: 48),
      ),
    );
  }
}

// Alternative minimal version for maximum performance
class MinimalPropertyDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> property;

  const MinimalPropertyDetailsScreen({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final photos = (property['photos'] as List<dynamic>?)?.cast<String>() ?? [];
    final title = property['title']?.toString() ?? '';
    final price = (property['price'] as num?)?.toDouble() ?? 0.0;
    final location = property['location']?.toString() ?? '';
    final description = property['description']?.toString() ?? '';

    return Scaffold(
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            flexibleSpace: photos.isNotEmpty
                ? CachedNetworkImage(
              imageUrl: photos.first,
              fit: BoxFit.cover,
              placeholder: (context, url) => const _ImageLoadingPlaceholder(),
              errorWidget: (context, url, error) => const _ImageErrorPlaceholder(),
            )
                : const _PlaceholderImage(),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "ZMW ${price.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    location,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Description",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(description),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Contact Owner'),
        ),
      ),
    );
  }
}