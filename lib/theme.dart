import 'package:flutter/material.dart';

const cSurface = Color(0xFFF8F9FF);
const cSurfaceLow = Color(0xFFEFF4FF);
const cSurfaceContainer = Color(0xFFE6EEFF);
const cSurfaceHigh = Color(0xFFDEE9FC);
const cSurfaceHighest = Color(0xFFD9E3F6);
const cOnSurface = Color(0xFF121C2A);
const cOnSurfaceVariant = Color(0xFF59413E);
const cPrimary = Color(0xFF760009);
const cPrimaryContainer = Color(0xFF991B1B);
const cSecondary = Color(0xFF904D00);
const cSecondaryContainer = Color(0xFFFE932C);
const cSecondaryFixed = Color(0xFFFFDCC3);
const cTertiary = Color(0xFF004118);
const cTertiaryFixed = Color(0xFF7FFC97);
const cError = Color(0xFFBA1A1A);
const cOutline = Color(0xFF8D706D);
const cOutlineVariant = Color(0xFFE1BFBB);

TextStyle t(double size, FontWeight weight, Color color, {double? height}) {
  return TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
  );
}
