import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:house_rent_app/core/helpers.dart';
import 'package:house_rent_app/core/routes/routes.dart';
import 'package:house_rent_app/models/DataModels.dart';
import 'package:house_rent_app/models/Professional.dart';
import 'package:house_rent_app/screens/home/components/location_suggestion.dart';
import 'package:house_rent_app/screens/home/components/properties_list.dart';
import 'package:house_rent_app/screens/home/property_card.dart';
import 'package:house_rent_app/services/nominatim_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin<HomeScreen> {
  bool _showSearchDropdown = false;
  Timer? _searchDebounce;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _selectedCategory = 0;
  final Map<int, Widget> _categoryCache = {};

  bool _isMapMode = false;
  bool _showSearchBar = true;
  Stream<QuerySnapshot>? _currentPropertiesStream;

  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  final ValueNotifier<Map<String, dynamic>?> selectedPropertyNotifier =
      ValueNotifier(null);
  final ValueNotifier<String> searchQueryNotifier = ValueNotifier('');

  List<Category> categories = [Category('All', Icons.all_inclusive_rounded)];
  List<Professional> professionals = [];

  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();
  final FocusNode _searchFocusNode = FocusNode();

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

    _searchFocusNode.addListener(() {
      final hasFocus = _searchFocusNode.hasFocus;
      // Only update state if visibility actually changes
      if (_showSearchDropdown != hasFocus) {
        setState(() {
          _showSearchDropdown = hasFocus;
        });
      }
    });

    // Listen to search controller for text changes
    _searchController.addListener(() {
      setState(() {});
      searchQueryNotifier.value = _searchController.text;
    });
  }

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
      debugPrint('Error loading professionals: $e');
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
      debugPrint('Error loading categories: $e');
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
    _searchDebounce?.cancel();
    _searchFocusNode.dispose();
    _searchController.dispose();
    selectedPropertyNotifier.dispose();
    searchQueryNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Animated Header
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
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
                      child: PropertyMap(
                        mapController: _mapController,
                        selectedPropertyNotifier: selectedPropertyNotifier,
                        searchQueryNotifier: searchQueryNotifier,
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
                                    PropertiesListWidget(
                                      propertiesStream:
                                          _currentPropertiesStream,
                                    ),
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

  Widget _buildMiniPropertyCard(Map<String, dynamic> property) {
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
            // Preview Photo
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(
                property['photos'][0],
                height: 70,
                width: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 70,
                    width: 80,
                    color: Colors.grey[300],
                    child: const Icon(Icons.home, color: Colors.grey),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),

            // Text Information
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
                  Text(
                    property['location'] ?? 'No Location',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
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

            // Close button to dismiss the card
            IconButton(
              onPressed: () {
                selectedPropertyNotifier.value = null;
              },
              icon: const Icon(Icons.close, size: 20),
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
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
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

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: CircularProgressIndicator(),
              ),
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
                  Navigator.of(context).pushNamed(
                    RouteNames.propertyDetails,
                    arguments: property,
                  );
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
  bool get wantKeepAlive => true;
}

// ====================================================
// PROPERTY MAP WIDGET (FULLY DECOUPLED)
// ====================================================

class PropertyMap extends StatefulWidget {
  final MapController mapController;
  final ValueNotifier<Map<String, dynamic>?> selectedPropertyNotifier;
  final ValueNotifier<String> searchQueryNotifier;

  const PropertyMap({
    super.key,
    required this.mapController,
    required this.selectedPropertyNotifier,
    required this.searchQueryNotifier,
  });

  @override
  State<PropertyMap> createState() => _PropertyMapState();
}

class _PropertyMapState extends State<PropertyMap> {
  // Class-level variables
  final ValueNotifier<List<Map<String, dynamic>>> _suggestionsNotifier =
      ValueNotifier([]);
  final ValueNotifier<bool> _showDropdownNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier(false);

  final _markerCache = <String, Widget>{};
  List<QueryDocumentSnapshot> _allProperties = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final FocusNode _searchFocusNode = FocusNode();
  bool _showSearchDropdown =
      false; // Add this line at the top of _PropertyMapState class

  bool _isLoadingSuggestions = false;
  List<Map<String, dynamic>> _onlineSuggestions = [];
  Timer? _searchDebounce;
  Stream<QuerySnapshot> get _stream => FirebaseFirestore.instance
      .collection('posts')
      .where('latitude', isNotEqualTo: null)
      .where('longitude', isNotEqualTo: null)
      .snapshots();

  Widget _buildPropertyMarker(String category, String price, String currency) {
    final key = '$category-$price-$currency';
    if (_markerCache.containsKey(key)) return _markerCache[key]!;

    String symbol;

    switch (currency.toLowerCase()) {
      case "usd":
        symbol = '\$';
        break;
      default:
        symbol = 'K';
    }

    final widget = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.3),
            blurRadius: 6,
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: Text(
        "$symbol$price",
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    _markerCache[key] = widget;
    return widget;
  }

  LatLng _getInitialCenter(List<QueryDocumentSnapshot> properties) {
    if (properties.isEmpty) {
      return const LatLng(-15.3875, 28.3228); // Default Lusaka center
    }

    // Calculate average center of all properties
    double totalLat = 0;
    double totalLng = 0;
    int validProperties = 0;

    for (final doc in properties) {
      final data = doc.data() as Map<String, dynamic>;
      final lat = (data['latitude'] as num?)?.toDouble();
      final lng = (data['longitude'] as num?)?.toDouble();

      if (lat != null && lng != null) {
        totalLat += lat;
        totalLng += lng;
        validProperties++;
      }
    }

    if (validProperties > 0) {
      return LatLng(totalLat / validProperties, totalLng / validProperties);
    }

    return const LatLng(-15.3875, 28.3228); // Fallback to Lusaka center
  }

  List<Marker> _buildMarkers(List<QueryDocumentSnapshot> properties) {
    return properties
        .map((doc) {
          final data = doc.data() as Map<String, dynamic>;

          // Safely parse coordinates with null checks
          final lat = (data['latitude'] as num?)?.toDouble();
          final lng = (data['longitude'] as num?)?.toDouble();

          if (lat == null || lng == null) {
            return const Marker(
              point: LatLng(0, 0),
              width: 0,
              height: 0,
              child: SizedBox(),
            );
          }

          final property = {
            'id': doc.id,
            ...data,
            'latitude': lat,
            'longitude': lng,
          };

          return Marker(
            point: LatLng(lat, lng),
            width: 60,
            height: 30,
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () {
                debugPrint('Property tapped: ${data['title']}');
                widget.selectedPropertyNotifier.value = property;
              },
              child: _buildPropertyMarker(
                data['category'].toString(),
                data['price'].toString(),
                data['currency'] ?? 'ZMW',
              ),
            ),
          );
        })
        .where((marker) =>
            marker.point.latitude != 0 && marker.point.longitude != 0)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error loading properties',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No properties found',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        // Store all properties
        _allProperties = snapshot.data!.docs;

        return Stack(
          children: [
            // Map with markers (rebuilds only when stream updates)
            FlutterMap(
              mapController: widget.mapController,
              options: MapOptions(
                initialCenter: _getInitialCenter(_allProperties),
                initialZoom: 13,
                keepAlive: true,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  maxZoom: 19,
                  userAgentPackageName: 'com.example.house_rent_app',
                ),
                MarkerLayer(markers: _buildMarkers(_allProperties)),
                const CurrentLocationLayer(
                  style: LocationMarkerStyle(
                    marker: DefaultLocationMarker(
                      child: Icon(Icons.location_pin, color: Colors.white),
                    ),
                    markerSize: Size(35, 35),
                    markerDirection: MarkerDirection.heading,
                  ),
                ),
              ],
            ),
            // Mini property card (updates independently via ValueListenableBuilder)
            ValueListenableBuilder<Map<String, dynamic>?>(
              valueListenable: widget.selectedPropertyNotifier,
              builder: (context, property, _) {
                if (property == null) return const SizedBox.shrink();

                // Get the build context from the parent to access _buildMiniPropertyCard
                final homeScreenState =
                    context.findAncestorStateOfType<_HomeScreenState>();
                if (homeScreenState == null) return const SizedBox.shrink();

                return Positioned(
                  bottom: 40,
                  left: 20,
                  right: 20,
                  child: homeScreenState._buildMiniPropertyCard(property),
                );
              },
            ),
            ValueListenableBuilder<String>(
              valueListenable: widget.searchQueryNotifier,
              builder: (context, searchQuery, _) {
                return Positioned(
                  top: 40,
                  left: 20,
                  right: 20,
                  child: _buildMapSearchBar(),
                );
              },
            ),
          ],
        );
      },
    );
  }

  String _getAddressSubtitle(Map<String, dynamic> address) {
    final parts = [];

    if (address['city'] != null) parts.add(address['city']);
    if (address['town'] != null) parts.add(address['town']);
    if (address['state'] != null) parts.add(address['state']);
    if (address['country'] != null) parts.add(address['country']);

    return parts.join(', ');
  }

  String _formatDisplayName(String displayName, Map<String, dynamic> address) {
    // Extract the most relevant part of the name
    final city = address['city'] ?? address['town'];
    final suburb = address['suburb'] ?? address['neighbourhood'];
    final road = address['road'];

    if (suburb != null && city != null) {
      return '$suburb, $city';
    } else if (road != null && city != null) {
      return '$road, $city';
    }

    // Fallback to first part of display name
    return displayName.split(',').first;
  }

  IconData _getSuggestionIcon(String type) {
    switch (type) {
      case 'city':
        return Icons.location_city;
      case 'area':
      case 'suburb':
        return Icons.place;
      case 'village':
        return Icons.house;
      case 'region':
        return Icons.map;
      default:
        return Icons.location_on;
    }
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _onlineSuggestions = [];
      _searchFocusNode.requestFocus(); // Keep focus to show popular suggestions
    });
    widget.searchQueryNotifier.value = '';
  }

  Widget _buildMapSearchBar() {
    return Column(
      children: [
        Container(
          height: MediaQuery.of(context).size.height * 0.07,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.grey, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  // focusNode: _searchFocusNode,
                  decoration: const InputDecoration(
                    hintText: 'Search area in Zambia...',
                    hintStyle: TextStyle(fontSize: 15),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  onChanged: (value) {
                    _searchQuery = value;

                    _searchDebounce?.cancel();
                    _searchDebounce =
                        Timer(const Duration(milliseconds: 500), () async {
                      if (!mounted) return;

                      _isLoadingNotifier.value = true;

                      // For sample data
                      try {
                        final locations = await NominatimService.search(
                          query: _searchQuery,
                          countryCode: 'zm',
                        );

                        if (!mounted) return;

                        print("Found ${locations.length} locations");
                        _isLoadingSuggestions = false;
                        // Update suggestions and show dropdown
                        _suggestionsNotifier.value = locations;
                        _showDropdownNotifier.value = true;
                        _isLoadingNotifier.value = false;
                      } on NominatimException catch (e) {
                        debugPrint("error message: ${e.toString()}");
                        _buildSearchDropdown();
                        // if (!mounted) return;
                      }
                    });
                  },
                ),
              ),
              if (_searchQuery.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: _clearSearch,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.my_location, size: 18),
                onPressed: _moveToCurrentLocation,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
        // Search Dropdown - appears when typing or focused
        _buildSearchDropdown(),
      ],
    );
  }

