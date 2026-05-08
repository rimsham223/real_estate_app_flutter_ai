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
    on<UpdateFiltersEvent>(_onUpdateFilters);
  }

  Future<void> _onLoadProperties(LoadPropertiesEvent event, Emitter<PropertySearchState> emit) async {
    emit(state.copyWith(status: const Loading<void>()));
    try {
      final filters = event.filters;
      final properties = await _repository.searchProperties(
        searchQuery: filters.searchQuery,
        areaIds: filters.areaIds,
        compoundIds: filters.compoundIds,
        minPrice: filters.minPrice?.toDouble(),
        maxPrice: filters.maxPrice?.toDouble(),
        minBedrooms: filters.bedrooms,
        maxBedrooms: filters.bedrooms,
      );
      emit(state.copyWith(
        status: const Success<void>(null),
        properties: properties,
        currentFilters: filters,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: Failure<void>(e.toString()),
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateFilters(UpdateFiltersEvent event, Emitter<PropertySearchState> emit) async {
    emit(state.copyWith(currentFilters: event.filters));
    add(LoadPropertiesEvent(event.filters));
  }
}
