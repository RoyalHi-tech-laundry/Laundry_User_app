import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:laun_easy/constants/colors/app_colors.dart';

class MapView extends StatefulWidget {
  final double latitude;
  final double longitude;
  final Function() onCenterLocation;
  final Function(double latitude, double longitude) onLocationChanged;

  const MapView({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.onCenterLocation,
    required this.onLocationChanged,
  });

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  GoogleMapController? _mapController;
  CameraPosition? _cameraPosition;
  
  @override
  void initState() {
    super.initState();
    _cameraPosition = CameraPosition(
      target: LatLng(widget.latitude, widget.longitude),
      zoom: 16.0,
    );
  }
  
  @override
  void didUpdateWidget(MapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update camera position when coordinates change
    if (oldWidget.latitude != widget.latitude || 
        oldWidget.longitude != widget.longitude) {
      _updateCameraPosition();
    }
  }
  
  void _updateCameraPosition() {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(widget.latitude, widget.longitude),
          18.0, // Higher zoom for precise location
        ),
      );
    }
  }
  
  void _onCameraMove(CameraPosition position) {
    _cameraPosition = position;
  }
  
  void _onCameraIdle() {
    if (_cameraPosition != null) {
      widget.onLocationChanged(
        _cameraPosition!.target.latitude,
        _cameraPosition!.target.longitude,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Google Maps widget
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(widget.latitude, widget.longitude),
            zoom: 16.0,
          ),
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: false,
          onMapCreated: (controller) {
            _mapController = controller;
          },
          onCameraMove: _onCameraMove,
          onCameraIdle: _onCameraIdle,
        ),
        
        // Center pin marker
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pin shadow
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(height: 4),
              // Pin marker
              Transform.translate(
                offset: const Offset(0, -30),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Recenter button
        Positioned(
          bottom: 16,
          right: 16,
          child: InkWell(
            onTap: () {
              widget.onCenterLocation();
              if (_mapController != null) {
                _mapController!.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: LatLng(widget.latitude, widget.longitude),
                      zoom: 16.0,
                      bearing: 0.0,
                      tilt: 0.0,
                    ),
                  ),
                );
              }
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.my_location,
                color: AppColors.primaryColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
