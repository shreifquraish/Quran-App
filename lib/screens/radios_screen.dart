import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../providers/app_provider.dart';

class RadiosScreen extends StatefulWidget {
  const RadiosScreen({super.key});

  @override
  State<RadiosScreen> createState() => _RadiosScreenState();
}

class _RadiosScreenState extends State<RadiosScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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

    final filteredRadios = _searchQuery.isEmpty
        ? app.radios
        : app.radios.where((radio) =>
            radio.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'بحث في الإذاعات...',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: dark ? AppColors.card : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            itemCount: filteredRadios.length,
            itemBuilder: (context, index) {
              final radio = filteredRadios[index];
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
          ),
        ),
      ],
    );
  }
}
