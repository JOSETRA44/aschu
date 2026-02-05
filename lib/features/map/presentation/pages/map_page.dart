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

  /// Muestra diálogo para solicitar permisos de ubicación
  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Permiso de Ubicación'),
        content: const Text(
          'Qawaqawa Logistics necesita acceso a tu ubicación para mostrar '
          'vehículos en tiempo real y rutas optimizadas.\n\n'
          'Por favor, otorga los permisos de ubicación precisa.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // No hacer nada, quedarse en la pantalla esperando
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<MapBloc>().add(const RequestLocationPermissionEvent());
            },
            child: const Text('Permitir'),
          ),
        ],
      ),
    );
  }

  /// Muestra diálogo de error de permisos con opciones
  void _showPermissionErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Error de Permisos'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<MapBloc>().add(const RequestLocationPermissionEvent());
            },
            child: const Text('Intentar de nuevo'),
          ),
        ],
      ),
    );
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
            tooltip: 'Actualizar ubicaciones',
          ),
          IconButton(
            icon: const Icon(Icons.location_on),
            onPressed: () {
              context.read<MapBloc>().add(const RequestLocationPermissionEvent());
            },
            tooltip: 'Verificar permisos',
          ),
        ],
      ),
      body: BlocConsumer<MapBloc, MapState>(
        // Listener para efectos secundarios (diálogos, snackbars)
        listener: (context, state) {
          if (state is MapWaitingPermission) {
            _showPermissionDialog(context);
          } else if (state is MapError && state.isPermissionError) {
            _showPermissionErrorDialog(context, state.message);
          }
        },
        // Builder para UI
        builder: (context, state) {
          if (state is MapLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Inicializando mapa...',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          }

          if (state is MapWaitingPermission) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Permisos de ubicación requeridos',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Otorga permisos para continuar',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<MapBloc>().add(const RequestLocationPermissionEvent());
                    },
                    icon: const Icon(Icons.location_on),
                    label: const Text('Otorgar permisos'),
                  ),
                ],
              ),
            );
          }

          if (state is MapError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      state.isPermissionError ? Icons.location_off : Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.isPermissionError
                          ? 'Error de Permisos'
                          : 'Error al cargar mapa',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (state.isPermissionError) {
                          context.read<MapBloc>().add(const RequestLocationPermissionEvent());
                        } else {
                          context.read<MapBloc>().add(const InitializeMapEvent());
                        }
                      },
                      icon: Icon(state.isPermissionError ? Icons.location_on : Icons.refresh),
                      label: Text(state.isPermissionError ? 'Otorgar permisos' : 'Reintentar'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is MapLoaded) {
            return CustomMapView(
              markers: _buildMarkers(state.vehicles),
              onMapCreated: (controller) {
                // Registrar controller en el BLoC para control de cámara
                context.read<MapBloc>().setMapController(controller);
              },
              onCameraMove: (position) {
                // Notificar al BLoC sobre movimiento de cámara
                context.read<MapBloc>().add(CameraMovedEvent(position));
              },
              onCameraIdle: (position) {
                // Notificar al BLoC cuando la cámara termina de moverse
                context.read<MapBloc>().add(CameraIdleEvent(position));
              },
              myLocationEnabled: state.hasLocationPermission,
              myLocationButtonEnabled: state.hasLocationPermission,
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Cargando...',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          if (state is MapLoaded && state.vehicles.isNotEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Botón para centrar en mi ubicación
                if (state.hasLocationPermission)
                  FloatingActionButton(
                    heroTag: 'my_location',
                    mini: true,
                    onPressed: () {
                      // TODO: Implementar centrado en ubicación del usuario
                      context.read<MapBloc>().add(const LoadVehicleLocationsEvent());
                    },
                    tooltip: 'Mi ubicación',
                    child: const Icon(Icons.my_location),
                  ),
                const SizedBox(height: 12),
                // Botón para actualizar vehículos
                FloatingActionButton(
                  heroTag: 'refresh',
                  onPressed: () {
                    context.read<MapBloc>().add(const LoadVehicleLocationsEvent());
                  },
                  tooltip: 'Actualizar vehículos',
                  child: const Icon(Icons.directions_car),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
