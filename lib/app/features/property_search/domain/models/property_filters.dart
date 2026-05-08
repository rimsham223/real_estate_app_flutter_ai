class PropertyFilters {
  final String? searchQuery;
  final List<int>? areaIds;
  final List<int>? compoundIds;
  final double? minPrice;
  final double? maxPrice;
  final int? bedrooms;
  final String? propertyType;

  const PropertyFilters({
    this.searchQuery,
    this.areaIds,
    this.compoundIds,
    this.minPrice,
    this.maxPrice,
    this.bedrooms,
    this.propertyType,
  });

  PropertyFilters copyWith({
    String? searchQuery,
    List<int>? areaIds,
    List<int>? compoundIds,
    double? minPrice,
    double? maxPrice,
    int? bedrooms,
    String? propertyType,
  }) {
    return PropertyFilters(
      searchQuery: searchQuery ?? this.searchQuery,
      areaIds: areaIds ?? this.areaIds,
      compoundIds: compoundIds ?? this.compoundIds,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      bedrooms: bedrooms ?? this.bedrooms,
      propertyType: propertyType ?? this.propertyType,
    );
  }

  bool get hasFilters {
    return searchQuery != null ||
        (areaIds?.isNotEmpty ?? false) ||
        (compoundIds?.isNotEmpty ?? false) ||
        minPrice != null ||
        maxPrice != null ||
        bedrooms != null;
  }
}
