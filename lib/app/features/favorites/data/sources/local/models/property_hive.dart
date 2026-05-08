import 'package:hive_ce/hive.dart';
import 'package:nawy_ai_app/app/features/property_search/domain/models/property.dart' as domain;

part 'property_hive.g.dart';

/// Persistence model for Property - handles local storage of favorited properties only
@HiveType(typeId: 0)
class PropertyHive extends HiveObject {
  @HiveField(0)
  late int propertyId;

  @HiveField(1)
  late String name;

  @HiveField(2)
  String? slug;

  @HiveField(3)
  String? image;

  @HiveField(4)
  String? finishing;

  @HiveField(5)
  double? minUnitArea;

  @HiveField(6)
  double? maxUnitArea;

  @HiveField(7)
  double? minPrice;

  @HiveField(8)
  double? maxPrice;

  @HiveField(9)
  String? currency;

  @HiveField(10)
  int? maxInstallmentYears;

  @HiveField(11)
  String? maxInstallmentYearsMonths;

  @HiveField(12)
  bool isFavorite = false;

  @HiveField(13)
  int? propertyTypeId;

  @HiveField(14)
  int? areaId;

  @HiveField(15)
  int? developerId;

  @HiveField(16)
  int? compoundId;

  @HiveField(17)
  int? bedrooms;

  @HiveField(18)
  int? bathrooms;

  PropertyHive();

  PropertyHive._({
    required this.propertyId,
    required this.name,
    this.slug,
    this.image,
    this.finishing,
    this.minUnitArea,
    this.maxUnitArea,
    this.minPrice,
    this.maxPrice,
    this.currency,
    this.maxInstallmentYears,
    this.maxInstallmentYearsMonths,
    this.isFavorite = false,
    this.propertyTypeId,
    this.areaId,
    this.developerId,
    this.compoundId,
    this.bedrooms,
    this.bathrooms,
  });

  /// Convert persistence model to domain entity
  domain.Property toEntity() {
    return domain.Property(
      id: propertyId,
      name: name,
      slug: slug,
      propertyType: null, // Relationships handled separately
      compound: null,
      area: null,
      developer: null,
      images: image != null ? [image!] : [],
      finishing: finishing,
      minUnitArea: minUnitArea,
      maxUnitArea: maxUnitArea,
      minPrice: minPrice,
      maxPrice: maxPrice,
      currency: currency,
      maxInstallmentYears: maxInstallmentYears,
      maxInstallmentYearsMonths: maxInstallmentYearsMonths,
      numberOfBedrooms: bedrooms,
      numberOfBathrooms: bathrooms,
      isFavorite: isFavorite,
    );
  }

  /// Create persistence model from domain entity
  factory PropertyHive.fromEntity(domain.Property entity) {
    return PropertyHive._(
      propertyId: entity.id,
      name: entity.name,
      slug: entity.slug,
      image: entity.image,
      finishing: entity.finishing,
      minUnitArea: entity.minUnitArea,
      maxUnitArea: entity.maxUnitArea,
      minPrice: entity.minPrice,
      maxPrice: entity.maxPrice,
      currency: entity.currency,
      maxInstallmentYears: entity.maxInstallmentYears,
      maxInstallmentYearsMonths: entity.maxInstallmentYearsMonths,
      isFavorite: entity.isFavorite,
      propertyTypeId: entity.propertyType?.id,
      areaId: entity.area?.id,
      developerId: entity.developer?.id,
      compoundId: entity.compound?.id,
      bedrooms: entity.numberOfBedrooms,
      bathrooms: entity.numberOfBathrooms,
    );
  }
}
