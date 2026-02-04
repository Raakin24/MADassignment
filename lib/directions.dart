import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class DirectionsPage extends StatefulWidget {
  const DirectionsPage({super.key});

  @override
  State<DirectionsPage> createState() => _DirectionsPageState();
}

class _DirectionsPageState extends State<DirectionsPage> {
  late GoogleMapController mapController;

  LatLng? _currentPosition;
  bool _isLoading = true;
  bool _mapCreated = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    Location location = Location();

    try {
      // For web, directly get location - browser will handle permission popup
      LocationData locationData = await location.getLocation();
      setState(() {
        _currentPosition = LatLng(locationData.latitude!, locationData.longitude!);
        _isLoading = false;
      });
      
      // Move camera to current position if map is already created
      if (_mapCreated && _currentPosition != null) {
        _moveCameraToPosition(_currentPosition!);
      }
    } catch (e) {
      // Error getting location - show map with default position
      setState(() {
        _currentPosition = null;
        _isLoading = false;
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _mapCreated = true;
    
    // If we already have a position, move camera to it
    if (_currentPosition != null) {
      _moveCameraToPosition(_currentPosition!);
    }
  }

  void _moveCameraToPosition(LatLng position) {
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: position,
          zoom: 15.0, // Closer zoom for better visibility
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar( 
          title: const Text('Directions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,)),
          backgroundColor: Colors.white,
          centerTitle: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Directions'),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _getCurrentLocation();
            },
          ),
        ],
      ),
      body: GoogleMap(
            onMapCreated: _onMapCreated,
            myLocationEnabled: _currentPosition != null,
            myLocationButtonEnabled: _currentPosition != null,
            initialCameraPosition: CameraPosition(
              target: _currentPosition ?? const LatLng(37.7749, -122.4194), // Default to San Francisco if no location
              zoom: _currentPosition != null ? 15.0 : 10.0,
            ),
            markers: _currentPosition != null ? {
              Marker(
                markerId: const MarkerId('current_location'),
                position: _currentPosition!,
                infoWindow: const InfoWindow(title: 'Your Location'),
              ),
            } : {},
            mapType: MapType.normal,
          ),
    );
  }
}