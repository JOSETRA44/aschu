// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:supabase_flutter/supabase_flutter.dart' as _i454;

import '../../features/map/data/datasources/map_remote_datasource.dart'
    as _i583;
import '../../features/map/data/datasources/map_remote_datasource_impl.dart'
    as _i175;
import '../../features/map/data/repositories/map_repository_impl.dart' as _i457;
import '../../features/map/domain/repositories/map_repository.dart' as _i973;
import '../../features/map/domain/usecases/get_vehicle_locations.dart' as _i34;
import '../../features/map/domain/usecases/update_driver_position.dart'
    as _i457;
import '../../features/map/domain/usecases/watch_vehicle_location.dart'
    as _i614;
import '../../features/map/presentation/bloc/map_bloc.dart' as _i437;
import '../network/network_info.dart' as _i932;
import '../services/location_permission_service.dart' as _i700;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i454.SupabaseClient>(() => registerModule.supabaseClient);
    gh.lazySingleton<_i895.Connectivity>(() => registerModule.connectivity);
    gh.lazySingleton<_i700.LocationPermissionService>(
      () => _i700.LocationPermissionService(),
    );
    gh.lazySingleton<_i932.NetworkInfo>(
      () => _i932.NetworkInfoImpl(gh<_i895.Connectivity>()),
    );
    gh.lazySingleton<_i583.MapRemoteDataSource>(
      () => _i175.MapRemoteDataSourceImpl(
        gh<_i454.SupabaseClient>(),
        gh<_i932.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i973.MapRepository>(
      () => _i457.MapRepositoryImpl(gh<_i583.MapRemoteDataSource>()),
    );
    gh.lazySingleton<_i34.GetVehicleLocations>(
      () => _i34.GetVehicleLocations(gh<_i973.MapRepository>()),
    );
    gh.lazySingleton<_i457.UpdateDriverPosition>(
      () => _i457.UpdateDriverPosition(gh<_i973.MapRepository>()),
    );
    gh.lazySingleton<_i614.WatchVehicleLocation>(
      () => _i614.WatchVehicleLocation(gh<_i973.MapRepository>()),
    );
    gh.factory<_i437.MapBloc>(
      () => _i437.MapBloc(
        gh<_i34.GetVehicleLocations>(),
        gh<_i614.WatchVehicleLocation>(),
        gh<_i700.LocationPermissionService>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}
