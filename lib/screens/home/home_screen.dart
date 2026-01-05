import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:house_rent_app/models/DataModels.dart';
import 'package:house_rent_app/models/Professional.dart';

// Components
import 'components/home_header.dart';
import 'components/category_tabs.dart';
import 'components/property_map.dart';
import 'components/draggable_sheet.dart';

// Services
import 'services/category_service.dart';
import 'services/professional_service.dart';

// Utils
import 'utils/home_helpers.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // State variables
  bool _isMapMode = false;
  bool _showSearchBar = true;
  int _selectedCategory = 0;

  // Controllers
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Data
  List<Category> categories = [Category('All', Icons.all_inclusive_rounded)];
  List<Professional> professionals = [];
  Stream<QuerySnapshot>? _currentPropertiesStream;

  // Notifiers
  final ValueNotifier<Map<String, dynamic>?> selectedPropertyNotifier =
      ValueNotifier(null);
  final ValueNotifier<String> searchQueryNotifier = ValueNotifier('');

  // Caches
  final Map<int, Widget> _categoryCache = {};

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  void _initializeScreen() {
    _loadData();
    _setupControllers();
    _updatePropertiesStream();
  }

  void _loadData() async {
    await Future.wait([
      _loadCategories(),
      _loadProfessionals(),
    ]);
  }

  Future<void> _loadCategories() async {
    final loadedCategories = await CategoryService.loadCategories();
    if (mounted) {
      setState(() {
        categories =
            [Category('All', Icons.all_inclusive_rounded)] + loadedCategories;
      });
    }
  }

  Future<void> _loadProfessionals() async {
    final loadedProfessionals = await ProfessionalService.loadProfessionals();
    if (mounted) {
      setState(() {
        professionals = loadedProfessionals;
      });
    }
  }

  void _setupControllers() {
    _sheetController.addListener(_handleSheetChanges);
    _searchFocusNode.addListener(_handleSearchFocus);
    _searchController.addListener(_handleSearchText);
  }

  void _handleSheetChanges() {
    final isMapMode = _sheetController.size < 0.5;
    if (_isMapMode != isMapMode) {
      setState(() {
        _isMapMode = isMapMode;
        _showSearchBar = !_isMapMode;
      });
    }
  }

  void _handleSearchFocus() {
    if (mounted) {
      setState(() {});
    }
  }

  void _handleSearchText() {
    searchQueryNotifier.value = _searchController.text;
  }

  void _updatePropertiesStream() {
    final selectedCategory = categories[_selectedCategory].name;
    setState(() {
      _currentPropertiesStream = HomeHelpers.getPropertiesStream(
        category: selectedCategory,
      );
    });
  }

  void _handleCategoryChange(int index) {
    if (_selectedCategory != index) {
      setState(() {
        _selectedCategory = index;
        // Clear cache for the changed category
        _categoryCache.remove(_selectedCategory * 10);
        _categoryCache.remove(_selectedCategory * 10 + 1);
      });
      _updatePropertiesStream();
    }
  }

  void _toggleSheet() {
    HomeHelpers.toggleSheet(_sheetController);
  }

  @override
  void dispose() {
    _cleanupResources();
    super.dispose();
  }

  void _cleanupResources() {
    _sheetController.dispose();
    _searchFocusNode.dispose();
    _searchController.dispose();
    selectedPropertyNotifier.dispose();
    searchQueryNotifier.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Animated Header
            HomeHeader(
              showSearchBar: _showSearchBar,
              isMapMode: _isMapMode,
              searchController: _searchController,
              searchFocusNode: _searchFocusNode,
            ),

            // Category Tabs (only in list mode)
            if (!_isMapMode)
              CategoryTabs(
                categories: categories,
                selectedIndex: _selectedCategory,
                onCategorySelected: _handleCategoryChange,
                categoryCache: _categoryCache,
              ),

            // Map and Sheet Content
            Expanded(
              child: Stack(
                children: [
                  // Map Background
                  Positioned.fill(
                    child: Container(
                      color: Colors.grey[50],
                      child: PropertyMap(
                        selectedPropertyNotifier: selectedPropertyNotifier,
                        searchQueryNotifier: searchQueryNotifier,
                      ),
                    ),
                  ),

                  // Draggable Sheet
                  DraggableSheet(
                    sheetController: _sheetController,
                    isMapMode: _isMapMode,
                    showSearchBar: _showSearchBar,
                    onToggleSheet: _toggleSheet,
                    professionals: professionals,
                    selectedCategory: categories[_selectedCategory].name,
                    currentPropertiesStream: _currentPropertiesStream,
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
