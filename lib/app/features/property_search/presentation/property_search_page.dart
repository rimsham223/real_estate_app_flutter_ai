import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nawy_ai_app/app/core/injection/injection.dart';
import 'package:nawy_ai_app/app/core/network/network_aware_widget.dart';
import 'package:nawy_ai_app/app/core/models/status.dart';
import 'package:nawy_ai_app/app/features/favorites/presentation/bloc/favorites_bloc_exports.dart';
import 'package:nawy_ai_app/app/features/property_search/domain/models/property.dart';
import 'package:nawy_ai_app/app/features/property_search/domain/models/property_filters.dart';
import 'package:nawy_ai_app/app/features/property_search/domain/property_search_repository.dart';
import 'package:nawy_ai_app/app/features/property_search/presentation/bloc/property_search_bloc_exports.dart';
import 'package:nawy_ai_app/app/features/property_search/presentation/widgets/property_list_view.dart';
import 'package:nawy_ai_app/app/features/property_search/presentation/widgets/search_bar_widget.dart';

/// Property Search page - Main property search and discovery page
class PropertySearchPage extends StatelessWidget {
  const PropertySearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PropertySearchBloc(getIt<PropertySearchRepository>())
        ..add(const LoadPropertiesEvent(PropertyFilters())),
      child: Builder(
        builder: (context) {
          return NetworkAwareWidget(
            child: const _PropertySearchPageContent(),
            onRetry: () {
              context.read<PropertySearchBloc>().add(const LoadPropertiesEvent(PropertyFilters()));
            },
          );
        },
      ),
    );
  }
}

class _PropertySearchPageContent extends StatelessWidget {
  const _PropertySearchPageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<PropertySearchBloc, PropertySearchState>(
          builder: (context, state) {
            return Column(
              children: [
                // Search bar
                SearchBarWidget(
                  hintText: 'Search properties...',
                  searchQuery: state.currentFilters.searchQuery,
                  onChanged: (query) => _updateSearchQuery(context, query),
                  onFilterTap: () => _showFilterBottomSheet(context, state),
                  hasActiveFilters: state.currentFilters.hasFilters,
                  isLoading: state.status.isLoading,
                ),

                // Content based on state
                Expanded(child: _buildContent(context, state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, PropertySearchState state) {
    if (state.status.isLoading && state.properties.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status.isFailure) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.errorMessage ?? 'An error occurred'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<PropertySearchBloc>().add(LoadPropertiesEvent(state.currentFilters));
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.status.isSuccess && state.properties.isEmpty) {
      return const Center(child: Text('No properties found'));
    }

    return PropertyListView(
      properties: state.properties,
      isLoading: state.status.isLoading,
      onPropertyTap: (property) => _onPropertyTap(context, property),
      onFavoriteToggle: (property) => _onFavoriteToggle(context, property),
    );
  }

  void _updateSearchQuery(BuildContext context, String query) {
    final bloc = context.read<PropertySearchBloc>();
    bloc.add(UpdateFiltersEvent(bloc.state.currentFilters.copyWith(searchQuery: query)));
  }

  void _showFilterBottomSheet(BuildContext context, PropertySearchState state) {
    // Note: This placeholder SnackBar indicates where filter logic should go.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filter bottom sheet logic needs to be integrated with updated data source')),
    );
  }

  void _onPropertyTap(BuildContext context, Property property) {
    // Logic for navigating to property details
  }

  void _onFavoriteToggle(BuildContext context, Property property) {
    context.read<FavoritesBloc>().add(TogglePropertyFavoriteEvent(property));
  }
}
