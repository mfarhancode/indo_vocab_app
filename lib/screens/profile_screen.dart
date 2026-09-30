import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/notice_and_settings.dart';
import 'update_screens.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
            children: [
              Text('Profile', style: t(25, FontWeight.w800, cOnSurface)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: cSurfaceContainer),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: cPrimary,
                      child: Text('JD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Julian Davies', style: t(18, FontWeight.w700, cOnSurface)),
                        const SizedBox(height: 4),
                        Text('Intermediate learner', style: t(12, FontWeight.w500, cOnSurfaceVariant)),
                      ],
                    ),
                    const Spacer(),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const SettingsSection(
                title: 'Learning',
                items: [
                  SettingTile(Icons.school_outlined, 'Learning level', 'Intermediate'),
                  SettingTile(Icons.volume_up_outlined, 'Pronunciation speed', '1.0x'),
                  SettingTile(Icons.notifications_none_rounded, 'Daily reminder', '09:00'),
                ],
              ),
              const SizedBox(height: 18),
              const SettingsSection(
                title: 'App',
                items: [
                  SettingTile(Icons.cloud_download_outlined, 'Offline vocabulary', 'Up to date'),
                  SettingTile(Icons.language_outlined, 'Language', 'English'),
                  SettingTile(Icons.info_outline_rounded, 'About Indovoca', 'Version 1.0.0'),
                ],
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UpdateScreen())),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: Text('Check for updates', style: t(14, FontWeight.w700, cPrimary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
