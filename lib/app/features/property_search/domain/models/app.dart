class Area {
  final int id;
  final String name;
  final String? slug;

  Area({required this.id, required this.name, this.slug});

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
    );
  }
}