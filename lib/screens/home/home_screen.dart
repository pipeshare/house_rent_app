import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:house_rent_app/core/helpers.dart';
import 'package:house_rent_app/models/DataModels.dart';
import 'package:house_rent_app/models/Professional.dart';
import 'package:house_rent_app/screens/home/property_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin<HomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _selectedCategory = 0;

  bool _isMapMode = false;
  bool _showSearchBar = true;
  Stream<QuerySnapshot>? _currentPropertiesStream;

  void _updatePropertiesStream() {
    String selectedCategory = categories[_selectedCategory].name;

    setState(() {
      _currentPropertiesStream = selectedCategory == 'All'
          ? _firestore
              .collection('posts')
              .orderBy('createdAt', descending: true)
              .snapshots()
          : _firestore
              .collection('posts')
              .where('category', isEqualTo: selectedCategory)
              .snapshots();
    });
  }

  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  final Map<int, Widget> _categoryCache = {};

  List<Category> categories = [Category('All', Icons.all_inclusive_rounded)];
  List<Professional> professionals = [];

  final List<NavigationItem> navItems = [
    NavigationItem('Home', Icons.home_outlined),
    NavigationItem('Saved', Icons.favorite_border),
    NavigationItem('Notifications', Icons.notifications_outlined),
    NavigationItem('Profile', Icons.person_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadProfessionals();
    _updatePropertiesStream();

    // Listen to sheet size changes
    _sheetController.addListener(() {
      final isMapMode = _sheetController.size < 0.5;
      if (_isMapMode != isMapMode) {
        setState(() {
          _isMapMode = isMapMode;
          _showSearchBar = !_isMapMode;
        });
      }
    });
  }

  Future<void> _loadProfessionals() async {
    try {
      final snapshot = await _firestore.collection('professionals').get();

      final loadedProfessionals = snapshot.docs.map((doc) {
        final data = doc.data();

        // Convert the specialty string to enum safely
        final specialtyStr = (data['specialty'] ?? '').toString();
        final specialty = ProfessionalSpecialty.values.firstWhere(
          (e) => e.name.toLowerCase() == specialtyStr,
          orElse: () => ProfessionalSpecialty.agent, // fallback if unknown
        );

        return Professional(
          id: doc.id,
          name: data['name'] ?? 'Unknown',
          company: data['company'] ?? 'Unknown Company',
          specialty: specialty,
          rating: (data['rating'] ?? 0).toDouble(),
          verified: data['verified'] ?? false,
          imageUrl: data['imageUrl'] ?? '',
          yearsExperience: data['yearsExperience'] ?? 0,
          phone: data['phone'] ?? '',
        );
      }).toList();

      setState(() {
        professionals = loadedProfessionals;
      });
    } catch (e) {
      print('Error loading professionals: $e');
    }
  }

  // Helper method to convert string to IconData
  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'apartment':
        return Icons.apartment_rounded;
      case 'house':
        return Icons.house_rounded;
      case 'business_center':
        return Icons.business_center_rounded;
      case 'storefront':
        return Icons.storefront_rounded;
      case 'warehouse':
        return Icons.warehouse_rounded;
      case 'terrain':
        return Icons.terrain_rounded;
      case 'night_shelter':
        return Icons.night_shelter_rounded;
      case 'school':
        return Icons.school_rounded;
      case 'store_mall_directory':
        return Icons.store_mall_directory_rounded;
      case 'factory':
        return Icons.factory_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Future<void> _loadCategories() async {
    try {
      final snapshot = await _firestore.collection('categories').get();
      final loadedCategories = snapshot.docs.map((doc) {
        final data = doc.data();
        return Category(
          data['name'] ?? 'Unknown',
          _getIconFromString(data['icon'] ?? 'apartment'),
        );
      }).toList();

      setState(() {
        categories =
            [Category('All', Icons.all_inclusive_rounded)] + loadedCategories;
      });
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  // Method to toggle between map and list view
  void _toggleSheet() {
    if (_sheetController.size > 0.5) {
      // If currently in list view, switch to map view
      _sheetController.animateTo(
        0.04, // minChildSize
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // If currently in map view, switch to list view
      _sheetController.animateTo(
        1.0, // maxChildSize
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Animated Header
            AnimatedContainer(
              // color: Colors.black,
              duration: const Duration(milliseconds: 300),
              // height: _isMapMode ? 0 : 210,
              child: Opacity(
                opacity: _isMapMode ? 0 : 1.0,
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      // Header Section
                      _buildHeader(),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      color: Colors.grey[50],
                      child: Image.network(
                        'https://tile.openstreetmap.org/5/17/16.png',
                        fit: BoxFit.cover,
                        opacity: const AlwaysStoppedAnimation(0.3),
                      ),
                    ),
                  ),
                  DraggableScrollableSheet(
                    controller: _sheetController,
                    initialChildSize: 1,
                    minChildSize: 0.04,
                    maxChildSize: 1,
                    snap: true,
                    builder: (context, scrollController) {
                      scrollController.addListener(() {
                        if (scrollController.position.userScrollDirection ==
                            ScrollDirection.forward) {
                          setState(() {
                            _showSearchBar = true;
                          });
                        } else if (scrollController
                                .position.userScrollDirection ==
                            ScrollDirection.reverse) {
                          setState(() {
                            _showSearchBar = false;
                          });
                        }
                      });
                      return NotificationListener<
                          DraggableScrollableNotification>(
                        onNotification: (notification) {
                          setState(() {
                            _isMapMode = notification.extent < 0.5;
                            _showSearchBar = !_isMapMode;
                          });
                          return true;
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(0),
                            ),
                          ),
                          child: Column(
                            children: [
                              // Grab Handle
                              GestureDetector(
                                onTap: _toggleSheet,
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  width: 40,
                                  height: 5,
                                  margin:
                                      const EdgeInsets.only(top: 12, bottom: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[400],
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              // Content
                              Expanded(
                                child: CustomScrollView(
                                  controller: scrollController,
                                  physics: const BouncingScrollPhysics(),
                                  slivers: [
                                    // Find Professionals Section
                                    SliverToBoxAdapter(
                                      child: _buildProfessionalsSection(),
                                    ),
                                    // Featured Properties
                                    SliverToBoxAdapter(
                                        child: _buildFeaturedHeader()),
                                    // Properties List from Firestore
                                    _buildPropertiesList(),
                                    _PropertiesListWidget(
                                        propertiesStream:
                                            _currentPropertiesStream),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(microseconds: 200),
          height: _showSearchBar
              ? MediaQuery.of(context).size.height * 0.048 + 20
              : 0,
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: _buildSearchBar(),
          ),
        ),
        _buildCategoryTabs(),
      ],
    );
  }

  Widget _buildCategoryTab(Category category, bool isSelected, int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 55,
          height: 48,
          child: Icon(
            category.icon,
            color: isSelected ? Colors.grey[600] : Colors.grey[600],
            size: 50,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            border: isSelected
                ? const Border(
                    bottom: BorderSide(
                      color: Colors.black,
                      width: 3.0,
                    ),
                  )
                : null,
          ),
          child: Text(
            category.name,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.grey[600],
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      color: Colors.white,
      height: _isMapMode ? 0 : MediaQuery.of(context).size.height * 0.088,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == index;

          // Each category has two cache states: selected & unselected
          final cacheKey = index * 10 + (isSelected ? 1 : 0);

          // Return cached widget if exists
          if (_categoryCache.containsKey(cacheKey)) {
            return _categoryCache[cacheKey]!;
          }

          // Build the widget if not cached
          final widget = Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 20 : 12,
              right: index == categories.length - 1 ? 20 : 12,
            ),
            child: GestureDetector(
              onTap: () {
                // Only rebuild when actual change happens
                if (_selectedCategory != index) {
                  setState(() {
                    _selectedCategory = index;
                    // Clear only selected/unselected versions
                    _categoryCache.remove(index * 10);
                    _categoryCache.remove(index * 10 + 1);
                  });
                  _updatePropertiesStream();
                }
              },
              child: _buildCategoryTab(category, isSelected, index),
            ),
          );

          // Store it in cache
          _categoryCache[cacheKey] = widget;
          return widget;
        },
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 0,
      ),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(0),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 16),
            Icon(Icons.search, color: Colors.grey[500], size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search properties, locations, professionals...',
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 12,
                    height: 1.2,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            children: [
              Text(
                'Find a Professional',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const Spacer(),
              Text(
                'See more >',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 10),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: professionals.length,
            itemBuilder: (context, index) {
              final pro = professionals[index];
              return Container(
                width: 100,
                margin: const EdgeInsets.only(right: 12),
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(35),
                        color: Colors.grey[700],
                        image: pro.imageUrl.startsWith('http')
                            ? DecorationImage(
                                image: CachedNetworkImageProvider(pro.imageUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: pro.imageUrl.startsWith('http')
                          ? null
                          : Icon(Icons.person, color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      pro.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    ),
                    Text(
                      pro.specialty.displayName.toString(),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const Divider(height: 10),
      ],
    );
  }

  Widget _buildFeaturedHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Text(
            'Featured Properties',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const Spacer(),
          Text(
            'Explore more',
            style: TextStyle(
              color: Colors.blue[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertiesList() {
    String selectedCategory = categories[_selectedCategory].name;

    return StreamBuilder<QuerySnapshot>(
      stream: _currentPropertiesStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          // Check if it's an index error
          if (snapshot.error.toString().contains('index')) {
            return const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text('Setting up database...'),
                    SizedBox(height: 10),
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text(
                      'This may take a few minutes',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        // Rest of your existing code remains the same...
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

        // Manual sorting if not using orderBy
        if (selectedCategory != 'All') {
          properties.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;
            final aDate = aData['createdAt'] as Timestamp;
            final bDate = bData['createdAt'] as Timestamp;
            return bDate.compareTo(aDate); // Descending order
          });
        }

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
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.home_work_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No properties found',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new listings',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

// Pre-load images when property is likely to be viewed soon
void preloadPropertyImages(List<String> imageUrls) {
  for (final url in imageUrls) {
    CustomCacheManager().downloadFile(url);
  }
}

// Clear cache when needed (e.g., in settings)
Future<void> clearImageCache() async {
  await CustomCacheManager().emptyCache();
}

// Create a separate stateful widget for the properties list
class _PropertiesListWidget extends StatefulWidget {
  final Stream<QuerySnapshot>? propertiesStream;

  const _PropertiesListWidget({required this.propertiesStream});

  @override
  State<_PropertiesListWidget> createState() => _PropertiesListWidgetState();
}

class _PropertiesListWidgetState extends State<_PropertiesListWidget> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: widget.propertiesStream,
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
