import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/notice_and_settings.dart';

class UpdateScreen extends StatelessWidget {
  const UpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NoticeScreen(
      icon: Icons.system_update_alt_rounded,
      iconColor: cSecondary,
      iconBackground: cSecondaryContainer.withOpacity(.16),
      title: 'Time to Update!',
      body: 'A newer version of Indovoca is ready with vocabulary improvements and refinements.',
      primaryLabel: 'Update now',
      secondaryLabel: 'Maybe later',
    );
  }
}

class VocabularyUpdateNotice extends StatelessWidget {
  const VocabularyUpdateNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return NoticeScreen(
      icon: Icons.menu_book_rounded,
      iconColor: cTertiary,
      iconBackground: cTertiaryFixed.withOpacity(.28),
      title: 'Vocabulary Update Ready',
      body: 'New Indonesian words and improved definitions are available for offline study.',
      primaryLabel: 'Download update',
      secondaryLabel: 'Not now',
    );
  }
}
