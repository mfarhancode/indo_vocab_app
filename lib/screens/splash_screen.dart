import 'package:flutter/material.dart';

import '../data/app_database.dart';
import '../theme.dart';
import 'auth_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? error;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    try {
      await AppDatabase.instance.init();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AuthScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => error = 'Could not prepare vocabulary. $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: cPrimary,
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(Icons.translate_rounded, color: Colors.white, size: 46),
            ),
            const SizedBox(height: 20),
            Text('Indovoca', style: t(34, FontWeight.w800, cPrimary)),
            const SizedBox(height: 7),
            Text(
              'Indonesian vocabulary, made memorable.',
              style: t(14, FontWeight.w500, cOnSurfaceVariant),
            ),
            const SizedBox(height: 38),
            if (error == null)
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 3, color: cPrimary),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(error!, textAlign: TextAlign.center, style: t(13, FontWeight.w600, cError)),
              ),
          ],
        ),
      ),
    );
  }
}
