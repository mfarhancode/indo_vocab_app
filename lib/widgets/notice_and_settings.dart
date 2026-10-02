import 'package:flutter/material.dart';

import '../theme.dart';

class NoticeScreen extends StatelessWidget {
  const NoticeScreen({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.body,
    required this.primaryLabel,
    required this.secondaryLabel,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String body;
  final String primaryLabel;
  final String secondaryLabel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(color: iconBackground, shape: BoxShape.circle),
                    child: Icon(icon, color: iconColor, size: 42),
                  ),
                  const SizedBox(height: 24),
                  Text(title, textAlign: TextAlign.center, style: t(27, FontWeight.w800, cOnSurface)),
                  const SizedBox(height: 10),
                  Text(body, textAlign: TextAlign.center, style: t(14, FontWeight.w500, cOnSurfaceVariant, height: 1.5)),
                  const SizedBox(height: 26),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        backgroundColor: cPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(primaryLabel, style: t(15, FontWeight.w700, Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(secondaryLabel, style: t(13, FontWeight.w700, cPrimary)),
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

class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key, required this.title, required this.items});
  final String title;
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: t(13, FontWeight.w700, cOnSurfaceVariant)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: cSurfaceContainer),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }
}

class SettingTile extends StatelessWidget {
  const SettingTile(this.icon, this.title, this.value, {super.key});
  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: cOnSurfaceVariant),
      title: Text(title, style: t(14, FontWeight.w600, cOnSurface)),
      trailing: Text(value, style: t(12, FontWeight.w600, cOnSurfaceVariant)),
    );
  }
}

