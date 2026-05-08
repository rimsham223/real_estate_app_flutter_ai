class Developer {
  final int id;
  final String name;
  final String? slug;
  final String? logoPath;

  Developer({
    required this.id,
    required this.name,
    this.slug,
    this.logoPath,
  });

  factory Developer.fromJson(Map<String, dynamic> json) {
    return Developer(
      id: json['id'],
      name: json['name'] ?? '',
      slug: json['slug'],
      logoPath: json['logo_path'] ?? json['logo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'logo_path': logoPath,
    };
  }
}
