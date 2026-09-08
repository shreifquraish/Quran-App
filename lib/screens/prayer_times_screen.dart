import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../providers/app_provider.dart';
import '../services/prayer_times_service.dart';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  final PrayerTimesService _prayerService = PrayerTimesService();
  PrayerTimes? _prayerTimes;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPrayerTimes();
  }

  Future<void> _loadPrayerTimes() async {
    setState(() {
      _isLoading = true;
    });

    final times = await _prayerService.getPrayerTimes();
    
    setState(() {
      _prayerTimes = times;
      _isLoading = false;
    });
  }

  Future<void> _showCityPicker() async {
    final cities = _prayerService.getEgyptianCities();
    
    final selectedCity = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final dark = context.watch<AppProvider>().isDarkMode;
        return _CityPickerSheet(cities: cities, dark: dark);
      },
    );

    if (selectedCity != null) {
      await _prayerService.updateSettings(city: selectedCity);
      await _loadPrayerTimes();
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final dark = app.isDarkMode;
    final settings = _prayerService.settings;

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
                          Icons.access_time_rounded,
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
                              'أوقات الصلاة',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            if (settings != null)
                              Text(
                                '${settings.city}, ${settings.country}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _showCityPicker,
                        icon: const Icon(Icons.location_city_rounded),
                        tooltip: 'تغيير المدينة',
                      ),
                    ],
                  ),
                ),
                if (_isLoading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    ),
                  )
                else if (_prayerTimes == null)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 64,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'فشل تحميل أوقات الصلاة',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _loadPrayerTimes,
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _PrayerTimeCard(
                          name: 'الفجر',
                          time: _prayerTimes!.fajr,
                          icon: Icons.wb_twilight_rounded,
                          enabled: settings?.fajrEnabled ?? true,
                          dark: dark,
                        ),
                        const SizedBox(height: 12),
                        _PrayerTimeCard(
                          name: 'الظهر',
                          time: _prayerTimes!.dhuhr,
                          icon: Icons.wb_sunny_rounded,
                          enabled: settings?.dhuhrEnabled ?? true,
                          dark: dark,
                        ),
                        const SizedBox(height: 12),
                        _PrayerTimeCard(
                          name: 'العصر',
                          time: _prayerTimes!.asr,
                          icon: Icons.wb_sunny_outlined,
                          enabled: settings?.asrEnabled ?? true,
                          dark: dark,
                        ),
                        const SizedBox(height: 12),
                        _PrayerTimeCard(
                          name: 'المغرب',
                          time: _prayerTimes!.maghrib,
                          icon: Icons.nights_stay_rounded,
                          enabled: settings?.maghribEnabled ?? true,
                          dark: dark,
                        ),
                        const SizedBox(height: 12),
                        _PrayerTimeCard(
                          name: 'العشاء',
                          time: _prayerTimes!.isha,
                          icon: Icons.bedtime_rounded,
                          enabled: settings?.ishaEnabled ?? true,
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

class _PrayerTimeCard extends StatelessWidget {
  const _PrayerTimeCard({
    required this.name,
    required this.time,
    required this.icon,
    required this.enabled,
    required this.dark,
  });

  final String name;
  final String time;
  final IconData icon;
  final bool enabled;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.cardDecoration(dark: dark),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: enabled
                ? AppColors.accent.withOpacity(0.15)
                : AppColors.textSecondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: enabled ? AppColors.accent : AppColors.textSecondary,
          ),
        ),
        title: Text(
          name,
          style: TextStyle(
            color: enabled ? null : AppColors.textSecondary,
          ),
        ),
        trailing: Text(
          time,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: enabled ? AppColors.accent : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }
}

class _CityPickerSheet extends StatefulWidget {
  const _CityPickerSheet({
    required this.cities,
    required this.dark,
  });

  final List<String> cities;
  final bool dark;

  @override
  State<_CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends State<_CityPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> get _filteredCities {
    if (_searchQuery.isEmpty) {
      return widget.cities;
    }
    return widget.cities
        .where((city) => city.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredCities = _filteredCities;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: widget.dark ? AppColors.surface : AppColors.cardLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'اختر المحافظة',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'ابحث عن المحافظة...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: const Icon(Icons.search, color: AppColors.accent),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppColors.accent),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: widget.dark ? AppColors.card.withOpacity(0.5) : Colors.white.withOpacity(0.9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.accent, width: 2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filteredCities.isEmpty
                  ? Center(
                      child: Text(
                        'لا توجد نتائج',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: filteredCities.length,
                      itemBuilder: (context, index) {
                        final city = filteredCities[index];
                        return ListTile(
                          title: Text(city),
                          onTap: () => Navigator.pop(context, city),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
