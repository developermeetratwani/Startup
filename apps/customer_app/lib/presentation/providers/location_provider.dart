import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:core/core.dart';

class LocationState {
  final double latitude;
  final double longitude;
  final String areaName;
  final String cityName;
  final bool isLoading;
  final String? error;
  final bool permissionDeniedForever;

  const LocationState({
    required this.latitude,
    required this.longitude,
    required this.areaName,
    required this.cityName,
    this.isLoading = false,
    this.error,
    this.permissionDeniedForever = false,
  });

  LocationState copyWith({
    double? latitude,
    double? longitude,
    String? areaName,
    String? cityName,
    bool? isLoading,
    String? error,
    bool? permissionDeniedForever,
  }) {
    return LocationState(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      areaName: areaName ?? this.areaName,
      cityName: cityName ?? this.cityName,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      permissionDeniedForever: permissionDeniedForever ?? this.permissionDeniedForever,
    );
  }
}

class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier()
      : super(const LocationState(
          latitude: 23.0768,
          longitude: 72.6346,
          areaName: 'Kubernagar',
          cityName: 'Ahmedabad',
        )) {
    _autoDetectIfPermitted();
  }

  Future<void> _autoDetectIfPermitted() async {
    if (kIsWeb) return;
    try {
      final status = await Permission.location.status;
      if (status.isGranted) {
        await detectCurrentLocation(showRationale: false);
      }
    } catch (_) {}
  }

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
      isLoading: false,
      error: null,
    );
  }

  Future<void> detectCurrentLocation({bool showRationale = true}) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled && !kIsWeb) {
        state = state.copyWith(
          isLoading: false,
          error: 'GPS is turned off on your device. Please enable it in Settings.',
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        state = state.copyWith(
          isLoading: false,
          error: 'Location permission denied. Tap to allow and try again.',
        );
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(
          isLoading: false,
          permissionDeniedForever: true,
          error: 'Location permission permanently blocked. Open app settings to allow it.',
        );
        if (!kIsWeb) await openAppSettings();
        return;
      }

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
            timeLimit: Duration(seconds: 10),
          ),
        );
      } catch (_) {
        if (!kIsWeb) {
          position = await Geolocator.getLastKnownPosition();
        }
      }

      // Fallback coordinate default if browser/GPS timeout
      final lat = position?.latitude ?? 23.1090; // Nana Chiloda area by default if emulated
      final lng = position?.longitude ?? 72.6640;

      // Reverse geocode via Free OpenStreetMap Nominatim + locality resolver
      final geo = await FreeGeocodingService.reverseGeocode(
        latitude: lat,
        longitude: lng,
      );

      AppLogger.info(
        'LocationNotifier',
        'GPS fix: $lat,$lng → ${geo.area}, ${geo.city}',
      );

      state = state.copyWith(
        latitude: lat,
        longitude: lng,
        areaName: geo.area,
        cityName: geo.city,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      AppLogger.error('LocationNotifier.detectCurrentLocation', e.toString());
      state = state.copyWith(
        isLoading: false,
        error: 'Location error. Please try again.',
      );
    }
  }
}

final locationProvider =
    StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier();
});
