import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:house_rent_app/screens/home/property_card.dart';
import 'package:house_rent_app/screens/home/utils/home_helpers.dart';
import 'package:house_rent_app/screens/home/widgets/map_search_bar.dart';
import 'package:latlong2/latlong.dart';

class PropertyMap extends StatefulWidget {
  final ValueNotifier<Map<String, dynamic>?> selectedPropertyNotifier;
  final ValueNotifier<String> searchQueryNotifier;

  const PropertyMap({
    super.key,
    required this.selectedPropertyNotifier,
    required this.searchQueryNotifier,
  });

  @override
  State<PropertyMap> createState() => _PropertyMapState();
}

class _PropertyMapState extends State<PropertyMap> {
  final MapController _mapController = MapController();
  final Map<String, Widget> _markerCache = {};
  List<QueryDocumentSnapshot> _allProperties = [];

  Stream<QuerySnapshot> get _stream => FirebaseFirestore.instance
      .collection('posts')
      .where('latitude', isNotEqualTo: null)
      .where('longitude', isNotEqualTo: null)
      .snapshots();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
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
          return _buildErrorState();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }

        // Store all properties
        _allProperties = snapshot.data!.docs;

        return Stack(
          children: [
            // Map with markers
            FlutterMap(
              mapController: _mapController,
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

            // Map Search Bar
            Positioned(
              top: 40,
              left: 20,
              right: 20,
              child: MapSearchBar(
                onLocationSelected: _navigateToLocation,
                onCurrentLocationRequested: _moveToCurrentLocation,
              ),
            ),

            // Mini Property Card
            ValueListenableBuilder<Map<String, dynamic>?>(
              valueListenable: widget.selectedPropertyNotifier,
              builder: (context, property, _) {
                if (property == null) return const SizedBox.shrink();

                return Positioned(
                  bottom: 40,
                  left: 20,
                  right: 20,
                  child: PropertyCard(
                    property: property,
                    onClose: () => widget.selectedPropertyNotifier.value = null,
                    onTap: () {},
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildErrorState() {
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

  Widget _buildEmptyState() {
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

  LatLng _getInitialCenter(List<QueryDocumentSnapshot> properties) {
    return HomeHelpers.calculateMapCenter(properties);
  }

  List<Marker> _buildMarkers(List<QueryDocumentSnapshot> properties) {
    return properties
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

  Widget _buildPropertyMarker(String category, String price, String currency) {
    final key = '$category-$price-$currency';
    if (_markerCache.containsKey(key)) return _markerCache[key]!;

    final symbol = HomeHelpers.getCurrencySymbol(currency);
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

  Future<void> _moveToCurrentLocation() async {
    await HomeHelpers.moveToCurrentLocation(_mapController);
  }

  void _navigateToLocation(LatLng location, String name) {
    _mapController.move(location, 14.0);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigating to $name'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
