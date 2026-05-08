class Area {
  final int id;
  final String name;
  final String? slug;
  final Map<String, String>? translations;

  Area({
    required this.id, 
    required this.name, 
    this.slug,
    this.translations,
  });

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      id: json['id'],
      name: json['name'] ?? '',
      slug: json['slug'],
      translations: json['translations'] != null ? Map<String, String>.from(json['translations']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'translations': translations,
    };
  }
}
