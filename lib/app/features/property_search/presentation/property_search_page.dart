import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nawy_ai_app/app/core/injection/injection.dart';
import 'package:nawy_ai_app/app/core/models/status.dart';
import 'package:nawy_ai_app/app/core/network/network_aware_widget.dart';
import 'package:nawy_ai_app/app/features/favorites/presentation/bloc/favorites_bloc_exports.dart';
import 'package:nawy_ai_app/app/features/property_search/domain/models/property.dart';
import 'package:nawy_ai_app/app/features/property_search/domain/models/property_filters.dart';
import 'package:nawy_ai_app/app/features/property_search/domain/property_search_repository.dart';
import 'package:nawy_ai_app/app/features/property_search/presentation/bloc/property_search_bloc_exports.dart';
import 'package:nawy_ai_app/app/features/property_search/presentation/widgets/filter_bottom_sheet.dart';
import 'package:nawy_ai_app/app/features/property_search/presentation/widgets/property_list_view.dart';
import 'package:nawy_ai_app/app/features/property_search/presentation/widgets/search_bar_widget.dart';

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
              context.read<PropertySearchBloc>().add(LoadPropertiesEvent(context.read<PropertySearchBloc>().state.currentFilters));
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SearchHeader(state: state),
                if (state.currentFilters.hasFilters) _ActiveFiltersBar(state: state),
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

    if (state.status.isFailure && state.properties.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 56),
              const SizedBox(height: 12),
              Text(state.errorMessage ?? 'An error occurred', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.read<PropertySearchBloc>().add(LoadPropertiesEvent(state.currentFilters)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.status.isSuccess && state.properties.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('No properties matched your filters. Try broadening the budget, area, or bedroom range.'),
        ),
      );
    }

    return PropertyListView(
      properties: state.properties,
      isLoading: state.status.isLoading,
      onPropertyTap: (property) => _showPropertySummary(context, property),
      onFavoriteToggle: (property) => _onFavoriteToggle(context, property),
    );
  }

  void _showPropertySummary(BuildContext context, Property property) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(property.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text([
              property.area?.name,
              property.compound?.name,
              property.propertyType?.name,
            ].whereType<String>().join(' • ')),
            const SizedBox(height: 16),
            Text('Price: ${_formatPrice(property.minPrice)} - ${_formatPrice(property.maxPrice)}'),
            const SizedBox(height: 8),
            Text('Bedrooms: ${property.numberOfBedrooms ?? '-'}  •  Bathrooms: ${property.numberOfBathrooms ?? '-'}'),
          ],
        ),
      ),
    );
  }

  void _onFavoriteToggle(BuildContext context, Property property) {
    try {
      context.read<FavoritesBloc>().add(TogglePropertyFavoriteEvent(property));
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Favorites are available from the Home tab.')),
      );
    }
  }

  String _formatPrice(double? price) {
    if (price == null) return 'N/A';
    if (price >= 1000000) return '${(price / 1000000).toStringAsFixed(1)}M EGP';
    return '${price.toStringAsFixed(0)} EGP';
  }
}

class _SearchHeader extends StatelessWidget {
  final PropertySearchState state;

  const _SearchHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.primary.withValues(alpha: 0.78)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Discover real homes', style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text('${state.properties.length} curated properties with building photos and smart filters', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.9))),
          const SizedBox(height: 14),
          SearchBarWidget(
            hintText: 'Search by area, compound, type...',
            searchQuery: state.currentFilters.searchQuery,
            onChanged: (query) => context.read<PropertySearchBloc>().add(UpdateFiltersEvent(state.currentFilters.copyWith(searchQuery: query))),
            onFilterTap: () => _showFilterBottomSheet(context, state),
            hasActiveFilters: state.currentFilters.hasFilters,
            isLoading: state.status.isLoading,
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, PropertySearchState state) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BlocProvider.value(
        value: context.read<PropertySearchBloc>(),
        child: FilterBottomSheet(
          currentFilters: state.currentFilters,
          areas: state.areas,
          compounds: state.compounds,
          propertyTypes: state.propertyTypes,
          priceOptions: state.priceOptions,
          bedroomOptions: state.bedroomOptions,
        ),
      ),
    );
  }
}

class _ActiveFiltersBar extends StatelessWidget {
  final PropertySearchState state;

  const _ActiveFiltersBar({required this.state});

  @override
  Widget build(BuildContext context) {
    final filters = state.currentFilters;
    final chips = <Widget>[];
    if (filters.searchQuery?.isNotEmpty ?? false) chips.add(_chip(context, '“${filters.searchQuery}”'));
    if (filters.areaIds.isNotEmpty) chips.add(_chip(context, '${filters.areaIds.length} area(s)'));
    if (filters.compoundIds.isNotEmpty) chips.add(_chip(context, '${filters.compoundIds.length} compound(s)'));
    if (filters.propertyTypeIds.isNotEmpty) chips.add(_chip(context, '${filters.propertyTypeIds.length} type(s)'));
    if (filters.minPrice != null || filters.maxPrice != null) chips.add(_chip(context, 'Budget set'));
    if (filters.minBedrooms != null || filters.maxBedrooms != null) chips.add(_chip(context, 'Bedrooms set'));

    return SizedBox(
      height: 48,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        children: [
          ...chips,
          TextButton.icon(
            onPressed: () => context.read<PropertySearchBloc>().add(const ClearFiltersEvent()),
            icon: const Icon(Icons.close, size: 16),
            label: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(label: Text(label), visualDensity: VisualDensity.compact),
    );
  }
}
