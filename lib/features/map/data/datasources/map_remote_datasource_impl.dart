import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/vehicle_location_model.dart';
import 'map_remote_datasource.dart';

@LazySingleton(as: MapRemoteDataSource)
class MapRemoteDataSourceImpl implements MapRemoteDataSource {
  const MapRemoteDataSourceImpl(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<List<VehicleLocationModel>> getVehicleLocations() async {
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
}
