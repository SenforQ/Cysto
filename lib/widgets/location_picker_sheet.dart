import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

const Color _kThemeColor = Color(0xFF00C5E8);

Future<String?> _reverseGeocodeNominatim(double lat, double lng) async {
  final uri = Uri.parse(
    'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lng&format=json',
  );
  final response = await http.get(
    uri,
    headers: {'User-Agent': 'Cysto/1.0'},
  );
  if (response.statusCode != 200) return null;
  try {
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final address = json['address'] as Map<String, dynamic>?;
    if (address == null) return json['display_name'] as String?;
    final city = address['city'] ?? address['town'] ?? address['village'] ?? address['municipality'];
    final state = address['state'] ?? address['province'];
    final country = address['country'];
    final parts = <String>[];
    if (city != null && city.toString().isNotEmpty) parts.add(city.toString());
    if (state != null && state.toString().isNotEmpty) {
      if (parts.isEmpty || parts.last != state.toString()) {
        parts.add(state.toString());
      }
    }
    if (country != null && country.toString().isNotEmpty) {
      if (parts.isEmpty || parts.last != country.toString()) {
        parts.add(country.toString());
      }
    }
    return parts.isEmpty ? json['display_name'] as String? : parts.join(', ');
  } catch (_) {
    return null;
  }
}

String _formatPlacemark(Placemark p) {
  final parts = <String>[];
  if (p.locality != null && p.locality!.isNotEmpty) parts.add(p.locality!);
  if (p.administrativeArea != null && p.administrativeArea!.isNotEmpty) {
    if (parts.isEmpty || parts.last != p.administrativeArea) {
      parts.add(p.administrativeArea!);
    }
  }
  if (p.country != null && p.country!.isNotEmpty) {
    if (parts.isEmpty || parts.last != p.country) {
      parts.add(p.country!);
    }
  }
  return parts.isEmpty ? (p.name ?? 'Unknown') : parts.join(', ');
}

class LocationPickerSheet extends StatefulWidget {
  const LocationPickerSheet({super.key});

  @override
  State<LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<LocationPickerSheet> {
  final _searchController = TextEditingController();
  List<Placemark> _results = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled && mounted) {
        setState(() {
          _errorMessage = 'Please enable location services';
          _isLoading = false;
        });
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever && mounted) {
        setState(() {
          _errorMessage = 'Please allow app to access location';
          _isLoading = false;
        });
        return;
      }
      if (permission == LocationPermission.denied && mounted) {
        setState(() {
          _errorMessage = 'Location permission required to get current location';
          _isLoading = false;
        });
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks = [];
      try {
        placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
      } catch (_) {}
      if (placemarks.isNotEmpty && mounted) {
        final address = _formatPlacemark(placemarks.first);
        Navigator.of(context).pop(address);
      } else {
        final fallback =
            await _reverseGeocodeNominatim(position.latitude, position.longitude);
        if (fallback != null && fallback.isNotEmpty && mounted) {
          Navigator.of(context).pop(fallback);
        } else if (mounted) {
          setState(() {
            _errorMessage = 'Could not parse address, enter place name in search box above';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().contains('NOT_FOUND') ||
                  e.toString().contains('Could not find')
              ? 'Could not parse address, try searching or enter manually'
              : 'Failed to get location, check network or try searching';
          _isLoading = false;
        });
      }
      return;
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _searchLocation(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      setState(() {
        _results = [];
        _errorMessage = null;
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final locations = await locationFromAddress(q);
      if (locations.isEmpty && mounted) {
        setState(() {
          _results = [];
          _errorMessage = 'No locations found';
          _isLoading = false;
        });
        return;
      }
      final loc = locations.first;
      List<Placemark> placemarks = [];
      try {
        placemarks = await placemarkFromCoordinates(loc.latitude, loc.longitude);
      } catch (_) {}
      if (placemarks.isEmpty) {
        placemarks = [
          Placemark(
            name: q,
            street: null,
            locality: q,
            administrativeArea: null,
            subAdministrativeArea: null,
            country: null,
            subThoroughfare: null,
            thoroughfare: null,
            subLocality: null,
            isoCountryCode: null,
            postalCode: null,
          ),
        ];
      }
      if (mounted) {
        setState(() {
          _results = placemarks;
          _errorMessage = null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _results = [];
          _errorMessage = 'Search failed. Check network and try again';
          _isLoading = false;
        });
      }
    }
  }

  void _selectPlacemark(Placemark p) {
    Navigator.of(context).pop(_formatPlacemark(p));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.location_on, color: _kThemeColor, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Location',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search location (city, address, etc.)',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: _searchLocation,
              textInputAction: TextInputAction.search,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isLoading ? null : _getCurrentLocation,
                icon: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.my_location),
                label: Text(_isLoading ? 'Getting...' : 'Get current location'),
                style: FilledButton.styleFrom(
                  backgroundColor: _kThemeColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _errorMessage!,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.red.shade700,
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Expanded(
            child: _results.isEmpty
                ? Center(
                    child: Text(
                      _isLoading ? 'Searching...' : 'Search by keyword or tap to get current location',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _results.length,
                    itemBuilder: (context, index) {
                      final p = _results[index];
                      return ListTile(
                        leading: Icon(
                          Icons.place,
                          color: _kThemeColor,
                          size: 22,
                        ),
                        title: Text(_formatPlacemark(p)),
                        subtitle: p.street != null && p.street!.isNotEmpty
                            ? Text(
                                p.street!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              )
                            : null,
                        onTap: () => _selectPlacemark(p),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
