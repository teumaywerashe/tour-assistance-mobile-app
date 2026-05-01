import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../core/constants.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/theme_toggle_button.dart';

class AboutScreen extends ConsumerStatefulWidget {
  const AboutScreen({super.key});

  @override
  ConsumerState<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends ConsumerState<AboutScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _version = 'v${info.version}+${info.buildNumber}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        actions: const [ThemeToggleButton()],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mission card
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppConstants.accent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.school, color: AppConstants.accent, size: 28),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'AAU Campus Tour',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Your smart guide to Addis Ababa University\'s 5 Kilo Campus. '
                      'Navigate buildings, find facilities, and explore the campus with ease.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.6),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Text('Benefits', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(child: _BenefitCard(icon: Icons.speed, title: 'Efficiency', desc: 'Find any building in seconds')),
                  const SizedBox(width: 12),
                  Expanded(child: _BenefitCard(icon: Icons.explore, title: 'Orientation', desc: 'Never get lost on campus')),
                  const SizedBox(width: 12),
                  Expanded(child: _BenefitCard(icon: Icons.gps_fixed, title: 'Precision', desc: 'Accurate GPS navigation')),
                ],
              ),

              const SizedBox(height: 24),
              Text('Partners', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),

              _PartnerTile(icon: Icons.business_center, name: 'Campus Services'),
              _PartnerTile(icon: Icons.people_outline, name: 'Student Affairs'),
              _PartnerTile(icon: Icons.computer, name: 'IT Department'),

              const SizedBox(height: 24),

              // Settings
              Text('Settings', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              _SectionCard(
                child: Row(
                  children: [
                    const Icon(Icons.palette_outlined, color: AppConstants.accent),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Appearance', style: TextStyle(fontWeight: FontWeight.w600)),
                          Text(
                            ref.watch(themeProvider) == ThemeMode.dark ? 'Dark mode' : 'Light mode',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: ref.watch(themeProvider) == ThemeMode.dark,
                      onChanged: (_) => ref.read(themeProvider.notifier).toggle(),
                      activeColor: AppConstants.accent,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.feedback_outlined),
                  label: const Text('Give Feedback'),
                  onPressed: () => context.go('/feedback'),
                ),
              ),

              const SizedBox(height: 24),
              Center(
                child: Text(
                  _version.isNotEmpty ? _version : 'v1.0.0',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  '© 2024 AAU Campus Tour',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }
}

class _BenefitCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  const _BenefitCard({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppConstants.accent, size: 28),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 4),
          Text(desc, style: TextStyle(color: Colors.grey.shade500, fontSize: 11), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _PartnerTile extends StatelessWidget {
  final IconData icon;
  final String name;
  const _PartnerTile({required this.icon, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppConstants.accent, size: 20),
          const SizedBox(width: 12),
          Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Spacer(),
          Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 18),
        ],
      ),
    );
  }
}
