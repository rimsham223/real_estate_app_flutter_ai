import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/area.dart';
import 'models/compound.dart';
import 'models/property.dart';
import 'models/property_type.dart';

@singleton
class PropertySearchRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Property>? _cachedLocalProperties;
  List<Area>? _cachedLocalAreas;
  List<Compound>? _cachedLocalCompounds;
  List<PropertyType>? _cachedLocalPropertyTypes;

  Future<List<Area>> getAreas() async {
    try {
      final response = await _supabase.from('areas').select().order('name').timeout(const Duration(seconds: 8));
      final areas = response.map((json) => Area.fromJson(json)).toList();
      return areas.isEmpty ? _loadLocalAreas() : areas;
    } catch (_) {
      return _loadLocalAreas();
    }
  }

  Future<List<Compound>> getCompounds() async {
    try {
      final response = await _supabase.from('compounds').select('*, areas(*)').order('name').timeout(const Duration(seconds: 8));
      final compounds = response.map((json) => Compound.fromJson(json)).toList();
      return compounds.isEmpty ? _loadLocalCompounds() : compounds;
    } catch (_) {
      return _loadLocalCompounds();
    }
  }

  Future<List<PropertyType>> getPropertyTypes() async {
    try {
      final response = await _supabase.from('property_types').select().order('name').timeout(const Duration(seconds: 8));
      final propertyTypes = response.map((json) => PropertyType.fromJson(json)).toList();
      return propertyTypes.isEmpty ? _loadLocalPropertyTypes() : propertyTypes;
    } catch (_) {
      return _loadLocalPropertyTypes();
    }
  }

  Future<List<Property>> searchProperties({
    String? searchQuery,
    List<int>? areaIds,
    List<int>? compoundIds,
    List<int>? propertyTypeIds,
    double? minPrice,
    double? maxPrice,
    int? minBedrooms,
    int? maxBedrooms,
  }) async {
    try {
      var query = _supabase.from('properties').select('''
        *,
        compounds (*, areas (*), developers (*)),
        areas (*),
        developers (*),
        property_types (*)
      ''');

      final trimmedQuery = searchQuery?.trim();
      if (trimmedQuery != null && trimmedQuery.isNotEmpty) {
        query = query.ilike('name', '%$trimmedQuery%');
      }
      if (areaIds != null && areaIds.isNotEmpty) {
        query = query.inFilter('area_id', areaIds);
      }
      if (compoundIds != null && compoundIds.isNotEmpty) {
        query = query.inFilter('compound_id', compoundIds);
      }
      if (propertyTypeIds != null && propertyTypeIds.isNotEmpty) {
        query = query.inFilter('property_type_id', propertyTypeIds);
      }
      if (minPrice != null) query = query.gte('min_price', minPrice);
      if (maxPrice != null) query = query.lte('max_price', maxPrice);
      if (minBedrooms != null) query = query.gte('bedrooms', minBedrooms);
      if (maxBedrooms != null) query = query.lte('bedrooms', maxBedrooms);

      final response = await query.order('min_price', ascending: true).limit(80).timeout(const Duration(seconds: 8));
      final properties = response.map((json) => Property.fromJson(json)).toList();
      if (properties.isEmpty) {
        return _searchLocalProperties(
          searchQuery: searchQuery,
          areaIds: areaIds,
          compoundIds: compoundIds,
          propertyTypeIds: propertyTypeIds,
          minPrice: minPrice,
          maxPrice: maxPrice,
          minBedrooms: minBedrooms,
          maxBedrooms: maxBedrooms,
        );
      }
      return properties;
    } catch (_) {
      return _searchLocalProperties(
        searchQuery: searchQuery,
        areaIds: areaIds,
        compoundIds: compoundIds,
        propertyTypeIds: propertyTypeIds,
        minPrice: minPrice,
        maxPrice: maxPrice,
        minBedrooms: minBedrooms,
        maxBedrooms: maxBedrooms,
      );
    }
  }

  Future<List<Property>> _searchLocalProperties({
    String? searchQuery,
    List<int>? areaIds,
    List<int>? compoundIds,
    List<int>? propertyTypeIds,
    double? minPrice,
    double? maxPrice,
    int? minBedrooms,
    int? maxBedrooms,
  }) async {
    final properties = await _loadLocalProperties();
    final query = searchQuery?.trim().toLowerCase();

    final filtered = properties.where((property) {
      final searchableText = [
        property.name,
        property.area?.name,
        property.compound?.name,
        property.propertyType?.name,
      ].whereType<String>().join(' ').toLowerCase();

      if (query != null && query.isNotEmpty && !searchableText.contains(query)) {
        return false;
      }
      if (areaIds != null && areaIds.isNotEmpty && !areaIds.contains(property.areaId)) {
        return false;
      }
      if (compoundIds != null && compoundIds.isNotEmpty && !compoundIds.contains(property.compoundId)) {
        return false;
      }
      if (propertyTypeIds != null &&
          propertyTypeIds.isNotEmpty &&
          !propertyTypeIds.contains(property.propertyType?.id)) {
        return false;
      }
      if (minPrice != null && (property.minPrice ?? 0) < minPrice) return false;
      if (maxPrice != null && (property.minPrice ?? property.maxPrice ?? 0) > maxPrice) return false;
      if (minBedrooms != null && (property.numberOfBedrooms ?? 0) < minBedrooms) return false;
      if (maxBedrooms != null && (property.numberOfBedrooms ?? 99) > maxBedrooms) return false;
      return true;
    }).toList()
      ..sort((a, b) => (a.minPrice ?? 0).compareTo(b.minPrice ?? 0));

    return filtered;
  }

  Future<Map<String, dynamic>> _loadLocalDataset() async {
    final jsonString = await rootBundle.loadString('assets/dataset.json');
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  Future<List<Area>> _loadLocalAreas() async {
    if (_cachedLocalAreas != null) return _cachedLocalAreas!;
    final dataset = await _loadLocalDataset();
    _cachedLocalAreas = (dataset['areas'] as List<dynamic>).cast<Map<String, dynamic>>().map(Area.fromJson).toList();
    return _cachedLocalAreas!;
  }

  Future<List<Compound>> _loadLocalCompounds() async {
    if (_cachedLocalCompounds != null) return _cachedLocalCompounds!;
    final dataset = await _loadLocalDataset();
    final areas = {for (final area in await _loadLocalAreas()) area.id: area};
    _cachedLocalCompounds = (dataset['compounds'] as List<dynamic>).cast<Map<String, dynamic>>().map((json) {
      final area = areas[json['area_id']];
      return Compound.fromJson({...json, if (area != null) 'areas': area.toJson()});
    }).toList();
    return _cachedLocalCompounds!;
  }

  Future<List<PropertyType>> _loadLocalPropertyTypes() async {
    if (_cachedLocalPropertyTypes != null) return _cachedLocalPropertyTypes!;
    final properties = await _loadLocalProperties();
    final byName = <String, PropertyType>{};
    for (final property in properties) {
      final type = property.propertyType;
      if (type != null && type.name.trim().isNotEmpty) {
        byName[type.name.toLowerCase()] = type;
      }
    }
    _cachedLocalPropertyTypes = byName.values.toList()..sort((a, b) => a.name.compareTo(b.name));
    return _cachedLocalPropertyTypes!;
  }

  Future<List<Property>> _loadLocalProperties() async {
    if (_cachedLocalProperties != null) return _cachedLocalProperties!;
    final dataset = await _loadLocalDataset();
    final areas = {for (final area in await _loadLocalAreas()) area.id: area};
    final compounds = {for (final compound in await _loadLocalCompounds()) compound.id: compound};
    final typeIds = <String, int>{};

    _cachedLocalProperties = (dataset['properties'] as List<dynamic>).cast<Map<String, dynamic>>().map((json) {
      final area = areas[json['area_id']];
      final compound = compounds[json['compound_id']];
      final propertyTypeName = (json['property_type'] as String?) ?? 'Property';
      final typeKey = propertyTypeName.toLowerCase();
      final typeId = typeIds.putIfAbsent(typeKey, () => typeIds.length + 1);
      return Property.fromJson({
        ...json,
        'property_type_id': typeId,
        if (area != null) 'areas': area.toJson(),
        if (compound != null) 'compounds': compound.toJson(),
      });
    }).toList();
    return _cachedLocalProperties!;
  }
}
