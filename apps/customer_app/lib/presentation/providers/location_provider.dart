import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:core/core.dart';

class LocationState {
  final double latitude;
  final double longitude;
  final String areaName;
  final String cityName;
  final bool isLoading;
  final String? error;

  const LocationState({
    required this.latitude,
    required this.longitude,
    required this.areaName,
    required this.cityName,
    this.isLoading = false,
    this.error,
  });

  LocationState copyWith({
    double? latitude,
    double? longitude,
    String? areaName,
    String? cityName,
    bool? isLoading,
    String? error,
  }) {
    return LocationState(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      areaName: areaName ?? this.areaName,
      cityName: cityName ?? this.cityName,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier()
      : super(const LocationState(
          // Default initial location: Kubernagar, Ahmedabad
          latitude: 23.0768,
          longitude: 72.6346,
          areaName: 'Kubernagar',
          cityName: 'Ahmedabad',
        ));

  void setPresetLocation({
    required String area,
    required String city,
    required double lat,
    required double lng,
  }) {
    state = state.copyWith(
      areaName: area,
      cityName: city,
      latitude: lat,
      longitude: lng,
      error: null,
    );
  }

  Future<void> detectCurrentLocation() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(
          isLoading: false,
          error: 'Location services are disabled.',
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = state.copyWith(
            isLoading: false,
            error: 'Location permissions are denied.',
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(
          isLoading: false,
          error: 'Location permissions are permanently denied.',
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      state = state.copyWith(
        latitude: position.latitude,
        longitude: position.longitude,
        areaName: 'Current Location',
        cityName: 'Nearby',
        isLoading: false,
      );
    } catch (e) {
      AppLogger.error('detectCurrentLocation', e.toString());
      state = state.copyWith(
        isLoading: false,
        error: 'Could not fetch location.',
      );
    }
  }
}

final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier();
});
