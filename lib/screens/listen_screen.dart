import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../core/constants.dart';
import '../core/theme.dart';
import '../models/surah.dart';
import '../providers/app_provider.dart';

class ListenScreen extends StatelessWidget {
  const ListenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: featuredReciters.length,
      itemBuilder: (context, index) {
        final reciter = featuredReciters[index];
        return _ReciterCard(reciter: reciter, index: index);
      },
    );
  }
}

class _ReciterCard extends StatelessWidget {
  const _ReciterCard({required this.reciter, required this.index});

  final ReciterConfig reciter;
  final int index;

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<AppProvider>().isDarkMode;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ReciterSurahsScreen(reciter: reciter),
            ),
          ),
          child: Ink(
            decoration: AppTheme.cardDecoration(dark: dark),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          AppColors.accent.withOpacity(0.35),
                          AppColors.primaryLight.withOpacity(0.5),
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.mic_rounded,
                      color: AppColors.accent,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reciter.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'اضغط لاختيار السور والتنزيل',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ).animate(delay: (40 * index).ms).fadeIn().slideY(begin: 0.08, end: 0),
    );
  }
}

class ReciterSurahsScreen extends StatefulWidget {
  const ReciterSurahsScreen({super.key, required this.reciter});

  final ReciterConfig reciter;

  @override
  State<ReciterSurahsScreen> createState() => _ReciterSurahsScreenState();
}

class _ReciterSurahsScreenState extends State<ReciterSurahsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AudioProvider>().refreshDownloadCount(widget.reciter);
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final audio = context.watch<AudioProvider>();
    final dark = app.isDarkMode;
    final downloaded = audio.downloadCountFor(widget.reciter.id);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: AppTheme.gradientBackground(dark: dark),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_forward_rounded),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.reciter.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              'تم تنزيل $downloaded من 114 سورة',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: audio.bulkDownloading
                              ? null
                              : () => audio.downloadAll(widget.reciter),
                          icon: const Icon(Icons.download_rounded),
                          label: Text(
                            audio.bulkDownloading
                                ? audio.setupMessageLocal
                                : 'تنزيل المصحف كامل',
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primaryLight,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      if (downloaded > 0) ...[
                        const SizedBox(width: 8),
                        IconButton.filledTonal(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('حذف التنزيلات'),
                                content: const Text(
                                  'هل تريد حذف جميع السور المحملة لهذا الشيخ؟',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('إلغاء'),
                                  ),
                                  FilledButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('حذف'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true && context.mounted) {
                              await audio.deleteDownloads(widget.reciter);
                            }
                          },
                          icon: const Icon(Icons.delete_outline_rounded),
                        ),
                      ],
                    ],
                  ),
                ),
                if (audio.bulkDownloading &&
                    audio.bulkReciter?.id == widget.reciter.id)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: LinearProgressIndicator(
                      value: audio.setupProgressLocal,
                      backgroundColor: AppColors.card,
                      color: AppColors.accent,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: app.surahs.length,
                    itemBuilder: (context, index) {
                      final surah = app.surahs[index];
                      return _AudioSurahTile(
                        reciter: widget.reciter,
                        surah: surah,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AudioSurahTile extends StatelessWidget {
  const _AudioSurahTile({
    required this.reciter,
    required this.surah,
  });

  final ReciterConfig reciter;
  final Surah surah;

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioProvider>();
    final dark = context.watch<AppProvider>().isDarkMode;
    final progress = audio.activeDownloadProgress(reciter.id, surah.id);
    return FutureBuilder<bool>(
      future: context.read<AppProvider>().db.isSurahDownloaded(
            reciter.id,
            surah.id,
          ),
      builder: (context, snapshot) {
        final isDownloaded = snapshot.data ?? false;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            decoration: AppTheme.cardDecoration(dark: dark),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryLight.withOpacity(0.25),
                child: Text(
                  '${surah.id}',
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(surah.name),
              subtitle: progress != null
                  ? LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.card,
                      color: AppColors.accent,
                    )
                  : Text(
                      isDownloaded ? 'محمّل • بدون إنترنت' : 'بث أو تنزيل',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: progress != null
                        ? null
                        : () => audio.downloadSurah(
                              reciter: reciter,
                              surah: surah,
                            ),
                    icon: Icon(
                      isDownloaded
                          ? Icons.check_circle_rounded
                          : Icons.download_rounded,
                      color: isDownloaded
                          ? AppColors.primaryLight
                          : AppColors.accent,
                    ),
                  ),
                  IconButton(
                    onPressed: () => audio.playSurah(
                      reciter: reciter,
                      surah: surah,
                    ),
                    icon: const Icon(
                      Icons.play_circle_fill_rounded,
                      color: AppColors.accent,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
