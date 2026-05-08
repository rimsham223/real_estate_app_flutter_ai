import 'package:equatable/equatable.dart';
import '../../domain/models/property_filters.dart';

abstract class PropertySearchEvent extends Equatable {
  const PropertySearchEvent();
  @override
  List<Object?> get props => [];
}

// Event to load properties with filters
class LoadPropertiesEvent extends PropertySearchEvent {
  final PropertyFilters filters;
  const LoadPropertiesEvent(this.filters);
  @override
  List<Object?> get props => [filters];
}

// Event to update filters (e.g., from UI)
class UpdateFiltersEvent extends PropertySearchEvent {
  final PropertyFilters filters;
  const UpdateFiltersEvent(this.filters);
  @override
  List<Object?> get props => [filters];
}