// Update _navigateToSuggestion to hide dropdown after selection:
  void _navigateToSuggestion(Map<String, dynamic> suggestion) {
    final location = LatLng(
      (suggestion['lat'] as num).toDouble(),
      (suggestion['lng'] as num).toDouble(),
    );

    // Update search controller with selected suggestion
    _searchController.text = suggestion['name'];

    // Navigate to the location
    widget.mapController.move(location, 14.0);

    // Close the dropdown
    setState(() {
      _showSearchDropdown = false;
    });
    _searchFocusNode.unfocus();

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigating to ${suggestion['name']}'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildSearchDropdown() {
    return ValueListenableBuilder<List<Map<String, dynamic>>>(
      valueListenable: _suggestionsNotifier,
      builder: (context, suggestions, _) {
        return Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(8),
          width: MediaQuery.of(context).size.width,
          constraints: const BoxConstraints(maxHeight: 300),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: suggestions.isEmpty
              ? const Center(
                  child: Text(
                    'No locations found',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: suggestions.length,
                  shrinkWrap: true, // <-- allow it to take only needed space
                  itemBuilder: (context, index) {
                    final suggestion = suggestions[index];

                    return ListTile(
                      title: Text(suggestion['name'] ?? ''),
                      subtitle: Text(
                          suggestion['address']?['city'] ?? 'No city info'),
                      onTap: () {
                        debugPrint('Selected ${suggestion['name']}');
                        _showDropdownNotifier.value = false;
                      },
                    );
                  },
                ),
        );
      },
    );
  }

  Future<void> _moveToCurrentLocation() async {
    Location().getLocation().then((location) {
      widget.mapController
          .move(LatLng(location.latitude!, location.longitude!), 15.0);
    });
  }

  Widget _buildDropdownContent() {
    if (_isLoadingSuggestions) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_searchQuery.isEmpty) {
      return _buildPopularSuggestions();
      // return Text('');
    }

    if (_onlineSuggestions.isEmpty && _searchQuery.length > 2) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'No locations found',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return _buildOnlineSuggestions();
  }

  Widget _buildPopularSuggestions() {
    return ListView(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      children: [
        ListTile(
          leading:
              const Icon(Icons.location_city, color: Colors.blue, size: 20),
          title: const Text('Lusaka'),
          subtitle: const Text('Capital city of Zambia'),
          onTap: () =>
              _navigateToLatLng(const LatLng(-15.3875, 28.3228), 'Lusaka'),
        ),
        ListTile(
          leading: const Icon(Icons.place, color: Colors.blue, size: 20),
          title: const Text('Kitwe'),
          subtitle: const Text('Copperbelt Province'),
          onTap: () =>
              _navigateToLatLng(const LatLng(-12.8230, 28.1939), 'Kitwe'),
        ),
        ListTile(
          leading: const Icon(Icons.place, color: Colors.blue, size: 20),
          title: const Text('Ndola'),
          subtitle: const Text('Copperbelt Province'),
          onTap: () =>
              _navigateToLatLng(const LatLng(-12.9586, 28.6366), 'Ndola'),
        ),
      ],
    );
  }

  void _navigateToLatLng(LatLng location, String name) {
    widget.mapController.move(location, 14.0);
    setState(() {
      _searchController.text = name;
      _showSearchDropdown = false;
    });
    _searchFocusNode.unfocus();
  }

  Widget _buildOnlineSuggestions() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: _onlineSuggestions.length,
      itemBuilder: (context, index) {
        return _buildOnlineSuggestionItem(_onlineSuggestions[index]);
      },
    );
  }

  Widget _buildOnlineSuggestionItem(Map<String, dynamic> suggestion) {
    final address = suggestion['address'] as Map<String, dynamic>;
    final displayName = _formatDisplayName(suggestion['name'], address);

    return ListTile(
      leading: Icon(
        _getSuggestionIcon(suggestion['type']),
        color: Colors.blue,
        size: 20,
      ),
      title: Text(
        displayName,
        style: const TextStyle(fontSize: 14),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        _getAddressSubtitle(address),
        style: const TextStyle(fontSize: 12),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      visualDensity: const VisualDensity(vertical: -2),
      onTap: () {
        _navigateToSuggestion(suggestion);
      },
    );
  }
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
