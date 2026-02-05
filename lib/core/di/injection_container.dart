import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'injection_container.config.dart';

final GetIt sl = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async {
  // ========================================================================
  // CLEAN SOLUTION: Injectable maneja TODAS las dependencias
  // ========================================================================
  // RegisterModule provee:
  //   - SupabaseClient (desde Supabase.instance.client)
  //   - Connectivity (desde Connectivity())
  // NO registrar nada manualmente - Injectable lo hace automáticamente

  // Inicializar dependencias con injectable (NO usar await - init() es void)
  sl.init();
}

