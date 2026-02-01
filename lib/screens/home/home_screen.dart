import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
import 'package:house_rent_app/screens/home/components/properties_list.dart';
import 'package:house_rent_app/screens/home/property_card.dart';
import 'package:house_rent_app/services/post_service.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin<HomeScreen> {
  final MapController _mapController = MapController();
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  // ValueNotifiers for state that should NOT rebuild the map
  final ValueNotifier<Map<String, dynamic>?> selectedPropertyNotifier =
      ValueNotifier(null);
  final ValueNotifier<String> searchQueryNotifier = ValueNotifier('');
  final ValueNotifier<List<Marker>> markersNotifier = ValueNotifier([]);
  final ValueNotifier<bool> showSearchDropdownNotifier = ValueNotifier(false);
  final ValueNotifier<List<Map<String, dynamic>>> onlineSuggestionsNotifier =
      ValueNotifier([]);
  final ValueNotifier<bool> isLoadingSuggestionsNotifier = ValueNotifier(false);
  late final PostService _postService;
  // Stream subscriptions
  StreamSubscription<QuerySnapshot>? _propertiesSubscription;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // UI state that can rebuild freely
  int _selectedCategory = 0;
  final Map<int, Widget> _categoryCache = {};
  bool _isMapMode = false;
  bool _showSearchBar = true;
  List<Category> categories = [Category('All', Icons.all_inclusive_rounded)];
  List<Professional> professionals = [];

  // Controllers and focus nodes
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _searchDebounce;

  final List<NavigationItem> navItems = [
    NavigationItem('Home', Icons.home_outlined),
    NavigationItem('Saved', Icons.favorite_border),
    NavigationItem('Notifications', Icons.notifications_outlined),
    NavigationItem('Profile', Icons.person_outlined),
  ];

  @override
  void initState() {
    super.initState();

    _postService = PostService();

    // Initialize map camera once
    _initializeMapCamera();

    // Load initial data
    _loadCategories();
    _loadProfessionals();

    // Setup Firestore stream listener
    _setupPropertiesStream();

    // Listen to sheet controller
    _sheetController.addListener(_handleSheetChange);

    // Setup search focus listener using ValueNotifier
    _searchFocusNode.addListener(() {
      showSearchDropdownNotifier.value = _searchFocusNode.hasFocus;
    });

    // Setup search text listener using ValueNotifier
    _searchController.addListener(() {
      searchQueryNotifier.value = _searchController.text;
    });
  }

  late final PostService postsService;
  void _initializeMapCamera() {
    // Initial camera position is set once
    // The map controller will maintain this state internally
    // No need to store initial values in state variables
  }

  void _setupPropertiesStream() {
    String selectedCategory =
        categories.isNotEmpty && _selectedCategory < categories.length
            ? categories[_selectedCategory].name
            : 'All';

    final stream = selectedCategory == 'All'
        ? _firestore
            .collection('posts')
            .orderBy('createdAt', descending: true)
            .snapshots()
        : _firestore
            .collection('posts')
            .where('category', isEqualTo: selectedCategory)
            .snapshots();

    // Cancel previous subscription if exists
    _propertiesSubscription?.cancel();

    // Listen to stream and update ValueNotifier
    _propertiesSubscription = stream.listen((snapshot) {
      _processPropertiesSnapshot(snapshot);
    }, onError: (error) {
      debugPrint('Error in properties stream: $error');
    });
  }

  final postsStream = PostService().postsStream();

  void _processPropertiesSnapshot(QuerySnapshot snapshot) {
    final markers = snapshot.docs
        .map((doc) {
          final data = doc.data() as Map<String, dynamic>;
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

          return Marker(
            point: LatLng(lat, lng),
            width: 60,
            height: 30,
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: () {
                selectedPropertyNotifier.value = {
                  'id': doc.id,
                  ...data,
                  'latitude': lat,
                  'longitude': lng,
                };
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

    markersNotifier.value = markers;
  }

  Widget _buildPropertyMarker(String category, String price, String currency) {
    String symbol;
    switch (currency.toLowerCase()) {
      case "usd":
        symbol = '\$';
        break;
      default:
        symbol = 'K';
    }

    return Container(
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
  }

  void _handleSheetChange() {
    final isMapMode = _sheetController.size < 0.5;
    if (_isMapMode != isMapMode) {
      setState(() {
        _isMapMode = isMapMode;
        _showSearchBar = !_isMapMode;
      });
    }
  }

  void _updatePropertiesStream() {
    // Cancel and recreate stream with new category
    _setupPropertiesStream();
  }

  Future<void> _loadProfessionals() async {
    try {
      final snapshot = await _firestore.collection('professionals').get();
      final loadedProfessionals = snapshot.docs.map((doc) {
        final data = doc.data();
        final specialtyStr = (data['specialty'] ?? '').toString();
        final specialty = ProfessionalSpecialty.values.firstWhere(
          (e) => e.name.toLowerCase() == specialtyStr,
          orElse: () => ProfessionalSpecialty.agent,
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

  void _toggleSheet() {
    if (_sheetController.size > 0.5) {
      _sheetController.animateTo(
        0.04,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _sheetController.animateTo(
        1.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _propertiesSubscription?.cancel();
    _sheetController.dispose();
    _searchDebounce?.cancel();
    _searchFocusNode.dispose();
    _searchController.dispose();
    selectedPropertyNotifier.dispose();
    searchQueryNotifier.dispose();
    markersNotifier.dispose();
    showSearchDropdownNotifier.dispose();
    onlineSuggestionsNotifier.dispose();
    isLoadingSuggestionsNotifier.dispose();
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
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: Opacity(
                opacity: _isMapMode ? 0 : 1.0,
                child: Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      _buildHeader(),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  // PropertyMap NEVER rebuilds - all updates through ValueNotifiers
                  Positioned.fill(
                    child: Container(
                      color: Colors.grey[50],
                      child: PropertyMap(
                        mapController: _mapController,
                        selectedPropertyNotifier: selectedPropertyNotifier,
                        searchQueryNotifier: searchQueryNotifier,
                        markersNotifier: markersNotifier,
                        showSearchDropdownNotifier: showSearchDropdownNotifier,
                        onlineSuggestionsNotifier: onlineSuggestionsNotifier,
                        isLoadingSuggestionsNotifier:
                            isLoadingSuggestionsNotifier,
                        searchController: _searchController,
                        searchFocusNode: _searchFocusNode,
                      ),
                    ),
                  ),
                  // Draggable sheet can rebuild freely
                  DraggableScrollableSheet(
                    controller: _sheetController,
                    initialChildSize: 1,
                    minChildSize: 0.04,
                    maxChildSize: 1,
                    snap: true,
                    builder: (context, scrollController) {
                      return _buildDraggableSheet(scrollController);
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

  Widget _buildDraggableSheet(ScrollController scrollController) {
    scrollController.addListener(() {
      if (scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        if (!_showSearchBar) {
          setState(() {
            _showSearchBar = true;
          });
        }
      } else if (scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        if (_showSearchBar) {
          setState(() {
            _showSearchBar = false;
          });
        }
      }
    });

    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        final isMapMode = notification.extent < 0.5;
        if (_isMapMode != isMapMode) {
          setState(() {
            _isMapMode = isMapMode;
            _showSearchBar = !_isMapMode;
          });
        }
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
            GestureDetector(
              onTap: _toggleSheet,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Expanded(
              child: CustomScrollView(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildProfessionalsSection(),
                  ),
                  SliverToBoxAdapter(
                    child: _buildFeaturedHeader(),
                  ),
                  PostsSection(
                    postsStream: postsStream,
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
                controller: _searchController,
                focusNode: _searchFocusNode,
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
            color: Colors.grey[600],
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
          final cacheKey = index * 10 + (isSelected ? 1 : 0);

          if (_categoryCache.containsKey(cacheKey)) {
            return _categoryCache[cacheKey]!;
          }

          final widget = Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 20 : 12,
              right: index == categories.length - 1 ? 20 : 12,
            ),
            child: GestureDetector(
              onTap: () {
                if (_selectedCategory != index) {
                  setState(() {
                    _selectedCategory = index;
                    _categoryCache.remove(index * 10);
                    _categoryCache.remove(index * 10 + 1);
                  });
                  _updatePropertiesStream();
                }
              },
              child: _buildCategoryTab(category, isSelected, index),
            ),
          );

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
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    RouteNames.professionals,
                  );
                },
                child: Text(
                  'See more >',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[800],
                  ),
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

  @override
  bool get wantKeepAlive => true;
}

// ====================================================
// PROPERTY MAP WIDGET (STATIC - NEVER REBUILDS)
// ====================================================

class PropertyMap extends StatefulWidget {
  final MapController mapController;
  final ValueNotifier<Map<String, dynamic>?> selectedPropertyNotifier;
  final ValueNotifier<String> searchQueryNotifier;
  final ValueNotifier<List<Marker>> markersNotifier;
  final ValueNotifier<bool> showSearchDropdownNotifier;
  final ValueNotifier<List<Map<String, dynamic>>> onlineSuggestionsNotifier;
  final ValueNotifier<bool> isLoadingSuggestionsNotifier;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;

  const PropertyMap({
    super.key,
    required this.mapController,
    required this.selectedPropertyNotifier,
    required this.searchQueryNotifier,
    required this.markersNotifier,
    required this.showSearchDropdownNotifier,
    required this.onlineSuggestionsNotifier,
    required this.isLoadingSuggestionsNotifier,
    required this.searchController,
    required this.searchFocusNode,
  });

  @override
  State<PropertyMap> createState() => _PropertyMapState();
}

class _PropertyMapState extends State<PropertyMap> {
  LatLng? _initialCenter;
  double _initialZoom = 13.0;
  bool _isInitialized = false;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    // Initialize map camera once
    _initializeMapCamera();

    // Setup focus listener using ValueNotifier
    widget.searchFocusNode.addListener(() {
      widget.showSearchDropdownNotifier.value =
          widget.searchFocusNode.hasFocus &&
              widget.searchController.text.isEmpty;
    });
  }

  void _initializeMapCamera() async {
    try {
      // Get current location
      final location = await Location().getLocation();

      if (location.latitude != null && location.longitude != null) {
        _initialCenter = LatLng(location.latitude!, location.longitude!);
        _initialZoom = 15.0; // Zoomed in closer for current location
      } else {
        // Fallback to default if location is null
        _initialCenter = const LatLng(-15.3875, 28.3228); // Lusaka center
        _initialZoom = 13.0;
      }
    } catch (e) {
      debugPrint('Error getting current location: $e');
      // Fallback to default on error
      _initialCenter = const LatLng(-15.3875, 28.3228); // Lusaka center
      _initialZoom = 13.0;
    } finally {
      _isInitialized = true;
    }
  }

  void _debouncedSearch(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 500),
      () {
        _fetchOnlineSuggestions(value);
      },
    );
  }

  Future<void> _fetchOnlineSuggestions(String query) async {
    // Clean and trim the query
    final cleanQuery = query.trim();

    if (!mounted || cleanQuery.isEmpty) {
      widget.onlineSuggestionsNotifier.value = [];
      return;
    }

    // For very short queries (1-2 chars), show popular Zambian locations
    if (cleanQuery.length <= 2) {
      widget.onlineSuggestionsNotifier.value =
          _getPopularZambianLocations(cleanQuery);
      widget.isLoadingSuggestionsNotifier.value = false;
      return;
    }

    widget.isLoadingSuggestionsNotifier.value = true;

    try {
      // Build URL with multiple search strategies
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?'
        'q=${Uri.encodeComponent(cleanQuery)}&'
        'format=json&'
        'addressdetails=1&'
        'limit=15&' // Increased to 15
        'countrycodes=zm&'
        'namedetails=1&' // Get alternative names
        'accept-language=en&'
        'email=dev@houserentapp.com',
      );

      debugPrint('Fetching suggestions for: "$cleanQuery"');

      final client = HttpClient();
      final request = await client.getUrl(uri);
      request.headers
          .add('User-Agent', 'HouseRentApp/1.0 (dev@houserentapp.com)');
      request.headers.add('Accept', 'application/json');
      request.headers.add('Accept-Language', 'en');

      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();

        if (responseBody.trim().isEmpty) {
          widget.onlineSuggestionsNotifier.value = [];
          return;
        }

        final List<dynamic> data = json.decode(responseBody);

        // Process and filter results
        final suggestions = _processNominatimResults(data, cleanQuery);

        widget.onlineSuggestionsNotifier.value = suggestions;

        debugPrint('Found ${suggestions.length} suggestions for "$cleanQuery"');

        // If no results from Nominatim, try alternative search
        if (suggestions.isEmpty && cleanQuery.length >= 3) {
          await _getSuggestiveSearch(cleanQuery);
        }
      } else {
        debugPrint('API error ${response.statusCode} for "$cleanQuery"');
        widget.onlineSuggestionsNotifier.value = [];
      }
    } catch (e) {
      debugPrint('Error for "$query": $e');
      widget.onlineSuggestionsNotifier.value = [];

      // On error, show popular locations
      if (cleanQuery.isNotEmpty) {
        widget.onlineSuggestionsNotifier.value =
            _getPopularZambianLocations(cleanQuery);
      }
    } finally {
      widget.isLoadingSuggestionsNotifier.value = false;
    }
  }

  List<Map<String, dynamic>> _processNominatimResults(
      List<dynamic> data, String query) {
    final List<Map<String, dynamic>> results = [];

    for (final item in data) {
      try {
        final displayName = item['display_name']?.toString() ?? '';
        final importance = (item['importance'] as num?)?.toDouble() ?? 0;

        // Skip very low importance results for short queries
        if (query.length <= 3 && importance < 0.2) {
          continue;
        }

        // Get alternative names for better matching
        final namedetails = item['namedetails'] as Map<String, dynamic>?;
        final altNames = namedetails != null
            ? namedetails.values.whereType<String>().toList()
            : [];

        // Check if query matches display name or alternative names
        final queryLower = query.toLowerCase();
        final displayLower = displayName.toLowerCase();

        bool matches = displayLower.contains(queryLower);

        if (!matches && altNames.isNotEmpty) {
          for (final altName in altNames) {
            if (altName.toLowerCase().contains(queryLower)) {
              matches = true;
              break;
            }
          }
        }

        if (matches || query.length >= 4) {
          // Be more lenient for longer queries
          results.add({
            'name': displayName,
            'type': _getLocationType(item),
            'lat': double.parse(item['lat'].toString()),
            'lng': double.parse(item['lon'].toString()),
            'address': item['address'] ?? {},
            'importance': importance,
          });
        }
      } catch (e) {
        debugPrint('Error processing result: $e');
      }
    }

    // Sort by importance (highest first)
    results.sort((a, b) =>
        (b['importance'] as double).compareTo(a['importance'] as double));

    return results;
  }

  Future<void> _getSuggestiveSearch(String query) async {
    try {
      // Try a broader search without country restriction
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?'
        'q=${Uri.encodeComponent(query)}+Zambia&' // Append "Zambia" to query
        'format=json&'
        'addressdetails=1&'
        'limit=10&'
        'email=dev@houserentapp.com',
      );

      final client = HttpClient();
      final request = await client.getUrl(uri);
      request.headers.add('User-Agent', 'HouseRentApp/1.0');

      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();

        if (responseBody.trim().isNotEmpty) {
          final List<dynamic> data = json.decode(responseBody);

          // Filter to only include Zambian results
          final zambianResults = data.where((item) {
            final address = item['address'] as Map<String, dynamic>?;
            final country = address?['country']?.toString().toLowerCase();
            final countryCode =
                address?['country_code']?.toString().toLowerCase();
            return country == 'zambia' || countryCode == 'zm';
          }).toList();

          if (zambianResults.isNotEmpty) {
            final suggestions = zambianResults.map((item) {
              return {
                'name': item['display_name'] ?? '',
                'type': _getLocationType(item),
                'lat': double.parse(item['lat'].toString()),
                'lng': double.parse(item['lon'].toString()),
                'address': item['address'] ?? {},
              };
            }).toList();

            widget.onlineSuggestionsNotifier.value = suggestions;
            debugPrint('Suggestive search found ${suggestions.length} results');
          }
        }
      }
    } catch (e) {
      debugPrint('Alternative search failed: $e');
    }
  }

  List<Map<String, dynamic>> _getPopularZambianLocations(String prefix) {
    final List<Map<String, dynamic>> popular = [
      {
        'name': 'Lusaka, Zambia',
        'type': 'city',
        'lat': -15.3875,
        'lng': 28.3228,
        'address': {'city': 'Lusaka', 'country': 'Zambia'},
        'isPopular': true,
      },
      {
        'name': 'Kitwe, Zambia',
        'type': 'city',
        'lat': -12.8230,
        'lng': 28.1939,
        'address': {'city': 'Kitwe', 'country': 'Zambia'},
        'isPopular': true,
      },
      {
        'name': 'Ndola, Zambia',
        'type': 'city',
        'lat': -12.9586,
        'lng': 28.6366,
        'address': {'city': 'Ndola', 'country': 'Zambia'},
        'isPopular': true,
      },
      {
        'name': 'Livingstone, Zambia',
        'type': 'city',
        'lat': -17.8416,
        'lng': 25.8543,
        'address': {'city': 'Livingstone', 'country': 'Zambia'},
        'isPopular': true,
      },
      {
        'name': 'Kabwe, Zambia',
        'type': 'city',
        'lat': -14.4350,
        'lng': 28.4522,
        'address': {'city': 'Kabwe', 'country': 'Zambia'},
        'isPopular': true,
      },
      {
        'name': 'Chipata, Zambia',
        'type': 'city',
        'lat': -13.6455,
        'lng': 32.6464,
        'address': {'city': 'Chipata', 'country': 'Zambia'},
        'isPopular': true,
      },
      {
        'name': 'Solwezi, Zambia',
        'type': 'town',
        'lat': -12.1833,
        'lng': 26.4000,
        'address': {'town': 'Solwezi', 'country': 'Zambia'},
        'isPopular': true,
      },
      {
        'name': 'Mongu, Zambia',
        'type': 'town',
        'lat': -15.2796,
        'lng': 23.1200,
        'address': {'town': 'Mongu', 'country': 'Zambia'},
        'isPopular': true,
      },
    ];

    // Filter by prefix if provided
    if (prefix.isNotEmpty) {
      final prefixLower = prefix.toLowerCase();
      return popular.where((location) {
        final name = location['name'].toString().toLowerCase();
        return name.contains(prefixLower);
      }).toList();
    }

    return popular;
  }

// Improved location type detection
  String _getLocationType(dynamic item) {
    final address = item['address'] ?? {};
    final type = item['type']?.toString().toLowerCase() ?? '';
    final osmType = item['osm_type']?.toString().toLowerCase() ?? '';
    final category = item['category']?.toString().toLowerCase() ?? '';

    // Check address hierarchy first
    if (address['city'] != null) return 'city';
    if (address['town'] != null) return 'town';
    if (address['municipality'] != null) return 'municipality';
    if (address['suburb'] != null) return 'suburb';
    if (address['neighbourhood'] != null) return 'neighbourhood';
    if (address['village'] != null) return 'village';
    if (address['hamlet'] != null) return 'hamlet';
    if (address['county'] != null) return 'county';
    if (address['state'] != null) return 'state';

    // Check type/category
    if (type.contains('city') || category.contains('boundary')) return 'city';
    if (type.contains('town')) return 'town';
    if (type.contains('suburb')) return 'suburb';
    if (type.contains('village')) return 'village';
    if (type.contains('administrative')) return 'administrative';
    if (osmType.contains('node')) return 'place';
    if (osmType.contains('way')) return 'area';
    if (osmType.contains('relation')) return 'relation';

    return 'place';
  }

  void _navigateToSuggestion(Map<String, dynamic> suggestion) {
    final location = LatLng(
      (suggestion['lat'] as num).toDouble(),
      (suggestion['lng'] as num).toDouble(),
    );

    widget.searchController.text = suggestion['name'];
    widget.mapController.move(location, 14.0);
    widget.showSearchDropdownNotifier.value = false;
    widget.searchFocusNode.unfocus();
  }

  void _moveToCurrentLocation() async {
    final location = await Location().getLocation();
    widget.mapController.move(
      LatLng(location.latitude!, location.longitude!),
      15.0,
    );
  }

  void _clearSearch() {
    widget.searchController.clear();
    widget.searchQueryNotifier.value = '';
    widget.onlineSuggestionsNotifier.value = [];
    widget.searchFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This widget should NEVER rebuild after initial build
    return Stack(
      children: [
        // FlutterMap - static, never rebuilds
        FlutterMap(
          key: const Key('static_flutter_map'),
          mapController: widget.mapController,
          options: MapOptions(
            initialCenter: _initialCenter!,
            initialZoom: _initialZoom,
            keepAlive: true,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              maxZoom: 19,
              userAgentPackageName: 'com.example.house_rent_app',
            ),
            // MarkerLayer updates via ValueListenableBuilder
            ValueListenableBuilder<List<Marker>>(
              valueListenable: widget.markersNotifier,
              builder: (context, markers, _) {
                return MarkerLayer(markers: markers);
              },
            ),
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

        // Selected Property Card
        ValueListenableBuilder<Map<String, dynamic>?>(
          valueListenable: widget.selectedPropertyNotifier,
          builder: (context, property, _) {
            if (property == null) return const SizedBox.shrink();

            // Get parent state to build card
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

        // Search Bar and Dropdown
        Positioned(
          top: 40,
          left: 20,
          right: 20,
          child: Column(
            children: [
              // Search Bar
              MapSearchBar(
                controller: widget.searchController,
                focusNode: widget.searchFocusNode,
                searchQuery: widget.searchQueryNotifier,
                onMyLocation: _moveToCurrentLocation,
                onClear: _clearSearch,
                onSearch: _debouncedSearch,
              ),

              // Search Dropdown
              ValueListenableBuilder<bool>(
                valueListenable: widget.showSearchDropdownNotifier,
                builder: (context, showDropdown, _) {
                  if (!showDropdown) return const SizedBox.shrink();

                  return _buildSearchDropdown();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchDropdown() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      width: MediaQuery.of(context).size.width,
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
      constraints: const BoxConstraints(maxHeight: 350),
      child: ValueListenableBuilder2<String, List<Map<String, dynamic>>>(
        first: widget.searchQueryNotifier,
        second: widget.onlineSuggestionsNotifier,
        builder: (context, searchQuery, suggestions) {
          if (searchQuery.isEmpty) {
            return _buildPopularSuggestions();
          }

          return _buildOnlineSuggestionsList(suggestions);
        },
      ),
    );
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
    widget.searchController.text = name;
    widget.showSearchDropdownNotifier.value = false;
    widget.searchFocusNode.unfocus();
  }

  Widget _buildOnlineSuggestionsList(List<Map<String, dynamic>> suggestions) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.isLoadingSuggestionsNotifier,
      builder: (context, isLoading, _) {
        if (isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (suggestions.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'No locations found',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            return _buildOnlineSuggestionItem(suggestions[index]);
          },
        );
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
      onTap: () => _navigateToSuggestion(suggestion),
    );
  }

  String _formatDisplayName(String displayName, Map<String, dynamic> address) {
    final city = address['city'] ?? address['town'];
    final suburb = address['suburb'] ?? address['neighbourhood'];
    final road = address['road'];

    if (suburb != null && city != null) {
      return '$suburb, $city';
    } else if (road != null && city != null) {
      return '$road, $city';
    }

    return displayName.split(',').first;
  }

  String _getAddressSubtitle(Map<String, dynamic> address) {
    final parts = [];
    if (address['city'] != null) parts.add(address['city']);
    if (address['town'] != null) parts.add(address['town']);
    if (address['state'] != null) parts.add(address['state']);
    if (address['country'] != null) parts.add(address['country']);
    return parts.join(', ');
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
}

// Helper class for listening to multiple ValueNotifiers
class ValueListenableBuilder2<A, B> extends StatelessWidget {
  final ValueNotifier<A> first;
  final ValueNotifier<B> second;
  final Widget Function(BuildContext context, A a, B b) builder;

  const ValueListenableBuilder2({
    super.key,
    required this.first,
    required this.second,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<A>(
      valueListenable: first,
      builder: (context, a, _) {
        return ValueListenableBuilder<B>(
          valueListenable: second,
          builder: (context, b, __) {
            return builder(context, a, b);
          },
        );
      },
    );
  }
}

class MapSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueNotifier<String> searchQuery;
  final VoidCallback onMyLocation;
  final VoidCallback onClear;
  final Function(String) onSearch;

  const MapSearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.searchQuery,
    required this.onMyLocation,
    required this.onClear,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          const Icon(Icons.search, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: ValueListenableBuilder<String>(
              valueListenable: searchQuery,
              builder: (context, value, _) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    hintText: 'Search area in Zambia...',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onChanged: (newValue) {
                    searchQuery.value = newValue;
                    onSearch(newValue);
                  },
                );
              },
            ),
          ),
          ValueListenableBuilder<String>(
            valueListenable: searchQuery,
            builder: (context, value, _) {
              if (value.isEmpty) return const SizedBox();
              return IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: onClear,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.my_location, size: 18),
            onPressed: onMyLocation,
          ),
        ],
      ),
    );
  }
}

// Existing helper classes remain unchanged
void preloadPropertyImages(List<String> imageUrls) {
  for (final url in imageUrls) {
    CustomCacheManager().downloadFile(url);
  }
}

Future<void> clearImageCache() async {
  await CustomCacheManager().emptyCache();
}
