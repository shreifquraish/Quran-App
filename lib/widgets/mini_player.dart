import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../providers/app_provider.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final audio = context.watch<AudioProvider>();
    final player = app.playerService;
    return StreamBuilder(
      stream: player.player.playerStateStream,
      builder: (context, snapshot) {
        final current = player.current;
        if (current == null) return const SizedBox.shrink();

        final playing = player.player.playing;
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.accent.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withOpacity(0.1),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 32), // Balance for the close button
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          current.surahName,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          current.reciterName,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: player.stop,
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.accent,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!player.isRadio)
                    IconButton(
                      onPressed: audio.playNext,
                      icon: const Icon(
                        Icons.skip_next_rounded,
                        color: AppColors.accent,
                        size: 36,
                      ),
                    ),
                  if (!player.isRadio) const SizedBox(width: 16),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.accent,
                          AppColors.accent.withOpacity(0.8),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () {
                        if (playing) {
                          player.pause();
                        } else {
                          player.resume();
                        }
                      },
                      icon: Icon(
                        playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: AppColors.card,
                        size: 32,
                      ),
                    ),
                  ),
                  if (!player.isRadio) const SizedBox(width: 16),
                  if (!player.isRadio)
                    IconButton(
                      onPressed: audio.playPrevious,
                      icon: const Icon(
                        Icons.skip_previous_rounded,
                        color: AppColors.accent,
                        size: 36,
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
