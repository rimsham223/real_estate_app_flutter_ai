import 'package:equatable/equatable.dart';
import '../../domain/models/property_filters.dart';

abstract class PropertySearchEvent extends Equatable {
  const PropertySearchEvent();
  @override
  List<Object?> get props => [];
}

class LoadPropertiesEvent extends PropertySearchEvent {
  final PropertyFilters filters;
  const LoadPropertiesEvent(this.filters);
  @override
  List<Object?> get props => [filters];
}

class SearchPropertiesEvent extends PropertySearchEvent {
  final PropertyFilters filters;
  const SearchPropertiesEvent(this.filters);
  @override
  List<Object?> get props => [filters];
}

class UpdateFiltersEvent extends PropertySearchEvent {
  final PropertyFilters filters;
  const UpdateFiltersEvent(this.filters);
  @override
  List<Object?> get props => [filters];
}

class ClearFiltersEvent extends PropertySearchEvent {
  const ClearFiltersEvent();
}
