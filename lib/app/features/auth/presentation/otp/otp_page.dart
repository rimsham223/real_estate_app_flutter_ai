import 'package:flutter/material.dart';
import 'package:nawy_ai_app/app/core/injection/injection.dart';
import 'package:nawy_ai_app/app/core/services/auth_service.dart';

class OtpPage extends StatelessWidget {
  final String email;
  final String? name;
  const OtpPage({super.key, required this.email, this.name});

  @override
  Widget build(BuildContext context) {
    final TextEditingController otpController = TextEditingController();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Hello ${name ?? ''}, enter the 6-digit code sent to $email'),
            const SizedBox(height: 20),
            TextField(
              controller: otpController,
              decoration: const InputDecoration(labelText: 'OTP Code'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  final response = await getIt<AuthService>().verifyOtp(email, otpController.text);
                  await getIt<AuthService>().upsertProfile(
                    response.user!.id,
                    response.user!.email!,
                    fullName: name,
                  );
                  if (!context.mounted) return;
                  Navigator.pushReplacementNamed(context, '/home');
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invalid OTP. Please try again.')),
                  );
                }
              },
              child: const Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }
}