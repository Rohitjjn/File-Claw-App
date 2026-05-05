import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/constants/app_constants.dart';
import '../../core/themes/claude_colors.dart';
import '../../core/widgets/claude_app_bar.dart';
import '../../core/widgets/claude_card.dart';

/// Lightweight About screen with logo, version, tagline, and licenses.
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = AppConstants.appVersion;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) setState(() => _version = info.version);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondary = isDark
        ? ClaudeColors.darkTextSecondary
        : ClaudeColors.lightTextSecondary;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ClaudeAppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              title: const Text('About'),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const SizedBox(height: 16),
                  Center(
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: ClaudeColors.primary,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.description_outlined,
                          color: Colors.white, size: 52),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      AppConstants.appName,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 24,
                          ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      AppConstants.appTagline,
                      style: TextStyle(fontSize: 14, color: secondary),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      'v$_version',
                      style: TextStyle(fontSize: 12, color: secondary),
                    ),
                  ),
                  const SizedBox(height: 28),
                  ClaudeCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Privacy',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        const SizedBox(height: 8),
                        Text(
                          'Files Claw works entirely offline. No data is collected, transmitted, or stored on a server. Your files never leave your device.',
                          style: TextStyle(fontSize: 13.5, color: secondary, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClaudeCard(
                    padding: EdgeInsets.zero,
                    child: ListTile(
                      leading: const Icon(Icons.gavel_outlined),
                      title: const Text('Open Source Licenses'),
                      trailing: Icon(Icons.chevron_right, color: secondary),
                      onTap: () => showLicensePage(
                        context: context,
                        applicationName: AppConstants.appName,
                        applicationVersion: _version,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
