import 'package:flutter/material.dart';
import 'package:nawy_ai_app/app/core/injection/injection.dart';
import 'package:nawy_ai_app/app/core/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Settings page with account info, preferences, notifications, and sign out.
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _notificationsEnabled = true;
  bool _aiSuggestionsEnabled = true;
  bool _loading = true;
  bool _saving = false;

  AuthService get _authService => getIt<AuthService>();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    Map<String, dynamic>? profile;
    try {
      profile = await _authService.getProfile().timeout(const Duration(seconds: 8));
    } catch (_) {
      profile = null;
    }

    if (!mounted) return;
    final user = _authService.currentUser;
    setState(() {
      _nameController.text = (profile?['full_name'] as String?) ??
          prefs.getString('settings_full_name') ??
          user?.userMetadata?['full_name'] as String? ??
          '';
      _phoneController.text = (profile?['phone'] as String?) ?? prefs.getString('settings_phone') ?? '';
      _notificationsEnabled = prefs.getBool('settings_notifications_enabled') ?? true;
      _aiSuggestionsEnabled = prefs.getBool('settings_ai_suggestions_enabled') ?? true;
      _loading = false;
    });
  }

  Future<void> _saveSettings() async {
    setState(() => _saving = true);
    final prefs = await SharedPreferences.getInstance();
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    await prefs.setString('settings_full_name', name);
    await prefs.setString('settings_phone', phone);
    await prefs.setBool('settings_notifications_enabled', _notificationsEnabled);
    await prefs.setBool('settings_ai_suggestions_enabled', _aiSuggestionsEnabled);

    try {
      await _authService.updateProfile(fullName: name, phone: phone).timeout(const Duration(seconds: 8));
    } catch (_) {
      // Keep local settings even if Supabase is unavailable.
    }

    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved successfully.')),
    );
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
    } finally {
      if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = _authService.currentUser;
    final displayName = _nameController.text.trim().isEmpty ? 'Nawy user' : _nameController.text.trim();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundColor: Colors.white,
                        child: Text(
                          displayName[0].toUpperCase(),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(displayName, style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            Text(user?.email ?? 'Guest account', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white.withValues(alpha: 0.88))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _SectionCard(
                  title: 'Profile',
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full name',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone number',
                        prefixIcon: Icon(Icons.phone_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Preferences',
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Property alerts'),
                      subtitle: const Text('Notify me when matching properties are added.'),
                      value: _notificationsEnabled,
                      onChanged: (value) => setState(() => _notificationsEnabled = value),
                    ),
                    const Divider(),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('AI search suggestions'),
                      subtitle: const Text('Show personalized AI prompts and recommendations.'),
                      value: _aiSuggestionsEnabled,
                      onChanged: (value) => setState(() => _aiSuggestionsEnabled = value),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Support',
                  children: const [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.help_outline),
                      title: Text('Help center'),
                      subtitle: Text('Chat support, FAQs, and buying guidance.'),
                    ),
                    Divider(),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.privacy_tip_outlined),
                      title: Text('Privacy & security'),
                      subtitle: Text('Your saved searches and profile are protected.'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _saving ? null : _saveSettings,
                  icon: _saving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save_outlined),
                  label: Text(_saving ? 'Saving...' : 'Save settings'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _signOut,
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign out'),
                ),
              ],
            ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }
}
