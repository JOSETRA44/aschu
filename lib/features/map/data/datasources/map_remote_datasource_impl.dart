import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../models/driver_location_model.dart';
import '../models/vehicle_location_model.dart';
import 'map_remote_datasource.dart';

@LazySingleton(as: MapRemoteDataSource)
class MapRemoteDataSourceImpl implements MapRemoteDataSource {
  const MapRemoteDataSourceImpl(this._supabase, this._networkInfo);

  final SupabaseClient _supabase;
  final NetworkInfo _networkInfo;

  @override
  Future<List<VehicleLocationModel>> getVehicleLocations() async {
    // CRITICAL: Verificar conexión antes de hacer request (zonas rurales)
    if (!await _networkInfo.isConnected) {
      throw NetworkException('No hay conexión a internet. Verifica tu señal.');
    }

    try {
      final response = await _supabase
          .from('vehicle_locations')
          .select()
          .order('timestamp', ascending: false);

      return (response as List)
          .map((json) => VehicleLocationModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<VehicleLocationModel> getVehicleLocationById(String vehicleId) async {
    try {
      final response = await _supabase
          .from('vehicle_locations')
          .select()
          .eq('vehicle_id', vehicleId)
          .order('timestamp', ascending: false)
          .limit(1)
          .single();

      return VehicleLocationModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updateVehicleLocation(VehicleLocationModel location) async {
    try {
      await _supabase.from('vehicle_locations').upsert(location.toJson());
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<VehicleLocationModel> watchVehicleLocation(String vehicleId) {
    try {
      return _supabase
          .from('vehicle_locations')
          .stream(primaryKey: ['id'])
          .eq('vehicle_id', vehicleId)
          .map((data) => VehicleLocationModel.fromJson(data.first));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // ==================== DRIVER LOCATION METHODS ====================

  @override
  Future<List<DriverLocationModel>> getDriverLocations() async {
    // CRITICAL: Verificar conexión antes de hacer request
    if (!await _networkInfo.isConnected) {
      throw NetworkException('No hay conexión a internet. Verifica tu señal.');
    }

    try {
      final response = await _supabase
          .from('driver_locations')
          .select()
          .eq('is_online', true) // Solo conductores activos
          .order('timestamp', ascending: false);

      return (response as List)
          .map((json) => DriverLocationModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<DriverLocationModel> getDriverLocationById(String driverId) async {
    if (!await _networkInfo.isConnected) {
      throw NetworkException('No hay conexión a internet. Verifica tu señal.');
    }

    try {
      final response = await _supabase
          .from('driver_locations')
          .select()
          .eq('driver_id', driverId)
          .order('timestamp', ascending: false)
          .limit(1)
          .single();

      return DriverLocationModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updateDriverLocation(DriverLocationModel location) async {
    if (!await _networkInfo.isConnected) {
      throw NetworkException('No hay conexión a internet. Verifica tu señal.');
    }

    try {
      await _supabase.from('driver_locations').upsert(location.toJson());
    } on PostgrestException catch (e) {
      throw ServerException(e.message);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<DriverLocationModel> watchDriverLocation(String driverId) {
    try {
      return _supabase
          .from('driver_locations')
          .stream(primaryKey: ['id'])
          .eq('driver_id', driverId)
          .map((data) => DriverLocationModel.fromJson(data.first));
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
