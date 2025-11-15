// Extracted Location & Price Step - Simplified Version
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:house_rent_app/screens/post/components/hint.dart';
import 'package:house_rent_app/screens/post/steps/form_step.dart';

class LocationPriceStep extends StatefulWidget {
  final TextEditingController locationCtrl;
  final TextEditingController priceCtrl;
  final LatLng? selectedLocation;
  final Function(LatLng)? onLocationSelected;

  const LocationPriceStep({
    super.key,
    required this.locationCtrl,
    required this.priceCtrl,
    this.selectedLocation,
    this.onLocationSelected,
  });

  @override
  State<LocationPriceStep> createState() => _LocationPriceStepState();
}

class _LocationPriceStepState extends State<LocationPriceStep> {
  LatLng? _selectedLocation;
  bool _showMap = false;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.selectedLocation;
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

    // Update the location text field with coordinates
    widget.locationCtrl.text =
    "${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}";

    // Notify parent about location selection
    widget.onLocationSelected?.call(location);
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
        widget.locationCtrl.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FormStep(
      title: 'Location & Price',
      children: [
        // Location Input with Map Picker
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: widget.locationCtrl,
              decoration: InputDecoration(
                labelText: 'Location',
                hintText: 'e.g., Salama Park, Lusaka',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.map_outlined),
                  onPressed: _openMapPicker,
                  tooltip: 'Pick location from map',
                ),
              ),
              readOnly: true,
              onTap: _openMapPicker,
            ),
            if (_selectedLocation != null) ...[
              const SizedBox(height: 8),
              Text(
                'Selected: ${_selectedLocation!.latitude.toStringAsFixed(4)}, '
                    '${_selectedLocation!.longitude.toStringAsFixed(4)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 16),

        // Price Input
        TextField(
          controller: widget.priceCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Monthly Price',
            hintText: 'e.g., 9,500',
            border: OutlineInputBorder(),
            prefixText: 'ZMW ',
          ),
        ),

        const SizedBox(height: 12),
        const Hint(text: 'Tip: Add a fair price to increase visibility.'),

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
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              // Map Header
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.map, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Select Property Location',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: _cancelMapSelection,
                    ),
                  ],
                ),
              ),

              // Map (without MapController)
              SizedBox(
                height: 300,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: _selectedLocation ?? const LatLng(-15.3875, 28.3228),
                    initialZoom: 13,
                    onTap: (tapPosition, point) {
                      _selectLocation(point);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.house_rent_app',
                    ),

                    // Selected Location Marker
                    if (_selectedLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _selectedLocation!,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // Map Controls
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedLocation != null
                            ? 'Location selected: ${_selectedLocation!.latitude.toStringAsFixed(4)}, '
                            '${_selectedLocation!.longitude.toStringAsFixed(4)}'
                            : 'Tap on the map to select location',
                        style: TextStyle(
                          fontSize: 12,
                          color: _selectedLocation != null
                              ? Colors.green[700]
                              : Colors.grey[600],
                        ),
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _selectedLocation != null ? _confirmLocation : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Confirm'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),
        const Hint(
          text: 'Tap anywhere on the map to mark your property location. '
              'You can zoom and pan to find the exact spot.',
        ),
      ],
    );
  }
}