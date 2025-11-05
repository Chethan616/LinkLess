import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/color_palette.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Settings')),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'General',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              Card(
                color: isDark
                    ? ColorPalette.surfaceDark
                    : ColorPalette.surfaceLight,
                child: ListTile(
                  leading: const Icon(CupertinoIcons.brightness),
                  title: const Text('Appearance'),
                  subtitle: const Text('Theme, dark mode and display settings'),
                  onTap: () {},
                ),
              ),
              const SizedBox(height: 12),
              Card(
                color: isDark
                    ? ColorPalette.surfaceDark
                    : ColorPalette.surfaceLight,
                child: ListTile(
                  leading: const Icon(CupertinoIcons.lock),
                  title: const Text('Privacy & Permissions'),
                  subtitle: const Text('Manage SMS and storage permissions'),
                  onTap: () {},
                ),
              ),
              const SizedBox(height: 12),
              Card(
                color: isDark
                    ? ColorPalette.surfaceDark
                    : ColorPalette.surfaceLight,
                child: ListTile(
                  leading: const Icon(CupertinoIcons.info),
                  title: const Text('About'),
                  subtitle: const Text('Version, licenses and credits'),
                  onTap: () {},
                ),
              ),
              const Spacer(),
              Center(
                child: Text(
                  'Linkless • v1.0.0',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
