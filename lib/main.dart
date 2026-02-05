import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'features/map/presentation/bloc/map_bloc.dart';
import 'features/map/presentation/pages/map_page.dart';

Future<void> main() async {
  // Capturar TODOS los errores en modo production
  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // ========================================================================
      // CRITICAL FIX #1: Forzar LEGACY Renderer para GPUs Mali
      // ========================================================================
      // Problema: El log muestra "loadedRenderer: LATEST" que causa pantalla gris
      // Solución: FORZAR AndroidMapRenderer.legacy ANTES de cualquier mapa
      final GoogleMapsFlutterPlatform mapsImplementation =
          GoogleMapsFlutterPlatform.instance;
      
      if (mapsImplementation is GoogleMapsFlutterAndroid) {
        try {
          // Paso 1: FORZAR Hybrid Composition (requerido para Impeller + Mali)
          mapsImplementation.useAndroidViewSurface = true;
          debugPrint('🔧 Google Maps: useAndroidViewSurface = true (Hybrid Composition)');

          // Paso 2: FORZAR LEGACY Renderer (crítico para Mali GPUs)
          // IMPORTANTE: Usar .legacy, NO .platformDefault
          final AndroidMapRenderer renderer = await mapsImplementation
              .initializeWithRenderer(AndroidMapRenderer.legacy);
          
          debugPrint('✅ Maps Renderer FORZADO: $renderer');
          debugPrint('🎯 Configuración completa: Hybrid Composition + LEGACY Renderer');
        } catch (e, stackTrace) {
          debugPrint('❌ CRITICAL: Maps initialization failed: $e');
          debugPrint('Stack: $stackTrace');
          // No detener la app, continuar con renderer por defecto
        }
      }

      // ========================================================================
      // CRITICAL FIX #2: Inicializar Supabase ANTES de DI
      // ========================================================================
      await Supabase.initialize(
        url: 'YOUR_SUPABASE_URL',
        anonKey: 'YOUR_SUPABASE_ANON_KEY',
      );
      debugPrint('✅ Supabase initialized');

      // ========================================================================
      // CRITICAL FIX #3: Inyección de Dependencias (sin duplicar SupabaseClient)
      // ========================================================================
      // Injectable YA registra SupabaseClient desde RegisterModule
      // NO registrar manualmente en injection_container.dart
      await configureDependencies();
      debugPrint('✅ Dependency Injection configured');

      runApp(const QawaqawaApp());
    },
    (error, stackTrace) {
      // Log de errores no capturados en production
      debugPrint('❌ UNCAUGHT ERROR: $error');
      debugPrint('Stack: $stackTrace');
      
      // En modo debug, re-lanzar para ver el error completo
      if (kDebugMode) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stackTrace,
            library: 'main.dart',
            context: ErrorDescription('Unhandled error in runZonedGuarded'),
          ),
        );
      }
    },
  );
}

class QawaqawaApp extends StatelessWidget {
  const QawaqawaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => sl<MapBloc>())],
      child: MaterialApp(
        title: 'Qawaqawa Rural Logistics',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const MapPage(),
      ),
    );
  }
}
