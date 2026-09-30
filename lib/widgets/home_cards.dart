import 'package:flutter/material.dart';

import '../theme.dart';

class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: cSurfaceContainer),
      ),
      child: Column(
        children: [
          Icon(icon, color: cPrimary, size: 22),
          const SizedBox(height: 7),
          Text(value, style: t(18, FontWeight.w800, cOnSurface)),
          const SizedBox(height: 2),
          Text(label, style: t(10, FontWeight.w500, cOnSurfaceVariant)),
        ],
      ),
    );
  }
}

class ActionCard extends StatelessWidget {
  const ActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.button,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final String button;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: cSurfaceContainer),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: cPrimary.withOpacity(.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: cPrimary),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: t(14, FontWeight.w700, cOnSurface)),
                const SizedBox(height: 3),
                Text(subtitle, style: t(12, FontWeight.w500, cOnSurfaceVariant)),
              ],
            ),
          ),
          FilledButton(
            onPressed: onTap,
            style: FilledButton.styleFrom(
              backgroundColor: cPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(button, style: t(11, FontWeight.w700, Colors.white)),
          ),
        ],
      ),
    );
  }
}
