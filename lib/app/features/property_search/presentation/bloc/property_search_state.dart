import 'package:equatable/equatable.dart';
import 'package:nawy_ai_app/app/core/models/status.dart';
import 'package:nawy_ai_app/app/features/property_search/domain/models/area.dart';
import 'package:nawy_ai_app/app/features/property_search/domain/models/compound.dart';
import 'package:nawy_ai_app/app/features/property_search/domain/models/property.dart';
import 'package:nawy_ai_app/app/features/property_search/domain/models/property_filters.dart';
import 'package:nawy_ai_app/app/features/property_search/domain/models/property_type.dart';

class PropertySearchState extends Equatable {
  final VoidStatus status;
  final List<Property> properties;
  final List<Area> areas;
  final List<Compound> compounds;
  final List<PropertyType> propertyTypes;
  final PropertyFilters currentFilters;
  final String? errorMessage;

  const PropertySearchState._({
    required this.status,
    this.properties = const [],
    this.areas = const [],
    this.compounds = const [],
    this.propertyTypes = const [],
    required this.currentFilters,
    this.errorMessage,
  });

  factory PropertySearchState.initial() {
    return PropertySearchState._(
      status: const Initial(),
      currentFilters: const PropertyFilters(),
    );
  }

  PropertySearchState copyWith({
    VoidStatus? status,
    List<Property>? properties,
    List<Area>? areas,
    List<Compound>? compounds,
    List<PropertyType>? propertyTypes,
    PropertyFilters? currentFilters,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PropertySearchState._(
      status: status ?? this.status,
      properties: properties ?? this.properties,
      areas: areas ?? this.areas,
      compounds: compounds ?? this.compounds,
      propertyTypes: propertyTypes ?? this.propertyTypes,
      currentFilters: currentFilters ?? this.currentFilters,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  bool get hasFiltersApplied => currentFilters.hasFilters;

  List<int> get priceOptions {
    final prices = properties.map((property) => property.minPrice?.round()).whereType<int>().toList()..sort();
    if (prices.isEmpty) return const [1000000, 5000000, 10000000, 20000000, 30000000];
    return {prices.first, prices[(prices.length / 2).floor()], prices.last}.toList()..sort();
  }

  List<int> get bedroomOptions {
    final bedrooms = properties.map((property) => property.numberOfBedrooms).whereType<int>().toSet().toList()..sort();
    return bedrooms.isEmpty ? const [1, 2, 3, 4, 5, 6] : bedrooms;
  }

  @override
  List<Object?> get props => [
        status,
        properties,
        areas,
        compounds,
        propertyTypes,
        currentFilters,
        errorMessage,
      ];
}
