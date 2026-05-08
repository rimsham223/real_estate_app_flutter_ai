// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'property_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PropertyHiveAdapter extends TypeAdapter<PropertyHive> {
  @override
  final typeId = 0;

  @override
  PropertyHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PropertyHive()
      ..propertyId = (fields[0] as num).toInt()
      ..name = fields[1] as String
      ..slug = fields[2] as String?
      ..image = fields[3] as String?
      ..finishing = fields[4] as String?
      ..minUnitArea = (fields[5] as num?)?.toDouble()
      ..maxUnitArea = (fields[6] as num?)?.toDouble()
      ..minPrice = (fields[7] as num?)?.toDouble()
      ..maxPrice = (fields[8] as num?)?.toDouble()
      ..currency = fields[9] as String?
      ..maxInstallmentYears = (fields[10] as num?)?.toInt()
      ..maxInstallmentYearsMonths = fields[11] as String?
      ..isFavorite = fields[12] as bool
      ..propertyTypeId = (fields[13] as num?)?.toInt()
      ..areaId = (fields[14] as num?)?.toInt()
      ..developerId = (fields[15] as num?)?.toInt()
      ..compoundId = (fields[16] as num?)?.toInt()
      ..bedrooms = (fields[17] as num?)?.toInt()
      ..bathrooms = (fields[18] as num?)?.toInt();
  }

  @override
  void write(BinaryWriter writer, PropertyHive obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.propertyId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.slug)
      ..writeByte(3)
      ..write(obj.image)
      ..writeByte(4)
      ..write(obj.finishing)
      ..writeByte(5)
      ..write(obj.minUnitArea)
      ..writeByte(6)
      ..write(obj.maxUnitArea)
      ..writeByte(7)
      ..write(obj.minPrice)
      ..writeByte(8)
      ..write(obj.maxPrice)
      ..writeByte(9)
      ..write(obj.currency)
      ..writeByte(10)
      ..write(obj.maxInstallmentYears)
      ..writeByte(11)
      ..write(obj.maxInstallmentYearsMonths)
      ..writeByte(12)
      ..write(obj.isFavorite)
      ..writeByte(13)
      ..write(obj.propertyTypeId)
      ..writeByte(14)
      ..write(obj.areaId)
      ..writeByte(15)
      ..write(obj.developerId)
      ..writeByte(16)
      ..write(obj.compoundId)
      ..writeByte(17)
      ..write(obj.bedrooms)
      ..writeByte(18)
      ..write(obj.bathrooms);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PropertyHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
