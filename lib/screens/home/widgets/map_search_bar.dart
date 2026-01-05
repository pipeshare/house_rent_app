import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:house_rent_app/services/nominatim_service.dart';
import '../utils/home_helpers.dart';
import '../utils/home_constants.dart';

class MapSearchBar extends StatefulWidget {
  final Function(LatLng, String) onLocationSelected;
  final VoidCallback onCurrentLocationRequested;

  const MapSearchBar({
    super.key,
    required this.onLocationSelected,
    required this.onCurrentLocationRequested,
  });

  @override
  State<MapSearchBar> createState() => _MapSearchBarState();
}

class _MapSearchBarState extends State<MapSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ValueNotifier<List<Map<String, dynamic>>> _suggestionsNotifier =
      ValueNotifier([]);
  final ValueNotifier<bool> _showDropdownNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier(false);
  Timer? _searchDebounce;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_handleFocusChange);
    _searchController.addListener(_handleSearchText);
  }

  void _handleFocusChange() {
    final hasFocus = _searchFocusNode.hasFocus;
    if (_showDropdownNotifier.value != hasFocus) {
      _showDropdownNotifier.value = hasFocus;
    }
  }

  void _handleSearchText() {
    final value = _searchController.text;
    if (_searchQuery != value) {
      _searchQuery = value;
      _debounceSearch();
    }
  }

  void _debounceSearch() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(HomeConstants.debounceDuration, _performSearch);
  }

  Future<void> _performSearch() async {
    if (_searchQuery.isEmpty) {
      _suggestionsNotifier.value = [];
      return;
    }

    _isLoadingNotifier.value = true;

    try {
      final locations = await HomeHelpers.searchLocations(_searchQuery);
      _suggestionsNotifier.value = locations;
    } catch (e) {
      debugPrint('Search error: $e');
      _suggestionsNotifier.value = [];
    } finally {
      _isLoadingNotifier.value = false;
    }
  }

  void _clearSearch() {
    _searchController.clear();
    _searchQuery = '';
    _suggestionsNotifier.value = [];
    _searchFocusNode.requestFocus();
  }

  void _selectPopularLocation(String locationName) {
    final location = HomeConstants.popularLocations[locationName];
    if (location != null) {
      _searchController.text = locationName;
      widget.onLocationSelected(location, locationName);
      _hideDropdown();
    }
  }

  void _selectOnlineSuggestion(Map<String, dynamic> suggestion) {
    final lat = (suggestion['lat'] as num).toDouble();
    final lng = (suggestion['lng'] as num).toDouble();
    final location = LatLng(lat, lng);

    _searchController.text = suggestion['name'];
    widget.onLocationSelected(location, suggestion['name']);
    _hideDropdown();
  }

  void _hideDropdown() {
    _showDropdownNotifier.value = false;
    _searchFocusNode.unfocus();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _suggestionsNotifier.dispose();
    _showDropdownNotifier.dispose();
    _isLoadingNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Container(
          height: HomeConstants.searchBarHeight,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
              const Icon(Icons.search, color: Colors.grey, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: const InputDecoration(
                    hintText: 'Search area in Zambia...',
                    hintStyle: TextStyle(fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 14),
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
                onPressed: widget.onCurrentLocationRequested,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Search Dropdown
        ValueListenableBuilder<bool>(
          valueListenable: _showDropdownNotifier,
          builder: (context, showDropdown, _) {
            if (!showDropdown) return const SizedBox();
            return _buildDropdown();
          },
        ),
      ],
    );
  }

  Widget _buildDropdown() {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: MediaQuery.of(context).size.width - 40,
        constraints: const BoxConstraints(maxHeight: 300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ValueListenableBuilder<bool>(
          valueListenable: _isLoadingNotifier,
          builder: (context, isLoading, _) {
            if (isLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            return ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: _suggestionsNotifier,
              builder: (context, suggestions, _) {
                if (_searchQuery.isEmpty) {
                  return _buildPopularSuggestions();
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

                return _buildOnlineSuggestions(suggestions);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildPopularSuggestions() {
    return ListView(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      children: HomeConstants.popularLocations.entries.map((entry) {
        return ListTile(
          leading: Icon(
            Icons.place,
            color: Colors.blue,
            size: 20,
          ),
          title: Text(entry.key),
          subtitle: const Text('Zambia'),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          visualDensity: const VisualDensity(vertical: -2),
          onTap: () => _selectPopularLocation(entry.key),
        );
      }).toList(),
    );
  }

  Widget _buildOnlineSuggestions(List<Map<String, dynamic>> suggestions) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        final address = suggestion['address'] as Map<String, dynamic>? ?? {};

        return ListTile(
          leading: Icon(
            HomeHelpers.getSuggestionIcon(suggestion['type'] ?? ''),
            color: Colors.blue,
            size: 20,
          ),
          title: Text(
            HomeHelpers.formatDisplayName(suggestion['name'], address),
            style: const TextStyle(fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            HomeHelpers.formatAddress(address),
            style: const TextStyle(fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          visualDensity: const VisualDensity(vertical: -2),
          onTap: () => _selectOnlineSuggestion(suggestion),
        );
      },
    );
  }
}
