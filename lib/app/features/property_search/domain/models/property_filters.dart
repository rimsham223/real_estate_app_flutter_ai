import 'package:equatable/equatable.dart';

class PropertyFilters extends Equatable {
  final String? searchQuery;
  final List<int> areaIds;
  final List<int> compoundIds;
  final List<int> propertyTypeIds;
  final double? minPrice;
  final double? maxPrice;
  final int? minBedrooms;
  final int? maxBedrooms;
  final String? propertyType;

  const PropertyFilters({
    this.searchQuery,
    List<int>? areaIds,
    List<int>? compoundIds,
    List<int>? propertyTypeIds,
    this.minPrice,
    this.maxPrice,
    this.minBedrooms,
    this.maxBedrooms,
    this.propertyType,
  })  : areaIds = areaIds ?? const [],
        compoundIds = compoundIds ?? const [],
        propertyTypeIds = propertyTypeIds ?? const [];

  List<int> get selectedAreaIds => areaIds;
  List<int> get selectedCompoundIds => compoundIds;
  List<int> get selectedPropertyTypeIds => propertyTypeIds;
  int? get bedrooms => minBedrooms == maxBedrooms ? minBedrooms : null;

  PropertyFilters copyWith({
    String? searchQuery,
    List<int>? areaIds,
    List<int>? selectedAreaIds,
    List<int>? compoundIds,
    List<int>? selectedCompoundIds,
    List<int>? propertyTypeIds,
    List<int>? selectedPropertyTypeIds,
    double? minPrice,
    double? maxPrice,
    int? bedrooms,
    int? minBedrooms,
    int? maxBedrooms,
    String? propertyType,
    bool clearSearchQuery = false,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
    bool clearMinBedrooms = false,
    bool clearMaxBedrooms = false,
    bool clearPropertyType = false,
  }) {
    return PropertyFilters(
      searchQuery: clearSearchQuery ? null : searchQuery ?? this.searchQuery,
      areaIds: areaIds ?? selectedAreaIds ?? this.areaIds,
      compoundIds: compoundIds ?? selectedCompoundIds ?? this.compoundIds,
      propertyTypeIds: propertyTypeIds ?? selectedPropertyTypeIds ?? this.propertyTypeIds,
      minPrice: clearMinPrice ? null : minPrice ?? this.minPrice,
      maxPrice: clearMaxPrice ? null : maxPrice ?? this.maxPrice,
      minBedrooms: clearMinBedrooms ? null : minBedrooms ?? bedrooms ?? this.minBedrooms,
      maxBedrooms: clearMaxBedrooms ? null : maxBedrooms ?? bedrooms ?? this.maxBedrooms,
      propertyType: clearPropertyType ? null : propertyType ?? this.propertyType,
    );
  }

  PropertyFilters normalized() {
    final query = searchQuery?.trim();
    return copyWith(
      searchQuery: query == null || query.isEmpty ? null : query,
      clearSearchQuery: query == null || query.isEmpty,
    );
  }

  int get activeFilterCount {
    var count = 0;
    if ((searchQuery?.trim().isNotEmpty ?? false)) count++;
    if (areaIds.isNotEmpty) count++;
    if (compoundIds.isNotEmpty) count++;
    if (propertyTypeIds.isNotEmpty || propertyType != null) count++;
    if (minPrice != null || maxPrice != null) count++;
    if (minBedrooms != null || maxBedrooms != null) count++;
    return count;
  }

  bool get hasFilters => activeFilterCount > 0;

  @override
  List<Object?> get props => [
        searchQuery,
        areaIds,
        compoundIds,
        propertyTypeIds,
        minPrice,
        maxPrice,
        minBedrooms,
        maxBedrooms,
        propertyType,
      ];
}
