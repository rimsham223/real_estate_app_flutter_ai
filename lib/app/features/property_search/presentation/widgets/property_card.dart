import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nawy_ai_app/app/features/property_search/domain/models/property.dart';

/// Property card widget for displaying property information in search results
class PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;

  const PropertyCard({super.key, required this.property, this.onTap, this.onFavoriteToggle});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property image
            PropertyImage(property: property),

            // Property details
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Property name only
                  PropertyTitle(property: property),

                  const SizedBox(height: 16),

                  // Property details (location, area, bedrooms, bathrooms)
                  PropertyDetails(property: property),

                  const SizedBox(height: 12),

                  // Price and favorite button
                  PropertyPriceAndFavorite(property: property, onFavoriteToggle: onFavoriteToggle),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Property image widget with placeholder support
class PropertyImage extends StatelessWidget {
  final Property property;

  const PropertyImage({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final image = property.image;

    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        color: theme.colorScheme.surfaceContainerHighest,
      ),
      child: image == null
          ? const PropertyImagePlaceholder()
          : ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: image.startsWith('assets/')
                  ? Image.asset(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const PropertyImagePlaceholder(),
                    )
                  : CachedNetworkImage(
                      imageUrl: image,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const PropertyImagePlaceholder(),
                      errorWidget: (context, url, error) => const PropertyImagePlaceholder(),
                      fadeInDuration: const Duration(milliseconds: 300),
                      fadeOutDuration: const Duration(milliseconds: 100),
                    ),
            ),
    );
  }
}

/// Placeholder widget for property images
class PropertyImagePlaceholder extends StatelessWidget {
  const PropertyImagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        color: theme.colorScheme.surfaceContainerHighest,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home, size: 48, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
            const SizedBox(height: 8),
            Text(
              'No Image',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Property title widget (name only)
class PropertyTitle extends StatelessWidget {
  final Property property;

  const PropertyTitle({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      property.name,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Property location information widget
class PropertyLocationInfo extends StatelessWidget {
  final Property property;

  const PropertyLocationInfo({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locationParts = <String>[];

    if (property.area != null) {
      locationParts.add(property.area!.name);
    }
    if (property.compound != null) {
      locationParts.add(property.compound!.name);
    }

    return Row(
      children: [
        Icon(Icons.location_on_outlined, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            locationParts.join(' • '),
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Property details chips (bedrooms, bathrooms, area)
class PropertyDetails extends StatelessWidget {
  final Property property;

  const PropertyDetails({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final locationParts = <String>[];

    // Get location info
    if (property.area != null) {
      locationParts.add(property.area!.name);
    }
    if (property.compound != null) {
      locationParts.add(property.compound!.name);
    }

    // Get area info
    String? areaText;
    if (property.minUnitArea != null || property.maxUnitArea != null) {
      if (property.minUnitArea != null && property.maxUnitArea != null) {
        if (property.minUnitArea == property.maxUnitArea) {
          areaText = '${property.minUnitArea!.toInt()} m²';
        } else {
          areaText = '${property.minUnitArea!.toInt()}-${property.maxUnitArea!.toInt()} m²';
        }
      } else if (property.minUnitArea != null) {
        areaText = '${property.minUnitArea!.toInt()} m²';
      } else {
        areaText = '${property.maxUnitArea!.toInt()} m²';
      }
    }

    final details = <Widget>[];

    // Location
    if (locationParts.isNotEmpty) {
      details.add(
        PropertyDetailItem(icon: Icons.location_on_outlined, text: locationParts.join(' • ')),
      );
    }

    // Area
    if (areaText != null) {
      details.add(PropertyDetailItem(icon: Icons.square_foot_outlined, text: areaText));
    }

    // Bedrooms
    if (property.numberOfBedrooms != null && property.numberOfBedrooms! > 0) {
      details.add(
        PropertyDetailItem(
          icon: Icons.bed_outlined,
          text:
              '${property.numberOfBedrooms} ${property.numberOfBedrooms == 1 ? 'Bedroom' : 'Bedrooms'}',
        ),
      );
    }

    // Bathrooms
    if (property.numberOfBathrooms != null && property.numberOfBathrooms! > 0) {
      details.add(
        PropertyDetailItem(
          icon: Icons.bathtub_outlined,
          text:
              '${property.numberOfBathrooms} ${property.numberOfBathrooms == 1 ? 'Bathroom' : 'Bathrooms'}',
        ),
      );
    }

    return Wrap(spacing: 20, runSpacing: 8, children: details);
  }
}

/// Individual detail chip widget
class PropertyDetailChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const PropertyDetailChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// Property price and favorite button widget
class PropertyPriceAndFavorite extends StatelessWidget {
  final Property property;
  final VoidCallback? onFavoriteToggle;

  const PropertyPriceAndFavorite({super.key, required this.property, this.onFavoriteToggle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: PropertyPrice(price: property.minPrice?.round() ?? 0, currency: property.currency),
        ),
        IconButton(
          onPressed: onFavoriteToggle,
          icon: Icon(
            property.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: theme.colorScheme.primary,
            size: 28,
          ),
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        ),
      ],
    );
  }
}

/// Property price information widget
class PropertyPrice extends StatelessWidget {
  final int price;
  final String? currency;

  const PropertyPrice({super.key, required this.price, this.currency});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (price <= 0) {
      return Text(
        'Price on request',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    String formattedPrice = _formatPrice(price.toDouble());
    String priceText = '$formattedPrice ${currency ?? 'EGP'}';

    return Text(
      priceText,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.secondary,
      ),
    );
  }

  String _formatPrice(double price) {
    // Format price with thousands separators
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]},');
  }
}

/// Reusable property detail item widget with icon and text
class PropertyDetailItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isExpandable;

  const PropertyDetailItem({
    super.key,
    required this.icon,
    required this.text,
    this.isExpandable = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 19, color: theme.colorScheme.primary),
        const SizedBox(width: 6),
        Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          maxLines: isExpandable ? 1 : null,
          overflow: isExpandable ? TextOverflow.ellipsis : null,
        ),
      ],
    );

    if (isExpandable) {
      return Expanded(child: content);
    }
    return content;
  }
}
