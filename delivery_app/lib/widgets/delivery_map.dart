// lib/widgets/delivery_map.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:delivery_app/config/api_keys.dart';
import 'package:delivery_app/config/app_theme.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';

class DeliveryMap extends StatefulWidget {
  final double deliveryLatitude;
  final double deliveryLongitude;
  final String clientAddress;

  const DeliveryMap({
    super.key,
    required this.deliveryLatitude,
    required this.deliveryLongitude,
    required this.clientAddress,
  });

  @override
  State<DeliveryMap> createState() => _DeliveryMapState();
}

class _DeliveryMapState extends State<DeliveryMap> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  bool _isLoading = true;
  LatLng? _destinationLatLng;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      // Get destination coordinates from address
      final locations = await locationFromAddress(widget.clientAddress);
      if (locations.isNotEmpty) {
        _destinationLatLng = LatLng(
          locations.first.latitude,
          locations.first.longitude,
        );
      }
    } catch (e) {
      // If geocoding fails, use a default location near the delivery
      _destinationLatLng = LatLng(
        widget.deliveryLatitude + 0.01,
        widget.deliveryLongitude + 0.01,
      );
    }

    // Create markers
    _markers = {
      Marker(
        markerId: const MarkerId('delivery'),
        position: LatLng(widget.deliveryLatitude, widget.deliveryLongitude),
        infoWindow: const InfoWindow(title: 'Current Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
      if (_destinationLatLng != null)
        Marker(
          markerId: const MarkerId('destination'),
          position: _destinationLatLng!,
          infoWindow: const InfoWindow(title: 'Destination'),
        ),
    };

    // Create polyline if we have both points
    if (_destinationLatLng != null) {
      await _getPolyline();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _getPolyline() async {
    try {
      PolylinePoints polylinePoints = PolylinePoints();

      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(
            widget.deliveryLatitude,
            widget.deliveryLongitude,
          ),
          destination: PointLatLng(
            _destinationLatLng!.latitude,
            _destinationLatLng!.longitude,
          ),
          mode: TravelMode.driving,
        ),
      );

      List<LatLng> polylineCoordinates = [];
      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
      }

      setState(() {
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            color: AppTheme.primaryColor,
            points: polylineCoordinates,
            width: 5,
          ),
        );
      });
    } catch (e) {
      print('Error al obtener la ruta: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(widget.deliveryLatitude, widget.deliveryLongitude),
        zoom: 14,
      ),
      markers: _markers,
      polylines: _polylines,
      mapType: MapType.normal,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: true,
      onMapCreated: (controller) {
        _mapController = controller;
      },
    );
  }
}