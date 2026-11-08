import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/app_logger.dart';

class GeoResult {
  final String area;
  final String city;
  final double latitude;
  final double longitude;
  final String displayName;

  const GeoResult({
    required this.area,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.displayName,
  });
}

/// Free OpenStreetMap & Nominatim Geocoding Service (Zero API Keys required)
class FreeGeocodingService {
  static const String _userAgent = 'XYZHyperlocalFashion/1.0 (support@marsfashion.in)';

  /// Reverse geocode GPS coordinates to human-readable area name (e.g., "Nana Chiloda", "Ahmedabad")
  static Future<GeoResult> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&zoom=18&addressdetails=1',
      );

      final response = await http
          .get(uri, headers: {'User-Agent': _userAgent})
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>? ?? {};

        // Extract most specific locality
        final area = address['suburb'] ??
            address['neighbourhood'] ??
            address['village'] ??
            address['residential'] ??
            address['quarter'] ??
            address['commercial'] ??
            address['road'] ??
            address['city_district'] ??
            address['county'] ??
            _fallbackByCoordinates(latitude, longitude).area;

        final city = address['city'] ??
            address['town'] ??
            address['municipality'] ??
            address['state_district'] ??
            _fallbackByCoordinates(latitude, longitude).city;

        return GeoResult(
          area: area.toString(),
          city: city.toString(),
          latitude: latitude,
          longitude: longitude,
          displayName: data['display_name'] ?? '$area, $city',
        );
      }
    } catch (e) {
      AppLogger.warning('FreeGeocodingService.reverseGeocode', e.toString());
    }

    // High accuracy fallback based on coordinate bounds if network/OSM times out
    return _fallbackByCoordinates(latitude, longitude);
  }

  /// Search for an area by name (e.g., "Nana Chiloda", "Nikol", "Bopal")
  static Future<List<GeoResult>> searchPlaces(String query) async {
    if (query.trim().isEmpty) return [];

    final List<GeoResult> results = [];

    // 1. Check quick local dictionary first
    final lower = query.toLowerCase().trim();
    for (final preset in _localPresets) {
      if (preset.area.toLowerCase().contains(lower) ||
          preset.displayName.toLowerCase().contains(lower)) {
        results.add(preset);
      }
    }

    // 2. Fetch live suggestions from Nominatim
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent('$query, Ahmedabad, Gujarat')}&format=json&addressdetails=1&countrycodes=in&limit=5',
      );

      final response = await http
          .get(uri, headers: {'User-Agent': _userAgent})
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List<dynamic>;
        for (final item in list) {
          final data = item as Map<String, dynamic>;
          final addr = data['address'] as Map<String, dynamic>? ?? {};
          final lat = double.tryParse(data['lat']?.toString() ?? '') ?? 0.0;
          final lon = double.tryParse(data['lon']?.toString() ?? '') ?? 0.0;

          final area = addr['suburb'] ??
              addr['neighbourhood'] ??
              addr['village'] ??
              addr['residential'] ??
              addr['road'] ??
              data['name'] ??
              query;

          final city = addr['city'] ??
              addr['town'] ??
              addr['state_district'] ??
              'Ahmedabad';

          // Avoid duplicates
          if (!results.any((r) => r.area.toLowerCase() == area.toString().toLowerCase())) {
            results.add(GeoResult(
              area: area.toString(),
              city: city.toString(),
              latitude: lat,
              longitude: lon,
              displayName: data['display_name'] ?? '$area, $city',
            ));
          }
        }
      }
    } catch (_) {}

    return results;
  }

  static GeoResult _fallbackByCoordinates(double lat, double lng) {
    // Nana Chiloda / Naroda East Cluster
    if (lat >= 23.08 && lat <= 23.14 && lng >= 22.64 && lng <= 72.69) {
      return GeoResult(
        area: 'Nana Chiloda',
        city: 'Ahmedabad',
        latitude: lat,
        longitude: lng,
        displayName: 'Nana Chiloda, Ahmedabad, Gujarat',
      );
    }
    // Kubernagar / Sardarnagar Cluster
    if (lat >= 23.06 && lat <= 23.085 && lng >= 72.61 && lng <= 72.65) {
      return GeoResult(
        area: 'Kubernagar',
        city: 'Ahmedabad',
        latitude: lat,
        longitude: lng,
        displayName: 'Kubernagar, Ahmedabad, Gujarat',
      );
    }
    // Nikol / Odhav Cluster
    if (lat >= 23.03 && lat <= 23.06 && lng >= 72.65 && lng <= 72.70) {
      return GeoResult(
        area: 'Nikol',
        city: 'Ahmedabad',
        latitude: lat,
        longitude: lng,
        displayName: 'Nikol, Ahmedabad, Gujarat',
      );
    }
    // Gandhinagar Cluster
    if (lat >= 23.18 && lat <= 23.27 && lng >= 72.60 && lng <= 72.68) {
      return GeoResult(
        area: 'Gandhinagar',
        city: 'Gandhinagar',
        latitude: lat,
        longitude: lng,
        displayName: 'Gandhinagar, Gujarat',
      );
    }
    // Ghuma / Bopal West Cluster
    if (lat >= 23.01 && lat <= 23.05 && lng >= 72.44 && lng <= 72.49) {
      return GeoResult(
        area: 'Ghuma',
        city: 'Ahmedabad',
        latitude: lat,
        longitude: lng,
        displayName: 'Ghuma, Bopal, Ahmedabad, Gujarat',
      );
    }
    // Sindhu Bhavan Road / Bodakdev West Cluster
    if (lat >= 23.025 && lat <= 23.065 && lng >= 72.495 && lng <= 72.535) {
      return GeoResult(
        area: 'Sindhu Bhavan Road',
        city: 'Ahmedabad',
        latitude: lat,
        longitude: lng,
        displayName: 'Sindhu Bhavan Road (SBR), Bodakdev, Ahmedabad West',
      );
    }

    return GeoResult(
      area: 'Ahmedabad East',
      city: 'Ahmedabad',
      latitude: lat,
      longitude: lng,
      displayName: 'Ahmedabad, Gujarat',
    );
  }

  static const List<GeoResult> _localPresets = [
    GeoResult(
      area: 'Nana Chiloda',
      city: 'Ahmedabad',
      latitude: 23.1090,
      longitude: 72.6640,
      displayName: 'Nana Chiloda, Naroda-Chiloda Road, Ahmedabad',
    ),
    GeoResult(
      area: 'Kubernagar',
      city: 'Ahmedabad',
      latitude: 23.0768,
      longitude: 72.6346,
      displayName: 'Kubernagar Main Cloth Market, Ahmedabad',
    ),
    GeoResult(
      area: 'Nikol',
      city: 'Ahmedabad',
      latitude: 23.0485,
      longitude: 72.6738,
      displayName: 'Nikol, Ahmedabad East',
    ),
    GeoResult(
      area: 'Naroda',
      city: 'Ahmedabad',
      latitude: 23.0722,
      longitude: 72.6558,
      displayName: 'Naroda, Ahmedabad',
    ),
    GeoResult(
      area: 'Gandhinagar',
      city: 'Gandhinagar',
      latitude: 23.2156,
      longitude: 72.6369,
      displayName: 'Gandhinagar City Center & Sectors',
    ),
    GeoResult(
      area: 'Ghuma / Bopal',
      city: 'Ahmedabad',
      latitude: 23.0330,
      longitude: 72.4646,
      displayName: 'Ghuma, South Bopal, Ahmedabad West',
    ),
    GeoResult(
      area: 'C.G. Road',
      city: 'Ahmedabad',
      latitude: 23.0373,
      longitude: 72.5562,
      displayName: 'C.G. Road, Navrangpura, Ahmedabad Central',
    ),
    GeoResult(
      area: 'Sindhu Bhavan Road',
      city: 'Ahmedabad',
      latitude: 23.0402,
      longitude: 72.5028,
      displayName: 'Sindhu Bhavan Road (SBR), Bodakdev, Ahmedabad West',
    ),
    GeoResult(
      area: 'SG Highway / Bodakdev',
      city: 'Ahmedabad',
      latitude: 23.0450,
      longitude: 72.5180,
      displayName: 'SG Highway, Bodakdev, Ahmedabad West',
    ),
    GeoResult(
      area: 'Prahlad Nagar',
      city: 'Ahmedabad',
      latitude: 23.0125,
      longitude: 72.5100,
      displayName: 'Prahlad Nagar, Anandnagar, Ahmedabad West',
    ),
  ];
}
