import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../core/theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({
    super.key,
    required this.progress,
    required this.message,
    this.error,
    this.onRetry,
    this.showProgress = false,
  });

  final double progress;
  final String message;
  final String? error;
  final bool showProgress;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: AppTheme.gradientBackground(),
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.accent.withOpacity(0.25),
                            AppColors.primaryLight.withOpacity(0.35),
                          ],
                        ),
                        border: Border.all(
                          color: AppColors.accent.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        size: 52,
                        color: AppColors.accent,
                      ),
                    ).animate().scale(
                          duration: 800.ms,
                          curve: Curves.easeOutBack,
                        ),
                    const SizedBox(height: 28),
                    Text(
                      'القرآن الكريم',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 32,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 8),
                    const SizedBox(height: 40),
                    if (error != null) ...[
                      const Icon(
                        Icons.cloud_off_rounded,
                        color: AppColors.accentSoft,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'تعذر الاتصال بالانترنت. يرجى التأكد من اتصالك.',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: onRetry,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('إعادة المحاولة'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: AppColors.textDark,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ] else if (showProgress) ...[
                      CircularPercentIndicator(
                        radius: 80,
                        lineWidth: 10,
                        percent: progress.clamp(0.0, 1.0),
                        animateFromLastPercent: true,
                        animation: true,
                        animationDuration: 500,
                        center: Text(
                          '${(progress * 100).round()}%',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppColors.accent,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        progressColor: AppColors.accent,
                        backgroundColor: AppColors.accent.withOpacity(0.2),
                        circularStrokeCap: CircularStrokeCap.round,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        message,
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ] else ...[
                      const SizedBox(height: 22),
                      Text(
                        'تبدأ بسرعة',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textPrimary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
