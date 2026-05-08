import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:nawy_ai_app/app/core/models/status.dart';
import 'package:nawy_ai_app/app/features/property_search/domain/property_search_repository.dart';
import 'package:nawy_ai_app/app/features/property_search/domain/models/property_filters.dart';
import 'property_search_event.dart';
import 'property_search_state.dart';

@injectable
class PropertySearchBloc extends Bloc<PropertySearchEvent, PropertySearchState> {
  final PropertySearchRepository _repository;

  PropertySearchBloc(this._repository) : super(PropertySearchState.initial()) {
    on<LoadPropertiesEvent>(_onLoadProperties);
    on<SearchPropertiesEvent>(_onSearchProperties);
    on<UpdateFiltersEvent>(_onUpdateFilters);
    on<ClearFiltersEvent>(_onClearFilters);
  }

  Future<void> _onLoadProperties(LoadPropertiesEvent event, Emitter<PropertySearchState> emit) async {
    await _load(event.filters.normalized(), emit, refreshFilters: true);
  }

  Future<void> _onSearchProperties(SearchPropertiesEvent event, Emitter<PropertySearchState> emit) async {
    await _load(event.filters.normalized(), emit);
  }

  Future<void> _onUpdateFilters(UpdateFiltersEvent event, Emitter<PropertySearchState> emit) async {
    final filters = event.filters.normalized();
    emit(state.copyWith(currentFilters: filters, clearError: true));
    add(SearchPropertiesEvent(filters));
  }

  Future<void> _onClearFilters(ClearFiltersEvent event, Emitter<PropertySearchState> emit) async {
    const filters = PropertyFilters();
    emit(state.copyWith(currentFilters: filters, clearError: true));
    add(const SearchPropertiesEvent(filters));
  }

  Future<void> _load(
    PropertyFilters filters,
    Emitter<PropertySearchState> emit, {
    bool refreshFilters = false,
  }) async {
    emit(state.copyWith(status: const Loading<void>(), currentFilters: filters, clearError: true));
    try {
      final properties = await _repository.searchProperties(
        searchQuery: filters.searchQuery,
        areaIds: filters.areaIds,
        compoundIds: filters.compoundIds,
        propertyTypeIds: filters.propertyTypeIds,
        minPrice: filters.minPrice,
        maxPrice: filters.maxPrice,
        minBedrooms: filters.minBedrooms,
        maxBedrooms: filters.maxBedrooms,
      );
      final areas = refreshFilters || state.areas.isEmpty ? await _repository.getAreas() : state.areas;
      final compounds = refreshFilters || state.compounds.isEmpty
          ? await _repository.getCompounds()
          : state.compounds;
      final propertyTypes = refreshFilters || state.propertyTypes.isEmpty
          ? await _repository.getPropertyTypes()
          : state.propertyTypes;

      emit(state.copyWith(
        status: const Success<void>(null),
        properties: properties,
        areas: areas,
        compounds: compounds,
        propertyTypes: propertyTypes,
        currentFilters: filters,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Failure<void>(e.toString()),
        errorMessage: e.toString(),
      ));
    }
  }
}
