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

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}