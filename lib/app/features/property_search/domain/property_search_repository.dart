import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/area.dart';
import 'models/compound.dart';
import 'models/property.dart';

@singleton
class PropertySearchRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Area>> getAreas() async {
    final response = await _supabase.from('areas').select();
    return response.map((json) => Area.fromJson(json)).toList();
  }

  Future<List<Compound>> getCompounds() async {
    final response = await _supabase.from('compounds').select('*, areas(*)');
    return response.map((json) => Compound.fromJson(json)).toList();
  }

  Future<List<Property>> searchProperties({
    String? searchQuery,
    List<int>? areaIds,
    List<int>? compoundIds,
    double? minPrice,
    double? maxPrice,
    int? minBedrooms,
    int? maxBedrooms,
  }) async {
    // ✅ Only select existing tables: properties, compounds, areas
    var query = _supabase.from('properties').select('''
      *,
      compounds!inner (
        *,
        areas!inner (*)
      ),
      areas!inner (*)
    ''');

    if (searchQuery != null && searchQuery.isNotEmpty) {
      query = query.ilike('name', '%$searchQuery%');
    }

    if (areaIds != null && areaIds.isNotEmpty) {
      query = query.inFilter('area_id', areaIds);
    }

    if (compoundIds != null && compoundIds.isNotEmpty) {
      query = query.inFilter('compound_id', compoundIds);
    }

    if (minPrice != null) query = query.gte('min_price', minPrice);
    if (maxPrice != null) query = query.lte('max_price', maxPrice);
    if (minBedrooms != null) query = query.gte('bedrooms', minBedrooms);
    if (maxBedrooms != null) query = query.lte('bedrooms', maxBedrooms);

    final response = await query;
    return response.map((json) => Property.fromJson(json)).toList();
  }
}