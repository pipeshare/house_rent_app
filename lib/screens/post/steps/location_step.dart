// screens/post/steps/location_step.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:house_rent_app/screens/post/components/hint.dart';
import 'package:house_rent_app/screens/post/steps/form_step.dart';

class LocationStep extends StatefulWidget {
  final TextEditingController locationNameCtrl;
  final LatLng? selectedLocation;
  final Function(LatLng, String)? onLocationSelected;

  const LocationStep({
    super.key,
    required this.locationNameCtrl,
    this.selectedLocation,
    this.onLocationSelected,
  });

  @override
  State<LocationStep> createState() => _LocationStepState();
}

class _LocationStepState extends State<LocationStep> {
  LatLng? _selectedLocation;
  bool _showMap = false;
  final TextEditingController _locationNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.selectedLocation;
    _locationNameController.text = widget.locationNameCtrl.text;
  }

  void _openMapPicker() {
    setState(() {
      _showMap = true;
    });
  }

  void _selectLocation(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });

    // Auto-generate a location name based on coordinates
    final locationName = _generateLocationName(location);
    _locationNameController.text = locationName;
    widget.locationNameCtrl.text = locationName;

    // Notify parent about location selection with both coordinates and name
    widget.onLocationSelected?.call(location, locationName);
  }

  String _generateLocationName(LatLng location) {
    // This is a simple example - in a real app, you'd use reverse geocoding
    // to get the actual address from coordinates
    const List<String> areas = [
      'Kabulonga',
      'Ibex Hill',
      'Avondale',
      'Woodlands',
      'Roma',
      'Longacres',
      'Northmead',
      'Libala',
      'Chilenje',
      'Chelstone',
      'Salama Park',
      'Central Business District',
      'Makeni',
      'Chamba Valley'
    ];

    // Pick a consistent area name based on coordinates
    final areaIndex = (location.latitude * 1000).round() % areas.length;
    final area = areas[areaIndex];

    return '$area, Lusaka';
  }

  void _confirmLocation() {
    setState(() {
      _showMap = false;
    });
  }

  void _cancelMapSelection() {
    setState(() {
      _showMap = false;
      if (widget.selectedLocation == null) {
        _selectedLocation = null;
        _locationNameController.clear();
        widget.locationNameCtrl.clear();
      }
    });
  }

  void _onLocationNameChanged(String value) {
    widget.locationNameCtrl.text = value;
  }

  @override
  Widget build(BuildContext context) {
    return FormStep(
      title: 'Property Location',
      subtitle: 'Select where your property is located',
      children: [
        // Location Name Input
        TextField(
          controller: _locationNameController,
          decoration: InputDecoration(
            labelText: 'Location Name',
            hintText: 'e.g., Salama Park, Lusaka',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.map_outlined),
              onPressed: _openMapPicker,
              tooltip: 'Pick location from map',
            ),
          ),
          onChanged: _onLocationNameChanged,
        ),

        const SizedBox(height: 12),

        // Coordinates Display
        if (_selectedLocation != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[100]!),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Location Selected',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[800],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${_selectedLocation!.latitude.toStringAsFixed(6)}, '
                        '${_selectedLocation!.longitude.toStringAsFixed(6)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),

        // Map Picker Button
        OutlinedButton.icon(
          onPressed: _openMapPicker,
          icon: const Icon(Icons.map),
          label: const Text('Select Location on Map'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.blue,
            side: const BorderSide(color: Colors.blue),
            minimumSize: const Size.fromHeight(48),
          ),
        ),

        const SizedBox(height: 16),
        const Hint(
          text:
              'Tip: Be specific with the location to help potential tenants find your property easily.',
        ),

        // Map Picker Modal
        if (_showMap) _buildMapPicker(),
      ],
    );
  }

  Widget _buildMapPicker() {
    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Map Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.map, color: Colors.blue, size: 24),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Select Property Location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: _cancelMapSelection,
                    ),
                  ],
                ),
              ),

              // Map
              SizedBox(
                height: 300,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter:
                        _selectedLocation ?? const LatLng(-15.3875, 28.3228),
                    initialZoom: 13,
                    onTap: (tapPosition, point) {
                      _selectLocation(point);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.house_rent_app',
                    ),

                    // Selected Location Marker
                    if (_selectedLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _selectedLocation!,
                            width: 50,
                            height: 50,
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 50,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // Map Controls
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedLocation != null
                          ? '📍 Location selected: ${_locationNameController.text}'
                          : 'Tap anywhere on the map to select location',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: _selectedLocation != null
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: _selectedLocation != null
                            ? Colors.green[700]
                            : Colors.grey[600],
                      ),
                      maxLines: 2,
                    ),
                    if (_selectedLocation != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Coordinates: ${_selectedLocation!.latitude.toStringAsFixed(6)}, '
                        '${_selectedLocation!.longitude.toStringAsFixed(6)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            _selectedLocation != null ? _confirmLocation : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Confirm Location',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Hint(
          text: 'Tap anywhere on the map to mark your property location. '
              'You can zoom and pan to find the exact spot.',
        ),
      ],
    );
  }
}
