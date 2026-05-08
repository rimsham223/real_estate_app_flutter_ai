class PropertyType {
  final int id;
  final String name;
  final String? slug;
  final String? iconUrl;
  final bool hasLandArea;
  final bool hasMandatoryGardenArea;
  final int? manualRanking;

  PropertyType({
    required this.id,
    required this.name,
    this.slug,
    this.iconUrl,
    this.hasLandArea = false,
    this.hasMandatoryGardenArea = false,
    this.manualRanking,
  });

  factory PropertyType.fromJson(Map<String, dynamic> json) {
    return PropertyType(
      id: json['id'],
      name: json['name'] ?? '',
      slug: json['slug'],
      iconUrl: json['icon_url'],
      hasLandArea: json['has_land_area'] ?? false,
      hasMandatoryGardenArea: json['has_mandatory_garden_area'] ?? false,
      manualRanking: json['manual_ranking'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'icon_url': iconUrl,
      'has_land_area': hasLandArea,
      'has_mandatory_garden_area': hasMandatoryGardenArea,
      'manual_ranking': manualRanking,
    };
  }
}
