import 'area.dart';
import 'compound.dart';
import 'developer.dart';
import 'property_type.dart';

class Property {
  final int id;
  final String name;
  final String? slug;
  final int? areaId;
  final int? compoundId;
  final int? developerId;
  final double? minPrice;
  final double? maxPrice;
  final int? numberOfBedrooms;
  final int? numberOfBathrooms;
  final double? minUnitArea;
  final double? maxUnitArea;
  final PropertyType? propertyType;
  final List<String> images;
  final String? currency;
  final String? finishing;
  final int? maxInstallmentYears;
  final String? maxInstallmentYearsMonths;
  final Area? area;
  final Compound? compound;
  final Developer? developer;
  final bool isFavorite;

  Property({
    required this.id,
    required this.name,
    this.slug,
    this.areaId,
    this.compoundId,
    this.developerId,
    this.minPrice,
    this.maxPrice,
    this.numberOfBedrooms,
    this.numberOfBathrooms,
    this.minUnitArea,
    this.maxUnitArea,
    this.propertyType,
    this.images = const [],
    this.currency = 'EGP',
    this.finishing,
    this.maxInstallmentYears,
    this.maxInstallmentYearsMonths,
    this.area,
    this.compound,
    this.developer,
    this.isFavorite = false,
  });

  String? get image => images.isNotEmpty ? images.first : null;

  factory Property.fromJson(Map<String, dynamic> json) {
    Compound? compound;
    if (json['compounds'] != null) {
      compound = Compound.fromJson(json['compounds']);
    } else if (json['compound'] != null) {
      compound = Compound.fromJson(json['compound']);
    }

    Area? area;
    if (json['areas'] != null) {
      area = Area.fromJson(json['areas']);
    } else if (json['area_data'] != null) {
      area = Area.fromJson(json['area_data']);
    } else if (compound?.area != null) {
      area = compound?.area;
    }

    Developer? developer;
    if (json['developers'] != null) {
      developer = Developer.fromJson(json['developers']);
    } else if (json['developer'] != null) {
      developer = Developer.fromJson(json['developer']);
    }

    PropertyType? propertyType;
    if (json['property_types'] != null) {
      propertyType = PropertyType.fromJson(json['property_types']);
    } else if (json['property_type'] is Map<String, dynamic>) {
      propertyType = PropertyType.fromJson(json['property_type']);
    } else if (json['property_type'] is String) {
      propertyType = PropertyType(
        id: json['property_type_id'] ?? 0,
        name: json['property_type'],
      );
    }

    return Property(
      id: json['id'],
      name: json['name'] ?? '',
      slug: json['slug'],
      areaId: json['area_id'],
      compoundId: json['compound_id'],
      developerId: json['developer_id'],
      minPrice: (json['min_price'] as num?)?.toDouble(),
      maxPrice: (json['max_price'] as num?)?.toDouble(),
      numberOfBedrooms: json['bedrooms'] ?? json['number_of_bedrooms'],
      numberOfBathrooms: json['bath'] ?? json['number_of_bathrooms'],
      minUnitArea: (json['area'] as num?)?.toDouble() ?? (json['min_unit_area'] as num?)?.toDouble(),
      maxUnitArea: (json['max_unit_area'] as num?)?.toDouble(),
      propertyType: propertyType,
      images: _parseImages(json),
      currency: json['currency'] ?? 'EGP',
      finishing: json['finishing'],
      maxInstallmentYears: json['max_installment_years'],
      maxInstallmentYearsMonths: json['max_installment_years_months'],
      area: area,
      compound: compound,
      developer: developer,
      isFavorite: json['is_favorite'] ?? false,
    );
  }

  static List<String> _parseImages(Map<String, dynamic> json) {
    final images = json['images'];
    if (images is List) {
      return images.whereType<String>().where((url) => url.trim().isNotEmpty).toList();
    }
    final image = json['image'];
    if (image is String && image.trim().isNotEmpty) {
      return [image];
    }
    return const [];
  }

  Property copyWith({
    int? id,
    String? name,
    String? slug,
    int? areaId,
    int? compoundId,
    int? developerId,
    double? minPrice,
    double? maxPrice,
    int? numberOfBedrooms,
    int? numberOfBathrooms,
    double? minUnitArea,
    double? maxUnitArea,
    PropertyType? propertyType,
    List<String>? images,
    String? currency,
    String? finishing,
    int? maxInstallmentYears,
    String? maxInstallmentYearsMonths,
    Area? area,
    Compound? compound,
    Developer? developer,
    bool? isFavorite,
  }) {
    return Property(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      areaId: areaId ?? this.areaId,
      compoundId: compoundId ?? this.compoundId,
      developerId: developerId ?? this.developerId,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      numberOfBedrooms: numberOfBedrooms ?? this.numberOfBedrooms,
      numberOfBathrooms: numberOfBathrooms ?? this.numberOfBathrooms,
      minUnitArea: minUnitArea ?? this.minUnitArea,
      maxUnitArea: maxUnitArea ?? this.maxUnitArea,
      propertyType: propertyType ?? this.propertyType,
      images: images ?? this.images,
      currency: currency ?? this.currency,
      finishing: finishing ?? this.finishing,
      maxInstallmentYears: maxInstallmentYears ?? this.maxInstallmentYears,
      maxInstallmentYearsMonths: maxInstallmentYearsMonths ?? this.maxInstallmentYearsMonths,
      area: area ?? this.area,
      compound: compound ?? this.compound,
      developer: developer ?? this.developer,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'area_id': areaId,
      'compound_id': compoundId,
      'developer_id': developerId,
      'min_price': minPrice,
      'max_price': maxPrice,
      'bedrooms': numberOfBedrooms,
      'bath': numberOfBathrooms,
      'area': minUnitArea,
      'property_type_id': propertyType?.id,
      'images': images,
      'currency': currency,
      'finishing': finishing,
      'max_installment_years': maxInstallmentYears,
      'max_installment_years_months': maxInstallmentYearsMonths,
    };
  }
}
