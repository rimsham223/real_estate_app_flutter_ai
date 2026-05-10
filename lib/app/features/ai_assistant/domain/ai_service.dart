import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@singleton
class AiService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final PropertySearchRepository _propertyRepository;

  AiService({PropertySearchRepository? propertyRepository})
      : _propertyRepository = propertyRepository ?? PropertySearchRepository();

  Future<String> sendMessage(String message, List<Map<String, String>> history) async {
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

  String _localReply(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('budget') || lower.contains('price')) {
      return 'I can help you narrow by budget. Open Explore, tap the filter button, then set minimum and maximum price. A good shortlist also includes bedrooms and preferred area so you compare similar homes.';
    }
    if (lower.contains('bed') || lower.contains('room')) {
      return 'For bedrooms, use the Explore filters to set a minimum and maximum bedroom range. If you share your family size and work-from-home needs, I can suggest a practical range.';
    }
    if (lower.contains('area') || lower.contains('location') || lower.contains('compound')) {
      return 'Location matters most. Filter by area or compound first, then compare price per meter, commute, amenities, and delivery status before saving favorites.';
    }
    return 'Tell me your target area, budget, bedroom count, and move-in timeline. I will turn that into a focused property search plan and suggest filters to apply in Explore.';
  }
}
