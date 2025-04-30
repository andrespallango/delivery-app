// lib/services/location_service.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:delivery_app/config/api_keys.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LocationService {
  // Get current location
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever
      return null;
    }

    // When we reach here, permissions are granted and we can get the location
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  // Get address from coordinates
  Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}';
      }
      return null;
    } catch (e) {
      debugPrint('Error getting address: $e');
      return null;
    }
  }

  // Get coordinates from address
  Future<LatLng?> getCoordinatesFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLng(locations.first.latitude, locations.first.longitude);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting coordinates: $e');
      return null;
    }
  }

  // Calculate distance between two coordinates in kilometers
  double calculateDistance(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) {
    return Geolocator.distanceBetween(
        startLatitude,
        startLongitude,
        endLatitude,
        endLongitude
    ) / 1000; // Convert meters to kilometers
  }

  // Get directions between two points
  Future<Map<String, dynamic>?> getDirections(
      double startLat,
      double startLng,
      double endLat,
      double endLng
      ) async {
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=$startLat,$startLng'
        '&destination=$endLat,$endLng'
        '&key=${ApiKeys.googleMapsApiKey}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting directions: $e');
      return null;
    }
  }

  // Calculate estimated time of arrival
  Future<String?> getEstimatedTimeOfArrival(
      double startLat,
      double startLng,
      double endLat,
      double endLng
      ) async {
    try {
      final directions = await getDirections(startLat, startLng, endLat, endLng);

      if (directions != null &&
          directions['routes'] != null &&
          directions['routes'].isNotEmpty) {

        final route = directions['routes'][0];
        final leg = route['legs'][0];
        final duration = leg['duration']['text'];

        return duration;
      }
      return null;
    } catch (e) {
      debugPrint('Error calculating ETA: $e');
      return null;
    }
  }
}