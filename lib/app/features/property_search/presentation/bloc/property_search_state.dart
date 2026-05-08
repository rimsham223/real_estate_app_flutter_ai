import 'package:equatable/equatable.dart';
import 'package:nawy_ai_app/app/core/models/status.dart';
import 'package:nawy_ai_app/app/features/property_search/domain/models/property.dart';
import 'package:nawy_ai_app/app/features/property_search/domain/models/property_filters.dart';

class PropertySearchState extends Equatable {
  final VoidStatus status;
  final List<Property> properties;
  final PropertyFilters currentFilters;
  final String? errorMessage;

  const PropertySearchState._({
    required this.status,
    this.properties = const [],
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
    PropertyFilters? currentFilters,
    String? errorMessage,
  }) {
    return PropertySearchState._(
      status: status ?? this.status,
      properties: properties ?? this.properties,
      currentFilters: currentFilters ?? this.currentFilters,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  bool get hasFiltersApplied => currentFilters.hasFilters;

  @override
  List<Object?> get props => [status, properties, currentFilters, errorMessage];
}