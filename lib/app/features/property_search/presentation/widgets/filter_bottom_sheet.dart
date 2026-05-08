import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nawy_ai_app/app/features/property_search/domain/models/area.dart';
import 'package:nawy_ai_app/app/features/property_search/domain/models/compound.dart';
import 'package:nawy_ai_app/app/features/property_search/domain/models/property_filters.dart';
import 'package:nawy_ai_app/app/features/property_search/domain/models/property_type.dart';
import 'package:nawy_ai_app/app/features/property_search/presentation/bloc/property_search_bloc_exports.dart';

/// Filter bottom sheet for property search
class FilterBottomSheet extends StatefulWidget {
  final PropertyFilters currentFilters;
  final List<Area> areas;
  final List<Compound> compounds;
  final List<PropertyType> propertyTypes;
  final List<int> priceOptions;
  final List<int> bedroomOptions;

  const FilterBottomSheet({
    super.key,
    required this.currentFilters,
    required this.areas,
    required this.compounds,
    required this.propertyTypes,
    required this.priceOptions,
    required this.bedroomOptions,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late PropertyFilters _filters;

  @override
  void initState() {
    super.initState();
    _filters = widget.currentFilters;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          const FilterBottomSheetHeader(),

          // Filters content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Areas filter
                  AreasFilterSection(
                    areas: widget.areas,
                    selectedAreaIds: _filters.selectedAreaIds,
                    onSelectionChanged: (selectedIds) {
                      setState(() {
                        _filters = _filters.copyWith(selectedAreaIds: selectedIds);
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  // Compounds filter
                  CompoundsFilterSection(
                    compounds: widget.compounds,
                    selectedCompoundIds: _filters.selectedCompoundIds,
                    onSelectionChanged: (selectedIds) {
                      setState(() {
                        _filters = _filters.copyWith(selectedCompoundIds: selectedIds);
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  // Property types filter
                  PropertyTypesFilterSection(
                    propertyTypes: widget.propertyTypes,
                    selectedPropertyTypeIds: _filters.selectedPropertyTypeIds,
                    onSelectionChanged: (selectedIds) {
                      setState(() {
                        _filters = _filters.copyWith(selectedPropertyTypeIds: selectedIds);
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  // Price range filter
                  PriceRangeFilterSection(
                    priceOptions: widget.priceOptions,
                    minPrice: _filters.minPrice,
                    maxPrice: _filters.maxPrice,
                    onMinPriceChanged: (value) {
                      setState(() {
                        _filters = _filters.copyWith(minPrice: value);
                      });
                    },
                    onMaxPriceChanged: (value) {
                      setState(() {
                        _filters = _filters.copyWith(maxPrice: value);
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  // Bedrooms filter
                  BedroomsFilterSection(
                    bedroomOptions: widget.bedroomOptions,
                    minBedrooms: _filters.minBedrooms,
                    maxBedrooms: _filters.maxBedrooms,
                    onMinBedroomsChanged: (value) {
                      setState(() {
                        _filters = _filters.copyWith(minBedrooms: value);
                      });
                    },
                    onMaxBedroomsChanged: (value) {
                      setState(() {
                        _filters = _filters.copyWith(maxBedrooms: value);
                      });
                    },
                  ),

                  const SizedBox(height: 100), // Space for bottom buttons
                ],
              ),
            ),
          ),

          // Bottom buttons
          FilterBottomButtons(filters: _filters),
        ],
      ),
    );
  }
}

class FilterItem {
  final int id;
  final String name;
  final bool isSelected;

  const FilterItem({required this.id, required this.name, required this.isSelected});
}

/// Filter bottom sheet header widget
class FilterBottomSheetHeader extends StatelessWidget {
  const FilterBottomSheetHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2))),
      ),
      child: Row(
        children: [
          Text(
            'Filter Properties',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

/// Areas filter section widget
class AreasFilterSection extends StatelessWidget {
  final List<Area> areas;
  final List<int> selectedAreaIds;
  final Function(List<int>) onSelectionChanged;

  const AreasFilterSection({
    super.key,
    required this.areas,
    required this.selectedAreaIds,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return MultiSelectFilterWidget(
      title: 'Areas',
      items: areas
          .map(
            (area) => FilterItem(
              id: area.id,
              name: area.name,
              isSelected: selectedAreaIds.contains(area.id),
            ),
          )
          .toList(),
      onSelectionChanged: onSelectionChanged,
    );
  }
}

/// Compounds filter section widget
class CompoundsFilterSection extends StatelessWidget {
  final List<Compound> compounds;
  final List<int> selectedCompoundIds;
  final Function(List<int>) onSelectionChanged;

  const CompoundsFilterSection({
    super.key,
    required this.compounds,
    required this.selectedCompoundIds,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return MultiSelectFilterWidget(
      title: 'Compounds',
      items: compounds
          .map(
            (compound) => FilterItem(
              id: compound.id,
              name: compound.name,
              isSelected: selectedCompoundIds.contains(compound.id),
            ),
          )
          .toList(),
      onSelectionChanged: onSelectionChanged,
    );
  }
}

/// Property types filter section widget
class PropertyTypesFilterSection extends StatelessWidget {
  final List<PropertyType> propertyTypes;
  final List<int> selectedPropertyTypeIds;
  final Function(List<int>) onSelectionChanged;

  const PropertyTypesFilterSection({
    super.key,
    required this.propertyTypes,
    required this.selectedPropertyTypeIds,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return MultiSelectFilterWidget(
      title: 'Property Types',
      items: propertyTypes
          .map(
            (type) => FilterItem(
              id: type.id,
              name: type.name,
              isSelected: selectedPropertyTypeIds.contains(type.id),
            ),
          )
          .toList(),
      onSelectionChanged: onSelectionChanged,
    );
  }
}

/// Price range filter section widget
class PriceRangeFilterSection extends StatelessWidget {
  final List<int> priceOptions;
  final double? minPrice;
  final double? maxPrice;
  final ValueChanged<double?> onMinPriceChanged;
  final ValueChanged<double?> onMaxPriceChanged;

  const PriceRangeFilterSection({
    super.key,
    required this.priceOptions,
    required this.minPrice,
    required this.maxPrice,
    required this.onMinPriceChanged,
    required this.onMaxPriceChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Get actual min and max from API price options only
    if (priceOptions.isEmpty) {
      return const SizedBox.shrink(); // Don't show price filter if no options
    }

    final minOption = priceOptions.first.toDouble();
    final maxOption = priceOptions.last.toDouble();
    if (minOption >= maxOption) {
      return const SizedBox.shrink();
    }

    // Current range values
    final currentMin = (minPrice ?? minOption).clamp(minOption, maxOption).toDouble();
    final currentMax = (maxPrice ?? maxOption).clamp(currentMin, maxOption).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Price Range',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),

        // Range values display
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatPrice(currentMin),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              _formatPrice(currentMax),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Range slider
        RangeSlider(
          values: RangeValues(currentMin, currentMax),
          min: minOption,
          max: maxOption,
          divisions: 20,
          labels: RangeLabels(_formatPrice(currentMin), _formatPrice(currentMax)),
          onChanged: (RangeValues values) {
            onMinPriceChanged(values.start);
            onMaxPriceChanged(values.end);
          },
        ),
      ],
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M EGP';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}K EGP';
    } else {
      return '${price.toStringAsFixed(0)} EGP';
    }
  }
}

/// Bedrooms filter section widget
class BedroomsFilterSection extends StatelessWidget {
  final List<int> bedroomOptions;
  final int? minBedrooms;
  final int? maxBedrooms;
  final Function(int?) onMinBedroomsChanged;
  final Function(int?) onMaxBedroomsChanged;

  const BedroomsFilterSection({
    super.key,
    required this.bedroomOptions,
    required this.minBedrooms,
    required this.maxBedrooms,
    required this.onMinBedroomsChanged,
    required this.onMaxBedroomsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Get actual min and max from bedroom options, with fallbacks
    final minOption = bedroomOptions.isNotEmpty ? bedroomOptions.first.toDouble() : 1.0;
    var maxOption = bedroomOptions.isNotEmpty ? bedroomOptions.last.toDouble() : 6.0;
    if (maxOption <= minOption) {
      maxOption = minOption + 1;
    }

    // Use actual bedroom options length for divisions, or default to 5
    final divisions = bedroomOptions.length > 1 ? bedroomOptions.length - 1 : 5;

    // Current range values
    final currentMin = (minBedrooms ?? minOption.toInt()).clamp(minOption.toInt(), maxOption.toInt()).toDouble();
    final currentMax = (maxBedrooms ?? maxOption.toInt()).clamp(currentMin.toInt(), maxOption.toInt()).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bedrooms', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),

        // Range values display
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatBedrooms(currentMin.toInt()),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              _formatBedrooms(currentMax.toInt()),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Range slider
        RangeSlider(
          values: RangeValues(currentMin, currentMax),
          min: minOption,
          max: maxOption,
          divisions: divisions,
          labels: RangeLabels(
            _formatBedrooms(currentMin.toInt()),
            _formatBedrooms(currentMax.toInt()),
          ),
          onChanged: (RangeValues values) {
            onMinBedroomsChanged(values.start.round());
            onMaxBedroomsChanged(values.end.round());
          },
        ),
      ],
    );
  }

  String _formatBedrooms(int bedrooms) {
    if (bedrooms >= 6) {
      return '6+ BR';
    }
    return '$bedrooms BR';
  }
}

/// Filter bottom buttons widget
class FilterBottomButtons extends StatelessWidget {
  final PropertyFilters filters;

  const FilterBottomButtons({super.key, required this.filters});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.2))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  context.read<PropertySearchBloc>().add(const ClearFiltersEvent());
                  Navigator.of(context).pop();
                },
                child: const Text('Clear All'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () {
                  context.read<PropertySearchBloc>().add(UpdateFiltersEvent(filters));
                  Navigator.of(context).pop();
                },
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Multi-select filter widget
class MultiSelectFilterWidget extends StatelessWidget {
  final String title;
  final List<FilterItem> items;
  final Function(List<int>) onSelectionChanged;

  const MultiSelectFilterWidget({
    super.key,
    required this.title,
    required this.items,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items
              .map(
                (item) => FilterChip(
                  label: Text(
                    item.name,
                    style: TextStyle(
                      color: item.isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                      fontWeight: item.isSelected ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                  selected: item.isSelected,
                  onSelected: (selected) {
                    final currentSelection = items
                        .where((i) => i.isSelected)
                        .map((i) => i.id)
                        .toList();

                    if (selected) {
                      currentSelection.add(item.id);
                    } else {
                      currentSelection.remove(item.id);
                    }

                    onSelectionChanged(currentSelection);
                  },
                  backgroundColor: theme.colorScheme.surface,
                  selectedColor: theme.colorScheme.surface,
                  side: BorderSide(
                    color: item.isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline.withValues(alpha: 0.5),
                    width: item.isSelected ? 1.5 : 1.0,
                  ),
                  showCheckmark: false,
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
