import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/vehicle_location.dart';
import '../bloc/map_bloc.dart';
import '../widgets/custom_map_view.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MapBloc>()..add(const InitializeMapEvent()),
      child: const _MapPageContent(),
    );
  }
}

class _MapPageContent extends StatelessWidget {
  const _MapPageContent();

  Set<Marker> _buildMarkers(List<VehicleLocation> vehicles) {
    return vehicles.map((vehicle) {
      return Marker(
        markerId: MarkerId(vehicle.vehicleId),
        position: LatLng(vehicle.latitude, vehicle.longitude),
        infoWindow: InfoWindow(
          title: vehicle.driverName ?? vehicle.vehicleId,
          snippet: vehicle.vehicleType ?? 'Vehicle',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        rotation: vehicle.heading ?? 0.0,
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Qawaqawa Logistics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<MapBloc>().add(const LoadVehicleLocationsEvent());
            },
          ),
        ],
      ),
      body: BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          if (state is MapLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is MapError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<MapBloc>().add(const InitializeMapEvent());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is MapLoaded) {
            return CustomMapView(
              markers: _buildMarkers(state.vehicles),
              onMapCreated: (controller) {
                // Map created callback
              },
              onCameraMove: (position) {
                // Camera move callback
              },
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          if (state is MapLoaded) {
            return FloatingActionButton(
              onPressed: () {
                context.read<MapBloc>().add(const LoadVehicleLocationsEvent());
              },
              child: const Icon(Icons.my_location),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
