import 'package:flutter/material.dart';

import '../theme.dart';
import 'app_shell.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  int level = 0;
  final email = TextEditingController();

  @override
  void dispose() {
    email.dispose();
    super.dispose();
  }

  void enterApp() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AppShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: cPrimary.withOpacity(.10),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.translate_rounded, color: cPrimary, size: 36),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Center(child: Text('Indovoca', style: t(30, FontWeight.w800, cPrimary))),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Build confident Indonesian vocabulary\nthrough focused daily practice.',
                      textAlign: TextAlign.center,
                      style: t(15, FontWeight.w400, cOnSurfaceVariant, height: 1.45),
                    ),
                  ),
                  const SizedBox(height: 34),
                  Text('Your learning level', style: t(18, FontWeight.w700, cOnSurface)),
                  const SizedBox(height: 12),
                  Row(
                    children: List.generate(3, (i) {
                      final labels = ['Beginner', 'Intermediate', 'Advanced'];
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: i == 2 ? 0 : 8),
                          child: ChoiceChip(
                            label: Text(labels[i]),
                            selected: level == i,
                            onSelected: (_) => setState(() => level = i),
                            selectedColor: cPrimary.withOpacity(.12),
                            labelStyle: t(
                              12,
                              FontWeight.w600,
                              level == i ? cPrimary : cOnSurfaceVariant,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 26),
                  Text('Email', style: t(13, FontWeight.w600, cOnSurfaceVariant)),
                  const SizedBox(height: 7),
                  TextField(
                    controller: email,
                    decoration: InputDecoration(
                      hintText: 'you@example.com',
                      prefixIcon: const Icon(Icons.mail_outline_rounded),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: cSurfaceHighest),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: cSurfaceHighest),
                      ),
                    ),
                  ),
                  const SizedBox(height: 13),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: enterApp,
                      style: FilledButton.styleFrom(
                        backgroundColor: cPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text('Continue with email', style: t(15, FontWeight.w700, Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed: enterApp,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: cOutlineVariant),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text('Sign in', style: t(15, FontWeight.w700, cOnSurface)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: Text(
                      'By continuing, you agree to the Terms and Privacy Policy.',
                      textAlign: TextAlign.center,
                      style: t(11, FontWeight.w400, cOnSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
