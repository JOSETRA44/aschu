import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/constants/map_styles.dart';

class CustomMapView extends StatefulWidget {
  const CustomMapView({
    super.key,
    this.initialPosition = const LatLng(-14.1197, -72.2458),
    this.initialZoom = 14.0,
    this.markers = const {},
    this.onMapCreated,
    this.onCameraMove,
  });

  final LatLng initialPosition;
  final double initialZoom;
  final Set<Marker> markers;
  final void Function(GoogleMapController)? onMapCreated;
  final void Function(CameraPosition)? onCameraMove;

  @override
  State<CustomMapView> createState() => _CustomMapViewState();
}

class _CustomMapViewState extends State<CustomMapView> {
  GoogleMapController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;

    // Apply dark map style
    controller.setMapStyle(darkMapStyle);

    widget.onMapCreated?.call(controller);
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: widget.initialPosition,
        zoom: widget.initialZoom,
      ),
      onMapCreated: _onMapCreated,
      onCameraMove: widget.onCameraMove,
      markers: widget.markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: true,
      mapType: MapType.normal,
      style: darkMapStyle,
    );
  }
}
