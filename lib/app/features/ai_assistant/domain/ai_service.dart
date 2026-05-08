import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:injectable/injectable.dart';

@singleton
class AiService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<String> sendMessage(String message, List<Map<String, String>> history) async {
    final response = await _supabase.functions.invoke(
      'gemini-assistant',
      body: {
        'message': message,
        'history': history,
      },
    );
    final data = response.data as Map<String, dynamic>;
    return data['reply'] as String;
  }
}