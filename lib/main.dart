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
  WidgetsFlutterBinding.ensureInitialized();

  // CRITICAL: Configurar Google Maps para usar Android View Surface
  // Esto trabaja con el LEGACY Renderer de MainActivity.kt
  // Requerido para GPUs Mali en dispositivos rurales (Infinix, Xiaomi)
  final GoogleMapsFlutterPlatform mapsImplementation =
      GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    // Hybrid Composition mode - mejor para Impeller + LEGACY Renderer
    mapsImplementation.useAndroidViewSurface = true;
    debugPrint('✅ Google Maps: useAndroidViewSurface = true (Hybrid Composition)');
  }

  // Initialize Supabase (Add your credentials)
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  // Initialize Dependency Injection
  await configureDependencies();

  runApp(const QawaqawaApp());
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
