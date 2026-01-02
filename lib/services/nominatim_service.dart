import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:house_rent_app/screens/home/components/location_suggestion.dart';

/// Service class for handling Nominatim API calls
class NominatimService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';
  static const String _userAgent = 'HouseRentApp/2.0 (pipeshare@gmail.com)';

  /// Search for location suggestions based on query
  static Future<List<Map<String, dynamic>>> search({
    required String query,
    String? countryCode,
    int limit = 10,
    bool includeAddressDetails = true,
  }) async {
    if (query.trim().length < 3) {
      return [];
    }

    print('Sending Nominatim search request for query: "$query"');

    try {
      final uri = Uri.parse('$_baseUrl/search').replace(
        queryParameters: {
          'q': query.trim(), // ✅ FIX: remove manual encoding
          'format': 'jsonv2',
          'addressdetails': includeAddressDetails ? '1' : '0',
          'limit': limit.toString(),
          if (countryCode != null && countryCode.isNotEmpty)
            'countrycodes': countryCode.toLowerCase(),
        },
      );

      print('Nominatim request URL: $uri');

      final client = HttpClient();
      final request = await client.getUrl(uri);

      _addRequiredHeaders(request);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      client.close();

      if (response.statusCode == HttpStatus.ok) {
        final List<dynamic> data = json.decode(responseBody) as List;
        return data.whereType<Map<String, dynamic>>().toList();
      }

      if (response.statusCode == HttpStatus.forbidden) {
        throw NominatimException(
          'Access forbidden. Please check User-Agent header and rate limits.',
          response.statusCode,
        );
      }

      if (response.statusCode == HttpStatus.tooManyRequests) {
        throw NominatimException(
          'Rate limit exceeded. Please wait before making more requests.',
          response.statusCode,
        );
      }

      throw NominatimException(
        'Failed to fetch suggestions: ${response.statusCode}',
        response.statusCode,
      );
    } on SocketException catch (e) {
      throw NominatimException('Network error: ${e.message}', 0);
    } on HttpException catch (e) {
      throw NominatimException('HTTP error: ${e.message}', 0);
    } on FormatException catch (e) {
      throw NominatimException('Invalid response format: ${e.message}', 0);
    } catch (e) {
      throw NominatimException('Unexpected error: $e', 0);
    }
  }

  /// Add required headers to Nominatim request
  static void _addRequiredHeaders(HttpClientRequest request) {
    request.headers.set(
      HttpHeaders.userAgentHeader,
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
      'AppleWebKit/537.36 (KHTML, like Gecko) '
      'Chrome/120.0.0.0 Safari/537.36',
    );

    request.headers.set(
      HttpHeaders.acceptHeader,
      'application/json,text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    );

    request.headers.set(
      HttpHeaders.acceptLanguageHeader,
      'en-US,en;q=0.9',
    );

    request.headers.set(
      HttpHeaders.connectionHeader,
      'keep-alive',
    );
  }
}

/// Custom exception for Nominatim API errors
class NominatimException implements Exception {
  final String message;
  final int statusCode;

  NominatimException(this.message, this.statusCode);

  @override
  String toString() => 'NominatimException($statusCode): $message';
}

/// Widget-level integration example
mixin LocationSearchMixin<T extends StatefulWidget> on State<T> {
  final ValueNotifier<bool> _isLoadingSuggestions = ValueNotifier(false);
  final ValueNotifier<List<Map<String, dynamic>>> _onlineSuggestions =
      ValueNotifier([]);
  DateTime? _lastRequestTime;

  /// Fetch location suggestions with rate limiting and error handling
  Future<void> fetchLocationSuggestions(String query) async {
    // Rate limiting: max 1 request per second
    final now = DateTime.now();
    if (_lastRequestTime != null) {
      final timeSinceLast = now.difference(_lastRequestTime!);
      if (timeSinceLast < const Duration(seconds: 1)) {
        await Future.delayed(const Duration(seconds: 1) - timeSinceLast);
      }
    }

    if (!mounted || query.trim().length < 3) {
      _onlineSuggestions.value = [];
      return;
    }

    _isLoadingSuggestions.value = true;
    _lastRequestTime = DateTime.now();

    try {
      final suggestions = await NominatimService.search(
        query: query,
        countryCode: 'zm', // Zambia
        limit: 10,
      );

      if (mounted) {
        _onlineSuggestions.value = suggestions;
        if (kDebugMode) {
          print('Fetched ${suggestions.length} suggestions for "$query"');
        }
      }
    } on NominatimException catch (e) {
      if (mounted) {
        _onlineSuggestions.value = [];
        if (kDebugMode) {
          print('Nominatim error: $e');
        }
        // Optionally show error to user
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Location search failed: ${e.message}')),
        // );
      }
    } catch (e) {
      if (mounted) {
        _onlineSuggestions.value = [];
        if (kDebugMode) {
          print('Unexpected error: $e');
        }
      }
    } finally {
      if (mounted) {
        _isLoadingSuggestions.value = false;
      }
    }
  }

  /// Clear suggestions
  void clearSuggestions() {
    _onlineSuggestions.value = [];
  }

  // Dispose method to call from widget's dispose()
  void disposeLocationSearch() {
    _isLoadingSuggestions.dispose();
    _onlineSuggestions.dispose();
  }

  // Getters for widget access
  ValueListenable<bool> get isLoadingSuggestions => _isLoadingSuggestions;
  ValueListenable<List<Map<String, dynamic>>> get onlineSuggestions =>
      _onlineSuggestions;
}

/// Example widget usage
class LocationSearchWidget extends StatefulWidget {
  const LocationSearchWidget({super.key});

  @override
  State<LocationSearchWidget> createState() => _LocationSearchWidgetState();
}

class _LocationSearchWidgetState extends State<LocationSearchWidget>
    with LocationSearchMixin {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    disposeLocationSearch();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // Debounce search to avoid too many API calls
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      fetchLocationSuggestions(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            labelText: 'Search location',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          onChanged: _onSearchChanged,
        ),
        const SizedBox(height: 16),
        ValueListenableBuilder<bool>(
          valueListenable: isLoadingSuggestions,
          builder: (context, isLoading, _) {
            if (isLoading) {
              return const CircularProgressIndicator();
            }
            return const SizedBox.shrink();
          },
        ),
        ValueListenableBuilder<List<Map<String, dynamic>>>(
          valueListenable: onlineSuggestions,
          builder: (context, suggestions, _) {
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = suggestions[index];
                return ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text(suggestion['name']),
                  subtitle: Text(suggestion['type']),
                  onTap: () {
                    _searchController.text = suggestion['name'];
                    // Handle location selection
                    _onLocationSelected(suggestion);
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }

  void _onLocationSelected(Map<String, dynamic> suggestion) {
    // Handle location selection
    if (kDebugMode) {
      print('Selected: ${suggestion['name']} at '
          '${suggestion['lat']}, ${suggestion['lon']}');
    }
    clearSuggestions();
  }
}
