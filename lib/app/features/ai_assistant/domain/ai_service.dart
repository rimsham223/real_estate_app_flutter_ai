import 'package:injectable/injectable.dart';
import 'package:nawy_ai_app/app/features/property_search/domain/models/property.dart';
import 'package:nawy_ai_app/app/features/property_search/domain/property_search_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@singleton
class AiService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final PropertySearchRepository _propertyRepository;

  AiService({PropertySearchRepository? propertyRepository})
      : _propertyRepository = propertyRepository ?? PropertySearchRepository();

  Future<String> sendMessage(String message, List<Map<String, String>> history) async {
    if (_isPropertySearchIntent(message)) {
      return _propertySearchReply(message);
    }

    try {
      final response = await _supabase.functions.invoke(
        'gemini-assistant',
        body: {
          'message': message,
          'history': history,
        },
      ).timeout(const Duration(seconds: 12));
      final data = response.data as Map<String, dynamic>?;
      final reply = data?['reply'] as String?;
      if (reply == null || reply.trim().isEmpty) {
        return _localReply(message);
      }
      return reply;
    } catch (_) {
      return _localReply(message);
    }
  }

  Future<String> _localReply(String message) async {
    if (_isPropertySearchIntent(message)) {
      return _propertySearchReply(message);
    }

    final lower = message.toLowerCase();
    if (lower.contains('budget') || lower.contains('price')) {
      return 'I can help you narrow by budget. Tell me your budget and preferred bedroom count, for example: “Find 3 bedroom apartments under 8M”. I can then return matching properties directly from our listings.';
    }
    if (lower.contains('bed') || lower.contains('room')) {
      return 'Tell me the bedroom count and property type you want, for example: “Find me a 3 bedroom apartment”. I can return matching property names, prices, areas, and compounds from the listings.';
    }
    if (lower.contains('area') || lower.contains('location') || lower.contains('compound')) {
      return 'Location matters most. Tell me the area or compound plus your budget and bedroom count, and I can shortlist matching properties from the current listings.';
    }
    return 'Tell me your target area, budget, bedroom count, and move-in timeline. For example: “Find me a 3 bedroom apartment under 8M in Islamabad”.';
  }

  bool _isPropertySearchIntent(String message) {
    final lower = message.toLowerCase();
    final searchWords = ['find', 'show', 'recommend', 'suggest', 'search', 'looking for', 'need', 'want'];
    final propertyWords = ['property', 'properties', 'apartment', 'villa', 'home', 'house', 'bedroom', 'bed room', 'bhk'];
    return searchWords.any(lower.contains) && propertyWords.any(lower.contains);
  }

  Future<String> _propertySearchReply(String message) async {
    final lower = message.toLowerCase();
    final bedrooms = _extractBedrooms(lower);
    final maxBudget = _extractMaxBudget(lower);
    final propertyType = _extractPropertyType(lower);

    var matches = await _propertyRepository.searchProperties(
      minBedrooms: bedrooms,
      maxBedrooms: bedrooms,
      maxPrice: maxBudget,
    );

    if (propertyType != null) {
      matches = matches.where((property) {
        final typeName = property.propertyType?.name.toLowerCase() ?? '';
        final propertyName = property.name.toLowerCase();
        return typeName.contains(propertyType) || propertyName.contains(propertyType);
      }).toList();
    }

    final areaQuery = _extractKnownLocation(lower, matches);
    if (areaQuery != null) {
      matches = matches.where((property) {
        final area = property.area?.name.toLowerCase() ?? '';
        final compound = property.compound?.name.toLowerCase() ?? '';
        return area.contains(areaQuery) || compound.contains(areaQuery);
      }).toList();
    }

    if (matches.isEmpty) {
      return _emptyPropertyReply(bedrooms: bedrooms, maxBudget: maxBudget, propertyType: propertyType);
    }

    matches.sort((a, b) => (a.minPrice ?? double.infinity).compareTo(b.minPrice ?? double.infinity));
    final shortlist = matches.take(5).toList();
    final criteria = _criteriaSummary(bedrooms: bedrooms, maxBudget: maxBudget, propertyType: propertyType);
    final buffer = StringBuffer('Yes — I found ${matches.length} matching ${matches.length == 1 ? 'property' : 'properties'}$criteria. Here are the best matches:\n\n');

    for (var index = 0; index < shortlist.length; index++) {
      final property = shortlist[index];
      buffer.writeln('${index + 1}. ${property.name}');
      buffer.writeln('   • ${_propertyDetails(property)}');
    }

    buffer.write('\nOpen Explore to view photos, save favorites, or refine these results with filters.');
    return buffer.toString();
  }

  int? _extractBedrooms(String lower) {
    final numericMatch = RegExp(r'(\d+)\s*(?:bed|bedroom|bedrooms|bhk|room)').firstMatch(lower);
    if (numericMatch != null) return int.tryParse(numericMatch.group(1)!);

    const words = {
      'one': 1,
      'two': 2,
      'three': 3,
      'four': 4,
      'five': 5,
      'six': 6,
    };
    for (final entry in words.entries) {
      if (RegExp('\\b${entry.key}\\s*(?:bed|bedroom|bedrooms|bhk|room)').hasMatch(lower)) {
        return entry.value;
      }
    }
    return null;
  }

  double? _extractMaxBudget(String lower) {
    final match = RegExp(r'(?:under|below|less than|max|maximum|budget)\s*(?:egp|rs|pkr)?\s*(\d+(?:\.\d+)?)\s*(m|million|k|thousand|crore|cr)?').firstMatch(lower);
    if (match == null) return null;

    final value = double.tryParse(match.group(1)!);
    if (value == null) return null;

    final unit = match.group(2);
    if (unit == null) return value;
    if (unit == 'm' || unit == 'million') return value * 1000000;
    if (unit == 'k' || unit == 'thousand') return value * 1000;
    if (unit == 'crore' || unit == 'cr') return value * 10000000;
    return value;
  }

  String? _extractPropertyType(String lower) {
    if (lower.contains('apartment') || lower.contains('flat')) return 'apartment';
    if (lower.contains('villa') || lower.contains('house') || lower.contains('home')) return 'villa';
    return null;
  }

  String? _extractKnownLocation(String lower, List<Property> properties) {
    for (final property in properties) {
      final names = [property.area?.name, property.compound?.name].whereType<String>();
      for (final name in names) {
        final normalized = name.toLowerCase();
        if (normalized.isNotEmpty && lower.contains(normalized)) {
          return normalized;
        }
      }
    }
    return null;
  }

  String _criteriaSummary({int? bedrooms, double? maxBudget, String? propertyType}) {
    final parts = <String>[];
    if (bedrooms != null) parts.add('$bedrooms bedroom');
    if (propertyType != null) parts.add(propertyType);
    if (maxBudget != null) parts.add('under ${_formatPrice(maxBudget, 'EGP')}');
    return parts.isEmpty ? '' : ' for ${parts.join(' ')}';
  }

  String _emptyPropertyReply({int? bedrooms, double? maxBudget, String? propertyType}) {
    final criteria = _criteriaSummary(bedrooms: bedrooms, maxBudget: maxBudget, propertyType: propertyType);
    return 'I could not find an exact match$criteria in the current listings. Try widening the budget, changing the property type, or removing the exact bedroom count.';
  }

  String _propertyDetails(Property property) {
    final details = <String>[];
    final type = property.propertyType?.name;
    if (type != null && type.trim().isNotEmpty) details.add(_titleCase(type));
    if (property.numberOfBedrooms != null) details.add('${property.numberOfBedrooms} bedrooms');
    if (property.minPrice != null) details.add('from ${_formatPrice(property.minPrice!, property.currency)}');
    if (property.area?.name != null) details.add(property.area!.name);
    if (property.compound?.name != null) details.add(property.compound!.name);
    if (property.minUnitArea != null) details.add('${property.minUnitArea!.round()} sq ft');
    return details.join(' • ');
  }

  String _formatPrice(double value, String? currency) {
    final label = currency?.trim().isNotEmpty == true ? currency!.trim() : 'EGP';
    if (value >= 10000000) {
      return '${_trimNumber(value / 10000000)} Cr $label';
    }
    if (value >= 1000000) {
      return '${_trimNumber(value / 1000000)}M $label';
    }
    if (value >= 1000) {
      return '${_trimNumber(value / 1000)}K $label';
    }
    return '${value.round()} $label';
  }

  String _trimNumber(double value) {
    final fixed = value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1);
    return fixed.endsWith('.0') ? fixed.substring(0, fixed.length - 2) : fixed;
  }

  String _titleCase(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }
}
