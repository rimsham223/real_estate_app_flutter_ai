import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:injectable/injectable.dart';

@singleton
class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
  Session? get currentSession => _supabase.auth.currentSession;
  User? get currentUser => _supabase.auth.currentUser;

  Future<void> sendOtp(String email) async {
    await _supabase.auth.signInWithOtp(
      email: email,
      emailRedirectTo: 'io.supabase.flutter://reset-callback',
    );
  }

  Future<AuthResponse> verifyOtp(String email, String token) async {
    return await _supabase.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.email,
    );
  }

  Future<void> upsertProfile(String userId, String email, {String? fullName}) async {
    await _supabase.from('profiles').upsert({
      'id': userId,
      'email': email,
      'full_name': fullName,
    });
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final user = currentUser;
    if (user == null) return null;

    final profile = await _supabase.from('profiles').select().eq('id', user.id).maybeSingle();
    return profile;
  }

  Future<void> updateProfile({String? fullName, String? phone}) async {
    final user = currentUser;
    if (user == null) return;

    await _supabase.from('profiles').upsert({
      'id': user.id,
      'email': user.email,
      'full_name': fullName,
      'phone': phone,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}