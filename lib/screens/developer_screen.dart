import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../core/theme.dart';
import '../providers/app_provider.dart';

class DeveloperScreen extends StatelessWidget {
  const DeveloperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<AppProvider>().isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('تواصل مع المطور'),
        centerTitle: true,
      ),
      body: Container(
        decoration: AppTheme.gradientBackground(dark: dark),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.accent,
                  child: Icon(
                    Icons.person_rounded,
                    size: 60,
                    color: AppColors.card,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'ENG/ Shreif Quraish',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: dark ? AppColors.textPrimary : AppColors.primaryDark,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                   'Smartphone App Developer\nGoogle Sites Designer\nGraphic Designer',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: dark ? AppColors.textSecondary : AppColors.primaryLight,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1,
                    children: [
                      _ContactGridButton(
                        icon: FontAwesomeIcons.whatsapp,
                        color: const Color(0xFF25D366),
                        onTap: () => _launchUrl('https://wa.me/201556313513'),
                      ),
                      _ContactGridButton(
                        icon: FontAwesomeIcons.facebook,
                        color: const Color(0xFF1877F2),
                        onTap: () => _launchUrl('https://www.facebook.com/ShreifEngineer/'),
                      ),
                      _ContactGridButton(
                        icon: FontAwesomeIcons.linkedinIn,
                        color: const Color(0xFF0A66C2),
                        onTap: () => _launchUrl('https://www.linkedin.com/in/shreif-quraish'),
                      ),
                      _ContactGridButton(
                        icon: FontAwesomeIcons.globe,
                        color: const Color.fromARGB(255, 255, 170, 0),
                        onTap: () => _launchUrl('https://shreeif-quraish.netlify.app/'),
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

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _ContactGridButton extends StatelessWidget {
  const _ContactGridButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = context.watch<AppProvider>().isDarkMode;
    return Material(
      color: dark ? AppColors.card : AppColors.cardLight,
      elevation: 4,
      shadowColor: color.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: dark ? color.withOpacity(0.3) : color.withOpacity(0.1),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: FaIcon(
              icon,
              size: 56,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
