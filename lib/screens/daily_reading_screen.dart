import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../providers/app_provider.dart';
import '../services/daily_reading_service.dart';

class DailyReadingScreen extends StatefulWidget {
  const DailyReadingScreen({super.key});

  @override
  State<DailyReadingScreen> createState() => _DailyReadingScreenState();
}

class _DailyReadingScreenState extends State<DailyReadingScreen> {
  final DailyReadingService _readingService = DailyReadingService();
  final TextEditingController _pagesController = TextEditingController();
  final TextEditingController _juzController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    await _readingService.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _pagesController.dispose();
    _juzController.dispose();
    super.dispose();
  }

  Future<void> _showSettingsDialog() async {
    _pagesController.text = _readingService.targetPages.toString();
    _juzController.text = _readingService.targetJuz.toString();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final dark = context.watch<AppProvider>().isDarkMode;
        bool notificationsEnabled = _readingService.notificationsEnabled;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                title: const Text('إعدادات الورد اليومي'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _pagesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'عدد الصفحات المستهدف',
                        hintText: 'مثال: 10',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _juzController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'عدد الأجزاء المستهدف',
                        hintText: 'مثال: 1',
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('تفعيل الإشعارات'),
                      subtitle: const Text('تذكير بقراءة الورد اليومي'),
                      value: notificationsEnabled,
                      onChanged: (value) {
                        setDialogState(() => notificationsEnabled = value);
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('إلغاء'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('حفظ'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (result == true && mounted) {
      final targetPages = int.tryParse(_pagesController.text) ?? 10;
      final targetJuz = int.tryParse(_juzController.text) ?? 1;
      
      await _readingService.updateSettings(
        targetPages: targetPages,
        targetJuz: targetJuz,
        notificationsEnabled: _readingService.notificationsEnabled,
      );
      
      setState(() {});
    }
  }

  Future<void> _updateProgress() async {
    _pagesController.text = _readingService.currentProgress?.pagesRead.toString() ?? '0';
    _juzController.text = _readingService.currentProgress?.juzRead.toString() ?? '0';

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('تحديث التقدم'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _pagesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'عدد الصفحات المقروءة',
                    hintText: 'مثال: 5',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _juzController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'عدد الأجزاء المقروءة',
                    hintText: 'مثال: 0',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('إلغاء'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('تحديث'),
              ),
            ],
          ),
        );
      },
    );

    if (result == true && mounted) {
      final pagesRead = int.tryParse(_pagesController.text) ?? 0;
      final juzRead = int.tryParse(_juzController.text) ?? 0;
      
      await _readingService.updateProgress(
        pagesRead: pagesRead,
        juzRead: juzRead,
      );
      
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final dark = app.isDarkMode;
    final progress = _readingService.currentProgress;
    final history = _readingService.history;
    final streak = _readingService.getCurrentStreak();
    final completionRate = _readingService.getOverallCompletionRate();
    final avgPages = _readingService.getAveragePagesPerDay();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: AppTheme.gradientBackground(dark: dark),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.menu_book_rounded,
                          color: AppColors.accent,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الورد اليومي',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            Text(
                              'تتبع تقدمك في قراءة القرآن',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Settings Card (moved to top)
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: dark
                                ? [AppColors.card, AppColors.card.withOpacity(0.8)]
                                : [Colors.white, Colors.white.withOpacity(0.95)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.accent.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.flag_rounded,
                                    color: AppColors.accent,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'الهدف اليومي',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: _TargetInput(
                                    label: 'الصفحات',
                                    value: _readingService.targetPages,
                                    onChanged: (value) async {
                                      await _readingService.updateSettings(
                                        targetPages: value,
                                        targetJuz: _readingService.targetJuz,
                                        notificationsEnabled: _readingService.notificationsEnabled,
                                      );
                                      setState(() {});
                                    },
                                    dark: dark,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _TargetInput(
                                    label: 'الأجزاء',
                                    value: _readingService.targetJuz,
                                    onChanged: (value) async {
                                      await _readingService.updateSettings(
                                        targetPages: _readingService.targetPages,
                                        targetJuz: value,
                                        notificationsEnabled: _readingService.notificationsEnabled,
                                      );
                                      setState(() {});
                                    },
                                    dark: dark,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Today's Progress Card
                      Container(
                        decoration: AppTheme.cardDecoration(dark: dark),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'تقدم اليوم',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                if (progress != null)
                                  Text(
                                    progress.date,
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (progress != null) ...[
                              _ProgressRow(
                                label: 'الصفحات',
                                current: progress.pagesRead,
                                target: progress.targetPages,
                                progress: progress.pagesProgress,
                                dark: dark,
                              ),
                              const SizedBox(height: 12),
                              _ProgressRow(
                                label: 'الأجزاء',
                                current: progress.juzRead,
                                target: progress.targetJuz,
                                progress: progress.juzProgress,
                                dark: dark,
                              ),
                            ],
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline_rounded,
                                    color: AppColors.accent,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'يتم تحديث التقدم تلقائياً عند القراءة',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: AppColors.accent,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Statistics Cards
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.local_fire_department_rounded,
                              title: 'أيام متتالية',
                              value: '$streak',
                              dark: dark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.assessment_rounded,
                              title: 'نسبة الإنجاز',
                              value: '${(completionRate * 100).toStringAsFixed(0)}%',
                              dark: dark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _StatCard(
                        icon: Icons.auto_graph_rounded,
                        title: 'متوسط الصفحات/يوم',
                        value: avgPages.toStringAsFixed(1),
                        dark: dark,
                      ),
                    ],
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

class _TargetInput extends StatelessWidget {
  const _TargetInput({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.dark,
  });

  final String label;
  final int value;
  final Function(int) onChanged;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: value.toString());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: dark ? AppColors.card.withOpacity(0.6) : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.accent.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            decoration: const InputDecoration(
              filled: false,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            onSubmitted: (v) {
              final newValue = int.tryParse(v) ?? value;
              onChanged(newValue);
            },
          ),
        ),
      ],
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.label,
    required this.current,
    required this.target,
    required this.progress,
    required this.dark,
  });

  final String label;
  final int current;
  final int target;
  final double progress;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(
              '$current / $target',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: AppColors.card,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 1.0 ? AppColors.primaryLight : AppColors.accent,
            ),
            minHeight: 8,
          ),
        ),
     ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.dark,
  });

  final IconData icon;
  final String title;
  final String value;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration(dark: dark),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, color: AppColors.accent, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}


