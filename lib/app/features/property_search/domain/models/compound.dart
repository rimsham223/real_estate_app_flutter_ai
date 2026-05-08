import 'area.dart';
import 'developer.dart';

class Compound {
  final int id;
  final int areaId;
  final String name;
  final String? slug;
  final String? imagePath;
  final int? developerId;
  final DateTime? updatedAt;
  final int? nawyOrganizationId;
  final bool hasOffers;
  final bool isFavorite;
  final Area? area;
  final Developer? developer;

  Compound({
    required this.id,
    required this.areaId,
    required this.name,
    this.slug,
    this.imagePath,
    this.developerId,
    this.updatedAt,
    this.nawyOrganizationId,
    this.hasOffers = false,
    this.isFavorite = false,
    this.area,
    this.developer,
  });

  factory Compound.fromJson(Map<String, dynamic> json) {
    return Compound(
      id: json['id'],
      areaId: json['area_id'] ?? json['area']?['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'],
      imagePath: json['image_path'],
      developerId: json['developer_id'],
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      nawyOrganizationId: json['nawy_organization_id'],
      hasOffers: json['has_offers'] ?? false,
      isFavorite: json['is_favorite'] ?? false,
      area: json['areas'] != null
          ? Area.fromJson(json['areas'])
          : json['area'] is Map<String, dynamic>
              ? Area.fromJson(json['area'])
              : null,
      developer: json['developers'] != null ? Developer.fromJson(json['developers']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'area_id': areaId,
      'name': name,
      'slug': slug,
      'image_path': imagePath,
      'developer_id': developerId,
      'updated_at': updatedAt?.toIso8601String(),
      'nawy_organization_id': nawyOrganizationId,
      'has_offers': hasOffers,
      'is_favorite': isFavorite,
    };
  }
}
