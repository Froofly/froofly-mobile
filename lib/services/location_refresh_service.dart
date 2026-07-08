import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

class LocationRefreshService {
  static final LocationRefreshService _instance = LocationRefreshService._internal();
  factory LocationRefreshService() => _instance;
  LocationRefreshService._internal();

  Timer? _refreshTimer;
  
  // Starts refreshing location every 5 minutes while app is in foreground
  void startForegroundRefresh() {
    if (_refreshTimer != null && _refreshTimer!.isActive) {
      return;
    }
    
    // Initial fetch
    _fetchAndSendLocation();
    
    // Periodic fetch
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _fetchAndSendLocation();
    });
  }
  
  void stopRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  Future<void> _fetchAndSendLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return; // Need permissions first
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      if (kDebugMode) {
        print('Foreground Location Refresh: ${position.latitude}, ${position.longitude}');
      }
      
      // TODO: Send position to Supabase or Backend API
      // e.g., Supabase.instance.client.from('locations').insert(...)
      
    } catch (e) {
      if (kDebugMode) {
        print('Error refreshing location: $e');
      }
    }
  }
}
