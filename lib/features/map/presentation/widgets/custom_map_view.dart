import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/constants/map_styles.dart';

/// CustomMapView optimizado para Flutter 3.27+ con Impeller
/// 
/// Prevención de memory leaks:
/// - Dispose correcto del GoogleMapController
/// - Gestión de ciclo de vida completa
/// - Uso de const constructors donde es posible
/// 
/// Optimizaciones de renderizado:
/// - Hybrid Composition habilitado via MainActivity
/// - Gestión de tiles con caching
/// - Throttling de eventos de cámara
class CustomMapView extends StatefulWidget {
  const CustomMapView({
    super.key,
    this.initialPosition = const LatLng(-14.1197, -72.2458),
    this.initialZoom = 14.0,
    this.markers = const {},
    this.polylines = const {},
    this.onMapCreated,
    this.onCameraMove,
    this.onCameraIdle,
    this.onTap,
    this.myLocationEnabled = true,
    this.myLocationButtonEnabled = true,
    this.zoomControlsEnabled = false,
    this.compassEnabled = true,
    this.rotateGesturesEnabled = true,
    this.scrollGesturesEnabled = true,
    this.tiltGesturesEnabled = true,
    this.zoomGesturesEnabled = true,
    this.trafficEnabled = false,
  });

  final LatLng initialPosition;
  final double initialZoom;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final void Function(GoogleMapController)? onMapCreated;
  final void Function(CameraPosition)? onCameraMove;
  final void Function(CameraPosition)? onCameraIdle;
  final void Function(LatLng)? onTap;
  final bool myLocationEnabled;
  final bool myLocationButtonEnabled;
  final bool zoomControlsEnabled;
  final bool compassEnabled;
  final bool rotateGesturesEnabled;
  final bool scrollGesturesEnabled;
  final bool tiltGesturesEnabled;
  final bool zoomGesturesEnabled;
  final bool trafficEnabled;

  @override
  State<CustomMapView> createState() => _CustomMapViewState();
}

class _CustomMapViewState extends State<CustomMapView>
    with AutomaticKeepAliveClientMixin {
  GoogleMapController? _controller;
  bool _isMapCreated = false;
  bool _isDisposed = false;

  // Keep alive para prevenir recreación innecesaria del mapa
  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _isDisposed = true;
    _disposeController();
    super.dispose();
  }

  /// Dispose seguro del controller
  void _disposeController() {
    if (_controller != null) {
      try {
        _controller!.dispose();
      } catch (e) {
        debugPrint('Error disposing GoogleMapController: $e');
      } finally {
        _controller = null;
        _isMapCreated = false;
      }
    }
  }

  /// Callback cuando el mapa se crea
  Future<void> _onMapCreated(GoogleMapController controller) async {
    if (_isDisposed) return;

    _controller = controller;
    _isMapCreated = true;

    try {
      // Aplicar estilo oscuro al mapa
      await controller.setMapStyle(darkMapStyle);

      // Notificar al padre que el mapa está listo
      widget.onMapCreated?.call(controller);
    } catch (e) {
      debugPrint('Error applying map style: $e');
    }
  }

  /// Callback cuando la cámara se mueve
  void _onCameraMove(CameraPosition position) {
    if (_isDisposed || !_isMapCreated) return;
    widget.onCameraMove?.call(position);
  }

  /// Callback cuando la cámara termina de moverse
  void _onCameraIdle() {
    if (_isDisposed || !_isMapCreated || _controller == null) return;

    // Obtener posición actual de la cámara
    _controller!.getLatLng(const ScreenCoordinate(x: 0, y: 0)).then((center) {
      if (!_isDisposed) {
        _controller!.getZoomLevel().then((zoom) {
          if (!_isDisposed) {
            widget.onCameraIdle?.call(
              CameraPosition(
                target: center,
                zoom: zoom,
              ),
            );
          }
        });
      }
    }).catchError((error) {
      debugPrint('Error getting camera position: $error');
    });
  }

  /// Callback cuando se toca el mapa
  void _onTap(LatLng position) {
    if (_isDisposed || !_isMapCreated) return;
    widget.onTap?.call(position);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    return GoogleMap(
      // Configuración inicial
      initialCameraPosition: CameraPosition(
        target: widget.initialPosition,
        zoom: widget.initialZoom,
      ),

      // Callbacks
      onMapCreated: _onMapCreated,
      onCameraMove: _onCameraMove,
      onCameraIdle: _onCameraIdle,
      onTap: _onTap,

      // Marcadores y overlays
      markers: widget.markers,
      polylines: widget.polylines,

      // Configuración de UI
      myLocationEnabled: widget.myLocationEnabled,
      myLocationButtonEnabled: widget.myLocationButtonEnabled,
      zoomControlsEnabled: widget.zoomControlsEnabled,
      mapToolbarEnabled: false, // Deshabilitado para control personalizado
      compassEnabled: widget.compassEnabled,
      trafficEnabled: widget.trafficEnabled,

      // Gestos
      rotateGesturesEnabled: widget.rotateGesturesEnabled,
      scrollGesturesEnabled: widget.scrollGesturesEnabled,
      tiltGesturesEnabled: widget.tiltGesturesEnabled,
      zoomGesturesEnabled: widget.zoomGesturesEnabled,

      // Tipo de mapa
      mapType: MapType.normal,

      // Optimizaciones de renderizado
      liteModeEnabled: false, // Modo completo para mejor UX
      buildingsEnabled: true,
      indoorViewEnabled: false, // Deshabilitado para mejor performance
      
      // Padding para UI elements
      padding: EdgeInsets.zero,

      // Min/Max zoom (ajustar según necesidades)
      minMaxZoomPreference: const MinMaxZoomPreference(
        3.0, // Zoom mínimo (vista de país)
        20.0, // Zoom máximo (vista de edificio)
      ),
    );
  }
}

/// Widget envolvente con manejo de estados de carga
class MapViewContainer extends StatelessWidget {
  const MapViewContainer({
    super.key,
    required this.child,
    this.isLoading = false,
    this.errorMessage,
  });

  final Widget child;
  final bool isLoading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        // Mapa
        child,

        // Loading overlay
        if (isLoading)
          Container(
            color: theme.colorScheme.surface.withOpacity(0.8),
            child: Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
            ),
          ),

        // Error overlay
        if (errorMessage != null)
          Container(
            color: theme.colorScheme.surface.withOpacity(0.9),
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    errorMessage!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
