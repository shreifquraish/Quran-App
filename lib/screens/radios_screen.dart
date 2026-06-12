import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../providers/app_provider.dart';

class RadiosScreen extends StatelessWidget {
  const RadiosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final dark = app.isDarkMode;

    if (app.radios.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off_rounded,
              size: 56,
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'تحتاج إنترنت لتحميل الإذاعات',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => app.refreshRadios(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: app.radios.length,
      itemBuilder: (context, index) {
        final radio = app.radios[index];
        final isPlaying = context
                .watch<AppProvider>()
                .playerService
                .current
                ?.reciterId ==
            radio.id;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () =>
                  context.read<AudioProvider>().playRadio(radio),
              child: Ink(
                decoration: AppTheme.cardDecoration(dark: dark).copyWith(
                  border: isPlaying
                      ? Border.all(color: AppColors.accent, width: 1.5)
                      : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isPlaying
                              ? AppColors.accent.withOpacity(0.2)
                              : AppColors.primaryLight.withOpacity(0.2),
                        ),
                        child: Icon(
                          isPlaying
                              ? Icons.equalizer_rounded
                              : Icons.radio_rounded,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              radio.name.replaceAll('إذاعة ', ''),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isPlaying ? 'يعمل الآن • بث مباشر' : 'بث مباشر',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                color: isPlaying
                                    ? AppColors.accent
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isPlaying
                            ? Icons.pause_circle_filled_rounded
                            : Icons.play_circle_outline_rounded,
                        color: AppColors.accent,
                        size: 34,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ).animate(delay: (35 * index).ms).fadeIn(),
        );
      },
    );
  }
}
