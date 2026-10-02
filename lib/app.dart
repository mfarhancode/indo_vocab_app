import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'theme.dart';

class IndovocaApp extends StatelessWidget {
  const IndovocaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Indovoca',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: cSurface,
        colorScheme: ColorScheme.light(
          primary: cPrimary,
          onPrimary: Colors.white,
          primaryContainer: cPrimaryContainer,
          surface: cSurface,
          onSurface: cOnSurface,
          secondary: cSecondary,
          secondaryContainer: cSecondaryContainer,
          onSecondary: Colors.white,
          tertiary: cTertiary,
          error: cError,
        ),
        fontFamily: 'Plus Jakarta Sans',
      ),
      home: const SplashScreen(),
    );
  }
}
