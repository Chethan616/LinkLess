import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../core/color_palette.dart';
import '../widgets/liquid_glass_bottom_bar.dart';
import 'browser_tab.dart';
import 'history_tab.dart';

/// Home Screen - Main screen with tab navigation and Liquid Glass UI
/// Contains Browser and History tabs
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [BrowserTab(), HistoryTab()];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF000000) : Colors.grey[50],
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [ColorPalette.primary, ColorPalette.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: ColorPalette.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                CupertinoIcons.globe,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Linkless',
              style: TextStyle(
                color: isDark
                    ? ColorPalette.textPrimary
                    : ColorPalette.primaryDark,
                fontWeight: FontWeight.bold,
                fontSize: 24,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: isDark ? ColorPalette.surfaceDark : Colors.white,
        surfaceTintColor: Colors.transparent,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? ColorPalette.glassDark.withOpacity(0.5)
                  : ColorPalette.glassLight.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? ColorPalette.primary.withOpacity(0.3)
                    : ColorPalette.primary.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: IconButton(
              icon: Icon(
                CupertinoIcons.info_circle_fill,
                color: isDark ? ColorPalette.primary : ColorPalette.primaryDark,
                size: 22,
              ),
              onPressed: _showInfoDialog,
              tooltip: 'About Linkless',
            ),
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: LiquidGlassBottomBar(
        tabs: const [
          LiquidGlassBottomBarTab(
            label: 'Browser',
            icon: CupertinoIcons.compass,
            selectedIcon: CupertinoIcons.compass_fill,
          ),
          LiquidGlassBottomBarTab(
            label: 'History',
            icon: CupertinoIcons.clock,
            selectedIcon: CupertinoIcons.clock_fill,
          ),
        ],
        selectedIndex: _selectedIndex,
        onTabSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  void _showInfoDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? ColorPalette.surfaceDark : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: ColorPalette.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        title: Row(
          children: [
            Icon(CupertinoIcons.lock_shield, color: ColorPalette.primary),
            const SizedBox(width: 12),
            Text(
              'About Linkless',
              style: TextStyle(
                color: isDark
                    ? ColorPalette.textPrimary
                    : ColorPalette.primaryDark,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Linkless Browser v1.0',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark
                      ? ColorPalette.textPrimary
                      : ColorPalette.primaryDark,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Encrypted SMS Web Browsing',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: ColorPalette.accent,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Browse the web without internet using encrypted SMS messages.',
                style: TextStyle(
                  color: isDark
                      ? ColorPalette.textSecondary
                      : ColorPalette.primaryDark.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                CupertinoIcons.lock_shield_fill,
                'End-to-End Encryption',
                'AES-GCM 256-bit',
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                CupertinoIcons.antenna_radiowaves_left_right,
                'Key Exchange',
                'X25519',
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                CupertinoIcons.device_phone_portrait,
                'Communication',
                'SMS Only',
              ),
              const SizedBox(height: 16),
              Divider(color: ColorPalette.primary.withOpacity(0.2)),
              const SizedBox(height: 8),
              Text(
                'How it works:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isDark
                      ? ColorPalette.textPrimary
                      : ColorPalette.primaryDark,
                ),
              ),
              const SizedBox(height: 8),
              _buildStep('1', 'Enter a URL in the Browser tab'),
              _buildStep('2', 'Your request is encrypted and sent via SMS'),
              _buildStep('3', 'Gateway device fetches the webpage'),
              _buildStep('4', 'Content is encrypted and sent back'),
              _buildStep('5', 'You receive and read the webpage text'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: ColorPalette.primary),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(icon, size: 16, color: ColorPalette.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? ColorPalette.textPrimary
                      : ColorPalette.primaryDark,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? ColorPalette.textSecondary
                      : ColorPalette.primaryDark.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep(String number, String description) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [ColorPalette.primary, ColorPalette.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? ColorPalette.textSecondary
                    : ColorPalette.primaryDark.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
