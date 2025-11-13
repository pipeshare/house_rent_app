import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  int _selectedNavIndex = 0;

  // Optimized caching
  final Map<int, Widget> _categoryCache = {};
  final _professionalsCache = <Professional>[];
  bool _isProfessionalsLoaded = false;

  List<Category> categories = [Category('All', Icons.all_inclusive_rounded)];
  List<Professional> professionals = [];

  final List<NavigationItem> navItems = [
    NavigationItem('Home', Icons.home_outlined),
    NavigationItem('Saved', Icons.favorite_border),
    NavigationItem('Notifications', Icons.notifications_outlined),
    NavigationItem('Profile', Icons.person_outlined),
  ];

  // Firestore query caching
  Query<Map<String, dynamic>>? _cachedAllPropertiesQuery;
  final _categoryQueries = <String, Query<Map<String, dynamic>>>{};

  // Scroll controller for better performance
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeData();
    _scrollController.addListener(_onScroll);
  }

  void _initializeData() {
    _loadCategories();
    _loadProfessionals();
    // Pre-cache the "All" query
    _cachedAllPropertiesQuery = _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true);
  }

  Future<void> _loadProfessionals() async {
    if (_isProfessionalsLoaded) return;

    try {
      final snapshot = await _firestore.collection('professionals').get();

      final loadedProfessionals = snapshot.docs.map((doc) {
        final data = doc.data();
        final specialtyStr = (data['specialty'] ?? '').toString().toLowerCase();
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

      if (mounted) {
        setState(() {
          professionals = loadedProfessionals;
          _professionalsCache.addAll(loadedProfessionals);
          _isProfessionalsLoaded = true;
        });
      }
    } catch (e) {
      debugPrint('Error loading professionals: $e');
    }
  }

  // Optimized icon mapping with const map
  static const Map<String, IconData> _iconMap = {
    'apartment': Icons.apartment_rounded,
    'house': Icons.house_rounded,
    'business_center': Icons.business_center_rounded,
    'storefront': Icons.storefront_rounded,
    'warehouse': Icons.warehouse_rounded,
    'terrain': Icons.terrain_rounded,
    'night_shelter': Icons.night_shelter_rounded,
    'school': Icons.school_rounded,
    'store_mall_directory': Icons.store_mall_directory_rounded,
    'factory': Icons.factory_rounded,
  };

  IconData _getIconFromString(String iconName) {
    return _iconMap[iconName] ?? Icons.category_rounded;
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

      if (mounted) {
        setState(() {
          categories = [Category('All', Icons.all_inclusive_rounded)] + loadedCategories;
        });
      }
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  void _onScroll() {
    // Optional: Implement scroll-based optimizations
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Optimized Animated Header
          _buildAnimatedHeader(),
          Expanded(
            child: Stack(
              children: [
                _buildMapBackground(),
                _buildDraggableSheet(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildAnimatedHeader() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _isMapMode ? 0 : 210,
      child: SafeArea(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _isMapMode ? 0 : 1.0,
          child: const ColoredBox(
            color: Colors.white,
            child: Column(
              children: [
                _HeaderSection(), // Extracted to separate widget
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapBackground() {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.grey[50]!,
        child: Image.network(
          'https://tile.openstreetmap.org/5/17/16.png',
          fit: BoxFit.cover,
          opacity: const AlwaysStoppedAnimation(0.3),
          filterQuality: FilterQuality.low, // Better performance
        ),
      ),
    );
  }

  Widget _buildDraggableSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 1,
      minChildSize: 0.12,
      maxChildSize: 1,
      snap: true,
      builder: (context, scrollController) {
        return _SheetContent(
          scrollController: scrollController,
          isMapMode: _isMapMode,
          onMapModeChanged: (isMapMode) {
            if (_isMapMode != isMapMode) {
              setState(() => _isMapMode = isMapMode);
            }
          },
          professionals: professionals,
          selectedCategory: _selectedCategory,
          categories: categories,
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _isMapMode ? 0 : kBottomNavigationBarHeight,
      child: _BottomNavigationBar(
        navItems: navItems,
        selectedIndex: _selectedNavIndex,
        onItemSelected: (index) {
          if (_selectedNavIndex != index) {
            setState(() => _selectedNavIndex = index);
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}

// Extracted Header Section as const widget
class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SearchBar(),
        const SizedBox(height: 16),
        _CategoryList(), // Stateful category list
      ],
    );
  }
}

// Extracted Search Bar as const widget
class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 0),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(0),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 16),
            Icon(Icons.search, color: Colors.grey, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: TextField(
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search properties, locations, professionals...',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    height: 1.2,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
              ),
            ),
            SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}

// Stateful category list for caching
class _CategoryList extends StatefulWidget {
  @override
  State<_CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<_CategoryList> {
  final _categoryCache = <int, Widget>{};
  int _selectedCategory = 0;
  late List<Category> categories;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context.findAncestorStateOfType<_HomeScreenState>();
    categories = state?.categories ?? [];
    _selectedCategory = state?._selectedCategory ?? 0;
  }

  void _onCategorySelected(int index) {
    final state = context.findAncestorStateOfType<_HomeScreenState>();
    state?.setState(() {
      state._selectedCategory = index;
    });
    setState(() {
      _selectedCategory = index;
      // Clear cache for the changed category
      _categoryCache.remove(index * 10);
      _categoryCache.remove(index * 10 + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == index;
          final cacheKey = index * 10 + (isSelected ? 1 : 0);

          return _categoryCache.putIfAbsent(cacheKey, () {
            return Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 20 : 12,
                right: index == categories.length - 1 ? 20 : 12,
              ),
              child: _CategoryTab(
                category: category,
                isSelected: isSelected,
                onTap: () => _onCategorySelected(index),
              ),
            );
          });
        },
      ),
    );
  }
}

// Extracted Category Tab as const widget
class _CategoryTab extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryTab({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
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
      ),
    );
  }
}

// Extracted Sheet Content
class _SheetContent extends StatelessWidget {
  final ScrollController scrollController;
  final bool isMapMode;
  final ValueChanged<bool> onMapModeChanged;
  final List<Professional> professionals;
  final int selectedCategory;
  final List<Category> categories;

  const _SheetContent({
    required this.scrollController,
    required this.isMapMode,
    required this.onMapModeChanged,
    required this.professionals,
    required this.selectedCategory,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        final newMapMode = notification.extent < 0.5;
        if (isMapMode != newMapMode) {
          onMapModeChanged(newMapMode);
        }
        return true;
      },
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
        ),
        child: Column(
          children: [
            // Grab Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Content
            Expanded(
              child: CustomScrollView(
                controller: scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  const SliverToBoxAdapter(
                    child: _ProfessionalsSection(),
                  ),
                  const SliverToBoxAdapter(
                    child: _FeaturedHeader(),
                  ),
                  _PropertiesList(
                    selectedCategory: selectedCategory,
                    categories: categories,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extracted Professionals Section
class _ProfessionalsSection extends StatelessWidget {
  const _ProfessionalsSection();

  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_HomeScreenState>();
    final professionals = state?.professionals ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            children: [
              Text(
                'Find a Professional',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Spacer(),
              Text(
                'See more >',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
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
              return _ProfessionalCard(professional: pro);
            },
          ),
        ),
        const Divider(height: 10),
      ],
    );
  }
}

// Extracted Professional Card with optimized image caching
class _ProfessionalCard extends StatelessWidget {
  final Professional professional;

  const _ProfessionalCard({required this.professional});

  @override
  Widget build(BuildContext context) {
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
            ),
            child: professional.imageUrl.startsWith('http')
                ? ClipRRect(
              borderRadius: BorderRadius.circular(35),
              child: CachedNetworkImage(
                imageUrl: professional.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Icon(
                  Icons.person,
                  color: Colors.grey[400],
                ),
                errorWidget: (context, url, error) => Icon(
                  Icons.person,
                  color: Colors.grey[400],
                ),
              ),
            )
                : Icon(Icons.person, color: Colors.grey[400]),
          ),
          const SizedBox(height: 8),
          Text(
            professional.name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          Text(
            professional.specialty.name,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}

// Extracted Featured Header
class _FeaturedHeader extends StatelessWidget {
  const _FeaturedHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Text(
            'Featured Properties',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Spacer(),
          Text(
            'Explore more',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Extracted Properties List with optimized stream handling
class _PropertiesList extends StatelessWidget {
  final int selectedCategory;
  final List<Category> categories;

  const _PropertiesList({
    required this.selectedCategory,
    required this.categories,
  });

  Query<Map<String, dynamic>> _getQuery(FirebaseFirestore firestore) {
    final categoryName = categories[selectedCategory].name;

    if (categoryName == 'All') {
      return firestore
          .collection('posts')
          .orderBy('createdAt', descending: true);
    } else {
      return firestore
          .collection('posts')
          .where('category', isEqualTo: categoryName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;

    return StreamBuilder<QuerySnapshot>(
      stream: _getQuery(firestore).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          if (snapshot.error.toString().contains('index')) {
            return const SliverToBoxAdapter(
              child: _IndexBuildingState(),
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
            child: _LoadingState(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SliverToBoxAdapter(
            child: _EmptyState(),
          );
        }

        final properties = snapshot.data!.docs;

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
}

// Extracted Bottom Navigation Bar
class _BottomNavigationBar extends StatelessWidget {
  final List<NavigationItem> navItems;
  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  const _BottomNavigationBar({
    required this.navItems,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: navItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = selectedIndex == index;

              return _NavItem(
                item: item,
                isSelected: isSelected,
                onTap: () => onItemSelected(index),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// Extracted Navigation Item
class _NavItem extends StatelessWidget {
  final NavigationItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            item.icon,
            color: isSelected ? Colors.black : Colors.grey,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            item.label,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.grey,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// Loading States
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _IndexBuildingState extends StatelessWidget {
  const _IndexBuildingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
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
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      child: const Column(
        children: [
          Icon(Icons.home_work_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No properties found',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'Check back later for new listings',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }
}